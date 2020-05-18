IMPORT * FROM EDGAR_Extract;

EXPORT Text_Tools := MODULE

    EXPORT CashParse(UNICODE File) := FUNCTION

        rec1 := {UNICODE content};
        F := DATASET([{File}],rec1);

        pattern mess   := ANY NOT IN ['<','>'];
        pattern fmttag := '<' mess+ '>';
        pattern fmtend := '</' mess+ '>';
        pattern divtag := '<div ' mess+ '>';
        pattern spntag := '<span ' mess+ '>';
        pattern divend := '</div>';
        pattern spnend := '</span>';
        pattern txtblk := (ANY NOT IN ['<','>'])+;
        pattern blktop := txtblk;
        pattern divpat := divtag spntag txtblk spnend divend;
        pattern fmtpat := OPT(fmttag) OPT(fmttag) OPT(fmttag) OPT(fmttag) txtblk OPT(fmtend) OPT(fmtend) OPT(fmtend) OPT(fmtend);
        rule txtblock  := fmtpat;//divpat;

        outrec := RECORD
            STRING text := MATCHTEXT(fmtpat/txtblk);//MATCHTEXT(divpat/txtblk);
        END;

        casheqparse := PARSE(F,content,txtblock,outrec,SCAN ALL);
        RETURN casheqparse;
    END;
    rec2 := RECORD
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
    EXPORT FixTextBlock(DATASET(Extract_Layout_modified.Entry) ent) := FUNCTION
      
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
        
        Extract_Layout_modified.Entry fixHTML(Extract_Layout_modified.Entry lr) := TRANSFORM
            SELF.element    := lr.element;
            SELF.contextRef := lr.contextRef;
            SELF.unitRef    := lr.unitRef;
            SELF.decimals   := lr.decimals;
            SELF.content    := IF(lr.element IN //['us-gaap:CashAndCashEquivalentsPolicyTextBlock',
                                                //'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
                                                ['us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock'],
                                                //'us-gaap:AdditionalFinancialInformationTextBlock'],
                                                //'us-gaap:QuarterlyFinancialInformationTextBlock'],
                                    Concat(CashParse(lr.content)),
                                    lr.content);
            //SELF.content    := IF(lr.element = 'us-gaap:CashAndCashEquivalentsPolicyTextBlock',Concat(CashParse(lr.content)),lr.content);
        END;

        RECORDOF(File) cvthtml(RECORDOF(File) lr) := TRANSFORM
            SELF.fileName         := lr.fileName;
            SELF.filingType       := lr.filingType;
            SELF.reportPeriod     := lr.reportPeriod;
            SELF.name             := lr.name;
            SELF.is_smallbiz      := lr.is_smallbiz;
            SELF.pubfloat         := lr.pubfloat;
            SELF.comsharesout     := lr.comsharesout;
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
    
END;