IMPORT * FROM EDGAR_Extract;

// This is done as a module for symmetry with Classic EDGAR Extraction
EXPORT XBRL_Extract_modified := MODULE
  ds(STRING fileName) := Raw_Input_Files.Files(fileName);//, TRUE);   // strip prefix

  Extract_Layout_modified.Entry_clean getEntry(UNICODE element) := TRANSFORM
    SELF.element    := element;
    SELF.contextRef := XMLUNICODE('@contextRef');
    SELF.unitRef    := XMLUNICODE('@unitRef');
    SELF.decimals   := XMLUNICODE('@decimals');
    SELF.content    := (STRING)XMLUNICODE('');
  END;
  
  Extract_Layout_modified.Main cvt(RECORDOF(ds) lr) := TRANSFORM
    SELF.fileName         := lr.fileName;
    //SELF.filingType       := XMLUNICODE('dei:DocumentType');
    //SELF.reportPeriod     := XMLUNICODE('dei:DocumentPeriodEndDate');
    //SELF.name             := XMLUNICODE('dei:EntityRegistrantName');
    //SELF.is_smallbiz      := XMLUNICODE('dei:EntitySmallBusiness');
    SELF.pubfloat         := XMLUNICODE('dei:EntityPublicFloat');
    //SELF.comsharesout     := XMLUNICODE('dei:EntityCommonStockSharesOutstanding');
    SELF.wellknown        := XMLUNICODE('dei:EntityWellKnownSeasonedIssuer');
    //SELF.shell            := XMLUNICODE('dei:EntityShellCompany');
    //SELF.centralidxkey    := XMLUNICODE('dei:EntityCentralIndexKey');
    //SELF.amendflag        := XMLUNICODE('dei:AmendmentFlag');
    //SELF.filercat         := XMLUNICODE('dei:EntityFilerCategory');
    //SELF.fyfocus          := XMLUNICODE('dei:DocumentFiscalYearFocus');
    //SELF.fpfocus          := XMLUNICODE('dei:DocumentFiscalPeriodFocus');
    //SELF.emerging         := XMLUNICODE('dei:EntityEmergingGrowthCompany');
    //SELF.ticker           := XMLUNICODE('dei:TradingSymbol');
    SELF.volfilers        := XMLUNICODE('dei:EntityVoluntaryFilers');
    //SELF.currentstat      := XMLUNICODE('dei:EntityCurrentReportingStatus');
    //SELF.fyend            := XMLUNICODE('dei:CurrentFiscalYearEndDate');
    SELF.filingDate       := 'N/A';    // only classic EDGAR
    SELF.accessionNumber  := 'N/A';    // only classic EDGAR
    SELF.values           := XMLPROJECT('us-gaap:NetIncomeLoss', getEntry('us-gaap:NetIncomeLoss'))
                           + XMLPROJECT('us-gaap:SalesRevenueNet', getEntry('us-gaap:SalesRevenueNet'))
                           + XMLPROJECT('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFirstAnniversary', getEntry('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFirstAnniversary'))
                           + XMLPROJECT('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFifthAnniversary', getEntry('us-gaap:UnrecordedUnconditionalPurchaseObligationBalanceOnFifthAnniversary'))
                           + XMLPROJECT('us-gaap:QuarterlyFinancialInformationTextBlock', getEntry('us-gaap:QuarterlyFinancialInformationTextBlock'))
                           + XMLPROJECT('us-gaap:AdditionalFinancialInformationTextBlock', getEntry('us-gaap:AdditionalFinancialInformationTextBlock'))
                           + XMLPROJECT('us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock', getEntry('us-gaap:BasisOfPresentationAndSignificantAccountingPoliciesTextBlock'))
                           + XMLPROJECT('us-gaap:CommitmentsAndContingenciesDisclosureTextBlock', getEntry('us-gaap:CommitmentsAndContingenciesDisclosureTextBlock'))
                           + XMLPROJECT('us-gaap:CashAndCashEquivalentsPolicyTextBlock', getEntry('us-gaap:CashAndCashEquivalentsPolicyTextBlock'));
  END;

  EXPORT File(STRING fileName) := PARSE(ds(fileName), text, cvt(LEFT), XML('xbrl'));
END;