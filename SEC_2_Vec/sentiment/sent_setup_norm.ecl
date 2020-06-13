IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT tv.Types;
t_Vector := Types.t_Vector;


//the sentiment setup module.
//runs sentiment prep, which involves training Word2Vec on the given path location
//INITIALIZED DATASETS:
// sp (outputs sent_prep module evaluated on docPath)
// lex (outputs sent_prep.dLexicon)
// spsent (outputs sent_prep.sentences) -- numbered training sentences format
// words (lex subset down to just the field 'word')
// docus (spsent formally assigned record sentrec)
// tfidf_step1 (sets up each word in the lexicon with a table of all the training sentences)
//INITIALIZED RECORD TYPES:
// sentrec (used to format spsent -> docus) same format as numbered training sentences
// step1rec (used to format words -> tfidf_step1) each word paired with all of docus
// tfrec (used to extend docus to contain tfidf_score in tfidf_all)
// wrec (used to extend tfrec to contain w_Vector for calculating weighted vectors)
// tfidfrec (similar to step1rec, but docs field is DATASET(tfrec) rather than DATASET(docus))
// svecrec (contains a word and its vectorized embedding)
EXPORT sent_setup_norm(STRING docPath) := MODULE
  
  

  EXPORT sp     := sent_prep(docPath);
  EXPORT lex    := sp.dLexicon;
  EXPORT spsent := sp.sentences;

  EXPORT sentrec := RECORD
      UNSIGNED8 sentId := spsent.sentId;
      STRING      text := spsent.text;
  END;

  EXPORT words  := TABLE(lex,{STRING word := lex.word});
  EXPORT docus  := TABLE(sp.sentences,sentrec);

  //CREATING NORMALIZED word-sentence dataset
  EXPORT normrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
  END;

  EXPORT normed_ds := NORMALIZE(words,COUNT(spsent),TRANSFORM(normrec,
                                              SELF.word := LEFT.word,
                                              SELF.sentId := docus[COUNTER].sentId,
                                              SELF.text := docus[COUNTER].text));

  //Redoing tfidf calculation for NORMALIZED form
  EXPORT tfidf_norm := FUNCTION
    nds := normed_ds;

    tfnormrec := RECORD
      STRING word := nds.word;
      UNSIGNED8 sentId := nds.sentId;
      STRING sentence := nds.text;
      REAL8 tfidf_score := sp.tfidf(STD.Str.ToLowerCase(nds.word),nds.text);
    END;

    out_norm := TABLE(nds,tfnormrec);

    //RETURN out_norm(tfidf_score != 0);
    RETURN out_norm;
  END;

  //norm version of vector/tfidf join
  // FIXME: Does this need to be different from the original?
  EXPORT tf_withvecs_norm := FUNCTION
    sv := tv.SentenceVectors();
    mod := sv.GetModel(spsent);

    w2v := RECORD
      STRING word := mod.text;
      t_Vector vec:= mod.vec;
    END;

    wordvec_simp := TABLE(mod,w2v);

    combo := JOIN(wordvec_simp,tfidf_norm,STD.Str.ToLowerCase(LEFT.word) = STD.Str.ToLowerCase(RIGHT.word));
    RETURN combo;
  END;

  //Multiplying vectors by a real number
  EXPORT t_Vector vecmult(t_Vector v,REAL8 x) := BEGINC++
    #body
    size32_t N = lenV;
    __lenResult = (size32_t) (N * sizeof(double));
    double *wout = (double*) rtlMalloc(__lenResult);
    __isAllResult = false;
    __result = (void *) wout;
    double *vv = (double *) v;
    double xx = (double) x;
    for (unsigned i = 0; i < N; i++)
    {
      wout[i] = vv[i] * xx;
    }
  ENDC++;

  //Normed version of weighting
  //All we need to do is multiply
  //each row's t_Vector by tfidf_score
  EXPORT sent_vecs_byword_norm := FUNCTION

    twn := tf_withvecs_norm;

    weightrec := RECORD
      STRING word := twn.word;
      UNSIGNED8 sentId := twn.sentId;
      STRING text := twn.sentence;
      REAL8 tfidf_score := twn.tfidf_score;
      t_Vector w_Vector := vecmult(twn.vec,twn.tfidf_score);
    END;

    weighted := TABLE(twn,weightrec);
    RETURN weighted;
  END;

  //C++ function for adding t_Vector sets element-wise
  EXPORT t_Vector addvecs(t_Vector v1,t_Vector v2) := BEGINC++
    #body
    size32_t N = lenV1;
    __lenResult = (size32_t) (N*sizeof(double));
    double *wout = (double *) rtlMalloc(__lenResult);
    __isAllResult = false;
    __result = (void *) wout;
    double *vv1 = (double *) v1;
    double *vv2 = (double *) v2;
    for (unsigned i = 0; i < N; i++)
    {
      wout[i] = vv1[i]+vv2[i];
    }
  ENDC++;

  EXPORT sent_embed := FUNCTION
    svb := sent_vecs_byword_norm;

    svb roll_sents(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
    END;
    svb_sort := SORT(svb,svb.sentId);
    svb_grouped := GROUP(svb_sort,sentId);
    //out := ROLLUP(svb,LEFT.sentId=RIGHT.sentId,roll_sents(LEFT,RIGHT));
    out := ROLLUP(svb_grouped,GROUP,roll_sents(LEFT,RIGHT));
    RETURN out;
    //RETURN svb_grouped;
  END;


  //PRIORITY: FIXME: NEW AS OF 6/3 -- experiment with
  //When cluster back up
  EXPORT sembed_grp := FUNCTION
    svb := sent_vecs_byword_norm;

    //svb_ordered := SORT(svb,svb.sentId);
    //svb_grp := GROUP(svb_ordered,sentId);
    svb_sent1 := svb(sentId=1);
    svb1 := GROUP(svb_sent1,sentId);
    svb_sent2 := svb(sentId=2);
    svb2 := GROUP(svb_sent2,sentId);
    svb_grp := REGROUP(svb1,svb2);

    svb grpaddvecs(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
    END;

    svbrec := RECORDOF(svb);

    svb grproll(svb L,DATASET(svbrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := ROLLUP(R,TRUE,grpaddvecs(LEFT,RIGHT))[1].w_Vector;
      //SELF.w_vector := ITERATE(R.w_Vector,TRUE,addvecs(LEFT,RIGHT))
    END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    RETURN out;
  END;

  EXPORT wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    t_Vector w_Vector;
  END;

  EXPORT totalvec(DATASET(wrec) sgrp) := FUNCTION
    wrec grpaddvecsT(wrec L,wrec R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
    END;

    out := ROLLUP(sgrp,TRUE,grpaddvecsT(LEFT,RIGHT))[1].w_Vector;
    RETURN out;
  END;

  EXPORT sembed_grp_experimental := FUNCTION
    svb := sent_vecs_byword_norm;

    svb_ordered := SORT(svb,svb.sentId);
    svb_grp := GROUP(svb_ordered,sentId);

    // svb grpaddvecs(svb L,svb R) := TRANSFORM
    //   SELF.word := L.word;
    //   SELF.sentId := L.sentId;
    //   SELF.text := L.text;
    //   SELF.tfidf_score := L.tfidf_score;
    //   SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
    // END;

    svbrec := RECORDOF(svb);

    svb grproll(svb L,DATASET(svbrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := totalvec(R);
      //SELF.w_Vector := ROLLUP(R,TRUE,grpaddvecs(LEFT,RIGHT)).w_Vector;
    END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    RETURN out;
  END;
  

  //EXPERIMENT
  //Trying to do the same as above but
  //only rollup one sentence at a time
  EXPORT sent_roll(UNSIGNED8 sid) := FUNCTION
    svb := sent_vecs_byword_norm;
    svb_N := svb(sentId = sid);
    svb roll_sents(svb_N L,svb_N R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
    END;
    
    out := ROLLUP(svb_N,TRUE,roll_sents(LEFT,RIGHT));
    
    //PRIORITY 2: FIXME: Wondering if we want to try the above with a counter? Haven't run yet.
    //
    //svb roll_sents_cntr(svb_N L,svb_N R,INTEGER C) := TRANSFORM
    //  SELF.word := L.word;
    //  SELF.sentId := L.sentId;
    //  SELF.text := L.text;
    //  SELF.tfidf_score := L.tfidf_score;
    //  SELF.w_Vector := addvecs(L.w_Vector,R[C].w_Vector);
    //END;
    //
    //out := ROLLUP(svb_N,TRUE,roll_sents(LEFT,svb_N,COUNTER));

    RETURN out;
    
  END;
END;