IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM ML_Core;
IMPORT TextVectors as tv;

path := '~ncf::edgarfilings::raw::tech10qs_medium';
dat := sent_model.trndata_wlbl(path,FALSE);
vec1 := dat[1].vec;
nv1 := sent_model.tvec_to_numval(vec1);

trainrec := sent_model.trainrec;

vecrec := RECORD
    REAL8 value;
END;

vecdsrec := RECORD
    UNSIGNED rowid;
    DATASET(vecrec) vecds;
END;

vecdsrec todsT(trainrec d, INTEGER C) := TRANSFORM
    SELF.rowid := C;
    SELF.vecds := DATASET(d.vec,vecrec);
END;

vec_as_ds := PROJECT(dat,todsT(LEFT,COUNTER));

//ML_Core.ToField(vec_as_ds,traindat);
//nf := Utils.SequenceInField(dat,vec,'NumericField','wi');
OUTPUT(dat,NAMED('trnlbl_test'));
OUTPUT(nv1,NAMED('numval1_test'));
//OUTPUT(nf);
//OUTPUT(train,NAMED('train_nf_form'));
OUTPUT(vec_as_ds,NAMED('vecasds'));