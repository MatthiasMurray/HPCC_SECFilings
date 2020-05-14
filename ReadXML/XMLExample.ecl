//d := '<library>'+'<book isbn="123456789X">'+'<author>Bayliss</author>'+'<title>A Way Too Far</title>'+'</book>'+'<book isbn="1234567801">'+'<author>Smith</author>'+'<title>A Way Too Short</title>'+'</book>'+'</library>';


rform := RECORD
  //STRING author; //data from author tag -- tag name is lowercase and matches field name
  //STRING name {XPATH('title')}; //data from title tag, renaming the field
  //STRING isbn {XPATH('@isbn')}; //isbn definition data from book tag
  //STRING AmendmentFlag;
  STRING af {XPATH('dei:AmendmentFlag')};
END;
AFlag := DATASET('~ncf::edgarfilings::raw::aapl_20180929_asxml.xml',rform,XML('xbrli:xbrl'));

EXPORT XMLExample := AFlag;