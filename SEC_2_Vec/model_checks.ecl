IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors AS tv;
IMPORT tv.Types;
IMPORT * FROM SEC_2_Vec;
Sentence := Types.Sentence;


sv := tv.SentenceVectors();

model := DATASET(WORKUNIT('W20200526-115152','tech10qs_vecmod'),Types.TextMod);

Word := Types.Word;

testWords := DATASET([{1, 'debt'},{2,'equity'},{3,'cash'},{4,'liquid'}],
                Word);

wordVecs := sv.GetWordVectors(model, testWords);

OUTPUT(sv.WordAnalogy(model,'debt','cash','uncertain',3));