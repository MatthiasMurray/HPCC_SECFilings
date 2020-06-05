IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::tech10qs_medium';
//smallpath := '~ncf::edgarfilings::raw::group10q';
//#OPTION('outputLimit',1000);
//#OPTION('outputLimit',1000);
ssn := sent_setup_norm(path);

//OUTPUT(ssn.sent_embed,ALL,NAMED('Tech_Sent_Embeds_All_NormRun'));
//OUTPUT(ssn.tf_withvecs_norm,ALL,NAMED('Checking_Join_Norm'));
//OUTPUT(ssn.sent_roll(1),NAMED('sentence_1_embed'));
OUTPUT(ssn.sembed_grp,NAMED('sentembed_grouprollup'));