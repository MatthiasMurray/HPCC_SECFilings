//path := '~ncf::edgarfilings::supp::labelguide_sp_medium::labelguide.csv';

//csvrec := RECORD
//    STRING plainname;
//    STRING spname;
//END;

//ds := DATASET(path,csvrec,CSV(HEADING(1)));

//OUTPUT(ds);

IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

path := '~ncf::edgarfilings::raw::fixedlabels_allsecs_big';

lbld := secvec_input_lbl(path,TRUE,'s&p');

OUTPUT(lbld(label='0')[..10]+lbld(label='1')[..10]);