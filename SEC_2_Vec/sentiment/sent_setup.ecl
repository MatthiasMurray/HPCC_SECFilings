IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

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

END;