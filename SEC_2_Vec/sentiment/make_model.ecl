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
van_0 := dat_vn_all(label='0');
van_1 := dat_vn_all(label='1');
dat_vn := van_0[1..100]+van_1[1..600];
holdout_vn := van_0[101..]+van_1[601..800];

dat_tf_all := dat[2];
tf_0 := dat_tf_all(label='0');
tf_1 := dat_tf_all(label='1');
dat_tf := tf_0[1..100]+tf_1[1..600];
holdout_tf := tf_0[101..]+tf_1[601..800];

ff_vn := sent_model.getFields(dat_vn);
ff_vnhold := sent_model.getFields(holdout_vn);
ff_tf := sent_model.getFields(dat_tf);
ff_tfhold := sent_model.getFields(holdout_tf);

X_vn_ho := ff_vnhold.NUMF;
X_vn := ff_vn.NUMF;
X_tf_ho := ff_tfhold.NUMF;
X_tf := ff_tf.NUMF;

Y_vn_ho := ff_vnhold.DSCF;
Y_tf_ho := ff_tfhold.DSCF;
Y_tf := ff_tf.DSCF;
Y_vn := ff_vn.DSCF;

blr_mod_tf := sent_model.train_binlogreg(dat_tf,100);
blr_mod_vn := sent_model.train_binlogreg(dat_vn,100);

plainblr := LR.BinomialLogisticRegression();

//blr_rprt_vn := plainblr.Report(blr_mod_vn,X_vn,Y_vn);
//blr_rprt_tf := plainblr.Report(blr_mod_tf,X_tf,Y_tf)

allpreds_tf := plainblr.Classify(blr_mod_tf,X_tf);
allpreds_vn := plainblr.Classify(blr_mod_vn,X_vn);
allconfu_vn := LR.Confusion(Y_vn,allpreds_vn);
allconfu_tf := LR.Confusion(Y_tf,allpreds_tf);

holdpreds_vn := plainblr.Classify(blr_mod_vn,X_vn_ho);
holdpreds_tf := plainblr.Classify(blr_mod_tf,X_tf_ho);
holdconfu_vn := LR.Confusion(Y_vn_ho,holdpreds_vn);
holdconfu_tf := LR.Confusion(Y_tf_ho,holdpreds_tf);

hldvnconfu := LR.BinomialConfusion(holdconfu_vn);
blrvnconfu := LR.BinomialConfusion(allconfu_vn);
hldtfconfu := LR.BinomialConfusion(holdconfu_tf);
blrtfconfu := LR.BinomialConfusion(allconfu_tf);

OUTPUT(dat_vn,ALL,NAMED('sandp_vn_vecs'));
OUTPUT(dat_tf,ALL,NAMED('sandp_tf_vecs'));
OUTPUT(X_vn[..200],NAMED('sandp_vn_numeric'));
OUTPUT(X_tf[..200],NAMED('sandp_tf_numeric'));
OUTPUT(Y_vn,ALL,NAMED('sandp_vn_labels'));
OUTPUT(Y_tf,ALL,NAMED('sandp_tf_labels'));
OUTPUT(allpreds_vn,ALL,NAMED('sandp_vn_preds'));
OUTPUT(allpreds_tf,ALL,NAMED('sandp_tf_preds'));
OUTPUT(blrvnconfu,ALL,NAMED('blr_vn_confu'));
OUTPUT(blrtfconfu,ALL,NAMED('blr_tf_confu'));
OUTPUT(hldvnconfu,ALL,NAMED('holdout_vanilla_confusion'));
OUTPUT(hldtfconfu,ALL,NAMED('holdout_tfidf_confusion'));