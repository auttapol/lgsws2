public class CustomerProductHoldingsCtrl extends OscControllerBase {
    /*----------------------------------------------------------------------------------
  Author:        Keattisak Chinburarat
  Company:       I&I Consulting 
  Description:   Controller of CustomerProductHoldingsView.page
  Inputs:        
  1. rmid is equal to crmid in crmdb
  Base Class:    -
  Test Class:    TestCustomerProductHoldingsCtrl.cls
  History
  <Date>      <Authors Name>     <Brief Description of Change>
  2016-04-18   Keattisak.C        First Draft
  2016-06-15   Kanlaya.A  Change to use SEQ_GRP__c to group product instead of Product Sub Group
  ----------------------------------------------------------------------------------*/

    private String rmid; /* crmid  */
    public string acctId; /* account id   */
    public string cname; /* name  */
    private String requestBody = '';

    public Account acct{get;set;} /*standard account*/
    public ViewState ViewState { get; set; }
    private AsyncRTL_CustomerProductHoldingsService.getProductHoldingsResponse_elementFuture asyncRet;
    
    
    private static final string SECTION_CUST_HOLD_LOW = 'RtlCust:Customer Product Holding (Low)';
    private static final string SECTION_CUST_HOLD_MID = 'RtlCust:Customer Product Holding (Medium)';
    private static final string SECTION_CUST_HOLD_HIG = 'RtlCust:Customer Product Holding (High)';
    
    public Boolean isAccessibleCusHoldLow {get;set;}
    public Boolean isAccessibleCusHoldMid {get;set;}
    public Boolean isAccessibleCusHoldHig {get;set;}
    
    //public Boolean isAccessibleGeneral {get;set;}
    //public Boolean isAccessibleSensitive {get;set;}
    
    private Account acctDetail;
    private Profile userProfile;
    private RTL_CustomerProductHoldingsService.CustomerProductHoldings soapCustomerProductHoldings;
    private ProductHoldingDTO item;
    private String reqId = '';
    private Datetime startReq;

    public CustomerProductHoldingsCtrl() {
        params = ApexPages.currentPage().getParameters();
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        ViewState = new ViewState();
        getAccountName(acctId);

        // Get Retail Product Master
        //ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

        acctDetail = new Account();
        userProfile = new Profile();

        userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                
		//isAccessibleGeneral = RTL_AccountUtility.verifyFieldSecurity('general section',userProfile.name,acct.id );
        //isAccessibleSensitive = RTL_AccountUtility.verifyFieldSecurity('sensitive section',userProfile.name,acct.id);
        
        isAccessibleCusHoldLow = RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_LOW,userProfile.name,acct.id );
        isAccessibleCusHoldMid = RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_MID,userProfile.name,acct.id );
        isAccessibleCusHoldHig = RTL_AccountUtility.verifyFieldSecurity(SECTION_CUST_HOLD_HIG,userProfile.name,acct.id );
        
    }
        
    private void getAccountName(string acctId) {

        //List<Account> accs = AccountSelector.getAccountByIds(new set<Id> { acctId });
        acct = RetailAccountService.GetAccountById(acctId);
        if (null != acct)
        {
            cname = acct.Name;
            rmid = acct.TMB_Customer_ID_PE__c;// Should be TMB_Cust_Id__c
            ViewState.rmid = rmid;
            ViewState.isEmployee = acct.RTL_Is_Employee__c;
        }
    }
    public string getAccId() {
        return acctId;
    }
    public string getRMID() {
        return rmid;
    }
    public string getCustomerName() {
        return cname;
    }
    public Boolean getIsEmployee(){
        return acct.RTL_Is_Employee__c;
    }
    public override void CallSOAP(Continuation cont) {
        startReq = Datetime.now();
        cont.continuationMethod = 'processResponseSOAP';
        AsyncRTL_CustomerProductHoldingsService.AsyncCustomerProductHoldingsSOAP asynSvr = new AsyncRTL_CustomerProductHoldingsService.AsyncCustomerProductHoldingsSOAP();
        //asyncRet = asynSvr.beginGetProductHoldings(cont,/*CustomerRMID '00000000051187' */rmid ); // fix
        asyncRet = asynSvr.beginGetProductHoldings(cont, rmid); // fix
    }
    public Object processResponseSOAP() {
        //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017
        
        
        
        try
        {
            RTL_CustomerProductHoldingsService.getProductHoldings_element requestProductHolding = new RTL_CustomerProductHoldingsService.getProductHoldings_element();
            requestProductHolding.CustomerRMID = acct.TMB_Customer_ID_PE__c;
            requestBody = JSON.serialize(requestProductHolding);

            soapCustomerProductHoldings = asyncRet.getValue();
            item = ((ProductHoldingDTO) TypeMapper.MappingSoapToDTO(soapCustomerProductHoldings));
            if (item != null)
            {
                //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017
                reqId = item.reqId; 
                ViewState.ProductHoldings = item;
                if(item.SoapStatus == 'ERROR'){
                    ViewState.ErrorMessages +='SERVICE ERROR\n';
                    ViewState.ErrorMessages +='Status : '+item.SoapStatus+'\n';
                    ViewState.ErrorMessages +='Message : '+item.SoapMessage+'\n';
                    ViewState.isError = true;
                    //RTL_Utility.InsertErrorTransaction(cName,rmid,UserInfo.getName(),item.reqId,ViewState.ErrorMessages,acct.Core_Banking_Suggested_Segment__c );
                    //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017 // LOG FAIL
                    // RTL_Utility.InsertRTLog(cName
                    //                         ,rmid
                    //                         ,UserInfo.getName()
                    //                         ,reqId
                    //                         ,ViewState.ErrorMessages
                    //                         ,acct.Core_Banking_Suggested_Segment__c
                    //                         ,acct.Id
                    //                         ,startReq
                    //                         ,Datetime.now()
                    //                         ,'CustomerProductHoldings'
                    //                         ,false
                    //                        );
                    
                    // CR203 Product holding - 20181214
                    RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
                                                                    ViewState.ErrorMessages, 
                                                                    rmid,
                                                                    reqId,
                                                                    'CustomerProductHoldings', 
                                                                    acct.Id, 
                                                                    requestBody,
                                                                    JSON.serialize(soapCustomerProductHoldings), 
                                                                    startReq,
                                                                    Datetime.now() 
                                                                    );
                    pageMessage = System.Label.ERR002;
                    return null;
                }
                ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
                System.debug('TMB: -> Deposite Data Size : ' + ViewState.ProductHoldings.DepositeProducts.size());
                System.debug('TMB: -> Credit Card Data Size : ' + ViewState.ProductHoldings.CreditCardRDCProducts.size());
                System.debug('TMB: -> Loan Data Size : ' + ViewState.ProductHoldings.LoanProducts.size());
                System.debug('TMB: -> Bancassurance Data Size : ' + ViewState.ProductHoldings.Bancassurances.size());
                System.debug('TMB: -> Investment Data Size : ' + ViewState.ProductHoldings.InvestmentProducts.size());
                System.debug('before transform');
                ViewState.InvokeTranform();
                ViewState.InvokeSummary();
                // add  logic here
                // 
                // 
                System.debug('Product holding summary ::: '+ViewState.ProductHoldingSummaries);
                System.debug('before update AUM' + acctId);
                if (acctId != null && acctId != '')
                {
                    /*----------------------------------------------------------------------------------------------------------------------------
                    New Requirement from Jun You(Salesforce) on 016-05-03
                    There is one more action within the CustomerProductHoldingsCtrl: 
                    Once the product holdings are retrieved, it is required to updated the Account object fields as below: 
                    RTL_Actual_Product_Holding__c  -->  sum total of all accounts (Number of Account). 
                    RTL_AUM__c   --> sum of Deposit Outstanding (Transactional Deposit and Non Transactional Deposit) and Mutual Fund Outstanding. 
                    -----------------------------------------------------------------------------------------------------------------------------*/
                    UpdateFieldOnAccount(acctId, ViewState.NumberOfAccount(), ViewState.TotalDepositeOutstanding(),startReq);
                    System.debug('AUM ::: '+ ViewState.TotalDepositeOutstanding() );
                }
            }

            if(ViewState.ErrorMessages != ''){
                PageMessage = System.Label.ERR001;
                //RTL_Utility.InsertErrorTransaction(cName,rmid,UserInfo.getName(),item.reqId,ViewState.ErrorMessages,acct.Core_Banking_Suggested_Segment__c );
                //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017 // LOG FAIL
                // RTL_Utility.InsertRTLog(cName
                //                         ,rmid
                //                         ,UserInfo.getName()
                //                         ,reqId
                //                         ,ViewState.ErrorMessages
                //                         ,acct.Core_Banking_Suggested_Segment__c
                //                         ,acct.Id
                //                         ,startReq
                //                         ,Datetime.now()
                //                         ,'CustomerProductHoldings'
                //                         ,false
                //                        );

                // CR203 Product holding - 20181214
                RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
                                                                ViewState.ErrorMessages, 
                                                                rmid, 
                                                                reqId,
                                                                'CustomerProductHoldings', 
                                                                acct.Id, 
                                                                requestBody, 
                                                                JSON.serialize(soapCustomerProductHoldings), 
                                                                startReq,
                                                                Datetime.now() 
                                                                );

            }

        }
        catch(Exception e)
        {
            ViewState.isError = true;
            ViewState.ErrorMessages = e.getTypeName()+' '+e.getMessage()+' '+e.getStackTraceString();
            PageMessage = System.Label.ERR002;
            System.debug('Show Error Message '+PageMessage);
            System.debug('Show Internal Error Message '+ViewState.ErrorMessages);
            //RTL_Utility.InsertErrorTransaction(cName,rmid,UserInfo.getName(),null,ViewState.ErrorMessages,acct.Core_Banking_Suggested_Segment__c );
            //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017 // LOG FAIL
            // RTL_Utility.InsertRTLog(cName
            //                         ,rmid
            //                         ,UserInfo.getName()
            //                         ,reqId
            //                         ,ViewState.ErrorMessages
            //                         ,acct.Core_Banking_Suggested_Segment__c
            //                         ,acct.Id
            //                         ,startReq
            //                         ,Datetime.now()
            //                         ,'CustomerProductHoldings'
            //                         ,false
            //                        );

            // CR203 Product holding - 20181214
            RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
                                                            ViewState.ErrorMessages, 
                                                            rmid, 
                                                            reqId,
                                                            'CustomerProductHoldings', 
                                                            acct.Id, 
                                                            requestBody, 
                                                            JSON.serialize(soapCustomerProductHoldings), 
                                                            startReq,
                                                            Datetime.now() 
                                                            );

        }

        if (!ViewState.isError && ViewState.ErrorMessages == '') {
            //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017 // LOG SUCCESS
            // RTL_Utility.InsertRTLog(cName
            //                         ,rmid
            //                         ,UserInfo.getName()
            //                         ,reqId
            //                         ,ViewState.ErrorMessages
            //                         ,acct.Core_Banking_Suggested_Segment__c
            //                         ,acct.Id
            //                         ,startReq
            //                         ,Datetime.now()
            //                         ,'CustomerProductHoldings'
            //                         ,true
            //                        );

            // CR203 Product holding - 20181214
            RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
                                                            ViewState.ErrorMessages, 
                                                            rmid, 
                                                            reqId,
                                                            'CustomerProductHoldings', 
                                                            acct.Id, 
                                                            requestBody, 
                                                            JSON.serialize(soapCustomerProductHoldings), 
                                                            startReq,
                                                            Datetime.now() 
                                                            );

        }

        System.debug('Show Page Message '+PageMessage);
        return null;
    }


    public void UpdateFieldOnAccount(string acctId, decimal noOfProduct, decimal sumOfTotalDepositeOutstanding,Datetime startReq) {
        try
        {
            /* ----------------------------------------------------------------------------------------------------------
  - noOfProduct 
  - sumOfTotalDepositeOutstanding used 
  ( Mutual Fund outstanding +  Transactional Deposit outstanding +  Non Transactional Deposit outstanding) 
  --------------------------------------------------------------------------------------------------------------*/
            Boolean ret = RetailAccountService.UpdateTotalAccountsAndSumOfDepesite(acctId, noOfProduct, sumOfTotalDepositeOutstanding);
        }
        catch(Exception e)
        {
            ViewState.isError = true;
            PageMessage = 'Update Account Information  error with inner exception : ' + e.getMessage();
            System.debug('TMB :-> UpdateFieldOnAccount Exception  is ' + e.getMessage() +
                         '\nTMB :-> PageMessage is ' + PageMessage);
            //RTL_Utility.InsertErrorTransaction(cName,rmid,UserInfo.getName(),null,ViewState.ErrorMessages,acct.Core_Banking_Suggested_Segment__c );
            //SCR 2017-1-1794 - Retail Product Holding Usage Log 23/12/2017 // LOG FAIL
            // RTL_Utility.InsertRTLog(cName
            //                         ,rmid
            //                         ,UserInfo.getName()
            //                         ,null
            //                         ,ViewState.ErrorMessages
            //                         ,acct.Core_Banking_Suggested_Segment__c
            //                         ,acct.Id
            //                         ,startReq
            //                         ,Datetime.now()
            //                         ,'CustomerProductHoldings'
            //                         ,false
            //                        );

            // CR203 Product holding - 20181214
            RTL_CampaignUtil.insertOnlineLogWithResponse(   '',
                                                            ViewState.ErrorMessages, 
                                                            rmid, 
                                                            reqId,
                                                            'CustomerProductHoldings', 
                                                            acct.Id,
                                                            requestBody, 
                                                            JSON.serialize(soapCustomerProductHoldings), 
                                                            startReq,
                                                            Datetime.now() 
                                                            );

        }
    }
    // Inner Class 
    public class ViewState {
        public ProductHoldingDTO ProductHoldings { get; set; }
        public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }
        public Map<string /*ProductSubGroup*/, ProductHoldingSummaryDTO> ProductHoldingSummaries { get; set; }
        public List<String /*ProductSubGroup*/> ProductSummaryLabels { get; set; }

        public Map<String /*ProductSubGroup*/, string> ProductSummaryUpperCaseLabels { get; set; }
        //Error Handler
        public Boolean isError {get;set;}
        public Boolean isDepositError {get;set;}
        public Boolean isCreditError {get;set;}
        public Boolean isLoanError {get;set;}
        public Boolean isBancError {get;set;}
        public Boolean isInvestmentError {get;set;}
        public String errorMessages{get;set;}


        private Boolean isEmployee {get;set;}
        private string rmid {get;set;}



        public Map<String /*ProductSubGroup*/, String /*Section*/> PanelSections { get; set; }
        public ViewState() {
            ProductHoldings = new ProductHoldingDTO();
            ProductHoldingSummaries = new Map<string /*ProductSubGroup*/, ProductHoldingSummaryDTO> ();
            ProductSummaryLabels = new List<String /*ProductSubGroup*/> ();
            ProductSummaryUpperCaseLabels = new Map<String /*ProductSubGroup*/, string> ();

            PanelSections = new Map<String /*ProductSubGroup*/, String /*Section*/> ();
            //Fix product sub group

            ProductSummaryLabels.add('Transactional Deposit');
            ProductSummaryUpperCaseLabels.put('Transactional Deposit', '1');
            PanelSections.put('Transactional Deposit', 'section-deposit');

            ProductSummaryLabels.add('Non Transactional Deposit');
            ProductSummaryUpperCaseLabels.put('Non Transactional Deposit', '2');
            PanelSections.put('Non Transactional Deposit', 'section-deposit');

            ProductSummaryLabels.add('Credit Card');
            ProductSummaryUpperCaseLabels.put('Credit Card', '3');
            PanelSections.put('Credit Card', 'section-credit');

            //Hide Debit Card from Product Summary Table
            /*ProductSummaryLabels.add('Debit Card');
ProductSummaryUpperCaseLabels.put('Debit Card', '4');
PanelSections.put('Debit Card', 'section-credit');*/

            ProductSummaryLabels.add('Mutual Fund');
            ProductSummaryUpperCaseLabels.put('Mutual Fund', '5');
            PanelSections.put('Mutual Fund', 'section-investment');

            ProductSummaryLabels.add('Bancassurance');
            ProductSummaryUpperCaseLabels.put('Bancassurance', '6');
            PanelSections.put('Bancassurance', 'section-ban');

            ProductSummaryLabels.add('Personal Loan');
            ProductSummaryUpperCaseLabels.put('Personal Loan', '7');
            PanelSections.put('Personal Loan', 'section-loan');

            ProductSummaryLabels.add('Secured Loan');
            ProductSummaryUpperCaseLabels.put('Secured Loan', '8');
            PanelSections.put('Secured Loan', 'section-loan');

            // When product cannot map to Product2
            ProductSummaryLabels.add('Others');
            ProductSummaryUpperCaseLabels.put('Others','Others'.toUpperCase());
            PanelSections.put('Others', 'none');



            for (string str : ProductSummaryLabels) {
                ProductHoldingSummaryDTO d = new ProductHoldingSummaryDTO(ProductSummaryUpperCaseLabels.get(str));
                d.ProductSubGroup = ProductSummaryUpperCaseLabels.get(str);
                ProductHoldingSummaries.put(ProductSummaryUpperCaseLabels.get(str), d);
            }
            errorMessages = '';
            isError = false;
            isDepositError = false;
            isCreditError = false;
            isLoanError = false;
            isBancError = false;
            isInvestmentError = false;
        }

        public decimal NumberOfAccount() {
            decimal ret = 0;

            for (ProductHoldingSummaryDTO item : ProductHoldingSummaries.values())
            {
                ret += item.NoOfAccount;
            }


            return ret;
        }
        public decimal TotalDepositeOutstanding() {
            decimal ret = 0;

            ProductHoldingSummaryDTO transOutstanding = ProductHoldingSummaries.get(ProductSummaryUpperCaseLabels.get('Transactional Deposit'));
            ret += transOutstanding.GetOutstanding;
            ProductHoldingSummaryDTO nontransOutstanding = ProductHoldingSummaries.get(ProductSummaryUpperCaseLabels.get('Non Transactional Deposit'));
            ret += nontransOutstanding.GetOutstanding;
            ProductHoldingSummaryDTO mutualFuncOutstanding = ProductHoldingSummaries.get(ProductSummaryUpperCaseLabels.get('Mutual Fund'));
            ret += mutualFuncOutstanding.GetOutstanding;
            System.debug('sum :: '+ret);

            return ret;
        }
        public void InvokeTranform() {
            TransformDataDeposit();
            TransformDataCredit();
            TransformDataLoan();
            TransformDataBancassurance();
            TransformDataInvestment();

            ProductHoldings.InvestmentProducts.sort();


        }
        public void InvokeSummary() {
            SummaryDeposit();
            SummaryCredit();
            SummaryLoan();
            SummaryInvestment();
            SummaryBancasurance();
        }

        private void SummaryDeposit() {
            // Transform Deposit
            for (DepositeProductDTO dp : ProductHoldings.DepositeProducts)
            {
                System.debug('DEPOSIT PRODUCT NAME' + dp.ProductName);
                if (dp.ProductName != '#N/A') {


                    if (ProductHoldingSummaries.containsKey(dp.SeqGrp)) {
                        ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get(dp.SeqGrp)).AddItem(dp);
                    }
                }
                else {
                    // Put it Others
                    System.debug('DEPOSIT PRODUCT NAME ::: OTHERS' );
                    ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get('Others'.toUpperCase())).AddItem(dp);

                }



            }
        }
        private void SummaryCredit() {
            // Transform Deposit
            for (CreditCardRDCProductDTO cr : ProductHoldings.CreditCardRDCProducts)
            {
                System.Debug('TMB: -> SubProductGroup ' + cr.SubProductGroup.toUpperCase());
                System.Debug('TMB: -> Is SubProductGroup Contain Key ' + ProductHoldingSummaries.containsKey(cr.SubProductGroup.toUpperCase()));
                if (cr.ProductName != '#N/A') {
                    if (ProductHoldingSummaries.containsKey(cr.SeqGrp)) {
                        ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get(cr.SeqGrp)).AddItem(cr);
                    }
                }
                else {
                    // Put it Others
                    ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get('Others'.toUpperCase())).AddItem(cr);

                }
            }
        }
        private void SummaryLoan() {
            // Transform Deposit
            for (LoanProductDTO ln : ProductHoldings.LoanProducts)
            {
                if (ln.ProductName != '#N/A') {
                    if (ProductHoldingSummaries.containsKey(ln.SeqGrp)) {
                        ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get(ln.SeqGrp)).AddItem(ln);
                    }
                }
                else {
                    // Put it Others
                    ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get('Others'.toUpperCase())).AddItem(ln);

                }
            }
        }
        private void SummaryInvestment() {
            // Transform Deposit
            for (InvestmentProductDTO inv : ProductHoldings.InvestmentProducts)
            {
                if (inv.ProductName != '#N/A') {
                    if (ProductHoldingSummaries.containsKey(inv.SeqGrp)) {
                        ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get(inv.SeqGrp)).AddItem(inv);
                    }
                }
                else {
                    // Put it Others
                    ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get('Others'.toUpperCase())).AddItem(inv);

                }
            }
        }
        private void SummaryBancasurance() {
            System.debug('TMB: -> Invoke SummaryBancasurance ');

            // Transform Deposit
            for (BancassuranceDTO dp : ProductHoldings.Bancassurances)
            {
                ((ProductHoldingSummaryDTO) ProductHoldingSummaries.get('6')).AddItem(dp);
            }


        }

        /* Private Method */
        private void TransformDataDeposit() {
            // Transform Deposit
            if(ProductHoldings.depSoapStatus == 'ERROR'){
                isDepositError = true;
                ErrorMessages +='DEPOSIT SECTION\n';
                ErrorMessages +='Status : '+ProductHoldings.depSoapStatus+'\n';
                ErrorMessages +='Message : '+ProductHoldings.depSoapMessage+'\n\n';
            }
            for (DepositeProductDTO dp : ProductHoldings.DepositeProducts)
            {
                System.Debug('TMB: -> DepositProductCode = ' + dp.DepositProductCode);
                //productkey = productcode+projectcode+datasource
                string productcode = dp.DepositProductCode+dp.ProjectCode+dp.DataSource;
                System.debug('deposit product code '+productcode);
                System.debug('deposit Status :::::::::::::::: '+dp.SoapStatus);
                //set the is Employee value
                dp.isEmployee = isEmployee;
                //2nd drop
                dp.rmid = rmid;

                if(dp.SoapStatus == 'ERROR'){
                    String markedAccountNo = NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(dp.DepositAccountNumber));
                    dp.ProductName = '#N/A';
                    dp.DepositProductCode = '#N/A';
                    isDepositError = true;
                    ErrorMessages +='Deposit Account Number : '+markedAccountNo+'\n';
                    ErrorMessages +='Status : '+dp.SoapStatus+'\n';
                    ErrorMessages +='Message : '+dp.SoapMessage+'\n\n';
                }

                else if (OnlyProductWithProductCode.containsKey(productcode)) {

                    // Found Product code in RTL Product Master
                    dp.ProductName = OnlyProductWithProductCode.get(productcode).Name;
                    dp.SubProductGroup = OnlyProductWithProductCode.get(productcode).Product_Sub_group;
                    dp.SeqGrp = OnlyProductWithProductCode.get(productcode).SEQ_GRP;
                }
                else {

                    dp.ProductName = '#N/A';
                    dp.SubProductGroup = '#N/A';
                }
            }
        }
        private void TransformDataCredit() {
            // Transform Credite
            if(ProductHoldings.cardSoapStatus == 'ERROR'){
                isCreditError = true;
                ErrorMessages +='CREDIT CARD SECTION\n';
                ErrorMessages +='Status : '+ProductHoldings.cardSoapStatus+'\n';
                ErrorMessages +='Message : '+ProductHoldings.cardSoapMessage+'\n\n';
            }
            for (CreditCardRDCProductDTO cr : ProductHoldings.CreditCardRDCProducts)
            {
                System.Debug('TMB: -> CreditCardType = ' + cr.CreditCardType);
                cr.CreditCardType = cr.CreditCardType+'CRE';
                cr.isEmployee = isEmployee;
                if(cr.SoapStatus == 'ERROR'){
                    String markedCreditCardNo = NumberHelper.MarkCardNo(NumberHelper.TrimCardNo(cr.CardNumber));
                    cr.ProductName = '#N/A';
                    isCreditError = true;
                    ErrorMessages +='Card Number : '+markedCreditCardNo+'\n';
                    ErrorMessages +='Status : '+cr.SoapStatus+'\n';
                    ErrorMessages +='Message : '+cr.SoapMessage+'\n\n';
                }
                else if (OnlyProductWithProductCode.containsKey(cr.CreditCardType))
                {
                    // Found Product code in RTL Product Master
                    cr.ProductName = OnlyProductWithProductCode.get(cr.CreditCardType).Name;
                    cr.SubProductGroup = OnlyProductWithProductCode.get(cr.CreditCardType).Product_Sub_group;
                    cr.SeqGrp = OnlyProductWithProductCode.get(cr.CreditCardType).SEQ_GRP;
                }
                else {
                    //cr.CreditCardType = 'error';
                    cr.ProductName = '#N/A';
                    cr.SubProductGroup = '#N/A';
                }
            }
        }
        private void TransformDataLoan() {

            //Tranform Loan Accounts
            if(ProductHoldings.loanSoapStatus == 'ERROR'){
                isLoanError = true;
                ErrorMessages +='LOAN SECTION\n';
                ErrorMessages +='Status : '+ProductHoldings.loanSoapStatus+'\n';
                ErrorMessages +='Message : '+ProductHoldings.loanSoapMessage+'\n\n';
            }
            for (LoanProductDTO ln : ProductHoldings.LoanProducts)
            {
                System.Debug('TMB: -> LoanProductCode = ' + ln.LoanProductCode);
                //productkey = productcode + projectcode + datasource
                string productcode = ln.LoanProductCode+ln.ProjectCode+ln.DataSource;

                if(ln.SoapStatus == 'ERROR'){
                    String markedLoanAccountNo = NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(ln.LoanAccountNumber));
                    ln.ProductName = '#N/A';
                    isLoanError = true;
                    ErrorMessages +='Loan Account Number : '+markedLoanAccountNo+'\n';
                    ErrorMessages +='Status : '+ln.SoapStatus+'\n';
                    ErrorMessages +='Message : '+ln.SoapMessage+'\n\n';
                }        
                else if (OnlyProductWithProductCode.containsKey(productcode))
                {
                    // Found Product code in RTL Product Master
                    ln.ProductName = OnlyProductWithProductCode.get(productcode).Name;
                    ln.SubProductGroup = OnlyProductWithProductCode.get(productcode).Product_Sub_group;
                    ln.SeqGrp = OnlyProductWithProductCode.get(productcode).SEQ_GRP;
                }
                else {

                    ln.ProductName = '#N/A';
                    ln.SubProductGroup = '#N/A';
                }
            }

        }

        private void TransformDataBancassurance() {
            //Tranform BA Policy
            if(ProductHoldings.BASoapStatus == 'ERROR'){
                isBancError = true;
                ErrorMessages += 'BANCASSURANCE SECTION\n';
                ErrorMessages +='\tStatus : '+ProductHoldings.BASoapStatus+'\n';
                ErrorMessages +='\tMessage : '+ProductHoldings.BASoapMessage+'\n\n';
            }
            for (BancassuranceDTO ba : ProductHoldings.Bancassurances)
            {
                if(ba.SoapStatus == 'ERROR'){
                    isBancError = true;
                    ErrorMessages +='Policy No. : '+ba.PolicyNo+'\n';
                    ErrorMessages +='Status : '+ba.SoapStatus+'\n';
                    ErrorMessages +='Message : '+ba.SoapMessage+'\n\n';
                }

            }
        }

        private void TransformDataInvestment() {
            //Tranform Loan Accounts
            if(ProductHoldings.investmentSoapStatus == 'ERROR'){
                isInvestmentError = true;
                ErrorMessages += 'INVESTMENT SECTION\n';
                ErrorMessages +='Status : '+ProductHoldings.investmentSoapStatus +'\n';
                ErrorMessages +='Message : '+ProductHoldings.investmentSoapMessage+'\n\n';
            }
            for (InvestmentProductDTO iv : ProductHoldings.InvestmentProducts)
            {
                System.Debug('TMB: -> FundCode = ' + iv.FundCode);

                if(iv.SoapStatus == 'ERROR'){
                    iv.ProductName = '#N/A';
                    isInvestmentError = true;
                    ErrorMessages +='Unit Holder No. : '+iv.UnitHolderNo+'\n';
                    ErrorMessages +='\tStatus : '+iv.SoapStatus+'\n';
                    ErrorMessages +='\tMessage : '+iv.SoapMessage+'\n\n';
                }   
                else if (OnlyProductWithProductCode.containsKey(iv.FundCode))
                {
                    // Found Product code in RTL Product Master
                    iv.ProductName = OnlyProductWithProductCode.get(iv.FundCode).Name;
                    iv.SubProductGroup = OnlyProductWithProductCode.get(iv.FundCode).Product_Sub_group;
                    iv.AssetClass = OnlyProductWithProductCode.get(iv.FundCode).Asset_Class;
                    iv.SeqGrp = OnlyProductWithProductCode.get(iv.FundCode).SEQ_GRP;
                    iv.IssuerFundHouse = OnlyProductWithProductCode.get(iv.FundCode).Issuer_Fund_House;
                }
                else {

                    iv.ProductName = '#N/A';
                    iv.SubProductGroup = '#N/A';
                    iv.AssetClass = '#N/A';
                    iv.IssuerFundHouse = '#N/A';
                }
            }
        }

    }

    public void logAuthorizedProductHolding()
    {
        //Log to online service log if no access right to all field
        if( !isAccessibleCusHoldLow && !isAccessibleCusHoldLow && !isAccessibleCusHoldLow )
        {
            String tmb_cust_id = acct.TMB_Customer_ID_PE__c;
            String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            String serviceName = 'CustomerProductHoldings';
            String errorMessage = 'No Authorized on all sections in Product Hodling Page';

            RTL_CampaignUtil.saveToOnlineLogDataPartition(false ,'Account', errorMessage , '' , userName, tmb_cust_id , serviceName ,'','', acctDetail, true);
           
        }
    }
}