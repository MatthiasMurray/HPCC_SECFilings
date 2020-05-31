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

    vecmult(t_Vector v,REAL8 x) := FUNCTION
      
      vec := DATASET(v,vecrec);
      outrec := RECORD
        REAL8 w_elem := x * vec.elem;
      END;
      out := TABLE(vec,outrec);
      RETURN out;
    END;

    wgtrow(t_Vector v, DATASET(tfrec) d) := FUNCTION
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

  EXPORT sent_vecs := FUNCTION
    
    wdocrec := RECORD
      STRING word;
      t_Vector vec;
      DATASET(wrecnew) docs;
    END;

    svb1 := sent_vecs_byword;

    svbdrec:= RECORD
      UNSIGNED8 sentId := svb1.docs.sentId;
      STRING text := svb1.docs.text;
      REAL8 tfidf_score := svb1.docs.tfidf_score;
      vecrec w_Vector := svb1.docs.w_Vector;
    END;

    svbrec := RECORD
      STRING word := svb1.word;
      t_Vector vec:= svb1.vec;
      DATASET(wrecnew) docs := TABLE(svb1.docs,svbdrec);
    END;

    svb := TABLE(svb1,svbrec);

    DATASET(wrecnew) addvecsets(DATASET(wrecnew) L,DATASET(wrecnew) R) := FUNCTION
      
      vecrec addvecs(vecrec v1,vecrec v2) := FUNCTION

        vecrec addT(vecrec L,vecrec R) := TRANSFORM
          SELF.elem := L.elem + R.elem;
        END;

        out := PROJECT(v1,addT(LEFT,v2));

        RETURN out;
      END;

      DATASET(wrecnew) tsets(wrecnew L,wrecnew R) := TRANSFORM
        SELF.sentId := L.sentId;
        SELF.text   := L.text;
        SELF.tfidf_score := L.tfidf_score;
        SELF.w_Vector := addvecs(L.w_Vector,R.w_Vector);
      END;

      out := PROJECT(L,tsets(LEFT,R));

      RETURN out;
    END;

    wdocrec t(svb L,svb R) := TRANSFORM
      SELF.word := L.word;
      SELF.vec  := L.vec;
      SELF.docs := addvecsets(L.docs,R.docs);
    END;

    out := ROLLUP(svb,LEFT.docs.text = RIGHT.docs.text,t(LEFT,RIGHT));

    RETURN TABLE(out,{DATASET(wrecnew) docs := out.docs});

  END;

END;