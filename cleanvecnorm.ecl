IMPORT TextVectors.Internal.svUtils as utils;

//toyset := [1.2e105,-1.1e29,8.0e-200];
bigset := [1.2e304,-1.3e80,.02,2.1e300];
tinyset := [1.2e-304,-1.3e-80,.0002,1.4e-25];
mxdset := [1.2e304,-8.1,2.3e-302,0.04];
supertinyset := [1.2e-304,-8.9e-306,7.4e-305,1.42e-307];

//OUTPUT(utils.normalizeVector(toyset));

vrec := SET OF REAL8;


multvec(vrec invec,REAL8 x) := FUNCTION
    inds := DATASET(invec,{REAL8 val});
    inrec := RECORD
        REAL8 val;
    END;
    inrec mult_T(inrec v) := TRANSFORM
        SELF.val := v.val * x;
    END;
    multds := PROJECT(inds,mult_T(LEFT));
    RETURN SET(multds,multds.val);
END;

rescaleplain(vrec invec) := FUNCTION
    inds := DATASET(invec,{REAL8 val});
    inrec := RECORD
        REAL8 val;
    END;
    inrec abs_T(inrec v) := TRANSFORM
        SELF.val := ABS(v.val);
    END;
    absds := PROJECT(inds,abs_T(LEFT));
    maxab := 1/MAX(absds,absds.val);
    RETURN multvec(invec,maxab);
END;
rescale(vrec invec) := FUNCTION
    inds := DATASET(invec,{REAL8 val});
    inrec := RECORD
        REAL8 val;
    END;
    inrec abs_T(inrec v) := TRANSFORM
        SELF.val := ABS(v.val);
    END;
    absds := PROJECT(inds,abs_T(LEFT));
    maxab := 1/MAX(absds,absds.val);
    minab := 1/MIN(absds,absds.val);
    RETURN IF(maxab<1,multvec(invec,maxab),rescaleplain(multvec(invec,minab)));
END;

normalvec(vrec invec) := FUNCTION
    inds := DATASET(invec,{REAL8 val});
    inrec := RECORD
        REAL8 val;
    END;
    inrec norm_T(inrec v) := TRANSFORM
        SELF.val := v.val * v.val;
    END;
    normds := PROJECT(inds,norm_T(LEFT));
    normby := 1/SQRT(SUM(normds,normds.val));
    RETURN multvec(invec,normby);
END;

// mltset := multvec(toyset,4.0);

// OUTPUT(toyset);
// OUTPUT(utils.normalizeVector(toyset));
// OUTPUT(mltset);
// OUTPUT(utils.normalizeVector(mltset));
// OUTPUT(normalvec(mltset));

OUTPUT(bigset);
OUTPUT(normalvec(bigset));
OUTPUT(rescale(bigset));
OUTPUT(normalvec(rescale(bigset)));
//
OUTPUT(tinyset);
OUTPUT(normalvec(tinyset));
OUTPUT(rescale(tinyset));
OUTPUT(normalvec(rescale(tinyset)));
//
OUTPUT(mxdset);
OUTPUT(normalvec(mxdset));
OUTPUT(rescale(mxdset));
OUTPUT(normalvec(rescale(mxdset)));
//
OUTPUT(supertinyset);
OUTPUT(normalvec(supertinyset));
OUTPUT(rescale(supertinyset));
OUTPUT(normalvec(rescale(supertinyset)));