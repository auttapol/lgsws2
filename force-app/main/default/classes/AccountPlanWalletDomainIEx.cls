public without sharing class AccountPlanWalletDomainIEx {
    public String CompanyID {get;set;}
    public String GroupID {get;set;}
    public String WalletID {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isSystemAdmin {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public Map<String,AcctPlanCollectionDomestic__c> CollectionDomesticMap {get;set;}
    public Map<String,AcctPlanCollectionExport__c > CollectionExportMap {get;set;}
    public Map<String,AcctPlanPaymentDomestic__c > PaymentDomesticMap {get;set;}
    public Map<String,AcctPlanPaymentImport__c  > PaymentImportMap {get;set;}
    public AcctPlanWallet__c wallet {get;set;}
    public List<String> CollectionDomesticMetholdLabel {get;set;}
    public List<String> CollectionExportMetholdLabel {get;set;}
    public List<String> PaymentImportMetholdLabel {get;set;}
    public List<String> PaymentMetholdLabel {get;set;}
    public List<String> DomesticPaymentMethodLabel {get;set;}
    public List<AcctPlanQuestionnaire__c > QuestionnaireList {get;set;}
    public Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap {get;set;}
    public Map<String,List<string> > DomesticpaymentQ {get;set;}
    public  Set<String> DomesticPaymentSegment {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> CollectionList {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> PaymentList {get;set;}
    public Map<String,Double> StandardFeeTMB {get;set;}
    public Map<String,String> PaymentImportType {get;set;}
    public List<AcctPlan_Questionnaire_Template__c> QTemplateList {get;set;}
    public Map<String,List< AcctPlan_Questionnaire_Template__c> > QTemplateMap {get;set;}
    public Double TotalCollectiondomestic {get;set;}
    public AcctPlanWalletOtherBank__c otherBankCollectionDomestic {get;set;}
    public AcctPlanWalletOtherBank__c otherBankCollectionExport {get;set;}
    public AcctPlanWalletOtherBank__c otherBankPaymentDomestic {get;set;}
    public AcctPlanWalletOtherBank__c otherBankPaymentImport {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public Boolean isMiniView {get;set;}
    public Double tempEstimatedSalesAmtPerYear {get;set;}
    public Double tempEstimatedSalesPercent {get;set;}
    public double tempTotalDomesticPercent {get;set;}
    public Double tempTotalDomesticAmtPerYear {get;set;}
    public double tempTotalExportPercent {get;set;}
    public double tempTotalExportAmtPerYear {get;set;}
    public double tempCOGSPercent {get;set;}
    public Double tempCOGSAmount {get;set;}
    public Double tempOperatingExpAmount {get;set;}
    public double tempTotalPaymentPercent {get;set;}
    public double tempTotalPaymentAmount {get;set;}
    public double tempTotalPaymentDomesticPercent {get;set;}
    public double tempTotalPaymentDomesticAmtPerYear {get;set;}
    public double tempTotalPaymentImportPercent {get;set;}
    public double tempTotalPaymentImportAmtPerYear {get;set;}
    public double CollectionMethodExportStandardFee {get;set;}
    public String segmentOwner {get;set;}
    public String tempEstimatedSalesAmtPerYearStr {get;set;}
    public String tempOperatingExpAmountStr  {get;set;}
    public String tempTotalDomesticPercentStr  {get;set;}
    public String tempCOGSPercentStr  {get;set;}
    public String tempTotalPaymentDomesticPercentStr {get;set;}
    public List <AcctPlanCollectionDomestic__c> collectdomesticlist {get;set;}
    public List<AcctPlanCollectionExport__c> cExportList {get;set;}
    public List<AcctPlanPaymentDomestic__c > pDomesticList {get;set;}
    public List<AcctPlanPaymentImport__c > pImportList {get;set;}
    public Boolean isRequiredCollectionMethod {get;set;}
	public Boolean isRequiredBillPayment {get;set;}
    public Boolean isRequiredColletionExport {get;set;}
    public Boolean isRequiredPaymentMethod {get;set;}
    public Boolean isRequiredPaymentImport {get;set;}
    public Boolean IsHasCollectionExport {get;set;}
    public Boolean IsHasPaymentDomestic {get;set;}
    public Boolean IsHasPaymentImport {get;set;}
    public boolean isHasPermission {get;set;}
    public Boolean isCollectCurrencyNull {get{
        if(wallet.TotalExportPercent__c !=null && wallet.TotalExportPercent__c !=0){
        if(CollectionList !=null){
            if(CollectionList.size()>0){
                return false;
            }
        }
        }else{
            return false;
        }
        return true;
        
    }set;}
    public Boolean isPaymentCurrencyNull {get{
        if(wallet.TotalPaymentImportPercent__c !=null && wallet.TotalPaymentImportPercent__c !=0){
             if(PaymentList !=null){
            if(PaymentList.size()>0){
                return false;
            }
        }
        }else{
            return false;
        }
        return true;
        
    }set;}

    
    
    public void DynamicQuestionnaire(){
   		Map<Integer,AcctPlanQuestionnaire__c> DynamicQuestionMap = new Map<Integer,AcctPlanQuestionnaire__c>();
        for(String segment : DomesticPaymentSegment){
            for(AcctPlanQuestionnaire__c question :QuestionnaireMap.get(segment)){
              DynamicQuestionMap.put(Integer.valueOf(question.SEQ__c),question);
            }
        }
        
        
        //3-4
        if(DynamicQuestionMap.get(3).Answer__c =='Yes' && DynamicQuestionMap.get(4).Answer__c == 'Yes'){
            System.debug(DynamicQuestionMap.get(4).Question__c);
            DynamicQuestionMap.get(4).Opportunity__c = QTemplateMap.get('Cheque Trasaction').get(1).Opportunity__c;
        }else{
            DynamicQuestionMap.get(4).Opportunity__c = '';
        }
        
        // 7-8
           if(DynamicQuestionMap.get(7).OptionNumber__c !=null && DynamicQuestionMap.get(8).Answer__c == 'Yes'){
               if(DynamicQuestionMap.get(7).OptionNumber__c  >0){
                  DynamicQuestionMap.get(8).Opportunity__c = QTemplateMap.get('Payroll Transaction').get(1).Opportunity__c;
               }
        }else{
           DynamicQuestionMap.get(8).Opportunity__c = '';
           //DynamicQuestionMap.get(8).Opportunity__c = QTemplateMap.get('Payroll Transaction').get(1).Opportunity__c;              
        }
        
        //9
        // 10-11
        System.debug( QTemplateMap.get('Fleet card Transaction').get(2).Opportunity__c);
       if(DynamicQuestionMap.get(9).Answer__c == 'Yes'){
           System.debug(DynamicQuestionMap.get(10).OptionPercent__c );
           System.debug(DynamicQuestionMap.get(11).OptionText__c);
           if(DynamicQuestionMap.get(10).OptionPercent__c  !=null && DynamicQuestionMap.get(10).OptionPercent__c >0
             && DynamicQuestionMap.get(11).OptionText__c !=null && DynamicQuestionMap.get(11).OptionText__c !=null){
               DynamicQuestionMap.get(11).Opportunity__c = QTemplateMap.get('Fleet card Transaction').get(2).Opportunity__c;
               DynamicQuestionMap.get(11).Answer__c = 'Yes'; 
             }else{
                  DynamicQuestionMap.get(11).Opportunity__c = null;
             }
           
            DynamicQuestionMap.get(12).Answer__C =null;
            DynamicQuestionMap.get(13).Answer__C =null;   
            DynamicQuestionMap.get(12).Opportunity__c = null;
            DynamicQuestionMap.get(13).Opportunity__c = null;
           //9
           //12-13
        }else if(DynamicQuestionMap.get(9).Answer__c == 'No'){
            if(DynamicQuestionMap.get(12).Answer__c == 'Yes'  && DynamicQuestionMap.get(13).Answer__c =='Yes' ){
               DynamicQuestionMap.get(12).Opportunity__c = QTemplateMap.get('Fleet card Transaction').get(3).Opportunity__c;
               DynamicQuestionMap.get(13).Opportunity__c = QTemplateMap.get('Fleet card Transaction').get(4).Opportunity__c;
            }else{
                 DynamicQuestionMap.get(12).Opportunity__c = null;
                 DynamicQuestionMap.get(13).Opportunity__c = null;
            }
            
		    DynamicQuestionMap.get(10).OptionPercent__c =null;
            DynamicQuestionMap.get(11).OptionText__c =null;
             DynamicQuestionMap.get(11).Opportunity__c = null;
        }
       
        System.debug(DynamicQuestionMap.get(11).Opportunity__c);
    }
        
    public pagereference CalculateWallet(){
        Boolean invalid = false;
        try{
            tempEstimatedSalesAmtPerYearStr = String.valueOf(tempEstimatedSalesAmtPerYearStr).replaceAll(',','');
            tempOperatingExpAmountStr = String.valueOf(tempOperatingExpAmountStr).replaceAll(',','');
            tempTotalDomesticPercentStr = String.valueof(tempTotalDomesticPercentStr.rePlaceAll('%',''));
            tempCOGSPercentStr = String.valueof(tempCOGSPercentStr.rePlaceAll('%',''));
            tempTotalPaymentDomesticPercentStr = String.valueof(tempTotalPaymentDomesticPercentStr.rePlaceAll('%',''));
            if(tempEstimatedSalesAmtPerYearStr != ''){
                tempEstimatedSalesAmtPerYear = Double.valueOf(tempEstimatedSalesAmtPerYearStr);
            }
            if(tempOperatingExpAmountStr != ''){
                tempOperatingExpAmount = Double.valueOf(tempOperatingExpAmountStr);
            }
            if(tempTotalDomesticPercentStr != ''){
                tempTotalDomesticPercent = Double.valueOf(tempTotalDomesticPercentStr);  
            }
            if(tempCOGSPercentStr != '' ){
                tempCOGSPercent = Double.valueOf(tempCOGSPercentStr);  
            }
            if(tempTotalPaymentDomesticPercentStr != '' ){
                tempTotalPaymentDomesticPercent = Double.valueOf(tempTotalPaymentDomesticPercentStr);
            }
                           
            if(tempEstimatedSalesAmtPerYear >0 &&tempEstimatedSalesAmtPerYear !=null){
               tempEstimatedSalesPercent = 100;
                System.debug(tempTotalDomesticPercent);
                if(tempTotalDomesticPercent >= 0  && tempTotalDomesticPercent !=null 
                   &&tempTotalDomesticPercentStr != '' && tempTotalDomesticPercent <=100){
                    tempTotalDomesticAmtPerYear = tempEstimatedSalesAmtPerYear *(tempTotalDomesticPercent/100);
                    tempTotalExportPercent = tempEstimatedSalesPercent - tempTotalDomesticPercent;
                    tempTotalExportAmtPerYear = tempEstimatedSalesAmtPerYear - tempTotalDomesticAmtPerYear;
                }else{invalid = true;}
                
                
                if(tempCOGSPercent >0 && tempCOGSPercent !=null && tempCOGSPercent <=100){
                    tempCOGSAmount = tempEstimatedSalesAmtPerYear *(tempCOGSPercent/100);
                    
                    if(tempOperatingExpAmount >= 0 
                       && tempOperatingExpAmount !=null
                      &&tempOperatingExpAmountStr !=''){
                          
                        tempTotalPaymentPercent = 100;
                        tempTotalPaymentAmount = tempOperatingExpAmount + tempCOGSAmount;   
                    }else if ( tempOperatingExpAmountStr !='' && tempOperatingExpAmount ==0 ){
                        tempTotalPaymentPercent = 100;
                        tempTotalPaymentAmount = tempCOGSAmount;    
                    }
                    
                    
                    
                    //Total Payment Percent
                    //
                     if(tempTotalPaymentDomesticPercent >=0 
                           && tempTotalPaymentDomesticPercent !=null 
                           && tempTotalPaymentDomesticPercentStr !=''
                           && tempTotalPaymentDomesticPercent <=100){
                           
                            tempTotalPaymentDomesticAmtPerYear = tempTotalPaymentAmount * (tempTotalPaymentDomesticPercent/100);
                            tempTotalPaymentImportPercent = tempTotalPaymentPercent - tempTotalPaymentDomesticPercent;
                            tempTotalPaymentImportAmtPerYear =  tempTotalPaymentAmount * (tempTotalPaymentImportPercent/100);
                        }else{
                            tempTotalPaymentDomesticAmtPerYear = 0;
                            tempTotalPaymentImportPercent= 0;
                            tempTotalPaymentImportAmtPerYear =0;
                        }
                    
                    
                    
                }else{		tempCOGSAmount = 0;
                            tempTotalPaymentPercent = 0;
                            tempTotalPaymentAmount = 0;
                            tempTotalPaymentDomesticAmtPerYear = 0;
                            tempTotalPaymentImportPercent= 0;
                            tempTotalPaymentImportAmtPerYear =0;
                    
                    
                            tempTotalPaymentPercent = 0;
                            tempTotalPaymentAmount = 0;
                            tempTotalPaymentDomesticAmtPerYear = 0;
                            tempTotalPaymentImportPercent= 0;
                            tempTotalPaymentImportAmtPerYear =0;
                    
                } 
                
                
            }else{
               tempEstimatedSalesPercent =0;
                invalid = true;
            }
            
            
            
            if(invalid){
                tempTotalDomesticPercent = null;
                tempTotalExportPercent = null;
                tempTotalDomesticAmtPerYear = null;
                tempTotalExportAmtPerYear = null;
                
                tempCOGSPercent = null;      
                tempCOGSAmount = null;
                tempOperatingExpAmount = null;
                tempTotalPaymentPercent = null;
                tempTotalPaymentAmount = null;      
                tempTotalPaymentDomesticPercent = null;
                tempTotalPaymentDomesticAmtPerYear = null;
                tempTotalPaymentImportPercent = null;
                tempTotalPaymentImportAmtPerYear =  null;  
                
            }
        }catch(Exception E){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
            return null;
        }
         return null;
    }

     public AccountPlanWalletDomainIEx(ApexPages.StandardController controller){
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
         WalletID= ApexPages.currentPage().getParameters().get('WalletId');
         mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
          if(CompanyID !=null && CompanyID != ''){
        tempEstimatedSalesPercent = null;
        tempTotalDomesticPercent = null;
        tempTotalDomesticAmtPerYear= null;
        tempTotalExportPercent = null;
		tempTotalExportAmtPerYear = null;
          
        tempCOGSPercent = null;      
        tempCOGSAmount = null;
    	tempOperatingExpAmount = null;
    	tempTotalPaymentPercent = null;
        tempTotalPaymentAmount = null;      
    	tempTotalPaymentDomesticPercent = null;
    	tempTotalPaymentDomesticAmtPerYear = null;
    	tempTotalPaymentImportPercent = null;
    	tempTotalPaymentImportAmtPerYear =  null;   
              // Config Questionnaire and Labels
             CollectionDomesticMetholdLabel = new List<String>{ '1) Cash', '2) Cheque','- ในเขต', '- นอกเขต','3) Bill Payment','4) Transfer', '5) Card','- EDC','- E-Commerce'};
             CollectionExportMetholdLabel = new List<String>{ '1) Inward Remittance', '2) Export collection','B/C Sight (D/P)', 'B/C Term (D/A)','3) Advice L/C','L/C Sight', 'L/C Term'};
             PaymentImportMetholdLabel = new List<String>{ '1) Outward Remittance', '2) Bill','B/C Sight (D/P)', 'B/C Term (D/A)','3) Import L/C','L/C Sight', 'L/C Term','L/C Term 2'};
             
             PaymentMetholdLabel = new List<String>{'1) Cash','2) Cheque'
                 ,'2.1 จำนวนเช็คที่ทางบริษัทออกเอง'
                 ,'2.2 จำนวนเช็คที่ใช้บริการธนาคารออกเช็คให้'
                 ,'2.3 จำนวนเช็คในเขต'
                 ,'2.4 จำนวนเช็คข้ามเขต'
                 ,'3) Fund Transfer'
                 ,'3.1 Bahtnet'
                 ,'3.2 SMART credit'
                 ,'3.3 Direct credit'
                 ,'4) Payroll','5) Fleet card'};    
             DomesticPaymentMethodLabel = new List<String>{'Cash Transaction','Cheque Trasaction','Payroll Transaction','Fleet card Transaction'};
             CollectionList = new List<AcctPlanCollectionOrPaymentCurrency__c >();
             PaymentList = new List<AcctPlanCollectionOrPaymentCurrency__c >();
             DomesticPaymentSegment = new Set<String>();       
             
             
                 
             //Initial Maps
             CollectionDomesticMap = new  Map<String,AcctPlanCollectionDomestic__c>();
             CollectionExportMap = new Map<String,AcctPlanCollectionExport__c >();
             QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
             PaymentDomesticMap = new Map<String,AcctPlanPaymentDomestic__c >();
             PaymentImportMap = new Map<String,AcctPlanPaymentImport__c  >();
             PaymentImportType = new Map<String,String>();
             StandardFeeTMB = new Map<String,Double>();
             DomesticpaymentQ = new Map<String,List<String>>();
             //Query
              companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
               
              	ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
                isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
                isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
                isSystemAdmin= AccountPlanUtilities.isSystemAdmin;
              if(AccountPlanUtilities.OWNERSEGMENT != null){
                  isMiniView = AccountPlanUtilities.ISMINIVIEW;
                  segmentOwner = AccountPlanUtilities.OWNERSEGMENT;
              }else{
                  isMiniView = false;
                  segmentOwner = 'Default';
              }
              
              //Initial Total objects
             TotalCollectiondomestic = 0;
             //Setting Wallet   
             boolean isHasCollectionDomestic = true;
             boolean isHasCollectionExport = true;
             boolean isHasPaymentDomestic = true;
             boolean isHasPaymentImport = true;
              
             //Set Standard Fee
             CollectionMethodExportStandardFee = 0;
              List<AcctPlanStandardFee__c> standardFee = new List<AcctPlanStandardFee__c>();
              Database.QueryLocator qStandardFee = Database.getQueryLocator('SELECT ColumnName__c , PercentOfStandardFee__c,TableName__c, TypeOfFee__c,'+segmentOwner+'_StandardFee__c FROM AcctPlanStandardFee__c WHERE DomainName__c = \'Domain I\' order by TableName__c');
              Database.QueryLocatorIterator itStandardFee =  qStandardFee.iterator();
              while (itStandardFee.hasNext()){
                  AcctPlanStandardFee__c stdFee = (AcctPlanStandardFee__c)itStandardFee.next();
                  standardFee.add(stdFee);
                  if(stdFee.TableName__c == 'Collection Method Domestic' || stdFee.TableName__c == 'Payment Method Domestic'){
                      StandardFeeTMB.put(stdFee.ColumnName__c,Double.valueOf(stdFee.get(segmentOwner+'_StandardFee__c')));
                  }else if(stdFee.TableName__c == 'Payment Method Import'){
                      PaymentImportType.put(stdFee.ColumnName__c,stdFee.TypeOfFee__c);
                  }else if(stdFee.TableName__c == 'Collection Method Export'){
                      CollectionMethodExportStandardFee = Double.valueOf(stdFee.get(segmentOwner+'_StandardFee__c'));
                  }
              }
              
         List <AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
              
              
                String strurl = ApexPages.currentPage().getUrl();
                strurl = strurl.split('apex/')[1]; 
                System.debug('strurl : '+strurl);
              
         if(walletList.size() > 0){
                 wallet = walletList.get(0);
             
              //Warning Message
             isRequiredCollectionMethod = false;
             if((wallet.SumOfCollectionVolumnPercent__c ==null ||wallet.SumOfCollectionVolumnPercent__c ==0)
                &&(wallet.TotalDomesticPercent__c !=null && wallet.TotalDomesticPercent__c != 0) ){
                 isRequiredCollectionMethod = true;
             }
             
             isRequiredColletionExport = false;
             if((wallet.SumOfCollectionExportWalletTradeFee__c ==null 
                 ||wallet.SumOfCollectionExportWalletTradeFee__c ==0)
                &&(wallet.TotalExportPercent__c !=null && wallet.TotalExportPercent__c != 0)
               ){
                 isRequiredColletionExport = true;
             }
             
             isRequiredPaymentMethod = false;
             if((wallet.SumOfPaymentDomesticVolPercent__c ==null 
                 ||wallet.SumOfPaymentDomesticVolPercent__c ==0)
                &&(wallet.TotalPaymentDomesticPercent__c !=null && wallet.TotalPaymentDomesticPercent__c != 0)
               ){
                 isRequiredPaymentMethod = true;
             }
             
             isRequiredPaymentImport = false;
             System.debug(wallet.SumOfPaymentImportVolPercent__c +' : '+wallet.TotalPaymentImportPercent__c);
             if((wallet.SumOfPaymentImportVolPercent__c ==null 
                 ||wallet.SumOfPaymentImportVolPercent__c ==0)
                &&(wallet.TotalPaymentImportPercent__c !=null && wallet.TotalPaymentImportPercent__c != 0)
               ){
                 isRequiredPaymentImport = true;
             }
             
                if(strurl.containsIgnoreCase('View')){
                    CollectionList =new  List<AcctPlanCollectionOrPaymentCurrency__c>();
                    PaymentList = new List<AcctPlanCollectionOrPaymentCurrency__c> ();
                    List<AcctPlanCollectionOrPaymentCurrency__c> CurrencyList = [SELECT ID,CCY__c,CCY__R.Name,CollectionAmtPerYear__c, CollectionPortion__c,
                                                                                 Currency_Type__c ,PaymentAmtPerYear__c ,PaymentPortion__c   
                                                                                 FROM AcctPlanCollectionOrPaymentCurrency__c 
                                                                                 WHERE AcctPlanWallet__c =: wallet.id];
                     
                     for(AcctPlanCollectionOrPaymentCurrency__c curr : CurrencyList){ 
                         if(curr.Currency_Type__c =='Collection'){
                             CollectionList.add(curr);
                         }else if(curr.Currency_Type__c =='Payment'){
                             PaymentList.add(curr);
                         }
                     }
                    
                    
                    
                    List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_3_Percentage__c,
                      Account_Plan_Completion_Percentage__c , 
                      Step_3_1_Entered_Fields__c  ,                                          
                      Step_3_1_Percentage__c ,
                      Step_3_1_Required_Fields__c                                               
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                     if(CompleteList.size()>0){
                         Acctplancompletion = CompleteList.get(0);
                     }
                     
                     
                 }
              QuestionnaireList = AccountPlanUtilities.QueryQuestionnaireByWalletID(wallet.id);
              QTemplateList = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain I');
              QTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
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
             
              //Collection all Questionnaires
                     for(AcctPlanQuestionnaire__c question : QuestionnaireList){
                         if(QuestionnaireMap.containsKey(question.Segment__c)){
                             QuestionnaireMap.get(question.Segment__c).add(question);
                         }else{
                             
                             List<AcctPlanQuestionnaire__c> qlist = new List<AcctPlanQuestionnaire__c>();
                             
                             qlist.add(question);
                             QuestionnaireMap.put(question.Segment__c, qlist);
                         }
                     }
             
             for(String segment : QSegmentList){
                 if(!QuestionnaireMap.containsKey(segment)){
                          List<AcctPlanQuestionnaire__c> qList = new List<AcctPlanQuestionnaire__c>();
                          
                          for(integer i =0;i<QTemplateMap.get(segment).size();i++){
                              
                              AcctPlanQuestionnaire__c question = new AcctPlanQuestionnaire__c ();
                              question.Question__c = QTemplateMap.get(segment).get(i).Question__c;
                              question.Question_TH__c = QTemplateMap.get(segment).get(i).Question_TH__C;
                              question.Segment__c = segment;
                              question.Sub_Segment_SEQ__c = QTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c;
                              question.Product_Label__c = QTemplateMap.get(segment).get(i).Product_Label__c;
                              question.Sub_Domain__c = QTemplateMap.get(segment).get(i).Sub_Domain__c;
                              question.Opportunity__c = QTemplateMap.get(segment).get(i).Opportunity__c;
                              question.Answer_Type__c  = QTemplateMap.get(segment).get(i).Answer_Field_Type__c;
                              question.SEQ__c  = QTemplateMap.get(segment).get(i).SEQ__C;
                              question.AcctPlanWallet__c = wallet.id;
                              qList.add(question);
                          }
                     
                          QuestionnaireMap.put(segment, qList);
                 }
             }
             
            
             
             
                collectdomesticlist = [SELECT ID,AcctPlanCollectionMethodDomestic__c,
                                                                             FeeCharge__c,Label__c ,NoOfTransaction__c ,
                                                                             SharedBank1__c ,SharedBank2__c ,SharedBank3__c ,
                                                                             SharedBank4__c ,SharedTMB__c ,StandardFee__c ,
                                                                             Volume__c ,VolumePercent__c ,WalletFee__c 
                                                                             FROM AcctPlanCollectionDomestic__c 
                                                                            WHERE AcctPlanCollectionMethodDomestic__c = : wallet.id];
             
            List<AcctPlanWalletOtherBank__c> otherBankCollectionDomesticList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                                 FROM AcctPlanWalletOtherBank__c 
                                                                                 WHERE AcctPlanWallet__c = :wallet.Id AND TableName__c = 'Collection Method Domestic'];
            if(otherBankCollectionDomesticList.size() <= 0){          
                AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
                ob.AcctPlanWallet__c = wallet.Id;
                ob.TableName__c = 'Collection Method Domestic';
                otherBankCollectionDomestic = ob; 
            }else{
                otherBankCollectionDomestic = otherBankCollectionDomesticList.get(0); 
            }
             
             wallet.SumOfCollectionDomesticVolumn__c = 0;
             wallet.SumOfCollectionVolumnPercent__c  = 0;
            // wallet.SumOfCollectionWalletCashFee__c  = 0;
            
                //Existing Collection Domestic table
                 if(collectdomesticlist.size()>0){
                     isRequiredBillPayment = false;
                     for(AcctPlanCollectionDomestic__c collection : collectdomesticlist){
                       
                         if(StandardFeeTMB.containsKey(collection.Label__c)){
                             collection.StandardFee__c = StandardFeeTMB.get(collection.Label__c);
                             if(collection.WalletFee__c !=null){
                             //    wallet.SumOfCollectionWalletCashFee__c  += collection.WalletFee__c;
                             }  
                         }else{
                             collection.StandardFee__c = 0;
                         }
                         
                         if(wallet.TotalDomesticAmtPerYear__c !=null && collection.VolumePercent__c !=null){
                             collection.Volume__c = (wallet.TotalDomesticAmtPerYear__c * (collection.VolumePercent__c/100))/12;
                         }
                         
                         if(StandardFeeTMB.containsKey(collection.Label__c)){
                             if(collection.WalletFee__c !=null){
                                 TotalCollectiondomestic +=collection.WalletFee__c;
                             }
                         }
                         
                         if(collection.Volume__c !=null && collection.Label__c !='2) Cheque' && collection.Label__c !='5) Card'){wallet.SumOfCollectionDomesticVolumn__c  += collection.Volume__c;}
                          if(collection.VolumePercent__c !=null 
                             && collection.Label__c !='2) Cheque'
                             && collection.Label__c !='5) Card' ){wallet.SumOfCollectionVolumnPercent__c  += collection.VolumePercent__c;}
                         
                         
                         
                         CollectionDomesticMap.put(collection.Label__c,collection);
                         
                         if(collection.Label__c == '3) Bill Payment'){
                             if(collection.VolumePercent__c !=null && collection.VolumePercent__c != 0){
                                 if( collection.NoOfTransaction__c == null){
                                     isRequiredBillPayment = true;
                                 }else if(collection.NoOfTransaction__c == 0){
                                     isRequiredBillPayment = true;
                                 }
                                }
                         }
                     }
                    
                 }else{
                     isHasCollectionDomestic = false;
                 }
             
             //Collection Method (Export)
              
              cExportList = [SELECT ID,AcctPlanCollectionMethodExport__c ,Label__c,
                                                                             SharedBank1__c ,SharedBank2__c ,SharedBank3__c ,
                                                                             SharedBank4__c ,SharedTMB__c ,TermDays__c  ,StandardFee__c,
                                                                             Volumn__c  ,VolumnPercent__c,Pattern__c  
                                                                             FROM AcctPlanCollectionExport__c  
                                                                            WHERE AcctPlanCollectionMethodExport__c   = : wallet.id];
             
             List<AcctPlanWalletOtherBank__c> otherBankCollectionExportList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                               FROM AcctPlanWalletOtherBank__c 
                                                                               WHERE AcctPlanWallet__c = :wallet.Id AND TableName__c = 'Collection Method Export'];
             if(otherBankCollectionExportList.size() <= 0){          
                 AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
                 ob.AcctPlanWallet__c = wallet.Id;
                 ob.TableName__c = 'Collection Method Export';
                 otherBankCollectionExport = ob; 
             }else{
                 otherBankCollectionExport = otherBankCollectionExportList.get(0); 
             }  
             
            // wallet.TotalExportAvgPerMonth__c =0;
            // wallet.SumOfCollectionExportVolPercent__c =0;
             
             if( wallet.SumOfCollectionExportStandardFee__c ==null ||wallet.SumOfCollectionExportStandardFee__c ==0){
                wallet.SumOfCollectionExportStandardFee__c = CollectionMethodExportStandardFee; 
             }
             //Case Production issues
             //if( wallet.SumOfCollectionExportFeeCharge__c ==null ||wallet.SumOfCollectionExportFeeCharge__c ==0){
             if( wallet.SumOfCollectionExportFeeCharge__c ==null){
                wallet.SumOfCollectionExportFeeCharge__c = CollectionMethodExportStandardFee; 
             }
                
              if(cExportList.size()>0){
                     for(AcctPlanCollectionExport__c  cExport : cExportList){
                        // if(cExport.Volumn__c  !=null ){wallet.TotalExportAvgPerMonth__c  += cExport.Volumn__c ;}
                        //  if(cExport.VolumnPercent__c  !=null){wallet.SumOfCollectionExportVolPercent__c  += cExport.VolumnPercent__c ;}
                         
                          CollectionExportMap.put(cExport.Label__c,cExport);
                   
                     }
                      
                     
                 }else{
                     isHasCollectionExport = false;
                 }
             
             
             //Payment Metohd Domestic
             
              
              pDomesticList = [SELECT ID, AvgProvidentFund__c, Label__c, NoOfTransaction__c , SharedBank1__c ,
                                                             SharedBank2__c , SharedBank3__c , SharedBank4__c , SharedTMB__c , StandardFee__c ,FeeCharge__c,
                                                              Volume__c ,VolumePercent__c ,WalletFee__c , AcctPlanPaymentMethodDomestic__c 
                                                                             FROM AcctPlanPaymentDomestic__c   
                                                                            WHERE AcctPlanPaymentMethodDomestic__c    = : wallet.id
                              ORDER BY LastModifiedDate DESC LIMIT 12];
             List<AcctPlanWalletOtherBank__c> otherBankPaymentDomesticList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                               FROM AcctPlanWalletOtherBank__c 
                                                                               WHERE AcctPlanWallet__c = :wallet.Id AND TableName__c = 'Payment Method Domestic'];
             if(otherBankPaymentDomesticList.size() <= 0){          
                 AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
                 ob.AcctPlanWallet__c = wallet.Id;
                 ob.TableName__c = 'Payment Method Domestic';
                 otherBankPaymentDomestic = ob; 
             }else{
                 otherBankPaymentDomestic = otherBankPaymentDomesticList.get(0); 
             }
             
             wallet.SumOfPaymentDomesticAvgPerMonth__c = 0;
             wallet.SumOfPaymentDomesticVolPercent__c = 0.00;
             //wallet.SumOfPaymentDomesticWalletCashFee__c =0;
             IsHasPaymentDomestic  = false;
             if(pDomesticList.size()>0){
                 for(AcctPlanPaymentDomestic__c  pDomestic : pDomesticList){
                        if(pDomestic.Volume__c   !=null 
                           && pDomestic.Label__c != '2) Cheque'
                          
                           && pDomestic.Label__c != '2.3 จำนวนเช็คในเขต'
                           && pDomestic.Label__c != '2.4 จำนวนเช็คข้ามเขต'
                          ){wallet.SumOfPaymentDomesticAvgPerMonth__c   += pDomestic.Volume__c  ;}
                        if(pDomestic.VolumePercent__c   !=null
                           && pDomestic.Label__c != '2) Cheque'
                          
                           && pDomestic.Label__c != '2.3 จำนวนเช็คในเขต'
                           && pDomestic.Label__c != '2.4 จำนวนเช็คข้ามเขต'
                          ){wallet.SumOfPaymentDomesticVolPercent__c   += pDomestic.VolumePercent__c  ;
                           }
                     	if(pDomestic.WalletFee__c !=null && pdomestic.FeeCharge__c !=null){
                         //   wallet.SumOfPaymentDomesticWalletCashFee__c += pDomestic.WalletFee__c;
                        }
                          PaymentDomesticMap.put(pDomestic.Label__c,pDomestic);
                     	if(pDomestic.VolumePercent__c !=null){
                             IsHasPaymentDomestic  = true;
                         }
                     
                    
                     }
                 
                 
                 
             }else{
                 isHasPaymentDomestic = false;
             }
             
             
             //Payment Metohd Import
             
              
              pImportList = [SELECT ID, FeeCharge__c , Label__c, NoOfTransaction__c , SharedBank1__c ,Term__c,
                                                             SharedBank2__c , SharedBank3__c ,Type_of_Fee__c, SharedBank4__c , SharedTMB__c , StandardFee__c ,
                                                              Volume__c ,VolumePercent__c ,Pattern__c, AcctPlanPaymentMethodImport__c,WalletTFFee__c
                                                                             FROM AcctPlanPaymentImport__c    
                                                                            WHERE AcctPlanPaymentMethodImport__c = : wallet.id];
              
             List<AcctPlanWalletOtherBank__c> otherBankPaymentImportList = [SELECT Id,AcctPlanWallet__c,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                               FROM AcctPlanWalletOtherBank__c 
                                                                               WHERE AcctPlanWallet__c = :wallet.Id AND TableName__c = 'Payment Method Import'];
             if(otherBankPaymentImportList.size() <= 0){          
                 AcctPlanWalletOtherBank__c ob = new AcctPlanWalletOtherBank__c();
                 ob.AcctPlanWallet__c = wallet.Id;
                 ob.TableName__c = 'Payment Method Import';
                 otherBankPaymentImport = ob; 
             }else{
                 otherBankPaymentImport = otherBankPaymentImportList.get(0); 
             }
             
             wallet.SumOfPaymentImportImportVol__c=0;
             wallet.SumOfPaymentImportNoOfTransaction__c=0;
            // wallet.SumOfPaymentImportWalletTFFee__c = 0;
             wallet.SumOfPaymentImportVolPercent__c = 0.00;
             IsHasPaymentImport = false;
             if(pImportList.size()>0){
                 for(AcctPlanPaymentImport__c  pImport : pImportList){
                         if(pImport.Volume__c   !=null 
                            && pImport.Type_of_Fee__c  !='Engagement Fee' 
                            && pImport.Label__c != '2) Bill'  
                            && pImport.Label__c != '3) Import L/C'){
                                wallet.SumOfPaymentImportImportVol__c   
                                    += pImport.Volume__c  ;}
                          if(pImport.NoOfTransaction__c   !=null 
                             && pImport.Type_of_Fee__c  !='Engagement Fee' 
                             && pImport.Label__c != '2) Bill'  
                             && pImport.Label__c != '3) Import L/C')
                          {wallet.SumOfPaymentImportNoOfTransaction__c   
                              += pImport.NoOfTransaction__c  ;}
                            if(pImport.VolumePercent__c !=null && pImport.Type_of_Fee__c  !='Engagement Fee' && pImport.Label__c != '2) Bill'  && pImport.Label__c != '3) Import L/C'){wallet.SumOfPaymentImportVolPercent__c += pImport.VolumePercent__c;}
                     if(pImport.Type_of_Fee__c=='LC Commission'){
                         pImport.Type_of_Fee__c ='L/C Commission';
                     }
                     if(pImport.Type_of_Fee__c =='L/C Commission'){
                         AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport1');
                         pImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                     }else if (pImport.Type_of_Fee__c =='Engagement Fee'){
                         AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport3');
                         pImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                     }      
                    // if(pImport.WalletTFFee__c !=null && pImport.Type_of_Fee__c !=null ){ 
                   //      wallet.SumOfPaymentImportWalletTFFee__c +=pImport.WalletTFFee__c;
                   //  }
                          PaymentImportMap.put(pImport.Label__c,pImport);
                     
                     if(pImport.VolumePercent__c !=null){
                             IsHasPaymentImport   = true;
                         }
                     }
             }else{
                 isHasPaymentImport = false;
             }
             
             
             
             
             
                
             
         }else{
             wallet = new AcctPlanWallet__c();
             wallet.AcctPlanCompanyProfile__c = companyprofile.id;
              isHasCollectionDomestic = false;
              isHasCollectionExport = false;
              isHasPaymentDomestic = false;
              isHasPaymentImport = false;
              
         }
            

               
             
                
                loadCurrency();
				
             
             
             
              //First time initiate the Wallet   
             
             
             if(!isHasCollectionDomestic){
                  for(String label : CollectionDomesticMetholdLabel){
                   AcctPlanCollectionDomestic__c Collectiondomestic = new AcctPlanCollectionDomestic__c();
                     Collectiondomestic.Label__c = label;
                     Collectiondomestic.AcctPlanCollectionMethodDomestic__c = wallet.id;
                     if(StandardFeeTMB.containsKey(label)){
                             Collectiondomestic.StandardFee__c = StandardFeeTMB.get(label);
                             Collectiondomestic.FeeCharge__c = StandardFeeTMB.get(label);
                         }else{
                             Collectiondomestic.StandardFee__c = 0;
                              Collectiondomestic.FeeCharge__c = 0;
                         }
                     CollectionDomesticMap.put(label,Collectiondomestic);
                 }
             }
              
            
           if(!isHasCollectionExport){
                  for(String label : CollectionExportMetholdLabel){
                   AcctPlanCollectionExport__c CollectionExport = new AcctPlanCollectionExport__c();
                     CollectionExport.Label__c = label;
                     CollectionExport.AcctPlanCollectionMethodExport__c = wallet.id;
                     CollectionExportMap.put(label,CollectionExport);
                 }
             }
           
          if(!isHasPaymentDomestic){
                  for(String label : PaymentMetholdLabel){
                   AcctPlanPaymentDomestic__c PaymentDomestic = new AcctPlanPaymentDomestic__c();
                     PaymentDomestic.Label__c = label;
                     PaymentDomestic.AcctPlanPaymentMethodDomestic__c = wallet.id;
                      if(StandardFeeTMB.containsKey(label)){
                          PaymentDomestic.StandardFee__c = StandardFeeTMB.get(label);
                         // PaymentDomestic.AvgProvidentFund__c =StandardFeeTMB.get(label);
                          PaymentDomestic.FeeCharge__c = StandardFeeTMB.get(label);
                      }
                     PaymentDomesticMap.put(label,PaymentDomestic);
                 }
             }  
              if(!isHasPaymentImport){
                  for(String label : PaymentImportMetholdLabel){
                   AcctPlanPaymentImport__c PaymentImport = new AcctPlanPaymentImport__c();
                     PaymentImport.Label__c = label;
                     paymentImport.AcctPlanPaymentMethodImport__c = wallet.id;
                      if(PaymentImportType.containsKey(label)){
                          PaymentImport.Type_of_Fee__c = PaymentImportType.get(label); 
                          if(PaymentImport.Type_of_Fee__c =='L/C Commission'){
                             AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport1');
                             PaymentImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                             PaymentImport.FeeCharge__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                         }else if (PaymentImport.Type_of_Fee__c =='Engagement Fee'){
                             AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport3');
                             PaymentImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                             PaymentImport.FeeCharge__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                         } 
                          
                      }
                     PaymentImportMap.put(label,PaymentImport);
                 }
                  
                  
                  
              }
              
              
              
              

         } //Has ID
     }
    
    
    public void loadCurrency(){
        //Query Currency ShortName
        //
        if(wallet.id !=null){
            System.debug('Load Currency');
        CollectionList  = new List<AcctPlanCollectionOrPaymentCurrency__c>();
        PaymentList  = new List<AcctPlanCollectionOrPaymentCurrency__c>();
        
              List<AcctPlanCollectionOrPaymentCurrency__c > CurrencyList = [SELECT Name,AcctPlanWallet__c,
                                                                           CCY__c,
                                                                           CCY__r.ShortName__c ,
                                                                           CollectionAmtPerYear__c,
                                                                           CollectionIsDeleted__c,
                                                                           CollectionPortion__c,
                                                                           Currency_Type__c,
                                                                           PaymentAmtPerYear__c,
                                                                           PaymentIsDeleted__c,
                                                                           PaymentPortion__c 
                                                                           FROM AcctPlanCollectionOrPaymentCurrency__c 
                                                                           WHERE AcctPlanWallet__c =: wallet.id];
             
                 for(AcctPlanCollectionOrPaymentCurrency__c  curr : CurrencyList){
                     if(curr.Currency_Type__c == 'Collection'){
                         CollectionList.add(curr);
                     }else if (curr.Currency_Type__c == 'Payment'){
                         PaymentList.add(curr);
                     }
                 }
            
        }
    }
    
    
    public pagereference Save(){
        try{
            
            boolean validate = true;
            boolean walletvalidate = true;
            Double TotalnewCMDomestic =0.00;
            Double TotalnewCMExport =0.00;
            Double TotalnewPMDomestic =0.00;
            Double TotalnewPMImport =0.00;
           
            
            update wallet;            
            
            wallet =  AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id).get(0);
          
                
            DynamicQuestionnaire();
                //
            
            
            
             wallet.SumOfCollectionWalletCashFee__c  = 0;
            //Domain I Validate
            Set<AcctPlanQuestionnaire__c> QuestionsSet = new Set<AcctPlanQuestionnaire__c>();
			Boolean internetCollection = true;
            Boolean internetPayment = true;
            for(String segment : QuestionnaireMap.keySet()){
               
                for(AcctPlanQuestionnaire__c acctquestion : QuestionnaireMap.get(segment)){
                    if(acctquestion.Segment__c=='Collection Questionnaire' && acctquestion.SEQ__c == 1 && acctquestion.Answer__c != 'Yes'){
                        internetCollection = false;
                    }
                    if(acctquestion.Segment__c =='Payment Method Import' && acctquestion.SEQ__c == 1 && acctquestion.Answer__c != 'Yes'){
                        internetPayment = false;
                    }
                    if(acctquestion.Segment__c == 'Collection Questionnaire' && acctquestion.SEQ__c != 1 && !internetCollection){
                        acctquestion.Answer__c = null;
                    }
                    if(acctquestion.Segment__c == 'Payment Method Import' && acctquestion.SEQ__c != 1 && !internetPayment){
                        acctquestion.Answer__c = null;
                    }
                    QuestionsSet.add(acctquestion);                
                }
            }
            
            List <AcctPlanQuestionnaire__c> AllQuestionsupsertList = new List<AcctPlanQuestionnaire__c>();
                     
            AllQuestionsupsertList.addAll(QuestionsSet);
            
           
            List<AcctPlanCollectionDomestic__c> CollDomesticInsertList = new List<AcctPlanCollectionDomestic__c>();
            List<AcctPlanCollectionDomestic__c> CollDomesticUpdateList = new List<AcctPlanCollectionDomestic__c>();
            
            
                      //2) Cheque Total
                      AcctPlanCollectionDomestic__c cheque = CollectionDomesticMap.get('2) Cheque');
                      cheque.AcctPlanCollectionMethodDomestic__c = wallet.id;
                      AcctPlanCollectionDomestic__c indistrict = CollectionDomesticMap.get('- ในเขต');
                      AcctPlanCollectionDomestic__c outdistrict = CollectionDomesticMap.get('- นอกเขต');
                      cheque.Volume__c =0;
                      cheque.VolumePercent__c = 0;
                     if(indistrict.Volume__c!=null){cheque.Volume__c += indistrict.Volume__c;}
                     if(outdistrict.Volume__c!=null){cheque.Volume__c += outdistrict.Volume__c;}
                      cheque.SharedTMB__c = (indistrict.SharedTMB__c!=null?indistrict.SharedTMB__c:0) + (outdistrict.SharedTMB__c!=null?outdistrict.SharedTMB__c:0);
                      cheque.SharedBank1__c = (indistrict.SharedBank1__c!=null?indistrict.SharedBank1__c:0) + (outdistrict.SharedBank1__c!=null?outdistrict.SharedBank1__c:0);
                      cheque.SharedBank2__c = (indistrict.SharedBank2__c!=null?indistrict.SharedBank2__c:0) + (outdistrict.SharedBank2__c!=null?outdistrict.SharedBank2__c:0);
         			  cheque.SharedBank3__c = (indistrict.SharedBank3__c!=null?indistrict.SharedBank3__c:0) + (outdistrict.SharedBank3__c!=null?outdistrict.SharedBank3__c:0);
         			  cheque.SharedBank4__c = (indistrict.SharedBank4__c!=null?indistrict.SharedBank4__c:0) + (outdistrict.SharedBank4__c!=null?outdistrict.SharedBank4__c:0);
         
                      cheque.VolumePercent__c = (indistrict.VolumePercent__c!=null?indistrict.VolumePercent__c:0) + (outdistrict.VolumePercent__c!=null?outdistrict.VolumePercent__c:0);
                      CollectionDomesticMap.put('2) Cheque',cheque);
                     
                     //2) Card Total
                      AcctPlanCollectionDomestic__c card = CollectionDomesticMap.get('5) Card');
                      AcctPlanCollectionDomestic__c edc = CollectionDomesticMap.get('- EDC');
                      AcctPlanCollectionDomestic__c ecom = CollectionDomesticMap.get('- E-Commerce');
                      card.Volume__c =0;
                      card.VolumePercent__c = 0;
                      card.Volume__c = (edc.Volume__c!=null?edc.Volume__c:0) + (ecom.Volume__c!=null?ecom.Volume__c:0);
                      card.VolumePercent__c = (edc.VolumePercent__c!=null?edc.VolumePercent__c:0) + (ecom.VolumePercent__c!=null?ecom.VolumePercent__c:0);
                      card.SharedTMB__c = (edc.SharedTMB__c!=null?edc.SharedTMB__c:0) + (ecom.SharedTMB__c!=null?ecom.SharedTMB__c:0);
                      card.SharedBank1__c = (edc.SharedBank1__c!=null?edc.SharedBank1__c:0) + (ecom.SharedBank1__c!=null?ecom.SharedBank1__c:0);
                      card.SharedBank2__c = (edc.SharedBank2__c!=null?edc.SharedBank2__c:0) + (ecom.SharedBank2__c!=null?ecom.SharedBank2__c:0);
         			  card.SharedBank3__c = (edc.SharedBank3__c!=null?edc.SharedBank3__c:0) + (ecom.SharedBank3__c!=null?ecom.SharedBank3__c:0);
         			  card.SharedBank4__c = (edc.SharedBank4__c!=null?edc.SharedBank4__c:0) + (ecom.SharedBank4__c!=null?ecom.SharedBank4__c:0);
         
                      CollectionDomesticMap.put('5) Card',card);
            
            for(AcctPlanCollectionDomestic__c colDomestic : CollectionDomesticMap.values()){
                if(colDomestic.VolumePercent__c >0 &&wallet.TotalDomesticAmtPerYear__c !=null){
                    colDomestic.Volume__c = (wallet.TotalDomesticAmtPerYear__c/12) * (colDomestic.VolumePercent__c/100); 
                    if(colDomestic.Label__c !='2) Cheque'
                       && colDomestic.Label__c !='5) Card' 
                       &&colDomestic.Label__c!=null ){
                       
                        TotalnewCMDomestic += colDomestic.VolumePercent__c; 
                    }
                }else{
                    if(colDomestic.VolumePercent__c ==null || colDomestic.VolumePercent__c ==0){
                     	colDomestic.Volume__c =null;
                	}
                }
                //Case Production Issue
                if(StandardFeeTMB.containsKey(colDomestic.Label__c) && colDomestic.FeeCharge__c == null){
                    colDomestic.FeeCharge__c = StandardFeeTMB.get(colDomestic.Label__c);
                }
                if(colDomestic.id !=null){
                    CollDomesticUpdateList.add(colDomestic);
                }else{
                    CollDomesticInsertList.add(colDomestic);
                }
            }
            Double wallettrade = 0.00;
            wallet.TotalExportAvgPerMonth__c = 0.00;
            
            
            // Export collection
                  	  AcctPlanCollectionExport__c exportcollection = CollectionExportMap.get('2) Export collection');
                  	  exportcollection.VolumnPercent__c =0;
					  exportcollection.Volumn__c =0;
                  	  exportcollection.SharedTMB__c =0 ;
                      exportcollection.SharedBank1__c =0;
                      exportcollection.SharedBank2__c = 0;
         			  exportcollection.SharedBank3__c = 0;
         			  exportcollection.SharedBank4__c = 0;
         			
                      AcctPlanCollectionExport__c Exbcsight = CollectionExportMap.get('B/C Sight (D/P)');
                      AcctPlanCollectionExport__c Exbcterm = CollectionExportMap.get('B/C Term (D/A)'); 
                      exportcollection.VolumnPercent__c = (Exbcsight.VolumnPercent__c!=null?Exbcsight.VolumnPercent__c:0) + (Exbcterm.VolumnPercent__c!=null?Exbcterm.VolumnPercent__c:0);
					  exportcollection.Volumn__c = (Exbcsight.Volumn__c!=null?Exbcsight.Volumn__c:0) + (Exbcterm.Volumn__c!=null?Exbcterm.Volumn__c:0);
                      exportcollection.SharedTMB__c = (Exbcsight.SharedTMB__c!=null?Exbcsight.SharedTMB__c:0) + (Exbcterm.SharedTMB__c!=null?Exbcterm.SharedTMB__c:0);
                      exportcollection.SharedBank1__c = (Exbcsight.SharedBank1__c!=null?Exbcsight.SharedBank1__c:0) + (Exbcterm.SharedBank1__c!=null?Exbcterm.SharedBank1__c:0);
                      exportcollection.SharedBank2__c = (Exbcsight.SharedBank2__c!=null?Exbcsight.SharedBank2__c:0) + (Exbcterm.SharedBank2__c!=null?Exbcterm.SharedBank2__c:0);
         			  exportcollection.SharedBank3__c = (Exbcsight.SharedBank3__c!=null?Exbcsight.SharedBank3__c:0) + (Exbcterm.SharedBank3__c!=null?Exbcterm.SharedBank3__c:0);
         			  exportcollection.SharedBank4__c = (Exbcsight.SharedBank4__c!=null?Exbcsight.SharedBank4__c:0) + (Exbcterm.SharedBank4__c!=null?Exbcterm.SharedBank4__c:0);
         			// advice LC
         			 AcctPlanCollectionExport__c adviceLC = CollectionExportMap.get('3) Advice L/C');
                      AcctPlanCollectionExport__c Exlcsight = CollectionExportMap.get('L/C Sight');
                      AcctPlanCollectionExport__c Exlcterm = CollectionExportMap.get('L/C Term');
                  	  adviceLC.VolumnPercent__c =0;
					  adviceLC.Volumn__c =0;
                  	  adviceLC.SharedTMB__c =0 ;
                      adviceLC.SharedBank1__c =0;
                      adviceLC.SharedBank2__c = 0;
         			  adviceLC.SharedBank3__c = 0;
         			  adviceLC.SharedBank4__c = 0;
                      adviceLC.VolumnPercent__c = (Exlcsight.VolumnPercent__c!=null?Exlcsight.VolumnPercent__c:0) + (Exlcterm.VolumnPercent__c!=null?Exlcterm.VolumnPercent__c:0);
					  adviceLC.Volumn__c = (Exlcsight.Volumn__c!=null?Exlcsight.Volumn__c:0) + (Exlcterm.Volumn__c!=null?Exlcterm.Volumn__c:0);
                      adviceLC.SharedTMB__c = (Exlcsight.SharedTMB__c!=null?Exlcsight.SharedTMB__c:0) + (Exlcterm.SharedTMB__c!=null?Exlcterm.SharedTMB__c:0);
                      adviceLC.SharedBank1__c = (Exlcsight.SharedBank1__c!=null?Exlcsight.SharedBank1__c:0) + (Exlcterm.SharedBank1__c!=null?Exlcterm.SharedBank1__c:0);
                      adviceLC.SharedBank2__c = (Exlcsight.SharedBank2__c!=null?Exlcsight.SharedBank2__c:0) + (Exlcterm.SharedBank2__c!=null?Exlcterm.SharedBank2__c:0);
         			  adviceLC.SharedBank3__c = (Exlcsight.SharedBank3__c!=null?Exlcsight.SharedBank3__c:0) + (Exlcterm.SharedBank3__c!=null?Exlcterm.SharedBank3__c:0);
         			  adviceLC.SharedBank4__c = (Exlcsight.SharedBank4__c!=null?Exlcsight.SharedBank4__c:0) + (Exlcterm.SharedBank4__c!=null?Exlcterm.SharedBank4__c:0);
         
                  
            
            
            
            for(AcctPlanCollectionExport__c colExport : CollectionExportMap.values()){
                if(colExport.VolumnPercent__c >0 
                   && wallet.TotalExportAmtPerYear__c !=null 
                   && colExport.Label__c !='2) Export collection' 
                   && colExport.Label__c !='3) Advice L/C'){
                TotalnewCMExport += colExport.VolumnPercent__c;
                colExport.Volumn__c = (wallet.TotalExportAmtPerYear__c/12) * (colExport.VolumnPercent__c/100);
                if(colExport.Volumn__c  !=null ){wallet.TotalExportAvgPerMonth__c  += colExport.Volumn__c.setScale(0) ;}
                wallettrade +=  colExport.Volumn__c;
                }
                
                if(colExport.VolumnPercent__c ==null || colExport.VolumnPercent__c ==0){
                     colExport.Volumn__c =null;
                }
            }
             //Case Production Issue
            if( wallet.SumOfCollectionExportFeeCharge__c ==null){
                wallet.SumOfCollectionExportFeeCharge__c = CollectionMethodExportStandardFee; 
             }
            
            if(wallet.SumOfCollectionExportFeeCharge__c >0){
                wallet.SumOfCollectionExportWalletTradeFee__c = (wallet.SumOfCollectionExportFeeCharge__c/100)*(wallettrade*12);
            }
            
            List<AcctPlanPaymentDomestic__c> paymentDomesticInsertList = new List<AcctPlanPaymentDomestic__c>();
            List<AcctPlanPaymentDomestic__c> paymentDomesticUpdateList = new List<AcctPlanPaymentDomestic__c>();
            
            // issue cheque
         			  AcctPlanPaymentDomestic__c issuescheque = PaymentDomesticMap.get('2) Cheque');
                      AcctPlanPaymentDomestic__c cheque1 = PaymentDomesticMap.get('2.1 จำนวนเช็คที่ทางบริษัทออกเอง');
                      AcctPlanPaymentDomestic__c cheque2 = PaymentDomesticMap.get('2.2 จำนวนเช็คที่ใช้บริการธนาคารออกเช็คให้');
                 	  AcctPlanPaymentDomestic__c cheque3 = PaymentDomesticMap.get('2.3 จำนวนเช็คในเขต');
                 	  AcctPlanPaymentDomestic__c cheque4 = PaymentDomesticMap.get('2.4 จำนวนเช็คข้ามเขต');
                 	  issuescheque.NoOfTransaction__c =0;
					  issuescheque.Volume__c =0;
                  	  issuescheque.VolumePercent__c =0;
                  	  issuescheque.SharedTMB__c =0 ;
                      issuescheque.SharedBank1__c =0;
                      issuescheque.SharedBank2__c = 0;
         			  issuescheque.SharedBank3__c = 0;
         			  issuescheque.SharedBank4__c = 0;
                      
					  issuescheque.Volume__c = (cheque1.Volume__c!=null?cheque1.Volume__c:0) 
                          + (cheque2.Volume__c!=null?cheque2.Volume__c:0);
                 	  issuescheque.VolumePercent__c = (cheque1.VolumePercent__c!=null?cheque1.VolumePercent__c:0) 
                          + (cheque2.VolumePercent__c!=null?cheque2.VolumePercent__c:0);
                      issuescheque.SharedTMB__c = (cheque1.SharedTMB__c!=null?cheque1.SharedTMB__c:0) 
                          + (cheque2.SharedTMB__c!=null?cheque2.SharedTMB__c:0);
                      issuescheque.SharedBank1__c = (cheque1.SharedBank1__c!=null?cheque1.SharedBank1__c:0) 
                          + (cheque2.SharedBank1__c!=null?cheque2.SharedBank1__c:0);
                      issuescheque.SharedBank2__c = (cheque1.SharedBank2__c!=null?cheque1.SharedBank2__c:0) 
                          + (cheque2.SharedBank2__c!=null?cheque2.SharedBank2__c:0);
                  issuescheque.SharedBank3__c = (cheque1.SharedBank3__c!=null?cheque1.SharedBank3__c:0) 
                          + (cheque2.SharedBank3__c!=null?cheque2.SharedBank3__c:0);
                  issuescheque.SharedBank4__c = (cheque1.SharedBank4__c!=null?cheque1.SharedBank4__c:0) 
                          + (cheque2.SharedBank4__c!=null?cheque2.SharedBank4__c:0);
                 
            
            
            
            for(AcctPlanPaymentDomestic__c paydomestic : PaymentDomesticMap.values()){
               
                
                if(paydomestic.VolumePercent__c >0 
                   && wallet.TotalPaymentDomesticAmtPerYear__c !=null
                   && paydomestic.Label__c != '2) Cheque'
                   ){
                       if(paydomestic.Label__c != '2.3 จำนวนเช็คในเขต' && paydomestic.Label__c != '2.4 จำนวนเช็คข้ามเขต'){
                           TotalnewPMDomestic += paydomestic.VolumePercent__c;
                       }
                    
                	paydomestic.Volume__c = (wallet.TotalPaymentDomesticAmtPerYear__c /12) * (paydomestic.VolumePercent__c/100);

                }else{
                    if(paydomestic.VolumePercent__c ==null || paydomestic.VolumePercent__c ==0){
                     	paydomestic.Volume__c =null;
                	}
                }
                //Case Production Issue
                if(StandardFeeTMB.containsKey(paydomestic.Label__c) && paydomestic.FeeCharge__c == null){
                    paydomestic.FeeCharge__c = StandardFeeTMB.get(paydomestic.Label__c);
                }
                if(payDomestic.id !=null){
                    paymentDomesticUpdateList.add(payDomestic);
                }else{
                      paymentDomesticInsertList.add(payDomestic);      
                 }
            }
            
            
            
            
            
       		
            for(AcctPlanPaymentImport__c payImport : PaymentImportMap.values()){
                if(payImport.VolumePercent__c >0 && wallet.TotalPaymentImportAmtPerYear__c !=null
                   && payImport.Type_of_Fee__c != 'Engagement Fee'
                   && payImport.Label__c != '2) Bill'
                   && payImport.Label__c != '3) Import L/C'
                  ){
                     TotalNewPMImport += payImport.VolumePercent__c;
                payImport.Volume__c = (wallet.TotalPaymentImportAmtPerYear__c /12) * (payImport.VolumePercent__c/100);
                      
                     
                }else{
                    if(payImport.VolumePercent__c ==null || payImport.VolumePercent__c ==0){
                     	payImport.Volume__c =null;
                	}
                }
                //Case Production Issue
                if(PaymentImportType.containsKey(payImport.Label__c) && payImport.FeeCharge__c == null){
                    String TypeofFee = PaymentImportType.get(payImport.Label__c);                          
                    if(TypeofFee =='L/C Commission'){
                        AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport1');
                        payImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                        payImport.FeeCharge__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                    }else if (TypeofFee =='Engagement Fee'){
                        AcctPlanStandardFee__c item = AcctPlanStandardFee__c.getValues('StandardFeePaymentImport3');
                        payImport.StandardFee__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                        payImport.FeeCharge__c = Double.valueof(item.get(segmentOwner+'_StandardFee__c'));
                    } 
                    
                }                
            }
            
            //Clone L/C Term values
           AcctPlanPaymentImport__c lcterm = PaymentImportMap.get('L/C Term');
           AcctPlanPaymentImport__c lcterm2 = PaymentImportMap.get('L/C Term 2');
            boolean clearLC = false;
            if(lcterm.VolumePercent__c !=null){
                if(lcterm.VolumePercent__c >0){
                    lcterm2.VolumePercent__c = lcterm.VolumePercent__c;
                lcterm2.NoOfTransaction__c = lcterm.NoOfTransaction__c; 
                lcterm2.Volume__c = lcterm.Volume__c;
                lcterm2.Term__c = lcterm.Term__c;
                 }else{
                    clearLC =true;
                }
            }else{
                clearLC = true;
            }
            
            if(clearLC){
                lcterm2.VolumePercent__c = null;
                lcterm2.NoOfTransaction__c = null; 
                lcterm2.Volume__c = null;
                lcterm2.Term__c = null;
            }

            if(wallet.TotalDomesticPercent__c > 100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Total Sales Domestic (%) must not be more than 100%')); 
            }
            if(wallet.COGSPercent__c > 100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , '% COGS (from estimated sales) must not be null or equal to or more than 100%')); 
            }
            if(wallet.TotalPaymentDomesticPercent__c > 100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Total Payment Domestic (%) must not be more than 100%')); 
            }
            
            if(TotalnewCMDomestic >100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Collection Method (Domestic) table must not be more than 100%')); 
            }else{
                wallet.SumOfCollectionVolumnPercent__c =TotalnewCMDomestic;
            }
            
            if(TotalnewCMExport >100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Collection Method (Export) table must not be more than 100%')); 
            }else{
				
                wallet.SumOfCollectionExportVolPercent__c = TotalnewCMExport;
            }
            
            if(TotalnewPMDomestic >100){
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Payment Method (Domestic) table must not be more than 100%')); 
            }else{
                wallet.SumOfPaymentDomesticVolPercent__c = TotalnewPMDomestic;
            }
            
            if(TotalNewPMImport >100){ 
                validate = false;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Payment Method (Import) table must not be more than 100%')); 
            }else{
            // 2) Bill
			// 
			AcctPlanPaymentImport__c bill = PaymentImportMap.get('2) Bill');
			AcctPlanPaymentImport__c bcsight = PaymentImportMap.get('B/C Sight (D/P)');
            AcctPlanPaymentImport__c bcterm = PaymentImportMap.get('B/C Term (D/A)');
            bill.NoOfTransaction__c = 
                (bcsight.NoOfTransaction__c== null?0: bcsight.NoOfTransaction__c )+ 
                (bcterm.NoOfTransaction__c== null?0: bcterm.NoOfTransaction__c);
            bill.Volume__c = 
                (bcsight.Volume__c== null?0: bcsight.Volume__c)+ 
                (bcterm.Volume__c== null?0: bcterm.Volume__c);
            bill.VolumePercent__c = 
                (bcsight.VolumePercent__c== null?0: bcsight.VolumePercent__c)+ 
                (bcterm.VolumePercent__c== null?0: bcterm.VolumePercent__c);
            bill.SharedTMB__c = 
                (bcsight.SharedTMB__c== null?0: bcsight.SharedTMB__c)+ 
                (bcterm.SharedTMB__c== null?0: bcterm.SharedTMB__c);
            bill.SharedBank1__c = 
                (bcsight.SharedBank1__c== null?0: bcsight.SharedBank1__c)+ 
                (bcterm.SharedBank1__c== null?0: bcterm.SharedBank1__c);
            bill.SharedBank2__c = 
                (bcsight.SharedBank2__c== null?0: bcsight.SharedBank2__c)+ 
                (bcterm.SharedBank2__c== null?0: bcterm.SharedBank2__c);
             bill.SharedBank3__c = 
                (bcsight.SharedBank3__c== null?0: bcsight.SharedBank3__c)+ 
                (bcterm.SharedBank3__c== null?0: bcterm.SharedBank3__c);
             bill.SharedBank4__c = 
                (bcsight.SharedBank4__c== null?0: bcsight.SharedBank4__c)+ 
                (bcterm.SharedBank4__c== null?0: bcterm.SharedBank4__c);   
            
            //
            // 3) Import L/C
			// 
			AcctPlanPaymentImport__c importLCvalue = PaymentImportMap.get('3) Import L/C');
			AcctPlanPaymentImport__c LCSightvalue = PaymentImportMap.get('L/C Sight');
            AcctPlanPaymentImport__c LCTermvalue = PaymentImportMap.get('L/C Term');
              importLCValue.NoOfTransaction__c = 
                (LCSightvalue.NoOfTransaction__c== null?0: LCSightvalue.NoOfTransaction__c )+ 
                (LCTermvalue.NoOfTransaction__c== null?0: LCTermvalue.NoOfTransaction__c);
                importLCValue.Volume__c = 
                    (LCSightvalue.Volume__c== null?0: LCSightvalue.Volume__c)+ 
                    (LCTermvalue.Volume__c== null?0: LCTermvalue.Volume__c);
                importLCValue.VolumePercent__c = 
                    (LCSightvalue.VolumePercent__c== null?0: LCSightvalue.VolumePercent__c)+ 
                    (LCTermvalue.VolumePercent__c== null?0: LCTermvalue.VolumePercent__c);
                importLCValue.SharedTMB__c = 
                    (LCSightvalue.SharedTMB__c== null?0: LCSightvalue.SharedTMB__c)+ 
                    (LCTermvalue.SharedTMB__c== null?0: LCTermvalue.SharedTMB__c);
                importLCValue.SharedBank1__c = 
                    (LCSightvalue.SharedBank1__c== null?0: LCSightvalue.SharedBank1__c)+ 
                    (LCTermvalue.SharedBank1__c== null?0: LCTermvalue.SharedBank1__c);
                importLCValue.SharedBank2__c = 
                    (LCSightvalue.SharedBank2__c== null?0: LCSightvalue.SharedBank2__c)+ 
                    (LCTermvalue.SharedBank2__c== null?0: LCTermvalue.SharedBank2__c);
                 importLCValue.SharedBank3__c = 
                    (LCSightvalue.SharedBank3__c== null?0: LCSightvalue.SharedBank3__c)+ 
                    (LCTermvalue.SharedBank3__c== null?0: LCTermvalue.SharedBank3__c);
                 importLCValue.SharedBank4__c = 
                    (LCSightvalue.SharedBank4__c== null?0: LCSightvalue.SharedBank4__c)+ 
                    (LCTermvalue.SharedBank4__c== null?0: LCTermvalue.SharedBank4__c);   
                
            //
            //
            //
                
                wallet.SumOfPaymentImportVolPercent__c = TotalNewPMImport;
            }
            
            
            //Assign Opportunity to Questionnaire
            
            if(validate){
            upsert AllQuestionsupsertList;
            //upsert  CollectionDomesticMap.values();  
            //
            System.debug(CollDomesticUpdateList.size());
            System.debug(CollDomesticInsertList.size());
                if(CollDomesticUpdateList.size()>0){
                    
					update CollDomesticUpdateList;
                }
                if(CollDomesticInsertList.size()>0){
                    insert CollDomesticInsertList;
                }
            upsert  CollectionExportMap.values();
                if(paymentDomesticInsertList.size()>0){
                    insert paymentDomesticInsertList;
                }
                if(paymentDomesticUpdateList.size()>0){
                    update paymentDomesticUpdateList;
                }
            upsert  PaymentImportMap.values();
                wallet.SumOfCollectionWalletCashFee__c = 0;
                for(AcctPlanCollectionDomestic__c collection : [SELECT ID,AcctPlanCollectionMethodDomestic__c,
                                                                FeeCharge__c,Label__c ,NoOfTransaction__c ,
                                                                SharedBank1__c ,SharedBank2__c ,SharedBank3__c ,
                                                                SharedBank4__c ,SharedTMB__c ,StandardFee__c ,
                                                                Volume__c ,VolumePercent__c ,WalletFee__c 
                                                                FROM AcctPlanCollectionDomestic__c 
                                                                WHERE AcctPlanCollectionMethodDomestic__c = : wallet.id]){
                    if(StandardFeeTMB.containsKey(collection.Label__c)){
                        if(collection.WalletFee__c !=null){
                            wallet.SumOfCollectionWalletCashFee__c  += collection.WalletFee__c;
                        } 
                    }
                }
                 wallet.SumOfPaymentDomesticWalletCashFee__c = 0;
                for(AcctPlanPaymentDomestic__c  payDomestic :   [SELECT ID, FeeCharge__c, 
                                                                   Label__c ,
                                                                   WalletFee__c , 
                                                                   AcctPlanPaymentMethodDomestic__c 
                                                                             FROM AcctPlanPaymentDomestic__c   
                                                                            WHERE AcctPlanPaymentMethodDomestic__c    = : wallet.id]){
             
                  if(payDomestic.WalletFee__c !=null && payDomestic.FeeCharge__c !=null){
                    wallet.SumOfPaymentDomesticWalletCashFee__c += payDomestic.WalletFee__c;
                }
              }
                
                
                  wallet.SumOfPaymentImportWalletTFFee__c  =0;
                for(AcctPlanPaymentImport__c  payImport :  [SELECT ID,StandardFee__c,Type_of_Fee__c, Label__c, AcctPlanPaymentMethodImport__c,WalletTFFee__c
                                                                             FROM AcctPlanPaymentImport__c    
                                                                            WHERE AcctPlanPaymentMethodImport__c = : wallet.id]){
                     if(payImport.WalletTFFee__c !=null
                        //&& payImport.Type_of_Fee__c != 'Engagement Fee'
                   		&& payImport.Label__c != '2) Bill'
                   		&& payImport.Label__c != '3) Import L/C'
                       && payImport.StandardFee__c !=null){ 
                         wallet.SumOfPaymentImportWalletTFFee__c +=payImport.WalletTFFee__c;
                     }

                }
                
                  
            
            update wallet;      
            companyprofile.Status__c = 'In progress';
            update companyprofile;    
                 PageReference pr = Page.AccountPlanWalletDomainIView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
           if(GroupID !=null && GroupID !=''){
            pr.getParameters().put('GroupID',GroupID);
        	}
            if(Wallet.id !=null){
             pr.getParameters().put('WalletID',Wallet.id);   
            }
            if(mode !=null && mode !=''){
            	pr.getParameters().put('mode',mode);
            } 
            if(otherBankCollectionDomestic != null){
                upsert otherBankCollectionDomestic;
            }
            if(otherBankCollectionExport != null){
                upsert otherBankCollectionExport;
            }
            if(otherBankPaymentDomestic != null){
                upsert otherBankPaymentDomestic;
            }
            if(otherBankPaymentImport != null){
                upsert otherBankPaymentImport;
            }
                
                  AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(wallet.AcctPlanCompanyProfile__c);
                
            return pr;
            }else{
                return null;
            }
            
          
            
        }catch(Exception E){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
            System.debug(e.getMessage());
          return null;
        }
        
        
    }
    
    public pagereference cancel(){
         PageReference pr = Page.AccountPlanWalletDomainIView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
            pr.getParameters().put('GroupID',GroupID);
        	}
        	if(Wallet.id !=null){
             pr.getParameters().put('WalletID',Wallet.id);   
            }
        	if(mode !=null && mode !=''){
            	pr.getParameters().put('mode',mode);
            }
            return pr;
    }
    
    public pagereference initiateWallet(){
       if(wallet.id == null){
           PageReference pr = Page.AccountPlanWalletInitiate;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
            pr.getParameters().put('GroupID',GroupID);
        	}
           	if(mode !=null && mode !=''){
            	pr.getParameters().put('mode',mode);
            }
            return pr;
       }else{
           return null;
       }
       
        
    }
    
    
        public pagereference editpage(){
         PageReference pr = Page.AccountPlanWalletDomainIEdit;
            
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
            pr.getParameters().put('GroupID',GroupID);
        	}
            if(Wallet.id !=null){
             pr.getParameters().put('WalletID',Wallet.id);   
            }
            if(mode !=null && mode !=''){
            	pr.getParameters().put('mode',mode);
            }
            return pr;
    }

    
    
    public pagereference insertWallet(){
         PageReference pr = Page.AccountPlanWalletDomainIView;
        try{
              System.debug('tempEstimatedSalesAmtPerYear :'+tempEstimatedSalesAmtPerYear);
            System.debug('tempTotalDomesticPercent :'+tempTotalDomesticPercent);     
            System.debug('tempCOGSPercent :'+tempCOGSPercent);     
            System.debug('tempOperatingExpAmount :'+tempOperatingExpAmount);     
            System.debug('tempTotalPaymentDomesticPercent :'+tempTotalPaymentDomesticPercent);     
            
                    if(tempEstimatedSalesAmtPerYear ==null || Integer.valueOf(tempEstimatedSalesAmtPerYear)==0){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Estimated Sales (Year of account plan ) is required')); 
                        return null; 
                        
                    }else if(tempTotalDomesticPercent==null || tempTotalDomesticPercent >100   ){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Sales Domestic (%) must not be null or  more than 100% ')); 
                        return null;
                    }
            else if(tempCOGSPercent  >100  || tempCOGSPercent==null || tempCOGSPercent ==0){
                         ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'% COGS (From estimated sales) must not be null or  more than 100%'));
                        return null;
            }else if(tempOperatingExpAmount ==null){
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Operating Expense (Amount: THB) is required'));
                        return null;
            }
            
            else if(tempTotalPaymentDomesticPercent  >100 || tempTotalPaymentDomesticPercent==null ){
                         ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Payment Domestic (%) must not be null or  more than 100%'));
                        return null;
                    }else{
                        wallet.EstimatedSalesAmtPerYear__c =tempEstimatedSalesAmtPerYear;
                        wallet.TotalDomesticPercent__c = tempTotalDomesticPercent;
                        wallet.COGSPercent__c = tempCOGSPercent;
                        wallet.OperatingExpAmount__c = tempOperatingExpAmount;
                        wallet.TotalPaymentDomesticPercent__c = tempTotalPaymentDomesticPercent;
                        insert wallet;
                        companyprofile.AccountPlanWalletID__c = wallet.id;
                        update companyprofile;
                        AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(companyprofile.id);
                    }
                    
                    
                     
                }catch(DMLEXception e){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
                    System.debug(e.getMessage());
                  return null;
                
            } 
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
        	pr.getParameters().put('WalletID',wallet.id);
            if(GroupID !=null && GroupID !=''){
            	pr.getParameters().put('GroupID',GroupID);
            }
        	if(mode !=null && mode !=''){
            	pr.getParameters().put('mode',mode);
            }
            return pr;
    }
    //select option share bank
    public List<SelectOption> getShareBanks(){
        List<SelectOption> shareBanksOption = new List<SelectOption>();
        List<Bank__c> bankListitem = [SELECT Id,Name FROM Bank__c];
        shareBanksOption.add(new SelectOption('','none'));
        Id othersId;
        String othersName;
        for(Bank__c b : bankListitem){
            if(b.Name == 'Others'){
                othersId = b.Id;
                othersName = b.Name;
            }else{
            	shareBanksOption.add(new SelectOption(b.Id,b.Name));
            }
        }
        shareBanksOption.add(new SelectOption(othersId,othersName));
        return shareBanksOption;   
    }
}