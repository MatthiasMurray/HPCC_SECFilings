IMPORT EDGAR_Example;
IMPORT * FROM EDGAR_Example;

path := '~ncf::edgarfilings::raw::aapl_20190928_10k_blob';

EXPORT test_extract := XBRL_Extract_modified.File(path);