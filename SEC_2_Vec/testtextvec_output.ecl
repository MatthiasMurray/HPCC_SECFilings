IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors AS tv;
IMPORT tv.Types;
IMPORT * FROM SEC_2_Vec;
Sentence := Types.Sentence;

//path := '~ncf::edgarfilings::raw::aapl_20190928_10k_blob';
//path := '~ncf::edgarfilings::raw::group10q';

#OPTION('outputLimit',25);
#OPTION('minOccurs',1);
path := '~ncf::edgarfilings::raw::more10qs';

rawsents := secvec_input(path);
rawrec   := RECORD
    UNSIGNED8 sentId := rawsents.sentId;
    STRING    text   := rawsents.text;
END;
trainSentences := TABLE(rawsents,rawrec);

sv := tv.SentenceVectors();
model := sv.GetModel(trainSentences);

Word := Types.Word;

testWords := DATASET([{1, 'debt'},{2,'equity'},{3,'cash'},{4,'liquid'}],
                Word);

wordVecs := sv.GetWordVectors(model, testWords);


OUTPUT(model,ALL);
OUTPUT(wordVecs,ALL);
OUTPUT(sv.ClosestWords(model, testWords, 3));
//OUTPUT(sv.WordAnalogy(model,'quarter','year','part',2));
OUTPUT(sv.WordAnalogy(model,'certain','claims','statements',2));