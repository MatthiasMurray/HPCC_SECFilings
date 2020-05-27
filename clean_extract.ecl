IMPORT * FROM EDGAR_Extract;

//path := '~ncf::edgarfilings::raw::group10q';
path := '~ncf::edgarfilings::raw::tech10qs_group';

OUTPUT(Text_Tools.XBRL_HTML_File(path),NAMED('groupextract'));