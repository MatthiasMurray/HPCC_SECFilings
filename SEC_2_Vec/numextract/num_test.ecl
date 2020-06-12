IMPORT * FROM EDGAR_Extract;
labrec := Text_Tools.label_rec;

ds := DATASET(WORKUNIT('W20200610-233701','groupextract_withlabels'),labrec);

textsamp := ds[12].values[5].content;

OUTPUT(textsamp,NAMED('textsamp'));
OUTPUT(Text_Tools.MoneyTable(textsamp),NAMED('Money_Table_test'));