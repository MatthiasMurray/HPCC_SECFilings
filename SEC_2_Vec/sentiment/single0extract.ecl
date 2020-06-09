IMPORT * FROM EDGAR_Extract;
IMPORT SEC_2_Vec;
IMPORT * FROM EDGAR_Extract.Text_Tools;
#OPTION('outputLimit',500);

//path := '~ncf::edgarfilings::raw::hpq20200305_0_labeltest_single';
//path := '~ncf::edgarfilings::raw::tech_0labels_double';
path := '~ncf::edgarfilings::raw::labels_allsecs_medium';
lblfilings := label_filings(Text_tools.XBRL_HTML_File(path));

OUTPUT(lblfilings,NAMED('all_01_labeled_files_medium'));