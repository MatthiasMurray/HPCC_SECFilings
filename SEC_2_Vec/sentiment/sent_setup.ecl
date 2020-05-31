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

  EXPORT sent_vecs := FUNCTION
    weighted := RECORD
      STRING word := tf_withvecs.text;
      t_Vector vec:= tf_withvecs.vec;
      DATASET(tfrec) docs := tf_withvecs.docs;
    END;

    sentvecsform := TABLE(tf_withvecs,weighted);

    vecmult(t_Vector v,REAL8 x) := FUNCTION
      vecrec := RECORD
        REAL8 elem;
      END;
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

END;