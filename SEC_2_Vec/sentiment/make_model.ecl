IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression AS LR;
trainrec := sent_model.trainrec;


#OPTION('outputLimit',500);
//path := '~ncf::edgarfilings::raw::tech10qs_medium';
//path_w_labels := '~ncf::edgarfilings::raw::tech_10qs_medium_withlabels';
path := '~ncf::edgarfilings::raw::labels_allsecs_medium';

dat := sent_model.trndata_wlbl(path,TRUE);
dat_vn_all := dat[1];
dat_vn := dat_vn_all(label='0')[1..10]+dat_vn_all(label='1')[1..10];
dat_tf_all := dat[2];
dat_tf := dat_tf_all(label='0')[1..10]+dat_tf_all(label='1')[1..10];

X_vn := sent_model.getNumericField(dat_vn);
X_tf := sent_model.getNumericField(dat_tf);
Y_vn := sent_model.getDiscreteField(dat_vn);
Y_tf := sent_model.getDiscreteField(dat_tf);
//blr_mod := sent_model.train_binlogreg(dat,200);
blr_mod_tf := sent_model.train_binlogreg(dat_tf,200);
blr_mod_vn := sent_model.train_binlogreg(dat_vn,200);
plainblr := LR.BinomialLogisticRegression();
blr_rprt_vn := plainblr.Report(blr_mod_vn,X_vn,Y_vn);
blr_rprt_tf := plainblr.Report(blr_mod_tf,X_tf,Y_tf);

//X := sent_model.getNumericField(dat);
//Y := sent_model.getDiscreteField(dat);
//blr_mod := sent_model.train_binlogreg(dat,200);
//plainblr := LR.BinomialLogisticRegression();
//blr_rprt := plainblr.Report(blr_mod,X,Y);

//OUTPUT(X,ALL,NAMED('allNumeric_smallset32_balanced'));
//OUTPUT(Y,ALL,NAMED('allDiscrete_smallset32_balanced'));
//OUTPUT(blr_mod,ALL,NAMED('blrmod_32'));
//OUTPUT(blr_rprt,ALL,NAMED('blr_rprt_32'));
//OUTPUT(blr_rprt,NAMED('vanilla_report'));
//OUTPUT(blr_rprt_tf,NAMED('tfidf_report'));

OUTPUT(dat_tf,ALL);
OUTPUT(dat_vn,ALL);
OUTPUT(blr_mod_tf,ALL);
OUTPUT(blr_mod_vn,ALL);
OUTPUT(blr_rprt_vn,NAMED('vanilla_report'));
OUTPUT(blr_rprt_tf,NAMED('tfidf_report'));