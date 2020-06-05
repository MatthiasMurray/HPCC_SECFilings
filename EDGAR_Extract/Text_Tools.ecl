IMPORT * FROM EDGAR_Extract;
IMPORT STD;

EXPORT Text_Tools := MODULE
    
    EXPORT CashParse(STRING File) := FUNCTION

        rec1 := {STRING content};
        F := DATASET([{File}],rec1);

        pattern mess   := ANY NOT IN ['<','>'];
        pattern fmttag := '<span' mess+ '>';
        pattern divtag := '<div' mess+ '>';
        pattern fmtend := '</span>';
        pattern divend := '</div>';
        pattern txtblk := (ANY NOT IN ['<','>',divtag,divend])+;
        pattern fmtpat := fmttag txtblk fmtend;
        rule txtblock  := fmtpat;

        outrec := RECORD
            STRING text := MATCHTEXT(fmtpat/txtblk);
        END;

        casheqparse := PARSE(F,content,txtblock,outrec,SCAN);
        RETURN casheqparse;
    END;
    rec2 := RECORD
        STRING text;
    END;
    
    EXPORT STRING Concat(DATASET(rec2) File,STRING kDelimiter = ' ') := FUNCTION
        StringRec := RECORD
            STRING   text;
            //STRING label;
        END;
        StringRec MakeStringRec(StringRec l, StringRec r, STRING sep) := TRANSFORM
            SELF.text := l.text + IF(l.text != '',sep,'') + r.text;
            //SELF.label := l.label;
        END;
        txtconcat := ROLLUP(File,TRUE,MakeStringRec(LEFT,RIGHT,kDelimiter));
        RETURN txtconcat[1].text;
        //RETURN [txtconcat[1].text,txtconcat[1].label];
    END;

    //DECIDED TO JUST BUILD A LABEL VERSION OF CONCAT
    EXPORT concatlblrec := RECORD
        STRING text;
        STRING label;
    END;
    
    EXPORT concatlblrec lblConcat(DATASET(concatlblrec) File,STRING kDelimiter = ' ') := FUNCTION
        concatlblrec lbl_with_concat(concatlblrec l,concatlblrec r, STRING sep) := TRANSFORM
            SELF.text := l.text + IF(l.text != '',sep,'') + r.text;
            SELF.label := l.label;
        END;

        lbltxtconcat := ROLLUP(File,TRUE,lbl_with_concat(LEFT,RIGHT,kDelimiter));
        RETURN lbltxtconcat;
    END;
    
    EXPORT FixTextBlock(DATASET(Extract_Layout_modified.Entry_clean) ent) := FUNCTION
      
      outrec := RECORD
          UNICODE element := ent.element;
          UNICODE contextRef := ent.contextRef;
          UNICODE unitRef := ent.unitRef;
          UNICODE decimals:= ent.decimals;
          UNICODE content := Concat(CashParse(ent.content));
      END;

      Result := TABLE(ent,outrec,element);
      RETURN Result;
    END;
    EXPORT XBRL_HTML_File(STRING fileName) := FUNCTION
        File := XBRL_Extract_modified.File(fileName);
        
        Extract_Layout_modified.Entry_clean fixHTML(Extract_Layout_modified.Entry_clean lr) := TRANSFORM
            SELF.element    := lr.element;
            SELF.contextRef := lr.contextRef;
            SELF.unitRef    := lr.unitRef;
            SELF.decimals   := lr.decimals;
            SELF.content    := IF(lr.element IN ['us-gaap:CashAndCashEquivalentsPolicyTextBlock',
                                                'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
                                                'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
                                                'us-gaap:AdditionalFinancialInformationTextBlock',
                                                'us-gaap:QuarterlyFinancialInformationTextBlock'],
                                    '[OPN]'+Concat(CashParse(lr.content))+'[CLS]',
                                    lr.content);
        END;

        RECORDOF(File) cvthtml(RECORDOF(File) lr) := TRANSFORM
            SELF.fileName         := lr.fileName;
            SELF.filingType       := lr.filingType;
            SELF.reportPeriod     := lr.reportPeriod;
            SELF.name             := lr.name;
            SELF.is_smallbiz      := lr.is_smallbiz;
            SELF.pubfloat         := lr.pubfloat;
            //SELF.comsharesout     := lr.comsharesout;
            SELF.wellknown        := lr.wellknown;
            SELF.shell            := lr.shell;
            SELF.centralidxkey    := lr.centralidxkey;
            SELF.amendflag        := lr.amendflag;
            SELF.filercat         := lr.filercat;
            SELF.fyfocus          := lr.fyfocus;
            SELF.fpfocus          := lr.fpfocus;
            SELF.emerging         := lr.emerging;
            //SELF.ticker           := XMLUNICODE('dei:TradingSymbol');
            SELF.volfilers        := lr.volfilers;
            SELF.currentstat      := lr.currentstat;
            SELF.fyend            := lr.fyend;
            SELF.filingDate       := 'N/A';    // only classic EDGAR
            SELF.accessionNumber  := 'N/A';    // only classic EDGAR
            SELF.values           := PROJECT(lr.values,fixHTML(LEFT));
        END;
        
        Final := PROJECT(File,cvthtml(LEFT));
        RETURN Final;
    END;

    EXPORT label_filings(Extract_Layout_modified.Main extractedFiles) := FUNCTION
        grablabel(STRING fname) := FUNCTION
            splitname := STD.Str.SplitWords(fname,'_',FALSE);
            label_withxml := splitname[4];
            lwx_splitondot := STD.Str.SplitWords(label_withxml,'.',FALSE);
            label := lwx_splitondot[1];
            RETURN label;
        END;
        
        label_rec := RECORD
            STRING  fileName;
            UNICODE accessionNumber;
            UNICODE name;
            UNICODE filingType;
            UNICODE filingDate;
            UNICODE reportPeriod;
            UNICODE is_smallbiz;
            UNICODE pubfloat;
            UNICODE wellknown;
            UNICODE shell;
            UNICODE centralidxkey;
            UNICODE amendflag;
            UNICODE filercat;
            UNICODE fyfocus;
            UNICODE fpfocus;
            UNICODE emerging;
            UNICODE volfilers;
            UNICODE currentstat;
            UNICODE fyend;
            STRING  sent_label;
            DATASET(Extract_Layout_modified.Entry_clean) values;
        END;        

        label_rec addlabelfield(Extract_Layout_modified.Main f):= TRANSFORM
            SELF.fileName := f.fileName;
            SELF.accessionNumber := f.accessionNumber;
            SELF.name := f.name;
            SELF.filingType := f.filingType;
            SELF.filingDate := f.filingDate;
            SELF.reportPeriod := f.reportPeriod;
            SELF.is_smallbiz := f.is_smallbiz;
            SELF.pubfloat := f.pubfloat;
            SELF.wellknown := f.wellknown;
            SELF.shell := f.shell;
            SELF.centralidxkey := f.centralidxkey;
            SELF.amendflag := f.amendflag;
            SELF.filercat := f.filercat;
            SELF.fyfocus := f.fyfocus;
            SELF.fpfocus := f.fpfocus;
            SELF.emerging := f.emerging;
            SELF.volfilers := f.volfilers;
            SELF.currentstat := f.currentstat;
            SELF.fyend := f.fyend;
            SELF.sent_label := grablabel(f.fileName);
            SELF.values := f.values;
        END;


        out := PROJECT(extractedFiles,addlabelfield(LEFT));

        RETURN out;
    END;
    

    //FIXME: Work on revised version that keeps labels
    //EXPORT sep_sents_lbl()
    EXPORT sep_sents(STRING inString) := FUNCTION
        pattern endpunct := ['.','?','!'];
        pattern ws       := ' ';
        pattern mess     := PATTERN('[A-Z]') (ANY NOT IN endpunct)+;
        pattern sentence := mess endpunct ;
        pattern begsent  := '[OPN]' sentence ws PATTERN('[A-Z]') OPT('[CLS]');
        pattern midsent  := endpunct ws sentence ws PATTERN('[A-Z]');
        pattern endsent  := OPT('[OPN]') OPT(endpunct ws) sentence '[CLS]';
        rule    nicesent := begsent|midsent|endsent;

        inrec  := RECORD
            STRING text;
        END;

        F := DATASET([{inString}],inrec);
        
        parserec := RECORD
            UNSIGNED8 ones  := 1;
            UNSIGNED8 sentId:= 0; 
            STRING sentence := MATCHTEXT(nicesent/sentence);
        END;

        sentparse := DEDUP(PARSE(F,text,nicesent,parserec,SCAN));
        
        outrec := RECORD
            UNSIGNED8 ones;
            UNSIGNED8 sentId;
            STRING    sentence;
        END;

        outrec consec(outrec L,outrec R) := TRANSFORM
            SELF.sentId := L.sentId + R.ones;
            SELF        := R;
        END;

        sentlist := ITERATE(sentparse,consec(LEFT,RIGHT));

        finalrec := RECORD
            UNSIGNED8 sentId   := sentlist.sentId;
            STRING  text := sentlist.sentence;
        END;

        RETURN TABLE(sentlist,finalrec);
    END;
END;