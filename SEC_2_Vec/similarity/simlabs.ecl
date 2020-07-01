IMPORT STD;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;

trainrec := sentiment.sent_model.trainrec;

EXPORT simlabs(DATASET(trainrec) traindat) := MODULE
    get_ticker(STRING f) := FUNCTION
        parts := STD.Str.SplitWords(f,'_',FALSE);
        tick := parts[1];
        RETURN tick;
    END;

    tickrec := RECORD
        STRING ticker := get_ticker(fnamevecs_tf.fname);
    END;

    tickds := TABLE(fnamevecs_tf,tickrec);

    ticksdedup := DEDUP(tickds,tickds.ticker);
    ticks := SET(ticksdedup,ticksdedup.ticker);

    //for each tick, act on records
    //get similarity scores for consecutive filings
    //result should be sentiment labels paired with similarity labels
END;