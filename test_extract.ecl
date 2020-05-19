IMPORT * FROM EDGAR_Extract;
#OPTION('outputLimit',25);
path := '~ncf::edgarfilings::raw::aapl_20190928_10k_blob';
path2 := '~ncf::edgarfilings::raw::aapl_10q_exblob';

test_extract := Text_Tools.XBRL_HTML_File(path);

OUTPUT(test_extract,NAMED('cleantext'));