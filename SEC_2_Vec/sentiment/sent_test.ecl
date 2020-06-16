IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors AS TV;
IMPORT TV.Types;

// path := '~ncf::edgarfilings::raw::labels_allsecs_medium';
// #OPTION('outputLimit',500);
// ssn := sent_setup_norm(path);

//OUTPUT(ssn.sembed_grp_experimental,ALL,NAMED('num_non0_sents'));
//OUTPUT(ssn.sembed_grp_experimental,ALL,NAMED('allnon0'));
wrec := RECORD
    STRING word;
    UNSIGNED8 sentId;
    STRING text;
    REAL8 tfidf_score;
    Types.t_Vector w_Vector;
END;
svb := DATASET(WORKUNIT('W20200616-171709','tfidf_is_0'),wrec);

OUTPUT(svb(sentId=150),NAMED('sent_150'));
//svb_sort := SORT(svb,sentId);
//svb_grp := GROUP(svb_sort,sentId);
// svb_sort := SORT(svb,word);
// svb_grp := GROUP(svb_sort,word);

// rwctrec := RECORD
//     INTEGER numrows;
// END;

// rwctrec ctrws(wrec l,DATASET(wrec) r) := TRANSFORM
//     SELF.numrows := COUNT(r);
// END;

// sent_cts := ROLLUP(svb_grp,GROUP,ctrws(LEFT,ROWS(LEFT)));
// OUTPUT(sent_cts,ALL,NAMED('count_of0_by_sentId'));
//svb := DATASET(WORKUNIT('W20200616-164558','allnon0'),wrec);
//svb := ssn.sembed_grp_experimental;
//OUTPUT(svb(tfidf_score=0),ALL,NAMED('tfidf_is_0'));
// idcol := RECORD
//     UNSIGNED8 sentId := ds.sentId;
// END;

// idsonly := TABLE(ds,idcol);

// OUTPUT(COUNT(DEDUP(SORT(idsonly,sentId))));

// Types.t_Vector addvecs(Types.t_Vector v1,Types.t_Vector v2) := BEGINC++
//     #body
//     size32_t N = lenV1;
//     __lenResult = (size32_t) (N*sizeof(double));
//     double *wout = (double *) rtlMalloc(__lenResult);
//     __isAllResult = false;
//     __result = (void *) wout;
//     double *vv1 = (double *) v1;
//     double *vv2 = (double *) v2;

//     for (unsigned i = 0; i < N; i++)
//     {
//       wout[i] = vv1[i]+vv2[i];
//     }
// ENDC++;

// svb_ordered := SORT(svb,svb.sentId);
// svb_grp := GROUP(svb_ordered,sentId);

// svbrec := RECORDOF(svb);

// veconly := RECORD
//     Types.t_Vector w_Vector;
// END;

// svb iter_vecs(svb l,svb r,INTEGER C) := TRANSFORM
//     SELF.w_Vector := IF(C=1,r.w_Vector,addvecs(l.w_Vector,r.w_Vector));
//     SELF := r;
// END;

// svb grproll(svb L,DATASET(svbrec) R) := TRANSFORM
//     SELF.word := L.word;
//     SELF.sentId := L.sentId;
//     SELF.text := L.text;
//     SELF.tfidf_score := L.tfidf_score;
//     SELF.w_Vector := ITERATE(R,iter_vecs(LEFT,RIGHT,COUNTER),LOCAL)[1].w_Vector;
// END;

// out := ROLLUP(svb_grp,GROUP,grproll(LEFT,ROWS(LEFT)));

// OUTPUT(out,ALL,NAMED('tfidf_weighted_sentence_embeddings'));