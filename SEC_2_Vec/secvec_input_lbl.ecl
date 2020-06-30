IMPORT STD;
IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
mainrec := EDGAR_Extract.Extract_Layout_modified.Main;


EXPORT secvec_input_lbl(STRING inpath,BOOLEAN prelabeled=TRUE,STRING comparedto='plain') := FUNCTION
    start := XBRL_HTML_File(inpath);
    
    compjoin(DATASET(RECORDOF(start)) st) := FUNCTION
      //path := '~ncf::edgarfilings::supp::labelguide_sp_medium::labelguide.csv';
      //path := '~ncf::edgarfilings::raw::labels_allsecs_all';
      path := '~ncf::edgarfilings::supp::labelguide_full';
      csvrec := RECORD
        STRING plainname;
        STRING spname;
      END;
      draw := DATASET(path,csvrec,CSV(HEADING(1)));
      // RECORDOF(start) j_T(RECORDOF(start) st,RECORDOF(ds) d) := TRANSFORM
      //   SELF.filename := d.spname;
      //   SELF.accessionNumber := st.accessionNumber;
      //   SELF.filingDate := st.filingDate;
      //   SELF.pubfloat := st.pubfloat;
      //   SELF.wellknown := st.wellknown;
      //   SELF.volfilers := st.volfilers;
      //   SELF.values := st.values;
      // END;
      cj := JOIN(st,draw,LEFT.filename = RIGHT.plainname,TRANSFORM(RECORDOF(st),SELF.filename:=RIGHT.spname,SELF:=LEFT));
      RETURN cj;
    END;
    
    plain := IF(comparedto='plain',start,compjoin(start));

    STRING addfakelabels(STRING inName,STRING strlbl) := FUNCTION
        splitname := STD.Str.SplitWords(inName, '_', FALSE);
        ftwx_fakelabel := '10q_'+strlbl+'.xml';
        newname := splitname[1]+'_'+splitname[2]+'_'+ftwx_fakelabel;
        RETURN newname;
    END;

    Extract_Layout_modified.Main lblT(Extract_Layout_modified.Main r,INTEGER C) := TRANSFORM
        cntx := C%2;
        fakelabel := (STRING) cntx;
        SELF.fileName := addfakelabels(r.fileName,fakelabel);
        SELF.accessionNumber := r.accessionNumber;
        //SELF.name := r.name;
        //SELF.filingType := r.filingType;
        SELF.filingDate := r.filingDate;
        //SELF.reportPeriod := r.reportPeriod;
        //SELF.is_smallbiz := r.is_smallbiz;
        SELF.pubfloat := r.pubfloat;
        SELF.wellknown := r.wellknown;
        //SELF.shell := r.shell;
        //SELF.centralidxkey := r.centralidxkey;
        //SELF.amendflag := r.amendflag;
        //SELF.filercat := r.filercat;
        //SELF.fyfocus := r.fyfocus;
        //SELF.fpfocus := r.fpfocus;
        //SELF.emerging := r.emerging;
        SELF.volfilers := r.volfilers;
        //SELF.currentstat := r.currentstat;
        //SELF.fyend := r.fyend;
        SELF.values := r.values;    
    END;
    
    ds := IF(prelabeled,label_filings(plain),label_filings(PROJECT(plain,lblT(LEFT,COUNTER))));

    Entry_wlabel := RECORD
      UNICODE element;
      UNICODE contextRef;
      UNICODE unitRef;
      UNICODE decimals;
      STRING content;
      STRING label;
    END;

    Entry_wlabel augment_entry(label_rec bigrow,Extract_Layout_modified.Entry_clean r) := TRANSFORM
      SELF.element := r.element;
      SELF.contextRef := r.contextRef;
      SELF.unitRef := r.unitRef;
      SELF.decimals := r.decimals;
      SELF.content := r.content;
      SELF.label := bigrow.label;
    END;

    final_label_rec := RECORD
      STRING fileName;
      UNICODE accessionNumber;
      //UNICODE     name;
      //UNICODE     filingType;
      UNICODE     filingDate;
      //UNICODE     reportPeriod;
      //UNICODE     is_smallbiz;
      UNICODE     pubfloat;
    //UNICODE     comsharesout;
      UNICODE     wellknown;
      //UNICODE     shell;
      //UNICODE     centralidxkey;
      //UNICODE     amendflag;
      //UNICODE     filercat;
      //UNICODE     fyfocus;
      //UNICODE     fpfocus;
      //UNICODE     emerging;
    //UNICODE     ticker;
      UNICODE     volfilers;
      //UNICODE     currentstat;
      //UNICODE     fyend;
      DATASET(Entry_wlabel) values;
    END;

    final_label_rec apply_augment(RECORDOF(ds) f) := TRANSFORM
      SELF.fileName := f.fileName;
      SELF.accessionNumber := f.accessionNumber;
      //SELF.name := f.name;
      //SELF.filingType := f.filingType;
      SELF.filingDate := f.filingDate;
      //SELF.reportPeriod := f.reportPeriod;
      //SELF.is_smallbiz := f.is_smallbiz;
      SELF.pubfloat := f.pubfloat;
      SELF.wellknown := f.wellknown;
      //SELF.shell := f.shell;
      //SELF.centralidxkey := f.centralidxkey;
      //SELF.amendflag := f.amendflag;
      //SELF.filercat := f.filercat;
      //SELF.fyfocus := f.fyfocus;
      //SELF.fpfocus := f.fpfocus;
      //SELF.emerging := f.emerging;
      SELF.volfilers := f.volfilers;
      //SELF.currentstat := f.currentstat;
      //SELF.fyend := f.fyend;
      SELF.values := PROJECT(f.values,augment_entry(f,LEFT));
    END;

    labelds := PROJECT(ds,apply_augment(LEFT));

    textblocks(UNICODE el) := el IN [
        'us-gaap:QuarterlyFinancialInformationTextBlock',
        'us-gaap:AdditionalFinancialInformationTextBlock',
        'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
        'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
        'us-gaap:CashAndCashEquivalentsPolicyTextBlock'
    ];

    tb := labelds.values(textblocks(element));

    outrec := RECORD
      STRING text := tb.content;
      STRING label := tb.label;
    END;

    testtextvec_input_lbl := sep_sents_lbl(lblConcat(TABLE(tb,outrec)));
    

    RETURN testtextvec_input_lbl;
END;