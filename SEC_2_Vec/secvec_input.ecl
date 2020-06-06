IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;

EXPORT secvec_input(STRING inpath) := FUNCTION
    ds   := XBRL_HTML_File(inpath);
    //WORKING ON A VERSION WITH LABELS: hasn't been submitted yet
    //ds := label_filings(XBRL_HTML_File(inpath));
    //
    //apply labels to each values line for use in ML later
    //Entry_wlabel := RECORD
    //  UNICODE element;
    //  UNICODE contextRef;
    //  UNICODE unitRef;
    //  UNICODE decimals;
    //  STRING content;
    //  STRING label;
    //END;
    //
    //Entry_wlabel augment_entry(RECORDOF(ds) bigrow,Extract_Layout_modified.Entry_clean row) := TRANSFORM
    //  SELF.element := row.element;
    //  SELF.contextRef := row.contextRef;
    //  SELF.unitRef := row.unitRef;
    //  SELF.decimals := row.decimals;
    //  SELF.content := row.content;
    //  SELF.label := bigrow.label;
    //END;
    //
    //final_label_rec := RECORD
    //  STRING fileName;
    //  UNICODE accessionNumber;
    //  UNICODE     name;
    //  UNICODE     filingType;
    //  UNICODE     filingDate;
    //  UNICODE     reportPeriod;
    //  UNICODE     is_smallbiz;
    //  UNICODE     pubfloat;
    ////UNICODE     comsharesout;
    //  UNICODE     wellknown;
    //  UNICODE     shell;
    //  UNICODE     centralidxkey;
    //  UNICODE     amendflag;
    //  UNICODE     filercat;
    //  UNICODE     fyfocus;
    //  UNICODE     fpfocus;
    //  UNICODE     emerging;
    ////UNICODE     ticker;
    //  UNICODE     volfilers;
    //  UNICODE     currentstat;
    //  UNICODE     fyend;
    //  DATASET(Entry_wlabel) values;
    //END;
    //
    //final_label_rec apply_augment(RECORDOF(ds) f) := TRANSFORM
    //  SELF.fileName := f.fileName;
    //  SELF.accessionNumber := f.accessionNumber;
    //  SELF.name := f.name;
    //  SELF.filingType := f.filingType;
    //  SELF.filingDate := f.filingDate;
    //  SELF.reportPeriod := f.reportPeriod;
    //  SELF.is_smallbiz := f.is_smallbiz;
    //  SELF.pubfloat := f.pubfloat;
    //  SELF.wellknown := f.wellknown;
    //  SELF.shell := f.shell;
    //  SELF.centralidxkey := f.centralidxkey;
    //  SELF.amendflag := f.amendflag;
    //  SELF.filercat := f.filercat;
    //  SELF.fyfocus := f.fyfocus;
    //  SELF.fpfocus := f.fpfocus;
    //  SELF.emerging := f.emerging;
    //  SELF.volfilers := f.volfilers;
    //  SELF.currentstat := f.currentstat;
    //  SELF.fyend := f.fyend;
    //  SELF.values := PROJECT(f.values,augment_entry(f,LEFT));
    //END;
    //
    //labelds := PROJECT(ds,apply_augment(LEFT));



    textblocks(UNICODE el) := el IN [
        'us-gaap:QuarterlyFinancialInformationTextBlock',
        'us-gaap:AdditionalFinancialInformationTextBlock',
        'us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock',
        'us-gaap:CommitmentsAndContingenciesDisclosureTextBlock',
        'us-gaap:CashAndCashEquivalentsPolicyTextBlock'
    ];

    tb := ds.values(textblocks(element));

    //adding code for labelds
    //tb := labelds.values(textblocks(element));
    //
    //outrec := RECORD
    //  STRING text := tb.content;
    //  STRING label := tb.label;
    //END;
    //
    //

    outrec := RECORD
        STRING text := tb.content;
    END;

    //testtextvec_input_lbl := sep_sents_lbl(lblConcat(TABLE(tb,outrec)));
    testtextvec_input := sep_sents(Concat(TABLE(tb,outrec)));
    
    //RETURN testtextvec_input_lbl;
    RETURN testtextvec_input;
END;