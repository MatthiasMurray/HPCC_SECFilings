xflat := DATASET('~ncf::edgarfilings::raw::aapl_20180929.xml',{STRING words},CSV);
pattern alpha := PATTERN('[A-Za-zA-Za-z]')+;
pattern typ   := alpha;
pattern ws    := PATTERN(' ');
pattern doctag:='<dei:' typ ws;
RULE docstart :=doctag;

outrec := RECORD
    STRING DocumentType:=MATCHTEXT(docstart/typ);
END;

EXPORT ParseXMLtags := PARSE(xflat,words,docstart,outrec,SCAN ALL);