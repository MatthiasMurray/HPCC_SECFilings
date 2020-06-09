IMPORT * FROM EDGAR_Extract;
IMPORT SEC_2_Vec;
IMPORT * FROM EDGAR_Extract.Text_Tools;

//path := '~ncf::edgarfilings::raw::group10q';
path := '~ncf::edgarfilings::raw::tech10qs_medium';
lblpath := '~ncf::edgarfilings::raw::tech_10qs_medium_withlabels';
lblfilings := label_filings(Text_tools.XBRL_HTML_File(lblpath));
lbl0files := lblfilings(label='0');

//OUTPUT(Text_Tools.XBRL_HTML_File(path),NAMED('groupextract'));
OUTPUT(lblfilings,NAMED('groupextract_withlabels'));
OUTPUT(SEC_2_Vec.secvec_input_lbl(lblpath),ALL);
OUTPUT(lbl0files,NAMED('check_0_labels'));