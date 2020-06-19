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

//EXPORT sent_setup_norm(STRING docPath) := MODULE
//EXPORT sent_setup_norm(STRING docPath,Types.TextMod mod) := MODULE
EXPORT sent_setup_norm(DATASET(Types.Sentence) tsents,DATASET(Types.TextMod) bigmod) := MODULE
  
  //EXPORT tmod := DATASET(mod,DATASET(Types.TextMod));

  //EXPORT sp     := sent_prep(docPath);
  EXPORT sp := sent_prep(tsents);
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
    //sv := tv.SentenceVectors();
    //mod := sv.GetModel(spsent);
    mod := bigmod;

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

  EXPORT absmaxmin(t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec absT(vdsrec vds) := TRANSFORM
      SELF.val := ABS(vds.val);
    END;
    absds := PROJECT(vecasds,absT(LEFT));
    RETURN [MAX(absds,absds.val),MIN(absds,absds.val)];
  END;

  EXPORT lnvec(t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec lnT(vdsrec vds) := TRANSFORM
      abscell := ABS(vds.val);
      sign := IF(abscell=0,1,vds.val/abscell);
      absnu := IF(abscell<=1,1.1,abscell);
      SELF.val := sign*LN(absnu);
    END;
    outds := PROJECT(vecasds,lnT(LEFT));
    RETURN SET(outds,outds.val);
  END;

  EXPORT normalvec(t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec squareT(vdsrec vds) := TRANSFORM
      SELF.val := vds.val * vds.val;
    END;
    allsq := PROJECT(vecasds,squareT(LEFT));
    norm := 1/SQRT(SUM(allsq,allsq.val));
    RETURN vecmult(v,norm);
  END;

  EXPORT addvecs_ecl(t_Vector v1,t_Vector v2) := FUNCTION
    ds1 := DATASET(v1,{REAL8 val});
    ds2 := DATASET(v2,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec addT(vdsrec vds,INTEGER C) := TRANSFORM
      SELF.val := vds.val + ds2[C].val;
    END;
    add_ds := PROJECT(ds1,addT(LEFT,COUNTER));
    RETURN SET(add_ds,add_ds.val);
  END;

  EXPORT multvec_ecl(t_Vector v1,REAL8 x) := FUNCTION
    ds1 := DATASET(v1,{REAL8 val});
    vdsrec := RECORD
      REAL8 val;
    END;
    vdsrec multT(vdsrec vds) := TRANSFORM
      SELF.val := vds.val * x;
    END;
    mult_ds := PROJECT(ds1,multT(LEFT));
    RETURN SET(mult_ds,mult_ds.val);
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
      //abmm_r := absmaxmin(r.w_Vector);
      smallr := vecmult(r.W_vector,.0001)
      //SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
      SELF.w_Vector := IF(C=1,smallr,addvecs(l.w_Vector,smallr));
      //SELF.w_Vector := IF(C=1,vecmult(r.W_Vector,.0001),addvecs(l.w_Vector,vecmult(r.w_Vector,.0001)));
      SELF := r;
      //SELF := r;
      //SELF := smallr;
    END;

    svb_no0 grproll(svb_no0 L,DATASET(svbrec) R) := TRANSFORM
      SELF.word := L.word;
      SELF.sentId := L.sentId;
      SELF.text := L.text;
      SELF.tfidf_score := L.tfidf_score;
      //
      //My alternate approach to normalizing the vector directly
      //
      // totvec := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
      // absmax := MAX(ABS(MIN(totvec)),ABS(MAX(totvec)));
      // scaleby:= 1000/absmax;
      // bigvec := vecmult(totvec,scaleby);
      // SELF.w_Vector := tv.internal.svUtils.normalizeVector(bigvec);
      //
      totvec := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
      abmm := absmaxmin(totvec);
      absmax := abmm[1];
      // absmin := abmm[2];
      scaleby := IF(absmax<1,1,1/absmax);
      // //bigvec := IF(scaleby>1,vecmult(totvec,100),vecmult(totvec,scaleby));
      bigvec := vecmult(totvec,scaleby);
      // SELF.w_Vector := tv.internal.svUtils.normalizeVector(bigvec);
      //
      SELF.w_Vector := normalvec(bigvec);
      //
      //Pure normalize, which seems to be getting all 0s
      //
      //SELF.w_Vector := tv.internal.svUtils.normalizeVector(ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector);
      //
      //The totaled vector without re-scaling
      //SELF.w_Vector := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
      //totvec := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
      //SELF.w_Vector := normalvec(totvec);
      //
      //
      //totvec := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
      //lnscale := lnvec(totvec);
      //SELF.w_Vector := normalvec(lnscale);
    END;

    out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

    RETURN out;
  END;
END;