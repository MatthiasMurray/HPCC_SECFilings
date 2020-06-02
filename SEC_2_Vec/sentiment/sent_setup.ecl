IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors as tv;
IMPORT tv.Types;
t_Vector := Types.t_Vector;

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

  EXPORT vecrec := RECORD
      REAL8 elem;
  END;

  EXPORT wrecnew := RECORD
      UNSIGNED8    sentId;
      STRING         text;
      REAL8   tfidf_score;
      vecrec     w_Vector;
  END;

  EXPORT tfidf_step1 := TABLE(words,step1rec);

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

  EXPORT sent_vecs_byword := FUNCTION
    weighted := RECORD
      STRING word := tf_withvecs.text;
      t_Vector vec:= tf_withvecs.vec;
      DATASET(tfrec) docs := tf_withvecs.docs;
    END;

    sentvecsform := TABLE(tf_withvecs,weighted);

    //t_Vector vecmult(t_Vector v,UNSIGNED4 N,REAL8 x) := EMBED(C++)
    t_Vector vecmult(t_Vector v,REAL8 x) := EMBED(C++)
      #body
      size32_t N = lenV;
      //uint32_t N = (uint32_t) N;
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
    ENDEMBED;

    wgtrow(t_Vector v, DATASET(tfrec) d) := FUNCTION
      UNSIGNED4 C := COUNT(v);
      wrow := RECORD
        UNSIGNED8      sentId := d.sentId;
        STRING           text := d.text;
        REAL8     tfidf_score := d.tfidf_score;
        t_Vector     w_Vector := vecmult(v,d.tfidf_score);
        //t_Vector     w_Vector := PROJECT(v,vecmult(LEFT,d.tfidf_score));
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
  EXPORT t_Vector addvecs(t_Vector v1,t_Vector v2,INTEGER N) := EMBED(C++)
        #body
        __lenResult = (N*sizeof(double));
        double *wout = (double *) rtlMalloc(__lenResult);
        __isAllResult = false;
        __result = (void *) wout;
        double *vv1 = (double *) v1;
        double *vv2 = (double *) v2;
        for (int i = 0; i < N; i++)
        {
          wout[i] = vv1[i]+vv2[i];
        }
      ENDEMBED;

  EXPORT sent_vecs := FUNCTION

    svb := sent_vecs_byword;

    wrec addvecsets(DATASET(wrec) L,DATASET(wrec) R) := FUNCTION

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

      jj := JOIN(L,R,LEFT.sentId=RIGHT.sentId);

      RETURN jj;

    END;

    svb t(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.vec  := L.vec;
      SELF.docs := addvecsets(L.docs,R.docs);
    END;

    //out := ROLLUP(svb,TRUE,t(LEFT,RIGHT));

    //RETURN TABLE(out,{DATASET(wrec) docs := out.docs});

    RETURN addvecsets(svb[1].docs,svb[2].docs);

  END;

END;