IMPORT TextVectors.Internal.svUtils as utils;
IMPORT SEC_2_Vec.sentiment.sent_model as sm;
trec := sm.trainrec;

//toyset := [1.2e105,-1.1e29,8.0e-200];
bigset := [1.2e304,-1.3e80,.02,2.1e300];
tinyset := [1.2e-304,-1.3e-80,.0002,1.4e-25];
mxdset := [1.2e304,-8.1,2.3e-302,0.04];
supertinyset := [1.2e-304,-8.9e-306,7.4e-305,1.42e-307];
//realtfds := DATASET(WORKUNIT('W20200619-214633','Result 1'),trec);
realtfds := DATASET(WORKUNIT('W20200621-185037','Result 1'),trec);

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
    maxab := MAX(absds,absds.val);
    minab := MIN(absds,absds.val);
    RETURN IF(maxab>0.0,multvec(invec,1.0/maxab),invec);//rescaleplain(multvec(invec,SQRT(minab))));
    //RETURN multvec(invec,maxab);
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
    normby := SQRT(SUM(normds,normds.val));
    RETURN IF((1.0/normby)=0.0,invec,IF(normby>0.0,multvec(invec,1.0/normby),invec));
END;

// mltset := multvec(toyset,4.0);

// OUTPUT(toyset);
// OUTPUT(utils.normalizeVector(toyset));
// OUTPUT(mltset);
// OUTPUT(utils.normalizeVector(mltset));
// OUTPUT(normalvec(mltset));

vec1 := realtfds[1].vec;
vec2 := realtfds[2].vec;
vec3 := realtfds[3].vec;
vec4 := realtfds[4].vec;
vec5 := realtfds[5].vec;
vec6 := realtfds[6].vec;


OUTPUT(bigset,NAMED('highmagnitude_vecvals'));
OUTPUT(normalvec(bigset),NAMED('directnormal_highmag'));
OUTPUT(rescale(bigset),NAMED('rescale_highmag'));
OUTPUT(normalvec(rescale(bigset)),NAMED('normal_rescale_highmag'));
//
OUTPUT(tinyset,NAMED('smallmagnitude_vecvals'));
OUTPUT(normalvec(tinyset),NAMED('directnormal_smallmag'));
OUTPUT(rescale(tinyset),NAMED('rescale_smallmag'));
OUTPUT(normalvec(rescale(tinyset)),NAMED('normal_rescale_smallmag'));
//
OUTPUT(mxdset,NAMED('mixedmagnitude_vecvals'));
OUTPUT(normalvec(mxdset),NAMED('directnormal_mixedmag'));
OUTPUT(rescale(mxdset),NAMED('rescale_mixedmag'));
OUTPUT(normalvec(rescale(mxdset)),NAMED('normal_rescale_mixedmag'));
//
OUTPUT(supertinyset,NAMED('near0magnitude_vecvals'));
OUTPUT(normalvec(supertinyset),NAMED('directnormal_near0mag'));
OUTPUT(rescale(supertinyset),NAMED('rescale_near0mag'));
OUTPUT(normalvec(rescale(supertinyset)),NAMED('normal_rescale_near0mag'));
//
OUTPUT(vec1,NAMED('realvec1_vecvals'));
OUTPUT(normalvec(vec1),NAMED('directnormal_realvec1'));
OUTPUT(rescale(vec1),NAMED('rescale_realvec1'));
OUTPUT(normalvec(rescale(vec1)),NAMED('normal_rescale_realvec1'));
//
OUTPUT(vec2,NAMED('realvec2_vecvals'));
OUTPUT(normalvec(vec2),NAMED('directnormal_realvec2'));
OUTPUT(rescale(vec2),NAMED('rescale_realvec2'));
OUTPUT(normalvec(rescale(vec2)),NAMED('normal_rescale_realvec2'));
//
OUTPUT(vec3,NAMED('realvec3_vecvals'));
OUTPUT(normalvec(vec3),NAMED('directnormal_realvec3'));
OUTPUT(rescale(vec3),NAMED('rescale_realvec3'));
OUTPUT(normalvec(rescale(vec3)),NAMED('normal_rescale_realvec3'));
//
OUTPUT(vec4,NAMED('realvec4_vecvals'));
OUTPUT(normalvec(vec4),NAMED('directnormal_realvec4'));
OUTPUT(rescale(vec4),NAMED('rescale_realvec4'));
OUTPUT(normalvec(rescale(vec4)),NAMED('normal_rescale_realvec4'));
//
OUTPUT(vec5,NAMED('realvec5_vecvals'));
OUTPUT(normalvec(vec5),NAMED('directnormal_realvec5'));
OUTPUT(rescale(vec5),NAMED('rescale_realvec5'));
OUTPUT(normalvec(rescale(vec5)),NAMED('normal_rescale_realvec5'));
//
OUTPUT(vec6,NAMED('realvec6_vecvals'));
OUTPUT(normalvec(vec6),NAMED('directnormal_realvec6'));
OUTPUT(rescale(vec6),NAMED('rescale_realvec6'));
OUTPUT(normalvec(rescale(vec6)),NAMED('normal_rescale_realvec6'));
//