IMPORT * FROM SEC_2_Vec;

path_fic := '~ncf::edgarfilings::raw::cocaficsamp';
path_sec := '~ncf::edgarfilings::raw::tech10qs_group';

OUTPUT(Stage_Learn.FinalStage(path_sec,path_fic));