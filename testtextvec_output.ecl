IMPORT TextVectors AS tv;
IMPORT tv.Types;

Sentence := Types.Sentence;

trainSentences := DATASET(WORKUNIT('W20200519-173506','sentences'),Sentence);

sv := tv.SentenceVectors();
model := sv.GetModel(trainSentences);

Word := Types.Word;

testWords := DATASET([{1, 'debt'},{2,'equity'},{3,'cash'},{4,'liquid'}],
                Word);
//testSents := DATASET([{1, 'Things went as we hoped'},{2, 'We lost money this quarter'},{3, 'We are unsure what to expect'}],
//                Sentence);

wordVecs := sv.GetWordVectors(model, testWords);

//sentVecs := sv.GetSentVectors(model, testSents);
//etc

OUTPUT(wordVecs);
//OUTPUT(sentVecs);
OUTPUT(sv.WordAnalogy(model,'cash','liquid','debt',2));