IMPORT * FROM EDGAR_Extract;

path := '~ncf::edgarfilings::raw::group10q';

OUTPUT(Text_Tools.XBRL_HTML_File(path),NAMED('groupextract'));