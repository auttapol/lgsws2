public class ProductTransactionRisk2 {
    
    public account acct {get;set;}
    public decimal DAItotal1 {get;set;}
    public decimal DAItotal2 {get;set;}
    public decimal DAItotal3 {get;set;}
    public decimal DAItotal4 {get;set;}
    public decimal DAItotal5 {get;set;}
    public decimal DAItotal6 {get;set;}
    public decimal DAItotal7 {get;set;}
    public decimal DAItotal8 {get;set;}
    public decimal FABLoantotal1 {get;set;}
    public decimal FABLoantotal2 {get;set;}
    public decimal FABLoantotal3 {get;set;}
    public decimal FABLoantotal4 {get;set;}
    public decimal FABLoantotal5 {get;set;}
    public decimal FABLoantotal6 {get;set;}
    public decimal FABLoantotal7 {get;set;}
    public decimal FABLoantotal8 {get;set;}
    public decimal FABLiabilitytotal1 {get;set;}
    public decimal FABLiabilitytotal2 {get;set;}
    public decimal FABLiabilitytotal3 {get;set;}
    public decimal FABLiabilitytotal4 {get;set;}
    public decimal TFVtotal1 {get;set;}
    public decimal TFVtotal2 {get;set;}
    public decimal TFVtotal3 {get;set;}
    public decimal TFVtotal4 {get;set;}
    public decimal TFFtotal1 {get;set;}
    public decimal TFFtotal2 {get;set;}
    public decimal RPLoantotal1 {get;set;}
    public decimal RPLoantotal2 {get;set;}
    public decimal RPLoantotal3 {get;set;}
    public decimal RPLoantotal4 {get;set;}
    public decimal RPLoantotal5 {get;set;}
    public decimal RPLoantotal6 {get;set;}
    public decimal RPLoantotal7 {get;set;}
    public decimal RPLoantotal8 {get;set;}
    public decimal RPLiabilitytotal1 {get;set;}
    public decimal RPLiabilitytotal2 {get;set;}
    public decimal RPLiabilitytotal3 {get;set;}
    public decimal RPLiabilitytotal4 {get;set;}
    public Product_Trans_Risk__c nim {get;set;}
    
    //public map<string,list<Product_Performance__c>> mapProductPerformance {get;set;}
    public map<string,list<Product_Performance__c>> mapProductPerformanceDeposit {get;set;}
    public map<string,list<Product_Performance__c>> mapProductPerformanceFundLoan {get;set;}
    public map<string,list<Product_Performance__c>> mapProductPerformanceFundLiability {get;set;}
    public map<string,list<Product_Performance__c>> mapProductPerformanceRiskLoan {get;set;}
    public map<string,list<Product_Performance__c>> mapProductPerformanceRiskLiability {get;set;}
    public map<string,list<Product_Fee__c>> mapTradeFinanceVolumn {get;set;}
    public map<string,list<Product_Fee__c>> mapTradeFinanceFee {get;set;}
    public map<string,wrapSumProduct> mapSumProductDeposit {get;set;}
    public map<string,wrapSumProduct> mapSumProductFundLoan {get;set;}
    public map<string,wrapSumProduct> mapSumProductFundLiability {get;set;}
    public map<string,wrapSumProduct> mapSumProductRiskLoan {get;set;}
    public map<string,wrapSumProduct> mapSumProductRiskLiability {get;set;}
    public map<string,wrapSumTradeFinance> mapSumTradeFinanceVolumn {get;set;}
    public map<string,wrapSumTradeFinance> mapSumTradeFinanceFee {get;set;}
    public map<string,Product_NIM__c> mapProductNIM {get;set;}
    public string DataExist {get;set;}
    public string errorMsg {get;set;}
    public id PerfDepositReportId {get;set;}
    public id PerfFundingReportId {get;set;}
    public id PerfFundingReportLoanId {get;set;}
    public id PerfFundingReportLiabilityId {get;set;}
    public id PerfRiskReportLoanId {get;set;}
    public id PerfRiskReportLiabilityId {get;set;}
    
    public static final string LOAN_GROUP = 'LOAN';
    public static final string LIABILITY_GROUP = 'LIABILITY';
    
    public boolean isValid {get;set;}
    
    public ProductTransactionRisk2(ApexPages.standardController sc){
        account acc = (account)sc.getRecord();
        acct = [select ID, TMB_Customer_ID_PE__c, Name from account where id =: acc.ID];
        DataExist = 'true';
        errorMsg = '';
        isValid = true;

        try {
            
            nim = [select NIMC_YTD__c, NIMC_MTD__c, NIMD_YTD__c, NIMD_MTD__c,As_Of_Date__c from Product_Trans_Risk__c where Account__c =: acct.ID order by As_Of_Date__c DESC];
        
        
        DAItotal1 = 0.00; DAItotal2 = 0.00; DAItotal3 = 0.00; DAItotal4 = 0.00;
        DAItotal5 = 0.00; DAItotal6 = 0.00; DAItotal7 = 0.00; DAItotal8 = 0.00;
        
        FABLoantotal1 = 0.00; FABLoantotal2 = 0.00; FABLoantotal3 = 0.00; FABLoantotal4 = 0.00;
        FABLoantotal5 = 0.00; FABLoantotal6 = 0.00; FABLoantotal7 = 0.00; FABLoantotal8 = 0.00;        
        FABLiabilitytotal1 = 0.00; FABLiabilitytotal2 = 0.00; FABLiabilitytotal3 = 0.00; FABLiabilitytotal4 = 0.00;
        
        TFVtotal1 = 0.00; TFVtotal2 = 0.00; TFVtotal3 = 0.00; TFVtotal4 = 0.00;
        TFFtotal1 = 0.00; TFFtotal2 = 0.00; 
        
        RPLoantotal1 = 0.00; RPLoantotal2 = 0.00; RPLoantotal3 = 0.00; RPLoantotal4 = 0.00;
        RPLoantotal5 = 0.00; RPLoantotal6 = 0.00; RPLoantotal7 = 0.00; RPLoantotal8 = 0.00;
        RPLiabilitytotal1 = 0.00; RPLiabilitytotal2 = 0.00; RPLiabilitytotal3 = 0.00; RPLiabilitytotal4 = 0.00;
        
        //mapProductPerformance = getProductDetail();
        mapProductPerformanceDeposit = getProductDetail('Deposit','');
        mapProductPerformanceFundLoan = getProductDetail('Fund','LOAN');
        mapProductPerformanceFundLiability = getProductDetail('Fund','LIABILITY');
        mapProductPerformanceRiskLoan = getProductDetail('Risk','LOAN');
        mapProductPerformanceRiskLiability = getProductDetail('Risk','LIABILITY');
        mapSumProductDeposit = getSumProduct(mapProductPerformanceDeposit);
        mapSumProductFundLoan = getSumProduct(mapProductPerformanceFundLoan);
        mapSumProductFundLiability = getSumProduct(mapProductPerformanceFundLiability);
        mapSumProductRiskLoan = getSumProduct(mapProductPerformanceRiskLoan);
        mapSumProductRiskLiability = getSumProduct(mapProductPerformanceRiskLiability);
        
        mapProductNIM = getProductNIM();
        for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID and As_of_Date__c =: nim.As_of_Date__c]){
            if (mapProductNIM.get(a.Product_Name__c) == null)
                isValid = false;
        }
system.debug(isValid);
        if (!isValid) 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Status_Code__c.getValues('4010').Status_Message__c));
        
        mapTradeFinanceVolumn = getProductFee('TV');
        mapTradeFinanceFee = getProductFee('TF');
        mapSumTradeFinanceVolumn = getSumTradeFinance(mapTradeFinanceVolumn);
        mapSumTradeFinanceFee = getSumTradeFinance(mapTradeFinanceFee);
        
        }catch(exception e){
            DataExist = 'false';
            errorMsg = Trigger_Msg__c.getValues('Perf_no_data').Description__c;
        }
        
        try{
            CustSingleView__c CustSingleViewDeposit = CustSingleView__c.GetValues('PerfDepositReport');
            String PerfDepositReport = CustSingleViewDeposit.ReportName__c;
            PerfDepositReportId = [SELECT id FROM report where DeveloperName =: PerfDepositReport].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception PerfDepositReport Id not found::::::');
            DataExist = 'false';
            errorMsg = '::::::Exception PerfDepositReport Id not found::::::';
        }
        
        try{
            CustSingleView__c CustSingleViewFunding = CustSingleView__c.GetValues('PerfFundingReportLoan');
            String PerfFundingReportLoan = CustSingleViewFunding.ReportName__c;
            PerfFundingReportLoanId = [SELECT id FROM report where DeveloperName =: PerfFundingReportLoan].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception PerfFundingReportLoan Id not found::::::');
            DataExist = 'false';
            errorMsg = '::::::Exception PerfFundingReportLoan Id not found::::::';
        }   
          
        try{
            CustSingleView__c CustSingleViewFunding = CustSingleView__c.GetValues('PerfFundingReportLiability');
            String PerfFundingReportLiability = CustSingleViewFunding.ReportName__c;
            PerfFundingReportLiabilityId = [SELECT id FROM report where DeveloperName =: PerfFundingReportLiability].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception PerfFundingReportLiability Id not found::::::');
            DataExist = 'false';
            errorMsg = '::::::Exception PerfFundingReportLiability Id not found::::::';
        } 
        
        try{
            CustSingleView__c CustSingleViewFunding = CustSingleView__c.GetValues('PerfRiskReportLiability');
            String PerfRiskReportLiability = CustSingleViewFunding.ReportName__c;
            PerfRiskReportLiabilityId = [SELECT id FROM report where DeveloperName =: PerfRiskReportLiability].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception PerfRiskReportLiability Id not found::::::');
            DataExist = 'false';
            errorMsg = '::::::Exception PerfRiskReportLiability Id not found::::::';
        }   
        
        try{
            CustSingleView__c CustSingleViewFunding = CustSingleView__c.GetValues('PerfRiskReportLoan');
            String PerfRiskReportLoan = CustSingleViewFunding.ReportName__c;
            PerfRiskReportLoanId = [SELECT id FROM report where DeveloperName =: PerfRiskReportLoan].Id;
        }catch(Exception Ex){
            system.debug('::::::Exception PerfRiskReportLoan Id not found::::::');
            DataExist = 'false';
            errorMsg = '::::::Exception PerfRiskReportLoan Id not found::::::';
        }       
       
    }
    
    public Product_Trans_Risk__c getProductTransRisk()
    {
        Product_Trans_Risk__c retData = new Product_Trans_Risk__c();
        retData = [select ID
                    , AS_FEE_YTD__c
                    , AS_FEE_MTD__c
                    , DIRECT_CM_FEE_MTD__c
                    , DIRECT_CM_FEE_YTD__c
                    , OTHER_CM_FEE_MTD__c
                    , OTHER_CM_FEE_YTD__c
                    , EDC_FEE_MTD__c
                    , EDC_VOL_MTD__c
                    , EDC_FEE_YTD__c
                    , EDC_VOL_YTD__c
                    , FLEET_FEE_MTD__c
                    , FLEET_VOL_MTD__c
                    , FLEET_FEE_YTD__c
                    , FLEET_VOL_YTD__c
                    , TF_FEE_MTD__c
                    , TF_VOL_MTD__c
                    , TF_FEE_YTD__c
                    , TF_VOL_YTD__c
                    , CREDIT_FEE_MTD__c
                    , CREDIT_FEE_YTD__c
                    , IB_FEE_MTD__c
                    , IB_FEE_YTD__c
                    , OTHER_FEE_MTD__c
                    , OTHER_FEE_YTD__c
                    , FRONT_END_FEE_MTD__c
                    , FRONT_END_FEE_YTD__c
                    , FX_FEE_MTD__c
                    , FX_FEE_YTD__c
                    , FX_VOL_MTD__c
                    , FX_VOL_YTD__c
                    , BA_FEE_MTD__c
                    , BA_FEE_YTD__c
                    , DERIVATIVES_FEE_MTD__c
                    , DERIVATIVES_FEE_YTD__c
                    , LG_FEE_MTD__c
                    , LG_FEE_YTD__c
                    , As_of_Month__c
                    , As_of_Date__c
                   from Product_Trans_Risk__c
                   where account__c =: acct.ID
                   order by As_of_Date__c DESC
                  ];
        return retData;
    }
    
    public list<wrapTradeFinanceInfo> getTradeFinanceVolumn(){
        list<wrapTradeFinanceInfo> retData = new list<wrapTradeFinanceInfo>();
        set<string> setProductGroup = new set<string>();
        for(Product_Fee__c a : [select Product_Group__c 
                                FROM Product_Fee__c 
                                where customer__c =:acct.Id
                                and Data_Source__c like '%TV%'
                                and as_of_date__c =: nim.As_of_Date__c
                                order by Product_Order__c ASC ]){
            setProductGroup.add(a.Product_Group__c);               
        }
        
        try {
            for (string a: setProductGroup){
                list<Product_Fee__c> b = mapTradeFinanceVolumn.get(a); //getProductFee(a); 
                decimal c = mapSumTradeFinanceVolumn.get(a).volumn_ytd;
                decimal d = mapSumTradeFinanceVolumn.get(a).volumn_mtd;
                decimal e = mapSumTradeFinanceVolumn.get(a).no_of_transaction_ytd;
                decimal f = mapSumTradeFinanceVolumn.get(a).no_of_transaction_mtd;
                
                retData.add(new wrapTradeFinanceInfo(a,b,c,d,e,f));    
                
                TFVtotal1 += c;
                TFVtotal2 += d;
                TFVtotal3 += e;
                TFVtotal4 += f;                                           
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    public list<wrapTradeFinanceInfo> getTradeFinanceFee(){
        list<wrapTradeFinanceInfo> retData = new list<wrapTradeFinanceInfo>();
        set<string> setProductGroup = new set<string>();
        for(Product_Fee__c a : [select Product_Group__c 
                                FROM Product_Fee__c 
                                where customer__c =:acct.Id
                                and Data_Source__c like '%TF%'
                                and as_of_date__c =: nim.As_of_Date__c
                                order by Product_Order__c ASC ]){
            setProductGroup.add(a.Product_Group__c);               
        }
        
        try {
            for (string a: setProductGroup){
                list<Product_Fee__c> b = mapTradeFinanceFee.get(a); //getProductFee(a); 
                decimal c = mapSumTradeFinanceFee.get(a).fee_ytd;
                decimal d = mapSumTradeFinanceFee.get(a).fee_mtd;
    
                retData.add(new wrapTradeFinanceInfo(a,b,c,d,null,null));    
                
                TFFtotal1 += c;
                TFFtotal2 += d;                                          
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    
    public list<wrapProductInfo> getProductInfoDepositInvestment()
    {
        list<wrapProductInfo> retData = new list<wrapProductInfo>();
        set<string> setProductName = new set<string>();
        for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID
                                        //and Product_Domain__c like '%Deposit and Investment%'
                                        and (Product_Domain__c like '%Deposit%' or Product_Domain__c like '%deposit%')
                                        and as_of_date__c =: nim.As_of_Date__c
                                        order by Product_Name__c]){
            setProductName.add(a.Product_Name__c);
        }
        
        try {
            for (string a: setProductName){
                list<Product_Performance__c> b = slice(mapProductPerformanceDeposit.get(a),0,30); //getProductDetail(a);  
                System.debug('Performance  '+ mapProductPerformanceDeposit);
                System.debug('sum '+mapSumProductDeposit);
                
                decimal c = checkNull(mapProductNim.get(a).outstanding_ytd__c); //getProductNim(a,'outstanding-ytd');        
                decimal d = mapSumProductDeposit.get(a).outstanding_mtd; //getSumProductDetail(a,'outstanding-mtd');
                decimal e = checkNull(mapProductNim.get(a).average_ytd__c); //getProductNim(a,'average-ytd');      
                decimal f = mapSumProductDeposit.get(a).average_mtd; //getSumProductDetail(a,'average-mtd');
                decimal g = checkNull(mapProductNim.get(a).NIMd_YTD__c);//getProductNim(a,'nimd-ytd');
                decimal h = checkNull(mapProductNim.get(a).NIMd_MTD__c);//getProductNim(a,'nimd-mtd');
                decimal i = checkNull(mapProductNim.get(a).NIID_DPA_ytd__c); //getProductNim(a,'niid-ytd');
                decimal j = mapSumProductDeposit.get(a).niid_mtd; //getSumProductDetail(a,'niid-mtd');
               
                retData.add(new wrapProductInfo(a,b,c,d,e,f,g,h,i,j));    
                
                DAItotal1 += c;
                DAItotal2 += d;
                DAItotal3 += e;
                DAItotal4 += f;
                DAItotal5 += g;
                DAItotal6 += h;
                DAItotal7 += i;
                DAItotal8 += j;                                       
            }
        }catch(exception ex){
            system.debug(ex.getLineNumber()+' '+ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    
    public list<wrapProductInfo> getProductInfoFundingBorrowing()
    {
        
        list<wrapProductInfo> retData = new list<wrapProductInfo>();
        set<string> setProductName = new set<string>();
        
        
            for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID
                                        //and Product_Domain__c like '%Funding & Borrowing%'
                                        and (Product_Domain__c like '%Funding%' or Product_Domain__c like '%funding%')
                                        and Product_Group__c like '%Loan%'
                                        and as_of_date__c =: nim.As_of_Date__c
                                        order by Product_Name__c]){
            setProductName.add(a.Product_Name__c);
            }
        
        try {
            for (string a: setProductName){
                list<Product_Performance__c> b = slice(mapProductPerformanceFundLoan.get(a),0,30); //getProductDetail(a); 
                decimal c = checkNull(mapProductNim.get(a).outstanding_ytd__c); //getProductNim(a,'outstanding-ytd');
                decimal d = mapSumProductFundLoan.get(a).outstanding_mtd; //getSumProductDetail(a,'outstanding-mtd');
                decimal e = checkNull(mapProductNim.get(a).average_ytd__c); //getProductNim(a,'average-ytd');
                decimal f = mapSumProductFundLoan.get(a).average_mtd; //getSumProductDetail(a,'average-mtd');
                decimal g = checkNull(mapProductNim.get(a).NIMc_YTD__c);//getProductNim(a,'nimc-ytd');
                decimal h = checkNull(mapProductNim.get(a).NIMc_MTD__c);//getProductNim(a,'nimc-mtd');
                //decimal g = mapSumProduct.get(a).nimc_ytd; //getSumProductDetail(a,'nimc-ytd');
                //decimal h = mapSumProduct.get(a).nimc_mtd; //getSumProductDetail(a,'nimc-mtd');
                decimal i = checkNull(mapProductNim.get(a).niic_ytd__c); //getProductNim(a,'niic-ytd');
                decimal j = mapSumProductFundLoan.get(a).niic_mtd; //getSumProductDetail(a,'niic-mtd');
                retData.add(new wrapProductInfo(a,b,c,d,e,f,g,h,i,j));    
                
                FABLoantotal1 += c;
                FABLoantotal2 += d;
                FABLoantotal3 += e;
                FABLoantotal4 += f;
                FABLoantotal5 += g;
                FABLoantotal6 += h;
                FABLoantotal7 += i;
                FABLoantotal8 += j;                                            
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    
    public list<wrapProductInfo> getProductInfoFundingBorrowingLiability()
    {
        list<wrapProductInfo> retData = new list<wrapProductInfo>();
        set<string> setProductName = new set<string>();
        for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID
                                        //and Product_Domain__c like '%Funding & Borrowing%'
                                        and (Product_Domain__c like '%Funding%' or Product_Domain__c like '%funding%')
                                        and Product_Group__c like '%Liability%'
                                        and as_of_date__c =: nim.As_of_Date__c
                                        order by Product_Name__c]){
            setProductName.add(a.Product_Name__c);
        }
        
        try {
            for (string a: setProductName){
                list<Product_Performance__c> b = slice(mapProductPerformanceFundLiability.get(a),0,30); //getProductDetail(a); 
                decimal c = checkNull(mapProductNim.get(a).outstanding_ytd__c); //getProductNim(a,'outstanding-ytd');
                decimal d = mapSumProductFundLiability.get(a).outstanding_mtd; //getSumProductDetail(a,'outstanding-mtd');
                decimal e = checkNull(mapProductNim.get(a).average_ytd__c); //getProductNim(a,'average-ytd');
                decimal f = mapSumProductFundLiability.get(a).average_mtd; //getSumProductDetail(a,'average-mtd');
    
                retData.add(new wrapProductInfo(a,b,c,d,e,f,null,null,null,null));    
                
                FABLiabilitytotal1 += c;
                FABLiabilitytotal2 += d;
                FABLiabilitytotal3 += e;
                FABLiabilitytotal4 += f;                                           
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    
    public list<wrapProductInfo> getProductInfoRiskProtectionLoan()
    {
        list<wrapProductInfo> retData = new list<wrapProductInfo>();
        set<string> setProductName = new set<string>();
        for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID
                                        //and Product_Domain__c like '%Funding & Borrowing%'
                                        and (Product_Domain__c like '%Risk%' or Product_Domain__c like '%risk%')
                                        and Product_Group__c like '%Loan%'
                                        and as_of_date__c =: nim.As_of_Date__c
                                        order by Product_Name__c]){
            setProductName.add(a.Product_Name__c);
        }
        
        try {
            for (string a: setProductName){
                list<Product_Performance__c> b = slice(mapProductPerformanceRiskLoan.get(a),0,30); //getProductDetail(a); 
                decimal c = checkNull(mapProductNim.get(a).outstanding_ytd__c); //getProductNim(a,'outstanding-ytd');
                decimal d = mapSumProductRiskLoan.get(a).outstanding_mtd; //getSumProductDetail(a,'outstanding-mtd');
                decimal e = checkNull(mapProductNim.get(a).average_ytd__c); //getProductNim(a,'average-ytd');
                decimal f = mapSumProductRiskLoan.get(a).average_mtd; //getSumProductDetail(a,'average-mtd');
                //decimal g = 0;//mapProductNim.get(a).NIMc_YTD__c;//getProductNim(a,'nimc-ytd');
                //decimal h = 0;//mapProductNim.get(a).NIMc_MTD__c;//getProductNim(a,'nimc-mtd');
                decimal g = checkNull(mapProductNim.get(a).NIMc_YTD__c);//getProductNim(a,'nimc-ytd');
                decimal h = checkNull(mapProductNim.get(a).NIMc_MTD__c);//getProductNim(a,'nimc-mtd');
                //decimal g = mapSumProduct.get(a).nimc_ytd; //getSumProductDetail(a,'nimc-ytd');
                //decimal h = mapSumProduct.get(a).nimc_mtd; //getSumProductDetail(a,'nimc-mtd');
                decimal i = checkNull(mapProductNim.get(a).niic_ytd__c); //getProductNim(a,'niic-ytd');
                decimal j = mapSumProductRiskLoan.get(a).niic_mtd; //getSumProductDetail(a,'niic-mtd');
                retData.add(new wrapProductInfo(a,b,c,d,e,f,g,h,i,j));    
                
                RPLoantotal1 += c;
                RPLoantotal2 += d;
                RPLoantotal3 += e;
                RPLoantotal4 += f;
                RPLoantotal5 += g;
                RPLoantotal6 += h;
                RPLoantotal7 += i;
                RPLoantotal8 += j;                                            
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }
    
    public list<wrapProductInfo> getProductInfoRiskProtectionLiability()
    {
        list<wrapProductInfo> retData = new list<wrapProductInfo>();
        set<string> setProductName = new set<string>();
        for (Product_Performance__c a: [select Product_Name__c
                                        from Product_Performance__c
                                        where account__c =: acct.ID
                                        //and Product_Domain__c like '%Funding & Borrowing%'
                                        and (Product_Domain__c like '%Risk%' or Product_Domain__c like '%risk%')
                                        and Product_Group__c like '%Liability%'
                                        and as_of_date__c =: nim.As_of_Date__c
                                        order by Product_Name__c]){
            setProductName.add(a.Product_Name__c);
        }
        
        try {
            for (string a: setProductName){
                list<Product_Performance__c> b = slice(mapProductPerformanceRiskLiability.get(a),0,30); //getProductDetail(a); 
                decimal c = checkNull(mapProductNim.get(a).outstanding_ytd__c); //getProductNim(a,'outstanding-ytd');
                decimal d = mapSumProductRiskLiability.get(a).outstanding_mtd; //getSumProductDetail(a,'outstanding-mtd');
                decimal e = checkNull(mapProductNim.get(a).average_ytd__c); //getProductNim(a,'average-ytd');
                decimal f = mapSumProductRiskLiability.get(a).average_mtd; //getSumProductDetail(a,'average-mtd');
    
                retData.add(new wrapProductInfo(a,b,c,d,e,f,null,null,null,null));    
                
                RPLiabilitytotal1 += c;
                RPLiabilitytotal2 += d;
                RPLiabilitytotal3 += e;
                RPLiabilitytotal4 += f;                                           
            }
        }catch(exception ex){
            system.debug(ex.getMessage());
            //isValid = false;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Status_Code__c.getValues('4010').Status_Message__c));
            return null;
        }
        
        return retData;
    }

    public map<string,list<Product_Performance__c>> getProductDetail(String productDomain,String productGroup)
    {
        String domain = '%'+productDomain+'%';
        
        set<string> productName = new set<string>();
        
        if(productDomain == 'Deposit'){
            for (Product_Performance__c a :[select Product_Name__c from Product_Performance__c where Account__c =: acct.ID
                                        AND product_domain__c like :domain and as_of_date__c =: nim.As_of_Date__c]){
                productName.add(a.Product_Name__c);
            }
        }else{
            for (Product_Performance__c a :[select Product_Name__c from Product_Performance__c where Account__c =: acct.ID
                                        AND product_domain__c like :domain and product_group__c =: productGroup and as_of_date__c =: nim.As_of_Date__c]){
                productName.add(a.Product_Name__c);
            }
        }
        
               
        map<string,list<Product_Performance__c>> retData = new map<string,list<Product_Performance__c>>();
        for (string b: productName){
            
            list<Product_Performance__c> pp = new list<Product_Performance__c>();            
                
            for (Product_Performance__c a : [select ID, Product_Name__c, TMB_Account_ID__c
                                               , Ending_OS_MTD__c, Ending_OS_YTD__c
                                               , Average_OS_MTD__c, Average_OS_YTD__c
                                               , NIMd_DPA_MTD__c, NIMd_DPA_YTD__c
                                               , NIID_DPA_MTD__c, NIID_DPA_YTD__c
                                               , NIMC_MTD__c, NIMC_YTD__c
                                               , NIIC_MTD__c, NIIC_YTD__c
                                               , TMB_Suffix__c, TMB_Ref__c
                                               from Product_Performance__c
                                               where Account__c =: acct.ID and Product_Name__c =: b
                                               and product_domain__c like :domain and as_of_date__c =: nim.As_of_Date__c
                                               order by TMB_Account_ID__c, TMB_Suffix__c, TMB_Ref__c]){                 
                if (a.Product_Name__c == b ){
                    
                    integer noOfnewLine = 0;
                    if (a.TMB_Account_ID__c != null)
                    	noOfnewLine = integer.valueof(a.TMB_Account_ID__c.length() / 10);
                    
                    if (noOfnewLine > 1){
                        string tmbAcct = '';
                        for (integer i=1; i<=noOfnewLine; i++){
                            tmbAcct += a.TMB_Account_ID__c.mid((i-1)*14,14) + '<br/>';
                        }
                        a.TMB_Account_ID__c = tmbAcct;
                    }
                    pp.add(a); 
                }
            }
            
            retData.put(b, pp);
        }
        
        return retData;
    }
    
    
    public Map<String,wrapSumProduct> getSumProduct(Map<String,List<Product_Performance__c>> mapProductPerformance){
        map<string,wrapSumProduct> retData = new map<string,wrapSumProduct>();
        
        for(String productName : mapProductPerformance.keySet()){
            wrapSumProduct w = new wrapSumProduct();
            
            for (Product_Performance__c a : mapProductPerformance.get(productName)){
                if (a.Product_Name__c == productName)
                {
                    if (a.Ending_OS_YTD__c != null) w.outstanding_ytd += a.Ending_OS_YTD__c;
                    if (a.Ending_OS_MTD__c != null) w.outstanding_mtd += a.Ending_OS_MTD__c;
                    if (a.Average_OS_YTD__c != null) w.average_ytd += a.Average_OS_YTD__c;
                    if (a.Average_OS_MTD__c != null) w.average_mtd += a.Average_OS_MTD__c;
                    if (a.NIMd_DPA_YTD__c != null) w.nimd_ytd += a.NIMd_DPA_YTD__c;
                    if (a.NIMd_DPA_MTD__c != null) w.nimd_mtd += a.NIMd_DPA_MTD__c;
                    if (a.NIID_DPA_YTD__c != null) w.niid_ytd += a.NIID_DPA_YTD__c;
                    if (a.NIID_DPA_MTD__c != null) w.niid_mtd += a.NIID_DPA_MTD__c;
                    if (a.NIMC_YTD__c != null) w.nimc_ytd += a.NIMC_YTD__c;
                    if (a.NIMC_MTD__c != null) w.nimc_mtd += a.NIMC_MTD__c;
                    if (a.NIIC_YTD__c != null) w.niic_ytd += a.NIIC_YTD__c;
                    if (a.NIIC_MTD__c != null) w.niic_mtd += a.NIIC_MTD__c;
                }
            }
            
            retData.put(productName, w); 
        }
        return retData;
    }
    
    public Map<String,Product_NIM__c> getProductNIM(){
        List<Product_NIM__c> nimList = [SELECT Id,Name,Product_Name__c,NIMC_MTD__c,NIMC_YTD__c,NIMD_MTD__c,NIMD_YTD__c,Outstanding_YTD__c, Average_YTD__c, NIID_DPA_YTD__c,NIIC_YTD__c
                                         FROM Product_NIM__c WHERE Customer__c =: acct.ID and as_of_date__c =: nim.As_of_Date__c];
        
        Map<String,Product_NIM__c>  nimMap = new Map<String,Product_NIM__c>();
        
        for(Product_NIM__c nim : nimList){
            nimMap.put(nim.Product_Name__c,nim);
        }
        return nimMap;
    }
    
    public Map<String,List<Product_Fee__c>> getProductFee(String source){
        Map<String,List<Product_Fee__c>> retData = new Map<String,List<Product_Fee__c>> ();
        set<string> productGroup = new set<string>();
        List<Product_Fee__c> productFee = [select Product_Group__c from Product_Fee__c where Customer__c =: acct.ID
                                and data_source__c =: source and as_of_date__c =: nim.As_of_Date__c order by Product_Order__c ASC];
        
        for (Product_Fee__c a : productFee){
            productGroup.add(a.Product_Group__c);
            
        }

        for (string b: productGroup){
            System.debug(b);
            list<Product_Fee__c> pf = new list<Product_Fee__c>();            
                
            for (Product_Fee__c a : [select ID,Product_Group__c,Product_Type__c,
                                               Volume_YTD__c ,Transaction_YTD__c ,
                                               Volume_MTD__c , Transaction_MTD__c ,
                                               FEE_YTD__C,FEE_MTD__c
                                               from Product_Fee__c
                                               where Customer__c =: acct.ID and Product_Group__c =: b
                                               and data_source__c =:source
                                               and as_of_date__c =: nim.As_of_Date__c
                                               order by Product_Type__c]){                 
                if (a.Product_Group__c == b)
                    pf.add(a); 
            }
            
            retData.put(b, pf);
        }
        
        return retData;
    }
    
    public Map<String,wrapSumTradeFinance> getSumTradeFinance(Map<String,List<Product_Fee__c>> mapTradeFinance){
        map<string,wrapSumTradeFinance> retData = new map<string,wrapSumTradeFinance>();
        
        for(String productGroup : mapTradeFinance.keySet()){
            wrapSumTradeFinance w = new wrapSumTradeFinance();
            
            for (Product_Fee__c a : mapTradeFinance.get(productGroup)){
                if (a.Product_Group__c == productGroup)
                {
                    if (a.Volume_YTD__c != null) w.volumn_ytd += a.Volume_YTD__c;
                    if (a.Volume_MTD__c != null) w.volumn_mtd += a.Volume_MTD__c;
                    if (a.Transaction_YTD__c != null) w.no_of_transaction_ytd += a.Transaction_YTD__c;
                    if (a.Transaction_MTD__c != null) w.no_of_transaction_mtd += a.Transaction_MTD__c;
                    if (a.FEE_YTD__C != null) w.fee_ytd += a.FEE_YTD__C;
                    if (a.FEE_MTD__c != null) w.fee_mtd += a.FEE_MTD__c;
                }
            }
            
            retData.put(productGroup, w); 
        }
        return retData;
    }
    
    public Decimal checkNull(Decimal input){
        if(input == null)
            return 0;
        return input;
    }


    public class wrapProductInfo {
        public string header {get;set;}
        public list<Product_Performance__c> content {get;set;}
        public decimal sum1 {get;set;}
        public decimal sum2 {get;set;}
        public decimal sum3 {get;set;}
        public decimal sum4 {get;set;}
        public decimal sum5 {get;set;}
        public decimal sum6 {get;set;}
        public decimal sum7 {get;set;}
        public decimal sum8 {get;set;}
        public wrapProductInfo (string a, list<Product_Performance__c> b
                                , decimal c, decimal d, decimal e, decimal f
                                , decimal g, decimal h, decimal i, decimal j){
            header = a;
            content = b;
            sum1 = c; sum2 = d; sum3 = e; sum4 = f;
            sum5 = g; sum6 = h; sum7 = i; sum8 = j;
        }
    }
    
    public List<Product_Performance__c> slice(List<Product_Performance__c> productPerformance,Integer startIndex,Integer length){
        if(productPerformance.size() <= length) return productPerformance;
        List<Product_Performance__c> newList = new List<Product_Performance__c>();
        for(Integer i = startIndex ; i < startIndex+length; i++){
            newList.add(productPerformance[i]);
        }
        return newList;
    }
    
    public class wrapTradeFinanceInfo {
        public string header {get;set;}
        public list<Product_Fee__c> content {get;set;}
        public decimal sum1 {get;set;}
        public decimal sum2 {get;set;}
        public decimal sum3 {get;set;}
        public decimal sum4 {get;set;}
        public wrapTradeFinanceInfo (string a, list<Product_Fee__c> b
                                , decimal c, decimal d, decimal e, decimal f){
            header = a;
            content = b;
            sum1 = c; sum2 = d; sum3 = e; sum4 = f;
        }
    }
    
    public class wrapSumProduct {
        public decimal outstanding_ytd {get;set;}
        public decimal outstanding_mtd {get;set;}
        public decimal average_ytd {get;set;}
        public decimal average_mtd {get;set;}
        public decimal nimd_ytd {get;set;}
        public decimal nimd_mtd {get;set;}
        public decimal niid_ytd {get;set;}
        public decimal niid_mtd {get;set;}
        public decimal nimc_ytd {get;set;}
        public decimal nimc_mtd {get;set;}
        public decimal niic_ytd {get;set;}
        public decimal niic_mtd {get;set;}
        public wrapSumProduct(){
               outstanding_ytd = 0.00;               
               outstanding_mtd = 0.00;
               average_ytd = 0.00;               
               average_mtd = 0.00;
               nimd_ytd = 0.00;               
               nimd_mtd = 0.00;
               niid_ytd = 0.00;               
               niid_mtd = 0.00;
               nimc_ytd = 0.00;               
               nimc_mtd = 0.00;
               niic_ytd = 0.00;               
               niic_mtd = 0.00;
        }
    }
    
    public class wrapSumTradeFinance {
        public decimal volumn_ytd {get;set;}
        public decimal volumn_mtd {get;set;}
        public decimal no_of_transaction_ytd {get;set;}
        public decimal no_of_transaction_mtd {get;set;}
        public decimal fee_ytd {get;set;}
        public decimal fee_mtd {get;set;}

        public wrapSumTradeFinance(){
            volumn_ytd = 0.00;               
            volumn_mtd = 0.00;
            no_of_transaction_ytd = 0.00;               
            no_of_transaction_mtd = 0.00;
            fee_ytd = 0.00;
            fee_mtd = 0.00;
        }
    }

        // --------------------------------------------------------------------------------------
    public String section {get;set;}
    public String section1 {get;set;}
    public String section2 {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isVisible_product {get;set;}
    public Boolean isVisible_total {get;set;}
    public Boolean isLoadSuccess {get;set;}
    //public Account acct;

    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                hiddenText = system.Label.Data_Condition_Hidden_Text;
            }
            return hiddenText;
        }
        set;
    }
	public String notAuthorizedMsg {
        get{
            if( notAuthorizedMsg == null )
            {
                notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg;
            }
            return notAuthorizedMsg;
        }
        set;
    }
    /*public AccountDataPartitionExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        //isLoading = true;
        //isLoadSuccess = false;
    }*/

    public void loadData()
    {
        try{
        	section = apexpages.currentPage().getParameters().get('sectionName');            
        }catch(Exception e){
            this.section = section;
        }
        Account acctDetail = new Account();
        Profile userProfile = new Profile();

        try
        {
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :acct.id ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            //exception here
        }

        isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
        
        notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg;
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));
        
            //String accessLevel = RTL_AccountUtility.getAccountDataSecurity(section,userProfile.name,acctDetail.id);
            //isVisible = RTL_AccountUtility.getAccountAccessibility( acctDetail , accessLevel );
            system.debug('isVisible = '+isVisible);
        
    }
    
}