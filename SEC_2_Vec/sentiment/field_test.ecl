IMPORT SEC_2_Vec.sentiment.sent_model as sm;

vansents := DATASET(WORKUNIT('W20200623-012104','Result 2'),sm.trainrec);

//OUTPUT(sm.getNumericField(vansents[1..2]),ALL);
//OUTPUT(sm.getDiscreteField(vansents(label='0')[1]+vansents(label='1')[1]),ALL);
ff := sm.getFields(vansents[1..2]);
OUTPUT(ff.NUMF,ALL);
OUTPUT(ff.DSCF,ALL);