IMPORT LearningTrees as LT;
IMPORT LT.ClassificationForest as CF;
IMPORT SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;

vansents := DATASET(WORKUNIT('W20200623-012104','Result 2'),sm.trainrec);
X := sm.getNumericField(vansents);
Y := sm.getDiscreteField(vansents);

//vs := COUNT(vansents);
//dscan := DBSCAN(eps=0.01);
//clust := dscan.fit(X);
// X_fhalf := IF(vs%2=0,sm.getNumericField(vansents[1..vs/2]),sm.getNumericField(vansents[1..(vs-1)/2]));
// X_lhalf := IF(vs%2=0,sm.getNumericField(vansents[(vs/2)+1..]),sm.getNumericField(vansents[(vs+1)/2..]));
// Y_fhalf := IF(vs%2=0,sm.getDiscreteField(vansents[1..vs/2]),sm.getDiscreteField(vansents[1..(vs-1)/2]));
// Y_lhalf := IF(vs%2=0,sm.getDiscreteField(vansents[(vs/2)+1..]),sm.getDiscreteField(vansents[(vs+1)/2..]));

mod := CF.GetModel(X,Y);
// modfh := CF.GetModel(X_fhalf,Y_fhalf);
// modlh := CF.GetModel(X_lhalf,Y_lhalf);
//preds := CF.Classify(mod,X);
// preds_f_f := CF.Classify(modfh,X_fhalf);
// preds_f_l := CF.Classify(modfh,X_lhalf);
// preds_l_f := CF.Classify(modlh,X_fhalf);
// preds_l_l := CF.Classify(modlh,X_lhalf);
//treecon := LR.Confusion(Y,preds);
//probs := CF.GetClassProbs(mod,X);
// probsff := CF.GetClassProbs(modfh,X_fhalf);
// probsfl := CF.GetClassProbs(modfh,X_lhalf);
// probslf := CF.GetClassProbs(modlh,X_fhalf);
// probsll := CF.GetClassProbs(modlh,X_lhalf);

// OUTPUT(probsff,NAMED('probsff'));
// OUTPUT(probsfl,NAMED('probsfl'));
// OUTPUT(probslf,NAMED('probslf'));
// OUTPUT(probsll,NAMED('probsll'));
//OUTPUT(preds);
//OUTPUT(clust);

//mod := SVM.SVC.GetModel(X,Y);

//OUTPUT(SVM.SVC.Report(mod,X,Y),NAMED('SVC_Report_All'));
OUTPUT(mod);