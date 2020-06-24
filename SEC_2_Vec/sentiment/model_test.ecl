IMPORT SEC_2_Vec;
IMPORT sentiment FROM SEC_2_Vec;
IMPORT sentiment.sent_model AS sm;
IMPORT TextVectors as tv;
IMPORT tv.Types;
IMPORT LogisticRegression as LR;
//tfsents := DATASET(WORKUNIT('W20200617-175957','Result 1'),sm.trainrec);
vansents := DATASET(WORKUNIT('W20200623-012104','Result 2'),sm.trainrec);

van0s := vansents(label='0');
van1s := vansents(label='1');

//create artificially balanced datasets of size 20
vanpart(INTEGER j) := FUNCTION
    st := 1+(j*10);
    en := (j+1)*10;
    RETURN van0s[st..en]+van1s[st..en];
END;

vp1 := vanpart(0);
vp2 := vanpart(1);
vp3 := vanpart(2);

X1 := sm.getNumericField(vp1);
X2 := sm.getNumericField(vp2);
X3 := sm.getNumericField(vp3);
Y1 := sm.getDiscreteField(vp1);
Y2 := sm.getDiscreteField(vp2);
Y3 := sm.getDiscreteField(vp3);
X := sm.getNumericField(vansents);
Y := sm.getDiscreteField(vansents);

cx := COUNT(X);
cy := COUNT(Y);
vs := COUNT(vansents);

X_fhalf := IF(cx%2=0,X[1..cx/2],X[1..(cx-1)/2]);
X_lhalf := IF(cx%2=0,X[(cx/2)+1..],X[(cx+1)/2..]);
Y_fhalf := IF(cy%2=0,Y[1..cy/2],Y[1..(cy-1)/2]);
Y_lhalf := IF(cy%2=0,Y[(cy/2)+1..],Y[(cy+1)/2..]);
vansents_fhalf := IF(vs%2=0,vansents[1..vs/2],vansents[1..(vs-1)/2]);
vansents_lhalf := IF(vs%2=0,vansents[(vs/2)+1..],vansents[(vs+1)/2..]);

//using default 100 iters
//not
//using 250 iters
sent_mod1 := sm.train_binlogreg(vp1,250);
sent_mod2 := sm.train_binlogreg(vp2,250);
sent_mod3 := sm.train_binlogreg(vp3,250);
big_mod := sm.train_binlogreg(vansents,250);
fhf_mod := sm.train_binlogreg(vansents_fhalf,250);
lhf_mod := sm.train_binlogreg(vansents_lhalf,250);

plainblr := LR.BinomialLogisticRegression();

one_pred_one := plainblr.Classify(sent_mod1,X1);
one_pred_two := plainblr.Classify(sent_mod1,X2);
one_pred_three := plainblr.Classify(sent_mod1,X3);

two_pred_one := plainblr.Classify(sent_mod2,X1);
two_pred_two := plainblr.Classify(sent_mod2,X2);
two_pred_three := plainblr.Classify(sent_mod2,X3);

three_pred_one := plainblr.Classify(sent_mod3,X1);
three_pred_two := plainblr.Classify(sent_mod3,X2);
three_pred_three := plainblr.Classify(sent_mod3,X3);

one_con_one := LR.Confusion(Y1,one_pred_one);
one_con_two := LR.Confusion(Y2,one_pred_two);
one_con_three := LR.Confusion(Y3,one_pred_three);

two_con_one := LR.Confusion(Y1,two_pred_one);
two_con_two := LR.Confusion(Y2,two_pred_two);
two_con_three := LR.Confusion(Y3,two_pred_three);

three_con_one := LR.Confusion(Y1,three_pred_one);
three_con_two := LR.Confusion(Y2,three_pred_two);
three_con_three := LR.Confusion(Y3,three_pred_three);

first_pred_first:= plainblr.Classify(fhf_mod,X_fhalf);
first_pred_last := plainblr.Classify(fhf_mod,X_lhalf);

last_pred_first:= plainblr.Classify(lhf_mod,X_fhalf);
last_pred_last:= plainblr.Classify(lhf_mod,X_lhalf);

first_con_first := LR.Confusion(Y_fhalf,first_pred_first);
first_con_last := LR.Confusion(Y_lhalf,first_pred_last);

last_con_first := LR.Confusion(Y_fhalf,last_pred_first);
last_con_last := LR.Confusion(Y_lhalf,last_pred_last);

big_pred_all := plainblr.Classify(big_mod,X);
big_con_all := LR.Confusion(Y,big_pred_all);
//big_rprt := plainblr.Report(big_mod,X,Y);

one_pred_first := plainblr.Classify(sent_mod1,X_fhalf);
two_pred_first := plainblr.Classify(sent_mod2,X_fhalf);
thr_pred_first := plainblr.Classify(sent_mod3,X_fhalf);
one_pred_last := plainblr.Classify(sent_mod1,X_lhalf);
two_pred_last := plainblr.Classify(sent_mod2,X_lhalf);
thr_pred_last := plainblr.Classify(sent_mod3,X_lhalf);

one_con_first := LR.Confusion(Y_fhalf,one_pred_first);
two_con_first := LR.Confusion(Y_fhalf,two_pred_first);
thr_con_first := LR.Confusion(Y_fhalf,thr_pred_first);
one_con_last := LR.Confusion(Y_lhalf,one_pred_last);
two_con_last := LR.Confusion(Y_lhalf,two_pred_last);
thr_con_last := LR.Confusion(Y_lhalf,thr_pred_last);


OUTPUT(one_con_one,NAMED('one_con_one'));
OUTPUT(one_con_two,NAMED('one_con_two'));
OUTPUT(one_con_three,NAMED('one_con_three'));

OUTPUT(two_con_one,NAMED('two_con_one'));
OUTPUT(two_con_two,NAMED('two_con_two'));
OUTPUT(two_con_three,NAMED('two_con_three'));

OUTPUT(three_con_one,NAMED('three_con_one'));
OUTPUT(three_con_two,NAMED('three_con_two'));
OUTPUT(three_con_three,NAMED('three_con_three'));

OUTPUT(first_con_first,NAMED('first_con_first'));
OUTPUT(first_con_last,NAMED('first_con_last'));
OUTPUT(last_con_first,NAMED('last_con_first'));
OUTPUT(last_con_last,NAMED('last_con_last'));

//OUTPUT(big_rprt,NAMED('big_model_report'));
OUTPUT(big_con_all,NAMED('big_model_performance'));
OUTPUT(COUNT(van0s),NAMED('number_0_labels'));
OUTPUT(COUNT(van1s),NAMED('number_1_labels'));

OUTPUT(one_con_first,NAMED('one_con_first'));
OUTPUT(two_con_first,NAMED('two_con_first'));
OUTPUT(thr_con_first,NAMED('thr_con_first'));
OUTPUT(one_con_last,NAMED('one_con_last'));
OUTPUT(two_con_last,NAMED('two_con_last'));
OUTPUT(thr_con_last,NAMED('thr_con_last'));