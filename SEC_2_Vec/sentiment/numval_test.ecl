IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_medium';
dat := sent_model.trndata_wlbl(path,FALSE);
vec1 := dat[1].vec;
nv1 := sent_model.tvec_to_numval(vec1);
OUTPUT(dat,NAMED('trnlbl_test'));
OUTPUT(nv1,NAMED('numval1_test'));