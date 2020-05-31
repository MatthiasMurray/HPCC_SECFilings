IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_group';
#OPTION('outputLimit',50);
ss := sent_setup(path);
OUTPUT(ss.tf_withvecs,ALL,NAMED('Tech_TFWithVecs'));