IMPORT * FROM SEC_2_Vec;
IMPORT EDGAR_Extract.Extract_Layout_modified;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT STD;


path := '~ncf::edgarfilings::raw::tech10qs_medium';

lblsecvec := secvec_input_lbl(path,FALSE);


OUTPUT(lblsecvec,NAMED('test_secvecin'));
OUTPUT(lblsecvec(label='1'),ALL,NAMED('test_secvecin_with_labels1'));
OUTPUT(lblsecvec(label='0'),ALL,NAMED('test_secvecin_with_labels0'));