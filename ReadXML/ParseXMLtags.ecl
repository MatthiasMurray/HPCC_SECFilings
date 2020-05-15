xflat := DATASET('~ncf::edgarfilings::raw::aapl_20180929.xml',{STRING10000 words},CSV);
pattern alpha := PATTERN('[A-Za-zA-Za-z]')+;
pattern tag   := PATTERN('[-\t a-zA-Z]')+;
pattern tabs  := PATTERN('[\t]')+;
pattern typ   := alpha;
pattern ws    := PATTERN(' ');
//pattern doctag:='<dei:' typ ws;
//RULE docstart :=doctag;
pattern maintag:='<' tag ':' typ ws;
rule opentag:=maintag;
//pattern aapltag:='<aapl:' typ ws;
//rule aapl:=aapltag;

outrec := RECORD
    STRING Opener:=MATCHTEXT(maintag/tag);
    STRING DocumentType:=MATCHTEXT(maintag/typ);
END;

EXPORT ParseXMLtags := PARSE(xflat,words,opentag,outrec,SCAN ALL,KEEP(1000));