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
//EXPORT sent_setup_norm(STRING docPath,Types.TextMod mod) := MODULE
//EXPORT sent_setup_norm(TextVectors.Types.Sentence tsentences) := MODULE
  
  //EXPORT tmod := DATASET(mod,DATASET(Types.TextMod));

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

  EXPORT wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    t_Vector w_Vector;
  END;

  EXPORT sembed_grp_experimental := FUNCTION
    svb_cpy := sent_vecs_byword_norm;
    
    svb_no0 := svb_cpy(tfidf_score>0);
    
    svb_ordered := SORT(svb_no0,svb_no0.sentId);
    svb_grp := GROUP(svb_ordered,sentId);

    svbrec := RECORDOF(svb_no0);

    veconly := RECORD
      t_Vector w_Vector;
    END;

    svb_no0 iter_vecs(svb_no0 l,svb_no0 r,INTEGER C) := TRANSFORM
      SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
      SELF := r;
    END;

    svb_no0 grproll(svb_no0 L,DATASET(svbrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      SELF.w_Vector := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
    END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    RETURN out;
  END;
END;