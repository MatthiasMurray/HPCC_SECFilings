IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;

path := '~ncf::edgarfilings::raw::labels_allsecs_medium';

ssn := sent_setup_norm(path);

OUTPUT(ssn.sembed_grp_experimental,NAMED('experimental_sembed'));