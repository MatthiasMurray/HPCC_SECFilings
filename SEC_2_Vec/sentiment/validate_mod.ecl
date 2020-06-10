IMPORT LogisticRegression as LR;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT ML_Core;
trainrec := sent_model.trainrec;

//mod76 := DATASET(WORKUNIT('W20200610-131156','blrmod_76'),LR.Types.Layout_Model);
mod32 := DATASET(WORKUNIT('W20200610-132528','blrmod_32'),LR.Types.Layout_Model);
//smallmod := DATASET(WORKUNIT('W20200610-120119','binomial_mod_smallset'),LR.Types.Layout_Model);
//allmod := DATASET(WORKUNIT('W20200610-120513','binomial_mod_allset'),LR.Types.Layout_Model);

// path := '~ncf::edgarfilings::raw::labels_allsecs_medium';

//alldat := sent_model.trndata_wlbl(path);
adat := DATASET(WORKUNIT('W20200610-125439','alldat_allsecs_medium'),trainrec);
//dat := adat(label='1')[50..175];
//dat := adat;//(label = '1')[100..200]
//dat := alldat(label = '1')[50..150];
dat := adat(label = '0')[17..]+adat(label = '1')[17..26];//(label = '1')[100..300];
X := sent_model.getNumericField(dat);
Y := sent_model.getDiscreteField(dat);

plainblr := LR.BinomialLogisticRegression();
blr_classify := plainblr.Classify(mod32,X);
//blr_classify := plainblr.Classify(mod76,X);
//blr_classify := plainblr.Classify(smallmod,X);
//blr_classify := plainblr.Classify(allmod,X);

ML_Core.Types.DiscreteField class_to_discreteT(RECORDOF(blr_classify) bc) := TRANSFORM
    SELF.wi := bc.wi;
    SELF.id := bc.id;
    SELF.number := bc.number;
    SELF.value := bc.value;
END;
predicts := PROJECT(blr_classify,class_to_discreteT(LEFT));

confusion := LR.Confusion(Y,predicts);

OUTPUT(Y,ALL,NAMED('truelabels'));
OUTPUT(predicts,ALL,NAMED('predictedlabels'));
OUTPUT(confusion,ALL,NAMED('confusion_validate'));