IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT STD;

drec := sentiment.sent_model.sveclblrec;

ds := DATASET(WORKUNIT('W20200708-033917','sents_qk'),drec);

testrec := RECORD
    STRING fname;
    STRING ticker;
END;

get_tick(STRING f) := FUNCTION
    parts := STD.Str.SplitWords(f,'_',FALSE);
    RETURN parts[1];
END;

file_and_tick := PROJECT(ds,TRANSFORM(testrec,SELF.fname := LEFT.fname,SELF.ticker := get_tick(LEFT.fname)));

ftsort := SORT(file_and_tick,ticker,fname);

OUTPUT(ftsort[..1000]);