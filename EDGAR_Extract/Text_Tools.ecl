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
    //EXPORT MoneyTable(UNICODE16 text) := FUNCTION
    EXPORT MoneyTable(STRING text) := FUNCTION

        pattern num := PATTERN('[0-9]');
        pattern alpha := PATTERN('[a-zA-Z]');
        pattern lowcs := PATTERN('[a-z]');
        pattern upcs := PATTERN('[A-Z]');
        pattern acron := upcs+;
        pattern propwrd := upcs lowcs+;
        pattern normwrd := lowcs+;
        //pattern punct := ','|'('|')'|']'|'['|'-'|'\''|'"'|'/';
        pattern punct := '('|')';
        pattern ender := '.'|'!'|'?'|':';
        pattern year := num*4;
        pattern datepat := propwrd ' ' num* OPT(',') OPT(' ') year;
        //pattern descriptors := propwrd|acron|punct|year|datepat|' ';
        pattern descriptors := propwrd|'of'|acron|punct|year|' '|'(' normwrd|normwrd ')';
        notrule(STRING txt) := txt!='Rule';
        pattern desc := VALIDATE(descriptors,notrule(MATCHTEXT));

        pattern fullplc := num*3;
        pattern moncomma := ','|' ';
        pattern dollartag := ' $'|' $ '|' ';
        pattern hundreds := dollartag num OPT(num) OPT(num);
        pattern thousnds := hundreds moncomma fullplc;
        pattern millions := hundreds moncomma fullplc moncomma fullplc;
        pattern billions := hundreds moncomma fullplc moncomma fullplc moncomma fullplc;
        isint(STRING txt) := txt IN ['0','1','2','3','4','5','6','7','8','9','$'];
        notsingle(STRING txt) := NOT ((LENGTH(txt)=3) AND isint(TRIM(txt)[2]) AND NOT isint(txt[1]));
        notdouble(STRING txt) := NOT ((LENGTH(txt)=4) AND isint(TRIM(txt)[2]) AND isint(TRIM(txt)[3]) AND NOT isint(txt[1]));
        realmoney(STRING txt) := notsingle(txt) AND notdouble(txt);
        pattern origmoney := hundreds ' ' | thousnds ' ' | millions ' ' | billions ' ';
        pattern money := VALIDATE(origmoney,realmoney(MATCHTEXT));

        //pattern wildcard := ANY NOT IN [ender,':',money,descriptors,alpha,num,punct,'$'];
        pattern wildcard := ANY NOT IN [num,alpha,ender,punct,'[',']','}','{',' '];

        //pattern obelus := wildcard;
        pattern obelus := u'\u2020';//|'  ';
        //pattern obelus := '~';
        //pattern obelus := u'\u2020'|u'\uFFF9'|u'\uFFFA'|u'\uFFFB'|u'\uFFFC'|u'\uFFFD'|u'\uFFFE'|u'\uFFFF';
        //pattern obelus := u'\uFFF9'|u'\uFFFB';
        //pattern obelus := u'\uFFFD';
        //pattern obelus := u'\ue280a0';

        //pattern celldescr := (ANY NOT IN [money,ender,' Rule'])+;
        pattern celldescr := desc+;//descriptors+;
        //pattern cell := celldescr ' ' money;
        pattern topcell := wildcard celldescr wildcard*;
        pattern nrmcell := celldescr wildcard money;
        pattern cell := topcell | nrmcell;
        //pattern cell := celldescr wildcard money | wildcard celldescr wildcard;
        pattern tabrow := wildcard cell;
        pattern tblstart := wildcard|ender;
        pattern tabl := tblstart celldescr tabrow* wildcard;
        //pattern cell := celldescr OPT(PATTERN('[*]')) OPT(obelus) money;
        //pattern cell := celldescr obelus money;
        //pattern cell := celldescr '~' money;
        //pattern cell := celldescr wildcard money;

        rule moneytable := money;
        rule celltable := cell;
        rule daggtable := obelus;
        rule infotbl := tabl;

        outrec_money := RECORD
            STRING money := MATCHTEXT(money);
        END;

        outrec_cell := RECORD
            STRING descr := MATCHTEXT(cell/celldescr);
            STRING money := IF(MATCHED(nrmcell),MATCHTEXT(cell/money),'');
            //STRING descr := MATCHUNICODE(cell/celldescr);
            //STRING money := MATCHUNICODE(cell/money);
        END;
        
        outrec_tbl := RECORD
            STRING tbl_title := MATCHTEXT(tabl/celldescr);
            STRING descr := MATCHTEXT(tabl/tabrow/cell/celldescr);
            STRING money := MATCHTEXT(tabl/tabrow/cell/money);
            //STRING row := MATCHTEXT(tabl/tabrow);
        END;

        outrec_dagg := RECORD
            STRING dagg := MATCHTEXT(obelus);
            //UNICODE16 dagg := MATCHUNICODE(obelus);
        END;

        //rec1 := {UNICODE16 content};
        rec1 := {STRING content};
        T := DATASET([{text}],rec1);

        //out := PARSE(T,content,moneytable,outrec_money,SCAN);
        out := PARSE(T,content,celltable,outrec_cell,SCAN);
        //out := PARSE(T,content,daggtable,outrec_dagg,SCAN);
        //out := PARSE(T,content,infotbl,outrec_tbl,SCAN);

        //RETURN out;
        // descr_cond(STRING txt) := FUNCTION
        //     splitup := STD.Str.SplitWords(txt,' ',FALSE);
        //     lowers := ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
        //     RETURN (NOT (COUNT(splitup)=1 AND ((txt[1] IN lowers) OR LENGTH(splitup[1])=1))) AND (txt != '');
        // END;
        //dcond1(STRING txt) := (txt[1] NOT IN ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ']) AND (txt[2] IN ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']);
        //dcond1(STRING txt) := (LENGTH(txt) > 1) AND (txt[1] NOT IN lowers+uppers+ws) AND (txt[2] NOT IN lowers);
        //dcond2(STRING txt) := ((' ' NOT IN STD.Str.SplitWords(txt,'',FALSE)) AND (LENGTH(txt) < 3)) AND (txt[1] IN ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
        //dcond2(STRING txt) := LENGTH(txt) < 3 AND (txt[1] IN ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']);
        //dcond(STRING txt) := dcond1(txt) and dcond2(txt);
        //RETURN out(dcond2(descr));// OR money!='');
        //firstishidden(STRING txt) := txt[1] NOT IN ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' '];
        
        islower(STRING txt) := txt IN ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
        isuselessupper(STRING txt) := FUNCTION
        //(LENGTH(txt) < 3) AND CHOOSE(LENGTH(txt),(txt[1] IN ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']),(txt[1] IN ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']) AND (txt[2] IN ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']));
            trimmed := TRIM(txt,LEFT,RIGHT);
            RETURN (LENGTH(trimmed) < 3) AND (STD.Str.ToUpperCase(trimmed) = trimmed);
        END;
        //RETURN out((descr!='' OR money!='') AND (NOT firstishidden(descr)));
        //RETURN out((descr!='' OR money!='') AND (NOT islower(TRIM(descr,LEFT,RIGHT)[1])));
        RETURN out;
        // fix1 := out((descr!='' OR money!='') AND IF(money='',((NOT islower(TRIM(descr,LEFT,RIGHT)[1])) AND (NOT isuselessupper(descr))),TRUE));

        // //RETURN fix1;
        // isyear(STRING txt) := FUNCTION
        //     trimmed := TRIM(txt,LEFT,RIGHT);
        //     l4 := LENGTH(trimmed) = 4;
        //     nums := ['0','1','2','3','4','5','6','7','8','9'];
        //     isyr := (trimmed[1] in nums) AND (trimmed[2] in nums) AND (trimmed[3] in nums) AND (trimmed[4] in nums);
        //     RETURN IF(l4,isyr,FALSE);
        // END;

        // // isuselessyear(STRING dtxt,STRING mtxt) := FUNCTION
        // //     trimmed := TRIM(dtxt,LEFT,RIGHT);
        // //     RETURN IF(isyear(trimmed),TRIM(mtxt,LEFT,RIGHT)!='',FALSE);
        // // END;

        // isemptymon(STRING txt) := FUNCTION
        //     trimmed := TRIM(txt,LEFT,RIGHT);
        //     RETURN trimmed = '';
        // END;

        // fix2 := fix1(NOT (isyear(descr) AND isemptymon(money)));
        // //fix2 := fix1(NOT (isyear(descr)));// AND money=''));

        // RETURN fix2;
    END;
END;