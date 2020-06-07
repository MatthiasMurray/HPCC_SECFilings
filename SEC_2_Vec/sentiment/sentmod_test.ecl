IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_medium';
dat := sent_model.trndata_wlbl(path,FALSE);
num := sent_model.getNumericField(dat);

OUTPUT(num,NAMED('prepared_as_numeric_field'));