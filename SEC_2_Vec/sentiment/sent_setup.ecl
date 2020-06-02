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
EXPORT sent_setup(STRING docPath) := MODULE
  
  

  EXPORT sp     := sent_prep(docPath);
  EXPORT lex    := sp.dLexicon;
  EXPORT spsent := sp.sentences;

  EXPORT sentrec := RECORD
      UNSIGNED8 sentId := spsent.sentId;
      STRING      text := spsent.text;
  END;

  EXPORT words  := TABLE(lex,{STRING word := lex.word});
  EXPORT docus  := TABLE(sp.sentences,sentrec);

  EXPORT step1rec := RECORD
      STRING word                   := words.word;
      DATASET(RECORDOF(docus)) docs := docus;
  END;

  EXPORT tfrec    := RECORD
      UNSIGNED8  sentId;
      STRING       text;
      REAL8 tfidf_score;
  END;

  EXPORT wrec     := RECORD
      UNSIGNED8  sentId;
      STRING       text;
      REAL8 tfidf_score;
      t_Vector w_Vector;
  END;

  EXPORT tfidfrec := RECORD
    STRING word;
    DATASET(tfrec) docs;
  END;

  EXPORT svecrec  := RECORD
    STRING  text;
    t_Vector vec;
  END;

  EXPORT tfidf_step1 := TABLE(words,step1rec);


  //the tfidf calculation submodule
  // takes the tfidf_step1 dataset generated by sent_setup
  // module and transforms each word's docus field to contain
  // tfidf_scores for that word in each sentence in docus
  //OUTPUT RECORD: tfidfrec (probably left <unnamed>)
  EXPORT tfidf_all := FUNCTION
    dorow(STRING term, DATASET(sentrec) d) := FUNCTION
      trow := RECORD
        UNSIGNED8    sentId := d.sentId;
        STRING         text := d.text;
        REAL8   tfidf_score := sp.tfidf(STD.Str.ToLowerCase(term),d.text);
      END;
      
      donerow := TABLE(d,trow);
      RETURN donerow;
    END;

    doall := RECORD
        STRING word := tfidf_step1.word;
        DATASET(tfrec) docs := dorow(tfidf_step1.word,tfidf_step1.docs);
    END;

    tfidf_final := TABLE(tfidf_step1,doall);
    RETURN tfidf_final;
  END;


  //the word vector/tfidf join module
  EXPORT tf_withvecs := FUNCTION
    sv := tv.SentenceVectors();
    mod:= sv.GetModel(spsent);

    w2v := RECORD
      STRING text := mod.text;
      t_Vector vec:= mod.vec;
    END;

    wordvec_simp := TABLE(mod,w2v);

    combo := JOIN(wordvec_simp,tfidf_all,STD.Str.ToLowerCase(LEFT.text) = STD.Str.ToLowerCase(RIGHT.word));
    RETURN combo;
  END;


  //the sentence embeddings step 1 module
  // takes the joined dataset and appends a field
  // of t_Vectors weighted by the accompanying
  // tfidf_score in each row of docs.
  // Still need to add up contributions by word
  // to obtain overall sentence embedding.
  EXPORT sent_vecs_byword := FUNCTION
    weighted := RECORD
      STRING word := tf_withvecs.text;
      t_Vector vec:= tf_withvecs.vec;
      DATASET(tfrec) docs := tf_withvecs.docs;
    END;

    sentvecsform := TABLE(tf_withvecs,weighted);

    //t_Vector vecmult(t_Vector v,UNSIGNED4 N,REAL8 x) := EMBED(C++)
    t_Vector vecmult(t_Vector v,REAL8 x) := BEGINC++
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

    wgtrow(t_Vector v, DATASET(tfrec) d) := FUNCTION
      UNSIGNED4 C := COUNT(v);
      wrow := RECORD
        UNSIGNED8      sentId := d.sentId;
        STRING           text := d.text;
        REAL8     tfidf_score := d.tfidf_score;
        t_Vector     w_Vector := vecmult(v,d.tfidf_score);
      END;

      weightrow := TABLE(d,wrow);
      RETURN weightrow;
    END;

    dosents := RECORD
      STRING  word := sentvecsform.word;
      t_Vector vec := sentvecsform.vec;
      DATASET(wrec) docs := wgtrow(sentvecsform.vec,sentvecsform.docs);
    END;

    wsent_final := TABLE(sentvecsform,dosents);

    RETURN wsent_final;
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

  EXPORT sent_vecs := FUNCTION

    svb := sent_vecs_byword;

    wrec addvecsets(DATASET(wrec) L,DATASET(wrec) R) := FUNCTION
    
      //These comments are left to show another approach that was attempted

      //wrec helper1(t_Vector v1,DATASET(wrec) v2) := TRANSFORM
      //  SELF.sentId := v2.sentId;
      //  SELF.text := v2.text;
      //  SELF.tfidf_score := v2.tfidf_score;
      //  SELF.w_Vector := addvecs(v1,v2.w_Vector,COUNT(v1));
      //END;

      //DATASET(wrec) outT(wrec L,DATASET(wrec) R) := TRANSFORM
      //  SELF.sentId := L.sentId;
      //  SELF.text := L.text;
      //  SELF.tfidf_score := L.tfidf_score;
      //  SELF.w_Vector := helper1(L.w_Vector,R);
      //END;

      //out := PROJECT(L,outT(LEFT,R));

      //RETURN out;

      wrec helper(wrec L,INTEGER C) := TRANSFORM
        SELF.sentId := L.sentId;
        SELF.text := L.text;
        SELF.tfidf_score := L.tfidf_score;
        SELF.w_Vector := addvecs(L.w_Vector,R[C].w_Vector);
      END;

      out := PROJECT(L,helper(LEFT,COUNTER));

      RETURN out;

    END;

    svb t(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.vec  := L.vec;
      SELF.docs := addvecsets(L.docs,R.docs);
    END;

    out := ROLLUP(svb,TRUE,t(LEFT,RIGHT));

    RETURN TABLE(out,{DATASET(wrec) docs := out.docs});

  END;

    //CURRENTLY TESTING A JOIN APPROACH
  EXPORT DATASET(wrec) addvecsetsjoin(DATASET(wrec) L,DATASET(wrec) R) := FUNCTION
    temprec := RECORD
      UNSIGNED8 sentId := R.sentId;
      STRING text := R.text;
      REAL8 tfidf_score := R.tfidf_score;
      t_Vector w_Vector_R := R.w_Vector;
    END;

    tempR := TABLE(R,temprec);
    jj := JOIN(L,tempR,LEFT.sentId=RIGHT.sentId);

    outrec := RECORD
      UNSIGNED8 sentId := jj.sentId;
      STRING text := jj.text;
      REAL8 tfidf_score := jj.tfidf_score;
      t_Vector w_Vector := addvecs(jj.w_Vector,jj.w_Vector_R);
    END;

    out := TABLE(jj,outrec);
    RETURN out;
  END;

  EXPORT sent_vecs_experimental_join := FUNCTION

    svb := sent_vecs_byword;

    svb testingT(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.vec  := L.vec;
      SELF.docs := addvecsetsjoin(L.docs,R.docs);
    END;

    //out := PROJECT(svb,testingT(LEFT,COUNTER));
    //out := addvecsetsjoin(svb[1].docs,svb[2].docs);
    //out := ROLLUP(svb,TRUE,testingT(LEFT,RIGHT));
    out := ROLLUP(svb,testingT(LEFT,RIGHT),TRUE);

    RETURN out;
  END;
END;