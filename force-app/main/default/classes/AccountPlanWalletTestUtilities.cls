public class AccountPlanWalletTestUtilities {
     public static List<AcctPlanStandardFee__c> stdFeeList {
        get
        {
            if(stdFeeList == null){
                createStandardFee();
            }
            return stdFeeList;
            
        }set;
    }
    
    public static void createStandardFee(){
        stdFeeList = new List<AcctPlanStandardFee__c>();
        AcctPlanStandardFee__c stdFee1 = new AcctPlanStandardFee__c();
        stdFee1.Name ='1';
        stdFee1.DomainName__c  = 'Domain I';
        stdFee1.PercentOfStandardFee__c  = true;
        stdFee1.SE_StandardFee__c   = 1;
        stdFee1.BB_StandardFee__c    = 10;
        stdFee1.ColumnName__c = '3) Bill Payment';
        stdFee1.Default_StandardFee__c =10;
        stdFee1.TableName__c  = 'Collection Method Domestic';
        insert stdFee1;
        AcctPlanStandardFee__c stdFee2 = new AcctPlanStandardFee__c();
        stdFee2.Name ='2';
        stdFee2.DomainName__c  = 'Domain I';
        stdFee2.PercentOfStandardFee__c  = true;
        stdFee2.SE_StandardFee__c   = 1;
        stdFee2.BB_StandardFee__c    = 10;
        stdFee2.Default_StandardFee__c =10;
        stdFee2.ColumnName__c = 'L/C Term';
        stdFee2.TableName__c  = 'Payment Method Import';
        insert stdFee2;
        AcctPlanStandardFee__c stdFee3 = new AcctPlanStandardFee__c();
        stdFee3.Name ='3';
        stdFee3.DomainName__c  = 'Domain I';
        stdFee3.PercentOfStandardFee__c  = true;
        stdFee3.SE_StandardFee__c   = 1;
        stdFee3.BB_StandardFee__c    = 10;
        stdFee3.ColumnName__c = '2) Export collection';
        stdFee3.Default_StandardFee__c =10;

        stdFee3.TableName__c  = 'Collection Method Export';
        insert stdFee3;
        
        
        AcctPlanStandardFee__c stdFee4 = new AcctPlanStandardFee__c();
        stdFee4.Name ='StandardFeePaymentImport1';
        stdFee4.DomainName__c  = 'Domain I';
        stdFee4.PercentOfStandardFee__c  = true;
        stdFee4.SE_StandardFee__c   = 1;
        stdFee4.BB_StandardFee__c    = 10;
        stdFee4.ColumnName__c = 'L/C Sign';
        stdFee4.Default_StandardFee__c =10;
        stdFee4.TableName__c  = 'Payment Method Import	';
        insert stdFee4;
        
        AcctPlanStandardFee__c stdFee5 = new AcctPlanStandardFee__c();
        stdFee5.Name ='StandardFeePaymentImport3';
        stdFee5.DomainName__c  = 'Domain I';
        stdFee5.PercentOfStandardFee__c  = true;
        stdFee5.SE_StandardFee__c   = 1;
        stdFee5.BB_StandardFee__c    = 10;
        stdFee5.ColumnName__c = 'L/C Term 2';
        stdFee5.Default_StandardFee__c =10;
        stdFee5.TableName__c  = 'Payment Method Import	';
        insert stdFee5;
    }
    
    public static void createBanks(){
        Bank__c bank1 = new Bank__c();
        bank1.Name ='Others';
        Bank__c bank2 = new Bank__c();
        bank2.Name ='TMB';
        insert bank1;
        insert bank2;
    }
    
    public static void createCurrencies(){
        
        Currency__c usdcurrency = new Currency__c();
        usdcurrency.Name ='USD';
        usdcurrency.ShortName__c ='USD';
        usdcurrency.FlagForAcctPlan__c = true;
        insert usdcurrency;
        
        
                
    }
    
    public static Currency__c jpycurrency{get{
        if(jpycurrency ==null){
            Exchange_Rate_Of_Thai_FCY__c  jpyEx = new Exchange_Rate_Of_Thai_FCY__c ();
            jpyEx.Currency_Full_Name__c ='Japan Yen';
            jpyEx.Name__c ='JPY';
            jpyEx.ExchangeRateOfTHB__c = 0.0001;
            insert jpyEx;
            jpycurrency = new Currency__c();
            jpycurrency.Name ='JPY';
            jpycurrency.Exchange_Rate__c = jpyEx.id;
            jpycurrency.ShortName__c ='JPY';
            jpycurrency.FlagForAcctPlan__c = true;
            insert jpycurrency;
        }
        return jpycurrency;
    }set;}

    public static AcctPlanWallet__c createAccountPlanWallet(ID CompanyID,boolean isInsert){
        AcctPlanWallet__c wallet = new AcctPlanWallet__c ();
         wallet.AcctPlanCompanyProfile__c = CompanyID;
         wallet.EstimatedSalesAmtPerYear__c = 10000000;
                        wallet.TotalDomesticPercent__c = 30;
                        wallet.COGSPercent__c = 50;
                        wallet.OperatingExpAmount__c = 3000000;
                        wallet.TotalPaymentDomesticPercent__c = 30;
         
        if(isInsert){
            insert wallet;
        }
        return wallet;
	}
    public static List<AcctPlanCollectionOrPaymentCurrency__c> createWalletCurrency(ID AcctWallet){
       
        
        List<AcctPlanCollectionOrPaymentCurrency__c> currencyList = new List<AcctPlanCollectionOrPaymentCurrency__c>();
        AcctPlanCollectionOrPaymentCurrency__c  collection = new  AcctPlanCollectionOrPaymentCurrency__c();
        collection.AcctPlanWallet__c  = AcctWallet;
        collection.Currency_Type__c = 'Collection';
        collection.CollectionPortion__c = 50;
        collection.CCY__c = jpycurrency.id;
        currencyList.add(collection);
        AcctPlanCollectionOrPaymentCurrency__c  payment = new  AcctPlanCollectionOrPaymentCurrency__c();
        payment.AcctPlanWallet__c  = AcctWallet;
        payment.Currency_Type__c = 'Payment';
        payment.PaymentPortion__c = 50;
        payment.CCY__c = jpycurrency.id;
        currencyList.add(payment);
        
        insert currencyList;
        
        return currencyList;
    }
    
    public static List<AcctPlanWalletCreditFacility__c> CreateCreditFacility(ID AcctWallet){
       Bank__c bank2 = new Bank__c();
        bank2.Name ='SCB';
        insert bank2;
        
        List<AcctPlanWalletCreditFacility__c> creditList = new List<AcctPlanWalletCreditFacility__c>();
        AcctPlanWalletCreditFacility__c  credit1 = new  AcctPlanWalletCreditFacility__c();
        credit1.Segment__c = 'International';
        credit1.CreditType__c = 'Test';
        credit1.AcctPlanWallet__c = acctwallet;
        credit1.Outstanding__c  = 100;
        credit1.LimitAmount__c = 100;
        credit1.Bank__c = bank2.id;
        creditList.add(credit1);
		AcctPlanWalletCreditFacility__c  credit2 = new  AcctPlanWalletCreditFacility__c();
        credit2.Segment__c = 'Domestic';
        credit2.CreditType__c = 'Test';
        credit2.AcctPlanWallet__c = acctwallet;
        credit2.Outstanding__c  = 100;
        credit2.LimitAmount__c = 100;
        credit2.Bank__c = bank2.id;
        creditList.add(credit2); 
        AcctPlanWalletCreditFacility__c  credit3 = new  AcctPlanWalletCreditFacility__c();
        credit3.Segment__c = 'ImportTransaction';
        credit3.CreditType__c = 'Test';
        credit3.AcctPlanWallet__c = acctwallet;
        credit3.Outstanding__c  = 100;
        credit3.LimitAmount__c = 100;
        credit3.Bank__c = bank2.id;
        creditList.add(credit3);       
         AcctPlanWalletCreditFacility__c  credit4 = new  AcctPlanWalletCreditFacility__c();
        credit4.Segment__c = 'ExportTransaction';
        credit4.CreditType__c = 'Test';
        credit4.AcctPlanWallet__c = acctwallet;
        credit4.Outstanding__c  = 100;
        credit4.LimitAmount__c = 100;
        credit4.Bank__c = bank2.id;
        creditList.add(credit4);
        insert creditList;
        return creditList;
    }
    
    public static List<AcctPlanExistingLongTermLoan__c> CreateLongTermLoan(ID AcctWallet){
       Bank__c bank2 = new Bank__c();
        bank2.Name ='KTB';
        insert bank2;
        
        List<AcctPlanExistingLongTermLoan__c> longtermlist = new List<AcctPlanExistingLongTermLoan__c>();
        AcctPlanExistingLongTermLoan__c  longterm = new  AcctPlanExistingLongTermLoan__c();
        longterm.AcctPlanWallet__c = AcctWallet;
        longterm.Bank__c = bank2.id;
        longterm.CCY__c = jpycurrency.id;
        longterm.InterestType__c = 'Fixed Rate';
        longtermlist.add(longterm);
		
        insert longtermlist;
        
        List<AcctPlanCapitalExpenditurePlan__c> expenditurelist = new List<AcctPlanCapitalExpenditurePlan__c>();
        AcctPlanCapitalExpenditurePlan__c  expend = new  AcctPlanCapitalExpenditurePlan__c();
        expend.AcctPlanWallet__c = AcctWallet;
        expenditurelist.add(expend);
		
        insert expenditurelist;
        
        return longtermlist;
    }
    
    
    public static void createQuestionnaireTemplate(){
        List<AcctPlan_Questionnaire_Template__c> qtList = new List <AcctPlan_Questionnaire_Template__c>();
        AcctPlan_Questionnaire_Template__c qt1 = new AcctPlan_Questionnaire_Template__c ();
        qt1.Account_Plan_Page_Name__c = 'Domain I';
        qt1.Segment__c = 'Domestic Collection Method';
        qt1.Question__c = 'test1';
        qt1.Answer_Field_Type__c = 'Yes or No';
        qt1.SEQ__c = 1;
        qtList.add(qt1);
        
        AcctPlan_Questionnaire_Template__c qt4 = new AcctPlan_Questionnaire_Template__c ();
        qt4.Account_Plan_Page_Name__c = 'Domain I';
        qt4.Segment__c = 'Export Collection Method';
        qt4.Question__c = 'test1';
        qt4.Answer_Field_Type__c = 'Yes or No';
        qt4.SEQ__c = 1;
        qtList.add(qt4);
        
        AcctPlan_Questionnaire_Template__c qt6 = new AcctPlan_Questionnaire_Template__c ();
        qt6.Account_Plan_Page_Name__c = 'Domain I';
        qt6.Segment__c = 'Collection Questionnaire';
        qt6.Question__c = 'test1';
        qt6.Answer_Field_Type__c = 'Yes or No';
        qt6.SEQ__c = 1;
        qtList.add(qt6);
        
        AcctPlan_Questionnaire_Template__c qt9 = new AcctPlan_Questionnaire_Template__c ();
        qt9.Account_Plan_Page_Name__c = 'Domain I';
        qt9.Segment__c = 'Payment Method Import';
        qt9.Question__c = 'test1';
        qt9.Answer_Field_Type__c = 'Yes or No';
        qt9.SEQ__c = 1;
        qtList.add(qt9);
        
        AcctPlan_Questionnaire_Template__c qt11 = new AcctPlan_Questionnaire_Template__c ();
        qt11.Account_Plan_Page_Name__c = 'Domain I';
        qt11.Segment__c = 'Domestic Payment Method';
        qt11.Question__c = 'test1';
        qt11.Answer_Field_Type__c = 'Yes or No';
        qt11.SEQ__c = 1;
        qt11.Sub_Segment__c = 'Cash Transaction';
        qtList.add(qt11);
        
        AcctPlan_Questionnaire_Template__c qt13 = new AcctPlan_Questionnaire_Template__c ();
        qt13.Account_Plan_Page_Name__c = 'Domain I';
        qt13.Segment__c = 'Domestic Payment Method';
        qt13.Question__c = 'test1';
        qt13.Answer_Field_Type__c = 'Yes or No';
        qt13.SEQ__c = 3;
        qt13.Sub_Segment__c = 'Cheque Trasaction';
        qtList.add(qt13);
        
        AcctPlan_Questionnaire_Template__c qt17 = new AcctPlan_Questionnaire_Template__c ();
        qt17.Account_Plan_Page_Name__c = 'Domain I';
        qt17.Segment__c = 'Domestic Payment Method';
        qt17.Question__c = 'test1';
        qt17.Answer_Field_Type__c = 'Yes or No';
        qt17.SEQ__c = 7;
        qt17.Sub_Segment__c = 'Payroll Transaction';
        qtList.add(qt17);
        
        AcctPlan_Questionnaire_Template__c qt19 = new AcctPlan_Questionnaire_Template__c ();
        qt19.Account_Plan_Page_Name__c = 'Domain I';
        qt19.Segment__c = 'Domestic Payment Method';
        qt19.Question__c = 'test1';
        qt19.Answer_Field_Type__c = 'Yes or No';
        qt19.SEQ__c = 9;
        qt19.Sub_Segment__c = 'Fleet card Transaction';
        qtList.add(qt19);
        
        insert qtlist;
        
    }
    
    public static void createQuestionniare(ID AcctWallet){
        Set<String> DomesticPaymentSegment = new Set<String>();  
         List <AcctPlan_Questionnaire_Template__c> QTemplateList =  [SELECT ID,
                            Account_Plan_Page_Name__c ,
                            Answer_Field_Type__c ,
                            Opportunity__c,
                            Product_Label__c,
                             Sub_Domain__c,
                            Question__c ,
                            Question_TH__c,
                            Segment__c,
                            SEQ__c ,
                            Sub_Segment__c ,
                            Sub_Segment_SEQ__c 
                            FROM AcctPlan_Questionnaire_Template__c
                            WHERE Account_Plan_Page_Name__c =: 'Domain I '
                            ORDER BY  SEQ__c ASC,Sub_Segment_SEQ__c ASC
                            ];
			          
        	  Map<String,List< AcctPlan_Questionnaire_Template__c> > QTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
			  Set<String> QSegmentList = new Set<String>();         
                 for(AcctPlan_Questionnaire_Template__c QT : QTemplateList){
                     String Segment;
                     if(qt.Sub_Segment__c !=null){
                         Segment = qt.Sub_Segment__c;
                         DomesticPaymentSegment.add(qt.Sub_Segment__c);
                     }else{
                         Segment = qt.Segment__c;
                     }
                     if(QTemplateMap.containsKey(Segment)){
                         QTemplateMap.get(Segment).add(qt);
                     }else{
                        QSegmentList.add(Segment); 
                        List< AcctPlan_Questionnaire_Template__c>  QTList = new List< AcctPlan_Questionnaire_Template__c>();
                         QTList.add(qt);
                         QTemplateMap.put(Segment,QTList);
                         
                     }
                     
                 }
    }
    
    public static void createWalletDomainITables(ID AcctWallet){
         List <String> CollectionDomesticMetholdLabel = new List<String>{ '1) Cash', '2) Cheque','- ในเขต', '- นอกเขต','3) Bill Payment','4) Transfer', '5) Card','- EDC','- E-Commerce'};
         List <String>    CollectionExportMetholdLabel = new List<String>{ '1) Inward Remittance', '2) Export collection','B/C Sight (D/P)', 'B/C Term (D/A)','3) Advice L/C','L/C Sight', 'L/C Term'};
         List <String>    PaymentImportMetholdLabel = new List<String>{ '1) Outward Remittance', '2) Bill','B/C Sight (D/P)', 'B/C Term (D/A)','3) Import L/C','L/C Sight', 'L/C Term','L/C Term 2'};
         List <String>    PaymentMetholdLabel = new List<String>{'1) Cash','2) Cheque'
                 ,'2.1 จำนวนเช็คที่ทางบริษัทออกเอง'
                 ,'2.2 จำนวนเช็คที่ใช้บริการธนาคารออกเช็คให้'
                 ,'2.3 จำนวนเช็คในเขต'
                 ,'2.4 จำนวนเช็คข้ามเขต'
                 ,'3) Fund Transfer'
                 ,'3.1 Bahtnet'
                 ,'3.2 SMART credit'
                 ,'3.3 Direct credit'
                 ,'4) Payroll','5) Fleet card'};    
          List <String>   DomesticPaymentMethodLabel = new List<String>{'Cash Transaction','Cheque Trasaction','Payroll Transaction','Fleet card Transaction'};
   		  
          //Initial Maps 
             Map<String,AcctPlanCollectionDomestic__c> CollectionDomesticMap = new  Map<String,AcctPlanCollectionDomestic__c>();
             Map<String,AcctPlanCollectionExport__c> CollectionExportMap = new Map<String,AcctPlanCollectionExport__c >();
             Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
             Map<String,AcctPlanPaymentDomestic__c> PaymentDomesticMap = new Map<String,AcctPlanPaymentDomestic__c >();
             Map<String,AcctPlanPaymentImport__c> PaymentImportMap = new Map<String,AcctPlanPaymentImport__c  >();
		
        Map<String,Double> StandardFeeTMB = new Map<String,Double>();
        for(AcctPlanStandardFee__c stdfee :stdFeeList){
             StandardFeeTMB.put(stdfee.ColumnName__c,Double.valueOf(stdfee.BB_StandardFee__c));
        }
        
        for(String label : CollectionDomesticMetholdLabel){
                   AcctPlanCollectionDomestic__c Collectiondomestic = new AcctPlanCollectionDomestic__c();
                     Collectiondomestic.Label__c = label;
                     Collectiondomestic.AcctPlanCollectionMethodDomestic__c = AcctWallet;
                     if(StandardFeeTMB.containsKey(label)){
                        	 Collectiondomestic.VolumePercent__c =1;
                             Collectiondomestic.StandardFee__c = 0;
                              Collectiondomestic.FeeCharge__c = 0;
                            Collectiondomestic.NoOfTransaction__c = 1;
                         }
                     CollectionDomesticMap.put(label,Collectiondomestic);
                 }
        
         for(String label : CollectionExportMetholdLabel){
                   AcctPlanCollectionExport__c CollectionExport = new AcctPlanCollectionExport__c();
                     CollectionExport.Label__c = label;
             		 CollectionExport.VolumnPercent__c = 1;
                     CollectionExport.AcctPlanCollectionMethodExport__c =AcctWallet;
                     CollectionExportMap.put(label,CollectionExport);
                 }
        
         for(String label : PaymentMetholdLabel){
                   AcctPlanPaymentDomestic__c PaymentDomestic = new AcctPlanPaymentDomestic__c();
                     PaymentDomestic.Label__c = label;
                     PaymentDomestic.AcctPlanPaymentMethodDomestic__c =AcctWallet;
                      if(StandardFeeTMB.containsKey(label)){
                          PaymentDomestic.StandardFee__c = 0;
                          PaymentDomestic.VolumePercent__c = 0;
                          PaymentDomestic.FeeCharge__c = 0;
                      }
                     PaymentDomesticMap.put(label,PaymentDomestic);
                 }
        
        
        			Map<String,String> PaymentImportType= new Map<String,String>();
        			 PaymentImportType.put('L/C Sight','L/C Commission');
        			 PaymentImportType.put('L/C Term','L/C Commission');
        			 PaymentImportType.put('L/C Term 2','Engagement Fee');
                  for(String label : PaymentImportMetholdLabel){
                   AcctPlanPaymentImport__c PaymentImport = new AcctPlanPaymentImport__c();
                     PaymentImport.Label__c = label;
                     PaymentImport.VolumePercent__c = 4;
                     paymentImport.Volume__c = 100;
                     paymentImport.NoOfTransaction__c = 10;
                     paymentImport.AcctPlanPaymentMethodImport__c = AcctWallet;
                      if(PaymentImportType.containsKey(label)){
                          PaymentImport.Type_of_Fee__c = PaymentImportType.get(label);                          
                          if(PaymentImport.Type_of_Fee__c =='L/C Commission'){
                             PaymentImport.StandardFee__c =0;
                             PaymentImport.FeeCharge__c = 0;
                         }else if (PaymentImport.Type_of_Fee__c =='Engagement Fee'){
                             PaymentImport.StandardFee__c = 1;
                             PaymentImport.FeeCharge__c = 1;
                         } 
                          
                      }
                     PaymentImportMap.put(label,PaymentImport);
                 }
        
         insert  CollectionDomesticMap.values(); 
        insert  CollectionExportMap.values(); 
        insert  PaymentDomesticMap.values(); 
        insert  PaymentImportMap.values(); 	  
        
        
        
        
        
              
    }
    
    
    
    
    
    
    
}