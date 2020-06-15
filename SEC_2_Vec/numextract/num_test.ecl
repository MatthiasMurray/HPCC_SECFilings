IMPORT * FROM EDGAR_Extract;
labrec := Text_Tools.label_rec;

ds := DATASET(WORKUNIT('W20200610-233701','groupextract_withlabels'),labrec);

//working well for example 3, just needs useless results cleaned out
//retrying example 1
textsamp := ds[12].values[5].content;
//textsamp := ds[3].values[14].content;
//textsamp := ds[6].values[17].content;

OUTPUT(textsamp,NAMED('textsamp'));
OUTPUT(Text_Tools.MoneyTable(textsamp),ALL,NAMED('Money_Table_test'));
//ws_vers := (STRING)REGEXREPLACE(u'\u2020',textsamp,u'$1 ');
//ws_vers := REGEXREPLACE(u'\u2020',textsamp,u'$1~');
//ws_vers := (STRING)REGEXREPLACE(u'\uFFFD',textsamp,u'$1~');
//OUTPUT(ws_vers);
//OUTPUT(Text_Tools.MoneyTable(ws_vers),NAMED('Money_Table_wsvers'));

//TEST MONEY PARSE:
//OUTPUT(Text_Tools.MoneyTable(textsamp),NAMED('Money_Table_test'));