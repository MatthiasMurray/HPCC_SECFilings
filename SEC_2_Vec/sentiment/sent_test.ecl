IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_group';
//smallpath := '~ncf::edgarfilings::raw::group10q';
smallpath := '~ncf::edgarfilings::raw::more10qs';
#OPTION('outputLimit',250);
ss := sent_setup(smallpath);
//ss := sent_setup(smallpath);
//OUTPUT(ss.tf_withvecs,ALL,NAMED('Tech_TFWithVecs'));
//OUTPUT(ss.sent_vecs,ALL,NAMED('Tech_SentenceEmbeddings'));
OUTPUT(ss.sent_vecs,NAMED('Tech_SentenceEmbeddings'));
//OUTPUT(ss.sent_vecs_experimental_join,ALL,NAMED('experimental_join'));