IMPORT SEC_2_Vec;
IMPORT sentiment FROM SEC_2_Vec;
IMPORT sentiment.sent_model AS sm;
IMPORT TextVectors as tv;
IMPORT tv.Types;
//tfsents := DATASET(WORKUNIT('W20200617-175957','Result 1'),sm.trainrec);
tfsents := DATASET(WORKUNIT('W20200617-232228','Result 1'),sm.trainrec);

// totrec := RECORD
//     REAL8 vectot;
//     REAL8 vecmax;
//     REAL8 vecmin;
//     REAL8 absmax;
//     REAL8 absmin;
// END;

absmaxmin(Types.t_Vector v) := FUNCTION
    vecasds := DATASET(v,{REAL8 val});
    vdsrec := RECORD
        REAL8 val;
    END;
    vdsrec absT(vdsrec vds) := TRANSFORM
        SELF.val := ABS(vds.val);
    END;
    absds := PROJECT(vecasds,absT(LEFT));
    RETURN [MAX(absds,absds.val),MIN(absds,absds.val)];
END;

// totrec vectotT(RECORDOF(tfsents) L) := TRANSFORM
//     SELF.vectot := (REAL8) SUM(L.vec);
//     SELF.vecmax := (REAL8) MAX(L.vec);
//     SELF.vecmin := (REAL8) MIN(L.vec);
//     SELF.absmax := absmaxmin(L.vec,'max');
//     SELF.absmin := absmaxmin(L.vec,'min');
// END;

// out := PROJECT(tfsents,vectotT(LEFT));

// OUTPUT(out,NAMED('vec_totals'));

vec1 := tfsents[1].vec;

//make row1
OUTPUT(SUM(vec1));
OUTPUT(MAX(vec1));
OUTPUT(MIN(vec1));
OUTPUT(absmaxmin(vec1,'max'));
OUTPUT(absmaxmin(vec1,'min'));