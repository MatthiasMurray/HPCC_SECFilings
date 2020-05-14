IMPORT $;

outrec := RECORD
    STRING DocumentType:=$.ParseXMLtags.DocumentType;
    STRING info {XPATH('dei:'+$.ParseXMLtags.DocumentType)};
END;

EXPORT XMLdei := DATASET('~ncf::edgarfilings::raw::aapl_20180929_asxml.xml',outrec,XML('xbrli:xbrl'));