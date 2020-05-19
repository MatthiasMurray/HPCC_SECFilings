IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;

wufile := DATASET(WORKUNIT('W20200519-172257','cleantext'),Extract_Layout_modified.Main);

specrow := wufile.values(element='us-gaap:CashAndCashEquivalentsPolicyTextBlock')[1];

OUTPUT(sep_sents(specrow.content),NAMED('sentences'));

//sents := 'This is an example sentence. The more words the better!';

//OUTPUT(sep_sents(sents));