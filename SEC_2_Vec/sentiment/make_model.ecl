IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;
IMPORT LogisticRegression AS LR;
trainrec := sent_model.trainrec;


#OPTION('outputLimit',500);
//path := '~ncf::edgarfilings::raw::tech10qs_medium';
//path_w_labels := '~ncf::edgarfilings::raw::tech_10qs_medium_withlabels';
//path := '~ncf::edgarfilings::raw::labels_allsecs_medium';
//path := '~ncf::edgarfilings::raw::fixedlabels_allsecs_medium';
path := '~ncf::edgarfilings::raw::fixedlabels_allsecs_big';

dat := sent_model.trndata_wlbl(path,TRUE,'s&p');
dat_vn_all := dat[1];
dat_vn := dat_vn_all;
// van_0 := dat_vn_all(label='0');
// van_1 := dat_vn_all(label='1');
//dat_vn := van_0[1..10]+van_1[1..10];
dat_tf_all := dat[2];
// tf_0 := dat_tf_all(label='0');
// tf_1 := dat_tf_all(label='1');
// dat_tf := tf_0[1..10]+tf_1[1..10];
dat_tf := dat_tf_all;

// hout_van_0 := van_0[11..20];
// hout_van_1 := van_1[11..20];
// hout_tf_0 := tf_0[11..20];
// hout_tf_1 := tf_1[11..20];

//X_vn_all := sent_model.getNumericField(dat_vn_all);
//X_vn := sent_model.getNumericField(dat_vn);
ff_vn := sent_model.getFields(dat_vn);
X_vn := ff_vn.NUMF;
ff_tf := sent_model.getFields(dat_tf);
X_tf := ff_tf.NUMF;
//X_tf := sent_model.getNumericField(dat_tf);
//Y_vn_all := sent_model.getDiscreteField(dat_vn_all);
//Y_vn := sent_model.getDiscreteField(dat_vn);
//Y_tf := sent_model.getDiscreteField(dat_tf);
Y_vn := ff_vn.DSCF;
Y_tf := ff_tf.DSCF;

// X_vn_hout_0 := sent_model.getNumericField(hout_van_0);
// X_vn_hout_1 := sent_model.getNumericField(hout_van_1);
// X_tf_hout_0 := sent_model.getNumericField(hout_tf_0);
// X_tf_hout_1 := sent_model.getNumericField(hout_tf_1);

// Y_vn_hout_0 := sent_model.getDiscreteField(hout_van_0);
// Y_vn_hout_1 := sent_model.getDiscreteField(hout_van_1);
// Y_tf_hout_0 := sent_model.getDiscreteField(hout_tf_0);
// Y_tf_hout_1 := sent_model.getDiscreteField(hout_tf_1);

//blr_mod := sent_model.train_binlogreg(dat,200);
blr_mod_tf := sent_model.train_binlogreg(dat_tf,100);
blr_mod_vn := sent_model.train_binlogreg(dat_vn,100);
plainblr := LR.BinomialLogisticRegression();
//blr_rprt_vn := plainblr.Report(blr_mod_vn,X_vn,Y_vn);
//blr_rprt_tf := plainblr.Report(blr_mod_tf,X_tf,Y_tf);

// vn_pred_0 := plainblr.Classify(blr_mod_vn,X_vn_hout_0);
// vn_0_conf := LR.Confusion(Y_vn_hout_0,vn_pred_0);
// vn_pred_1 := plainblr.Classify(blr_mod_vn,X_vn_hout_1);
// vn_1_conf := LR.Confusion(Y_vn_hout_1,vn_pred_1);

// mod2dat_vn := hout_van_0 + hout_van_1;
// blr_mod_vn2:= sent_model.train_binlogreg(mod2dat_vn,100);

allpreds := plainblr.Classify(blr_mod_vn,X_vn);
allconfu := LR.Confusion(Y_vn,allpreds);
// mod1allpreds := plainblr.Classify(blr_mod_vn,X_vn_all);
// mod1con := LR.Confusion(Y_vn_all,mod1allpreds);
// mod2allpreds := plainblr.Classify(blr_mod_vn2,X_vn_all);
// mod2con := LR.Confusion(Y_vn_all,mod2allpreds);

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

OUTPUT(dat_tf,ALL,NAMED('sandp_tf_vecs'));
OUTPUT(dat_vn,ALL,NAMED('sandp_vn_vecs'));
OUTPUT(blr_mod_tf,ALL,NAMED('sandp_tf'));
OUTPUT(blr_mod_vn,ALL,NAMED('sandp_vn'));
// OUTPUT(blr_rprt_vn,NAMED('vanilla_report'));
// OUTPUT(blr_rprt_tf,NAMED('tfidf_report'));
// OUTPUT(vn_0_conf,NAMED('sandp_vanilla_0_holdout_confusion'));
// OUTPUT(vn_1_conf,NAMED('sandp_vanilla_1_holdout_confusion'));
// OUTPUT(mod1con,NAMED('sandp_Model_1_Confusion'));
// OUTPUT(mod2con,NAMED('sandp_Model_2_confusion'));
OUTPUT(allconfu,NAMED('allconfusion_sp_labels'));
OUTPUT(plainblr.Report(blr_mod_vn,X_vn,Y_vn));