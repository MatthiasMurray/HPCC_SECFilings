IMPORT * FROM EDGAR_Extract;

path := '~ncf::edgarfilings::raw::aapl_20190928_10k_blob';

//EXPORT test_extract := XBRL_Extract_modified.File(path);

EXPORT test_extract := Text_Tools.XBRL_HTML_File(path);