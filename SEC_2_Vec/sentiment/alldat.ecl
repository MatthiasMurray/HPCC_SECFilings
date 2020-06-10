IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::labels_allsecs_medium';

alldat := sent_model.trndata_wlbl(path);

OUTPUT(alldat,ALL,NAMED('alldat_allsecs_medium'));