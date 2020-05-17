IMPORT * FROM EDGAR_Extract.Text_Tools;

ds := ['h','e','l','l','o'];

rec := RECORD
    STRING text;
END;

file := DATASET(ds, rec);

EXPORT text_parse_test := Concat(file,'');