IMPORT STD;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

trainrec := sentiment.sent_model.trainrec;

EXPORT simlabs(DATASET(trainrec) traindat) := MODULE
    EXPORT get_ticker(STRING f) := FUNCTION
        parts := STD.Str.SplitWords(f,'_',FALSE);
        tick := parts[1];
        RETURN tick;
    END;

    EXPORT simsentcomp := FUNCTION
        tickrec := RECORD
            STRING fname  := traindat.fname;
            STRING ticker := get_ticker(traindat.fname);
        END;

        tickds := TABLE(traindat,tickrec);

        ticksdedup := DEDUP(SORT(tickds,tickds.ticker),tickds.ticker);
        fnames := DEDUP(SORT(tickds,tickds.fname),tickds.fname);
        ticks := SET(ticksdedup,ticksdedup.ticker);
        RETURN fnames;
    END;


    //for each tick, act on records
    //get similarity scores for consecutive filings
    //result should be sentiment labels paired with similarity labels
END;