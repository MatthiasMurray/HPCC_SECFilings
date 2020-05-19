IMPORT TextVectors AS tv;

IMPORT tv.Types;

Sentence := Types.Sentence;

trainSentences := $.testtextvec_input;

sv := tv.SentenceVectors();
model := sv.GetModel(trainSentences);

Word := Types.Word;

testWords := DATASET([{1, 'expectation'},{2,'hopeful'},{3,'income'}],
                Word);
testSents := DATASET([{1, 'Things went as we hoped'},{2, 'We lost money this quarter'},{3, 'We are unsure what to expect'}],
                Sentence);

wordVecs := sv.GetWordVectors(model, testWords);

sentVecs := sv.GetSentVectors(model, testSents);
//etc
OUTPUT(wordVecs);