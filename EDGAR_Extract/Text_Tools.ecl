IMPORT * FROM EDGAR_Extract;
IMPORT STD;

EXPORT Text_Tools := MODULE
    EXPORT CashParse(STRING File) := FUNCTION

        rec1 := {STRING content};
        F := DATASET([{File}],rec1);

        pattern mess   := ANY NOT IN ['<','>'];
        pattern fmttag := '<span' mess+ '>'|'<span>';
        pattern divtag := '<div' mess+ '>'|'<div>';
        pattern optag := fmttag | divtag;
        pattern fmtend := '</span>';
        pattern divend := '</div>';
        pattern endtag := fmtend | divend;
        pattern txtblk := (ANY NOT IN ['<','>',divtag,divend,fmttag,fmtend])+;
        pattern fmtpat := fmttag txtblk fmtend;
        rule txtblock  := fmtpat;

        outrec := RECORD
            //STRING text := MATCHTEXT(blkpat/fmtpat/txtblk);
            STRING text := MATCHTEXT(fmtpat/txtblk);
            //STRING text := MATCHTEXT(txtblk)
        END;

        casheqparse := PARSE(F,content,txtblock,outrec,SCAN ALL);
        RETURN casheqparse;
    END;

    EXPORT rec2 := RECORD
        STRING text;
    END;
    
    EXPORT STRING Concat(DATASET(rec2) File,STRING kDelimiter = ' ') := FUNCTION
        StringRec := RECORD
            STRING   text;
        END;
        StringRec MakeStringRec(StringRec l, StringRec r, STRING sep) := TRANSFORM
            SELF.text := l.text + IF(l.text != '',sep,'') + r.text;
        END;
        txtconcat := ROLLUP(File,TRUE,MakeStringRec(LEFT,RIGHT,kDelimiter));
        RETURN txtconcat[1].text;
    END;

    EXPORT concatlblrec := RECORD
        STRING text;
        STRING label;
    END;
    
    EXPORT concatlblrec lblConcat(DATASET(concatlblrec) File,STRING kDelimiter = ' ') := FUNCTION
        sortFile := SORT(File,File.label);
        grplbl   := GROUP(sortFile,label);

        concatlblrec lblconcat_grp(concatlblrec l,DATASET(concatlblrec) allRows) := TRANSFORM
            SELF.text := Concat(TABLE(allRows,{STRING text := allRows.text}),kDelimiter);
            SELF.label:= l.label;
        END;

        grplbltxtconcat := ROLLUP(grplbl,GROUP,lblconcat_grp(LEFT,ROWS(LEFT)));
        
        RETURN grplbltxtconcat;
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
            //SELF.filingType       := lr.filingType;
            SELF.reportPeriod     := lr.reportPeriod;
            //SELF.name             := lr.name;
            //SELF.is_smallbiz      := lr.is_smallbiz;
            SELF.pubfloat         := lr.pubfloat;
            //SELF.comsharesout     := lr.comsharesout;
            SELF.wellknown        := lr.wellknown;
            //SELF.shell            := lr.shell;
            SELF.centralidxkey    := lr.centralidxkey;
            SELF.amendflag        := lr.amendflag;
            //SELF.filercat         := lr.filercat;
            SELF.fyfocus          := lr.fyfocus;
            SELF.fpfocus          := lr.fpfocus;
            //SELF.emerging         := lr.emerging;
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

    EXPORT label_rec := RECORD
        STRING  fileName;
        UNICODE accessionNumber;
        //UNICODE name;
        //UNICODE filingType;
        UNICODE filingDate;
        UNICODE reportPeriod;
        //UNICODE is_smallbiz;
        UNICODE pubfloat;
        UNICODE wellknown;
        //UNICODE shell;
        UNICODE centralidxkey;
        UNICODE amendflag;
        //UNICODE filercat;
        UNICODE fyfocus;
        UNICODE fpfocus;
        //UNICODE emerging;
        UNICODE volfilers;
        UNICODE currentstat;
        UNICODE fyend;
        STRING  label;
        DATASET(Extract_Layout_modified.Entry_clean) values;
    END;    

    EXPORT label_rec label_filings(DATASET(Extract_Layout_modified.Main) extractedFiles) := FUNCTION
        grablabel(STRING fname) := FUNCTION
            splitname := STD.Str.SplitWords(fname,'_',FALSE);
            label_withxml := splitname[4];
            lwx_splitondot := STD.Str.SplitWords(label_withxml,'.',FALSE);
            label := lwx_splitondot[1];
            RETURN label;
        END;    

        label_rec addlabelfield(Extract_Layout_modified.Main f):= TRANSFORM
            SELF.fileName := f.fileName;
            SELF.accessionNumber := f.accessionNumber;
            //SELF.name := f.name;
            //SELF.filingType := f.filingType;
            SELF.filingDate := f.filingDate;
            SELF.reportPeriod := f.reportPeriod;
            //SELF.is_smallbiz := f.is_smallbiz;
            SELF.pubfloat := f.pubfloat;
            SELF.wellknown := f.wellknown;
            //SELF.shell := f.shell;
            SELF.centralidxkey := f.centralidxkey;
            SELF.amendflag := f.amendflag;
            //SELF.filercat := f.filercat;
            SELF.fyfocus := f.fyfocus;
            SELF.fpfocus := f.fpfocus;
            //SELF.emerging := f.emerging;
            SELF.volfilers := f.volfilers;
            SELF.currentstat := f.currentstat;
            SELF.fyend := f.fyend;
            SELF.label := grablabel(f.fileName);
            SELF.values := f.values;
        END;

        out := PROJECT(extractedFiles,addlabelfield(LEFT));

        RETURN out;
    END;
    
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

    EXPORT sep_sents_lbl(DATASET(concatlblrec) cr) := FUNCTION
        pattern endpunct := ['.','?','!'];
        pattern ws       := ' ';
        pattern mess     := PATTERN('[A-Z]') (ANY NOT IN endpunct)+;
        pattern sentence := mess endpunct ;
        pattern begsent  := '[OPN]' sentence ws PATTERN('[A-Z]') OPT('[CLS]');
        pattern midsent  := endpunct ws sentence ws PATTERN('[A-Z]');
        pattern endsent  := OPT('[OPN]') OPT(endpunct ws) sentence '[CLS]';
        rule    nicesent := begsent|midsent|endsent;
               
        lblOutrec := RECORD
          UNSIGNED8 ones;
          UNSIGNED8 sentId;
          STRING sentence;
          STRING label;
        END;

        lblOutrec lblParseT(RECORDOF(cr) f) := TRANSFORM
            SELF.ones := 1;
            SELF.sentId:= 0;
            SELF.sentence:= MATCHTEXT(nicesent/sentence);
            SELF.label := f.label;
        END;

        lblSentparse := PARSE(cr,text,nicesent,lblParseT(LEFT),SCAN);

        lblOutrec lblConsec(lblOutrec L,lblOutrec R) := TRANSFORM
          SELF.sentId := L.sentId + R.ones;
          SELF := R;
        END;

        lblSentlist := ITERATE(lblSentparse,lblConsec(LEFT,RIGHT));

        lblFinalrec := RECORD
          UNSIGNED8 sentId := lblSentlist.sentId;
          STRING text := lblSentlist.sentence;
          STRING label := lblSentlist.label;
        END;

        RETURN TABLE(lblSentlist,lblFinalrec);
    END;

    //FIXME: We want money descriptions, not just money!
    EXPORT MoneyTable(STRING text) := FUNCTION
    //EXPORT MoneyTable(UNICODE16 text) := FUNCTION

        dagds := DATASET(WORKUNIT('W20200612-024132','Result 1'),{STRING dagger});
        dagdag := dagds[1].dagger[1];


        pattern num := PATTERN('[0-9]');
        pattern alpha := PATTERN('[a-zA-Z]');
        pattern fullplc := num*3;
        pattern moncomma := ','|' ';
        pattern dollartag := ' $'|' $ '|' ';
        pattern ender := '.'|'!'|'?';
        //pattern money := dollartag num OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc) | '$' num num OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc) | '$' num num num OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc) OPT(moncomma) OPT(fullplc);
        pattern hundreds := dollartag num OPT(num) OPT(num);
        pattern thousnds := hundreds moncomma fullplc;
        pattern millions := hundreds moncomma fullplc moncomma fullplc;
        pattern billions := hundreds moncomma fullplc moncomma fullplc moncomma fullplc;
        pattern money := hundreds ' ' | thousnds ' ' | millions ' ' | billions ' ';
        pattern obelus := u'\u2020'|'  ';
        //pattern obelus := '†';
        //pattern obelus := U'†'|U'&dagger;'|U'&#8224;'|U'&#134;'|U'&#x86;'|dagdag;//'';
        pattern celldescr := (ANY NOT IN [obelus,money,ender])+;
        pattern year := num*4;
        //pattern celldescr := (ANY NOT IN ['$',num,','])+ | year;
        //pattern cell := celldescr obelus money | celldescr money;
        pattern cell := celldescr money;
        //pattern tabrow := obelus celldescr obelus cell OPT(cell+) | obelus+ cell obelus+;
        pattern cell2 := cell;
        //pattern cells := OPT(cell2)+ cell OPT(cell2)+;
        pattern cellZ := celldescr cell;
        pattern infotbl := ender cellZ ' ';//celldescr cell ' ';
        //pattern tblrow := celldescr obelus money;
        //pattern tblrow := money obelus;
        //pattern tblrow := obelus money;
        //pattern tblrow := obelus alpha+ obelus;
        
        //rule moneytable := tblrow;
        //rule moneytable := celldescr
        //rule moneytable := obelus cell obelus;
        //rule moneytable := tabrow;
        //rule moneytable := money;
        rule moneytable := cell;
        //rule moneytable := ' ' money;
        //rule moneytable := obelus;
        //rule moneytable := infotbl;

        outrec := RECORD
            //STRING cell := MATCHTEXT(infotbl/cellZ);
            //STRING cell := MATCHTEXT(infotbl/cells/cell);
            //UNICODE16 cell := MATCHUNICODE(obelus);
            //STRING cell := MATCHTEXT(obelus);
            //STRING cell := MATCHTEXT(cell);
            //STRING cell := MATCHTEXT(money);
            //STRING cell := MATCHTEXT(tabrow/cell);
            //STRING cell := MATCHTEXT(tblrow);
            //UNICODE16 cell := MATCHUNICODE(tblrow);
            //STRING cell := MATCHTEXT(tabrow);
            STRING descr := MATCHTEXT(cell/celldescr);
            STRING money := MATCHTEXT(cell/money);
        END;

        rec1 := {STRING content};
        //rec1 := {UNICODE16 content};
        T := DATASET([{text}],rec1);

        out := PARSE(T,content,moneytable,outrec,SCAN);

        RETURN out;
    END;
END;