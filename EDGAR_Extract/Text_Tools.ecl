EXPORT Text_Tools := MODULE
    SHARED rec := {STRING text};
    EXPORT CashParse(DATASET(rec) File) := FUNCTION
        pattern mess   := ANY NOT IN ['<','>'];
        pattern divtag := '<div ' mess '>';
        pattern spntag := '<span ' mess '>';
        pattern divend := '</div>';
        pattern spnend := '</span>';
        pattern txtblk := ANY NOT IN ['<','>'];
        pattern blktop := txtblk;
        pattern divpat := divtag spntag txtblk spnend divend;
        rule txtblock  := divpat;

        outrec := RECORD
            STRING text := MATCHTEXT(divpat/txtblk);
        END;

        casheqparse := PARSE(File,text,txtblock,outrec,SCAN ALL);
        RETURN casheqparse;
    END;
    EXPORT Concat(DATASET(rec) File,STRING kDelimiter) := FUNCTION
        StringRec := RECORD
            STRING   text;
        END;
        StringRec MakeStringRec(StringRec l, StringRec r, STRING sep) := TRANSFORM
            SELF.text := l.text + IF(l.text != '',sep,'') + r.text;
        END;
        txtconcat := ROLLUP(File,TRUE,MakeStringRec(LEFT,RIGHT,kDelimiter));
        RETURN txtconcat;
    END;
END;