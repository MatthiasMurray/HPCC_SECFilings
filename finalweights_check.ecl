IMPORT SEC_2_Vec;
IMPORT SV2, secvec_input FROM SEC_2_Vec;

path := '~ncf::edgarfilings::raw::tech10qs_group';

rawsents := secvec_input(path);

rawrec := RECORD
    UNSIGNED8 sentId := rawsents.sentId;
    STRING    text   := rawsents.text;
END;
trainSentences := TABLE(rawsents,rawrec);
sv := SV2();

OUTPUT(sv.GetModel_finalweights(trainSentences));