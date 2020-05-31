IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_group';

ss := sent_setup(path);
OUTPUT(ss.tfidf_all);