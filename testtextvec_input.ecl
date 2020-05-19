IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;

//wufile := DATASET(WORKUNIT('html_cleaned'),Extract_Layout_modified.Main);

//OUTPUT(wufile.values);

sents := 'This is an example sentence. The more words the better!';

OUTPUT(sep_sents(sents));