IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression AS LR;
trainrec := sent_model.trainrec;

//path := '~ncf::edgarfilings::raw::tech10qs_medium';
//path_w_labels := '~ncf::edgarfilings::raw::tech_10qs_medium_withlabels';
path := '~ncf::edgarfilings::raw::labels_allsecs_medium';

//adat := DATASET(WORKUNIT('W20200610-125439','alldat_allsecs_medium'),trainrec);
//dat := adat(label = '0')[1..16]+adat(label = '1')[1..16];

//dat := sent_model.trndata_wlbl(path);
dat_tf := sent_model.trndata_wlbl(path,TRUE,'tfidf');

// X := sent_model.getNumericField(dat);
// X_tf := sent_model.getNumericField(dat_tf);
// Y := sent_model.getDiscreteField(dat);
// Y_tf := sent_model.getDiscreteField(dat_tf);
// blr_mod := sent_model.train_binlogreg(dat,200);
// blr_mod_tf := sent_model.train_binlogreg(dat_tf,200);
// plainblr := LR.BinomialLogisticRegression();
// blr_rprt := plainblr.Report(blr_mod,X,Y);
// blr_rprt_tf := plainblr.Report(blr_mod_tf,X_tf,Y_tf);

// X := sent_model.getNumericField(dat);
// Y := sent_model.getDiscreteField(dat);
// blr_mod := sent_model.train_binlogreg(dat,200);
// plainblr := LR.BinomialLogisticRegression();
// blr_rprt := plainblr.Report(blr_mod,X,Y);

// OUTPUT(X,ALL,NAMED('allNumeric_smallset32_balanced'));
// OUTPUT(Y,ALL,NAMED('allDiscrete_smallset32_balanced'));
// OUTPUT(blr_mod,ALL,NAMED('blrmod_32'));
// OUTPUT(blr_rprt,ALL,NAMED('blr_rprt_32'));
//OUTPUT(blr_rprt,NAMED('vanilla_report'));
//OUTPUT(blr_rprt_tf,NAMED('tfidf_report'));

OUTPUT(dat_tf);