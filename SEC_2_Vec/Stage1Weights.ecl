IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors AS tv;
IMPORT tv.Types;
IMPORT * FROM SEC_2_Vec;
Sentence := Types.Sentence;
t_Vector := Types.t_Vector;

//#OPTION('outputLimit',25);
EXPORT Stage1Weights(STRING filePath) := FUNCTION
//path := '~ncf::edgarfilings::raw::tech10qs_group';

  rawsents := secvec_input(filePath);
  rawrec   := RECORD
      UNSIGNED8 sentId := rawsents.sentId;
      STRING    text   := rawsents.text;
  END;
  trainSentences := TABLE(rawsents,rawrec);

  sv_mod := SentenceVectors_modified();
  
  stage1weights := sv_mod.GetModel_finalweights(trainSentences);

  RETURN stage1weights;
END;