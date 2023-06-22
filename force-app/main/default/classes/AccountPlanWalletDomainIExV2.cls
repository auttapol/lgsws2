public without sharing class AccountPlanWalletDomainIExV2 {
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
    public AcctPlanWallet__c wallet {get;set;}
    public List<AcctPlanQuestionnaire__c > QuestionnaireList {get;set;}
    public Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap {get;set;}
    public Map<String,List<string> > DomesticpaymentQ {get;set;}
    public  Set<String> DomesticPaymentSegment {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> CollectionList {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> PaymentList {get;set;}
    public Map<String,Map<String,Double>> StandardFeeTMBMap {get;set;}
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
    public Boolean isRequiredCollectionMethod {get;set;}
    public Boolean isRequiredBillPayment {get;set;}
    public Boolean isRequiredColletionExport {get;set;}
    public Boolean isRequiredPaymentMethod {get;set;}
    public Boolean isRequiredPaymentImport {get;set;}
    public boolean isHasPermission {get;set;}
    public boolean isInitiateNewVersion {get;set;}
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

    
    //Account Plan 5.2
    public Map<String,Account_Plan_Flow_Header__c> fheaderMap {get;set;}
    public Map<String,List<String>> fParentHeaderMap {get;set;}
    public Map<String,List<Account_Plan_Flow_details__c>> fdetailMap {get;set;}
    
    public set<Account_Plan_Flow_Details__c> AcctPlanFlowUpsertSet {get;set;}
    public Map<String,Boolean> existingotherMap {get;set;}
    public Map<String,Double> legacyWalletFeeMap {get;set;}


    public class legacyWallet{
      public Double FeeCharge {get;set;}
      public String Label {get;set;}
      public Double NoOfTransaction {get;set;}
      public Double Volume {get;set;}
      public Double VolumePercent {get;set;}
      public Double SharedTMB {get;set;}
      public Double SharedBank1 {get;set;}
      public Double SharedBank2 {get;set;}
      public Double SharedBank3 {get;set;}
      public Double SharedBank4 {get;set;}
      public Double TermDays {get;set;}
      public String Pattern {get;set;}
      public String TypeOfFee {get;set;}
      public string tablename {get;set;}
      public Double WalletCashFee {get;set;}

    }


     //Account Plan Bond : Jantanee Saetung R5.2
    //public List<AccountPlanBond__c> APBond  {get;set;}
    public List<Account_Plan_AS_Fee__c> ASFee  {get;set;}
    public Double SumOfBondAmount {get;set;}
    public Double SumOfBondNetAssetValue {get;set;}
    public Double SumOfBondIBFee {get;set;}
    public Double SumOfBondASFeeBondRep {get;set;}
    public Double TotalWalletIBFee {get;set;}
    public Double TotalWalletASFee {get;set;}  

    public Double SumOfNetAssetValue {get;set;}  
    public Double SumOfASFee {get;set;}  
    public Double SumOfFixedASFee {get;set;}  
    public Double SumOfWalletASFee {get;set;}  



  //mandotory
    public String msgSalesDomestic {get;set;}
    public String msgSalesExport {get;set;}
    public String msgCollectionCurrency {get;set;}
    public String msgPaymentDomestic {get;set;}
    public String msgPaymentImport {get;set;}
    public String msgPaymentCurrency {get;set;}
    public String msgRequiredBillPayment {get;set;}
    
    //warning message

    public String msgWarningNewVersion {get;set;}
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
                
                
                if( (tempCOGSPercent >=0 && tempCOGSPercent !=null && tempCOGSPercent <=100)
                    || (tempOperatingExpAmount >= 0 
                       && tempOperatingExpAmount !=null
                      &&tempOperatingExpAmountStr !='')
                 ){
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
                    
                    
                    
                }else{      tempCOGSAmount = 0;
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

     public AccountPlanWalletDomainIExV2(ApexPages.StandardController controller){
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
       CollectionList = new List<AcctPlanCollectionOrPaymentCurrency__c >();
             PaymentList = new List<AcctPlanCollectionOrPaymentCurrency__c >();
             DomesticPaymentSegment = new Set<String>();       
             
             
                 
             //Initial Maps
             QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
             StandardFeeTMBMap = new Map<String,Map<String,Double>>();
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
              
             //Set Standard Fee 
             //TestChangedGit
             CollectionMethodExportStandardFee = 0;
              Database.QueryLocator qStandardFee = Database.getQueryLocator('SELECT ColumnName__c , PercentOfStandardFee__c,TableName__c, TypeOfFee__c,'+segmentOwner+'_StandardFee__c FROM AcctPlanStandardFee__c order by TableName__c');
              Database.QueryLocatorIterator itStandardFee =  qStandardFee.iterator();
              while (itStandardFee.hasNext()){
                  AcctPlanStandardFee__c stdFee = (AcctPlanStandardFee__c)itStandardFee.next();
                   if(stdFee.TableName__c == 'Collection Method Export'){
                      CollectionMethodExportStandardFee = Double.valueOf(stdFee.get(segmentOwner+'_StandardFee__c'));
                  }
                  String tablename = stdFee.TableName__c.replace(' Method','');
                  if(StandardFeeTMBMap.containsKey(tablename)){
                      StandardFeeTMBMap.get(tablename).put(stdFee.ColumnName__c,Double.valueOf(stdFee.get(segmentOwner+'_StandardFee__c')));
                  }else{
                      Map<String,Double> stdfeemap = new Map<String,Double>();
                      stdfeemap.put(stdFee.ColumnName__c,Double.valueOf(stdFee.get(segmentOwner+'_StandardFee__c')));
                      StandardFeeTMBMap.put(tablename,stdfeemap);
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
                &&(wallet.TotalPaymentDomesticAmtPerYear__c !=null && wallet.TotalPaymentDomesticAmtPerYear__c != 0)
               ){
                 isRequiredPaymentMethod = true;
             }
             
             isRequiredPaymentImport = false;
             if((wallet.SumOfPaymentImportVolPercent__c ==null 
                 ||wallet.SumOfPaymentImportVolPercent__c ==0)
                &&(wallet.TotalPaymentImportPercent__c !=null && wallet.TotalPaymentImportPercent__c != 0)
                 &&(wallet.TotalPaymentImportAmtPerYear__c !=null && wallet.TotalPaymentImportAmtPerYear__c != 0)
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
             
            
             
             
                 List <Account_Plan_Flow_Header__c> flowheaderList = [SELECT ID,Account_Plan_Flow_Header__c, EX_ID__c,SEQ__c,
                                   Method__c, Label__c,isHideRow__c,
                                   Account_Plan_Flow_Clone__c,isHide_Shared__c ,
                                   isExcludeforSum__c, isFreeCharge__c,Type_of_Fee__c ,
                                    isNoTransactions__c,Fee_Charge_Type__c ,isActive__C,
                                   isProvidentfund__c, isTerm__c, isVolumePercent__c 
                                   from Account_Plan_Flow_Header__c
                                   WHERE isActive__C = true
                                  ORDER BY SEQ__c ASC
                                  ];
               
             
             
          List <Account_Plan_Flow_Details__c> flowdetailList = [SELECT ID, Account_Plan_Flow_Header__c , Account_Plan_Wallet__c,
                                   FeeCharge__c ,Pattern__c ,TermDays__c ,
                                   NoOfTransaction__c,SharedBank1__c,
                                   SharedBank2__c ,SharedBank3__c,
                                   SharedBank4__c ,SharedTMB__c ,
                                   StandardFee__c ,Volume__c ,
                                   Account_Plan_Flow_Header__r.isExcludeforSum__c,
                                   Account_Plan_Flow_Header__r.isFreeCharge__c ,
                                    Account_Plan_Flow_Header__r.isHideRow__c ,
                                    Account_Plan_Flow_Header__r.Account_Plan_Flow_Clone__c,
                                   Account_Plan_Flow_Header__r.Label__c ,   
                                   Account_Plan_Flow_Header__r.Method__c ,                                   
                                   VolumePercent__c ,CD_WalletFee__c,AvgProvidentFund__c
                                 FROM Account_Plan_Flow_Details__c 
                                 WHERE Account_Plan_Wallet__c =: wallet.id
                                 AND Account_Plan_Flow_Header__r.isActive__c = true                                      
                                 ORDER BY Account_Plan_Flow_Header__r.SEQ__c ASC,Account_Plan_Flow_Header__r.method__c ASC];
             
             Map<String,Map<String,legacyWallet>> legacyWalletMap = new Map<String,Map<String,legacyWallet>>();
             legacyWalletFeeMap = new Map<String,Double>();
             fdetailMap = new Map<String,List<Account_Plan_Flow_Details__c>>();
             fParentHeaderMap = new Map<String,List<String>>();
             fheaderMap = new Map<String,Account_Plan_Flow_Header__c>();
             Map<String,Account_Plan_Flow_Details__c> fheaderwithDetailMap = new Map<String,Account_Plan_Flow_Details__c>();
             existingotherMap = new Map<String,Boolean>();
             //Existing DetailList
             for(Account_Plan_Flow_Details__c fdetail : flowdetailList){
                 fheaderwithDetailMap.put(fdetail.Account_Plan_Flow_Header__c,fdetail);
             }

             isInitiateNewVersion = false;

             //Initiate Acctplan 5.2 
             System.debug('flowdetailList: '+flowdetailList.size());

             if(flowdetailList.size()==0){


              //Check Migration needed or not

              List<AcctPlanCollectionDomestic__c> collectdomesticlist = [SELECT ID,AcctPlanCollectionMethodDomestic__c,
                                                                             FeeCharge__c,Label__c ,NoOfTransaction__c ,
                                                                             SharedBank1__c ,SharedBank2__c ,SharedBank3__c ,
                                                                             SharedBank4__c ,SharedTMB__c ,StandardFee__c ,
                                                                             Volume__c ,VolumePercent__c ,WalletFee__c 
                                                                             FROM AcctPlanCollectionDomestic__c 
                                                                            WHERE AcctPlanCollectionMethodDomestic__c = : wallet.id];

             if(collectdomesticlist.size()>0){
              //Migration data is needed
              Map<String,legacyWallet> legacyCollectionDomesticMap = new Map<String,legacyWallet>();
              for(AcctPlanCollectionDomestic__c Cdomestic :  collectdomesticlist){

                  legacyWallet legacyDomestic = new legacyWallet();
                  legacyDomestic.Label = Cdomestic.Label__c;
                  legacyDomestic.NoOfTransaction = Cdomestic.NoOfTransaction__c;
                  legacyDomestic.Volume = Cdomestic.Volume__c;
                  legacyDomestic.VolumePercent = Cdomestic.VolumePercent__c;
                  legacyDomestic.SharedTMB = Cdomestic.SharedTMB__c;
                  legacyDomestic.SharedBank1 = Cdomestic.SharedBank1__c;
                  legacyDomestic.SharedBank2 = Cdomestic.SharedBank2__c;
                  legacyDomestic.SharedBank3 = Cdomestic.SharedBank3__c;
                  legacyDomestic.SharedBank4 = Cdomestic.SharedBank4__c;
                  legacyDomestic.FeeCharge = Cdomestic.FeeCharge__c;
                  legacyDomestic.WalletCashFee = Cdomestic.WalletFee__c;
                  legacyDomestic.tablename = 'Collection Domestic';
                  legacyCollectionDomesticMap.put(Cdomestic.label__c,legacyDomestic);

              }

              legacyWalletMap.put('Collection Domestic',legacyCollectionDomesticMap);


              //Migrate the rest
              Map<String,legacyWallet> legacyCollectionExportMap = new Map<String,legacyWallet>();
              for(AcctPlanCollectionExport__c Cexport :  [SELECT ID,AcctPlanCollectionMethodExport__c ,Label__c,
                                                                             SharedBank1__c ,SharedBank2__c ,SharedBank3__c ,
                                                                             SharedBank4__c ,SharedTMB__c ,TermDays__c  ,StandardFee__c,
                                                                             Volumn__c  ,VolumnPercent__c,Pattern__c  
                                                                             FROM AcctPlanCollectionExport__c  
                                                                            WHERE AcctPlanCollectionMethodExport__c   = : wallet.id]){

                legacyWallet legacyExport = new legacyWallet();
                  legacyExport.Label = Cexport.Label__c;
                  legacyExport.Volume = Cexport.Volumn__c;
                  legacyExport.VolumePercent = Cexport.VolumnPercent__c;
                  legacyExport.SharedTMB = Cexport.SharedTMB__c;
                  legacyExport.SharedBank1 = Cexport.SharedBank1__c;
                  legacyExport.SharedBank2 = Cexport.SharedBank2__c;
                  legacyExport.SharedBank3 = Cexport.SharedBank3__c;
                  legacyExport.SharedBank4 = Cexport.SharedBank4__c;
                  legacyExport.Pattern = Cexport.Pattern__c;
                  legacyExport.TermDays =Cexport.TermDays__c;
                  legacyExport.WalletCashFee = 0;
                  legacyExport.tablename = 'Collection Export';
                  legacyCollectionExportMap.put(Cexport.label__c,legacyExport);

              }
              legacyWalletMap.put('Collection Export',legacyCollectionExportMap);

             


              Map<String,legacyWallet> legacyPaymentDomesticMap = new Map<String,legacyWallet>();

              for(AcctPlanPaymentDomestic__c pDomestic :  [SELECT ID, AvgProvidentFund__c, Label__c, NoOfTransaction__c , SharedBank1__c ,
                                                             SharedBank2__c , SharedBank3__c , SharedBank4__c , SharedTMB__c , StandardFee__c ,FeeCharge__c,
                                                              Volume__c ,VolumePercent__c ,WalletFee__c , AcctPlanPaymentMethodDomestic__c 
                                                                             FROM AcctPlanPaymentDomestic__c   
                                                                            WHERE AcctPlanPaymentMethodDomestic__c    = : wallet.id
                              ORDER BY LastModifiedDate DESC LIMIT 12]){

                 legacyWallet legacyPdomestic = new legacyWallet();
                  legacyPdomestic.Label = pDomestic.Label__c;
                  legacyPdomestic.FeeCharge = pDomestic.FeeCharge__c;
                  legacyPdomestic.Volume = pDomestic.Volume__c;
                  legacyPdomestic.VolumePercent = pDomestic.VolumePercent__c;
                  legacyPdomestic.NoOfTransaction = pDomestic.NoOfTransaction__c;
                  legacyPdomestic.SharedTMB = pDomestic.SharedTMB__c;
                  legacyPdomestic.SharedBank1 = pDomestic.SharedBank1__c;
                  legacyPdomestic.SharedBank2 = pDomestic.SharedBank2__c;
                  legacyPdomestic.SharedBank3 = pDomestic.SharedBank3__c;
                  legacyPdomestic.SharedBank4 = pDomestic.SharedBank4__c;
                  if(pDomestic.StandardFee__c !=null){
                    legacyPdomestic.WalletCashFee = pDomestic.WalletFee__c;
                  }else{
                    legacyPdomestic.WalletCashFee = 0;
                  }
                  legacyPdomestic.tablename = 'Payment Domestic';
                  legacyPaymentDomesticMap.put(pDomestic.label__c,legacyPdomestic);


              }
              legacyWalletMap.put('Payment Domestic',legacyPaymentDomesticMap);



              Map<String,legacyWallet> legacyPaymentImportMap = new Map<String,legacyWallet>();

              for(AcctPlanPaymentImport__c pImport :  [SELECT ID, FeeCharge__c , Label__c, NoOfTransaction__c , SharedBank1__c ,Term__c,
                                                             SharedBank2__c , SharedBank3__c ,Type_of_Fee__c, SharedBank4__c , SharedTMB__c , StandardFee__c ,
                                                              Volume__c ,VolumePercent__c ,Pattern__c, AcctPlanPaymentMethodImport__c,WalletTFFee__c
                                                                             FROM AcctPlanPaymentImport__c    
                                                                            WHERE AcctPlanPaymentMethodImport__c = : wallet.id]){

                 legacyWallet legacyPImport = new legacyWallet();
                  legacyPImport.Label = pImport.Label__c;
                  legacyPImport.FeeCharge = pImport.FeeCharge__c;
                  legacyPImport.Volume = pImport.Volume__c;
                  legacyPImport.VolumePercent = pImport.VolumePercent__c;
                  legacyPImport.NoOfTransaction = pImport.NoOfTransaction__c;
                  legacyPImport.SharedTMB = pImport.SharedTMB__c;
                  legacyPImport.SharedBank1 = pImport.SharedBank1__c;
                  legacyPImport.SharedBank2 = pImport.SharedBank2__c;
                  legacyPImport.SharedBank3 = pImport.SharedBank3__c;
                  legacyPImport.SharedBank4 = pImport.SharedBank4__c;
                  legacyPImport.Pattern = pImport.Pattern__c;
                  legacyPImport.TermDays =pImport.Term__c;
                  legacyPImport.TypeOfFee = pImport.Type_of_Fee__c;
                  legacyPImport.WalletCashFee = pImport.WalletTFFee__c;
                  legacyPImport.tablename = 'Payment Import';
                  legacyPaymentImportMap.put(pImport.label__c,legacyPImport);


              }
              legacyWalletMap.put('Payment Import',legacyPaymentImportMap);







             }                                                               
             


             }
             

             if(legacyWalletMap.size()>0){
                if(flowdetailList.size()==0){
                  
                    isInitiateNewVersion = true;
                   }
                         Double wallettrade = 0.00;
                            wallet.TotalExportAvgPerMonth__c = 0.00;
                            wallet.SumOfPaymentDomesticAvgPerMonth__c =0;
                            wallet.SumOfPaymentImportImportVol__c = 0;
                            wallet.SumOfPaymentImportVolPercent__c = 0;
                            wallet.SumOfPaymentImportNoOfTransaction__c = 0;  
                            wallet.SumOfCollectionDomesticVolumn__c = 0;       
                            wallet.SumOfCollectionExportVolPercent__c = 0;
                            wallet.SumOfCollectionVolumnPercent__c =0;
                            wallet.SumOfPaymentDomesticVolPercent__c = 0;
                           //wallet.SumOfCollectionWalletCashFee__c = 0;  
                           //wallet.SumOfCollectionExportWalletTradeFee__c = 0;
                           //wallet.SumOfPaymentDomesticWalletCashFee__c = 0;
                           //wallet.SumOfPaymentImportWalletTFFee__c = 0;

                           
                     }



            
             Double PaymentDomesticExcluded = 0;
             //Get all Header List
             for(Account_Plan_Flow_Header__c fheader : flowheaderList){   
                 fheaderMap.put(fheader.id,fheader);
                 //Keep collection of Parent-child fheader
                 
                 if(fheader.Account_Plan_Flow_Header__c !=null){
                     if(fParentHeaderMap.containsKey(fheader.Account_Plan_Flow_Header__c)){
                         fParentHeaderMap.get(fheader.Account_Plan_Flow_Header__c).add(fheader.id);
                     }else{
                         List<String> ListofChildren = new List<String>();
                         ListofChildren.add(fheader.id);
                         fParentHeaderMap.put(fheader.Account_Plan_Flow_Header__c,ListofChildren);
                     }
                 }
                 
                 
                 //New or Existing fDetail
                 Account_Plan_Flow_Details__c fdetail;
                 if(!fheaderwithDetailMap.containsKey(fheader.id)){
                      fdetail = new Account_Plan_Flow_Details__c();
                     fdetail.Account_Plan_Wallet__c = wallet.Id;
                     // IF This row need to has standard FEE
                     if(StandardFeeTMBMap.containsKey(fheader.Method__c)){
                         if(StandardFeeTMBMap.get(fheader.Method__c).containsKey(fheader.label__c)){
                             fdetail.StandardFee__c = StandardFeeTMBMap.get(fheader.Method__c).get(fheader.label__c);
                           fdetail.FeeCharge__c = StandardFeeTMBMap.get(fheader.Method__c).get(fheader.label__c);
                         }
                     }
                     fdetail.Account_Plan_Flow_Header__c = fheader.id;

                     //Check Migration with Legacy Wallet


                     legacyWalletFeeMap.put(fheader.id,0);


                     


                     if(legacyWalletMap.containsKey(fheader.Method__c)){
                        Map<String,legacyWallet> legacymap = legacyWalletMap.get(fheader.Method__c);

                        if(legacymap.containsKey(fheader.Label__c)){
                          legacyWallet legacy = legacymap.get(fheader.Label__c);
                              
                          fdetail.NoOfTransaction__c = legacy.NoOfTransaction;
                          fdetail.Volume__c = legacy.Volume;
                          fdetail.VolumePercent__c = legacy.VolumePercent;
                          fdetail.SharedTMB__c = legacy.SharedTMB;
                          fdetail.SharedBank1__c = legacy.SharedBank1;
                          fdetail.SharedBank2__c = legacy.SharedBank2;
                          fdetail.SharedBank3__c = legacy.SharedBank3;
                          fdetail.SharedBank4__c = legacy.SharedBank4;
                          fdetail.Pattern__c =  legacy.Pattern;
                          fdetail.TermDays__c = legacy.TermDays;
                          if(legacy.FeeCharge !=null && legacy.FeeCharge!=0){
                            fdetail.FeeCharge__c = legacy.FeeCharge;
                          }
                          fdetail.Volume__c = legacy.Volume;

                          if(legacy.WalletCashFee !=null ){
                            legacyWalletFeeMap.put(fheader.id,legacy.WalletCashFee);

                            //Sum Total for show
                                 /*if(fheader.Method__c == 'Collection Domestic'){
                                         wallet.SumOfCollectionWalletCashFee__c  += legacy.WalletCashFee;
                                 } else if(fheader.Method__c== 'Collection Export'){
                                             wallet.SumOfCollectionExportWalletTradeFee__c  += legacy.WalletCashFee;
                                 }
                                 else if(fheader.Method__c == 'Payment Domestic' ){
                                            wallet.SumOfPaymentDomesticWalletCashFee__c  += legacy.WalletCashFee;
                                 }else if(fheader.Method__c == 'Payment Import'){
                                             wallet.SumOfPaymentImportWalletTFFee__c  += legacy.WalletCashFee;
                                }
                                */

                        //

                          }
                        

                          // LC Term 2 clear Volume Percent ( Clone )

                          if(fheader.Account_Plan_Flow_Clone__c !=null){
                            fdetail.VolumePercent__c = 0;
                          }
                         

                        }
                        



                     }

                    



                     
                     fheaderwithDetailMap.put(fheader.id,fdetail);
                 }else{
                     fdetail = fheaderwithDetailMap.get(fheader.id);
                 }
                 
                 //fdetailList
                 if(fdetailMap.containsKey(fheader.Method__c)){
                     fdetailMap.get(fheader.Method__c).add(fdetail);
                 }else{
                    List<Account_Plan_Flow_Details__c>  fdetailList = new List<Account_Plan_Flow_Details__c>();
                     fdetailList.add(fdetail);
                     fdetailMap.put(fheader.Method__c,fdetailList);
                 }
                 
             }


             //Recalculate - new Version
             if(isInitiateNewVersion){
                   
             for(String parentID : fParentHeaderMap.keyset()){
                      if(fheaderwithDetailMap.containsKey(ParentID)){
                            Account_Plan_Flow_details__c parent = fheaderwithDetailMap.get(ParentID);
                          Double Volume=0;
                          Double VolumePercent =0;
                          Double SharedTMB =0;
                          Double SharedBank1  =0;
                          Double SharedBank2 =0;
                          Double SharedBank3  =0;
                          Double SharedBank4 =0;
                          Double NoOfTransaction = 0;
                          boolean isHasIncluded = false;

                    for(String childID : fParentHeaderMap.get(ParentID)){
                      if(fheaderwithDetailMap.containskey(childID)){
                        Account_Plan_Flow_details__c child = fheaderwithDetailMap.get(childID);
                        if(!fheaderMap.get(child.Account_Plan_Flow_Header__c).isExcludeforSum__c){
                          isHasIncluded = true;
                                        Volume += (child.Volume__c!=null?child.Volume__c:0);
                                        VolumePercent += (child.VolumePercent__c!=null?child.VolumePercent__c:0);
                                        SharedTMB += (child.SharedTMB__c!=null?child.SharedTMB__c:0);
                                        SharedBank1 += (child.SharedBank1__c!=null?child.SharedBank1__c:0) ;
                                        SharedBank2 += (child.SharedBank2__c!=null?child.SharedBank2__c:0);
                                        SharedBank3 += (child.SharedBank3__c!=null?child.SharedBank3__c:0);
                                        SharedBank4 += (child.SharedBank4__c!=null?child.SharedBank4__c:0);
                                        NoOfTransaction +=(child.NoOfTransaction__c!=null?child.NoOfTransaction__c:0);

                        }
                      }

                    }

                    if(isHasIncluded){

                              parent.Volume__c=Volume;
                              parent.VolumePercent__c =VolumePercent;
                              parent.SharedTMB__c =SharedTMB;
                              parent.SharedBank1__c =SharedBank1;
                              parent.SharedBank2__c=SharedBank2;
                              parent.SharedBank3__c =SharedBank3;
                              parent.SharedBank4__c =SharedBank4;
                              //if(fdetailParent.Account_Plan_Flow_Header__r.Method__c =='Payment Import'){
                              parent.NoOfTransaction__c = NoOfTransaction;
                              //}else{
                              //  fdetailParent.NoOfTransaction__c =0;
                              //}

                           }


                      }
             }



                 //Sum Total wallet

                    for(String Domainname : fdetailMap.keyset()){
                          for(Account_Plan_Flow_Details__c fdetail : fdetailMap.get(domainName)){
                                Account_Plan_Flow_Header__c fheader = fheaderMap.get(fdetail.Account_Plan_Flow_Header__c);
                                    if(fheader.Method__c == 'Collection Domestic' && fheader.Account_Plan_Flow_Header__c ==null){
                                             wallet.SumOfCollectionDomesticVolumn__c += fdetail.Volume__c==null?0:fdetail.Volume__c;
                                             wallet.SumOfCollectionVolumnPercent__c += fdetail.VolumePercent__c==null?0:fdetail.VolumePercent__c;
                                       
                                     }else if(fheader.Method__c== 'Collection Export' && fheader.Account_Plan_Flow_Header__c ==null){
                                                  wallet.TotalExportAvgPerMonth__c  +=  fdetail.Volume__c==null?0:fdetail.Volume__c.setScale(0) ;
                                                  wallet.SumOfCollectionExportVolPercent__c += fdetail.VolumePercent__c==null?0:fdetail.VolumePercent__c;

                                     }else if(fheader.Method__c == 'Payment Domestic' && fheader.Account_Plan_Flow_Header__c ==null 
                                      && !fheader.isExcludeforSum__c){
                                        wallet.SumOfPaymentDomesticAvgPerMonth__c += fdetail.Volume__c==null?0:fdetail.Volume__c;
                                        wallet.SumOfPaymentDomesticVolPercent__c += fdetail.VolumePercent__c==null?0:fdetail.VolumePercent__c;
                                        
                                    }else if(fheader.Method__c == 'Payment Domestic' && fheader.Account_Plan_Flow_Header__c ==null && fheader.isExcludeforSum__c){
                                        PaymentDomesticExcluded += fdetail.Volume__c==null?0:fdetail.Volume__c;
                                        
                                    }else if(fheader.Method__c =='Payment Import' && fheader.Account_Plan_Flow_Header__c ==null &&!fheader.isExcludeforSum__c && !fheader.isHideRow__c ){
                                        System.debug('fdetail : '+fheader.Label__c+' : '+fdetail.VolumePercent__c+' : '+fdetail.Volume__c +' : '+fdetail.NoOfTransaction__c);
                                        wallet.SumOfPaymentImportNoOfTransaction__c += fdetail.NoOfTransaction__c==null?0:fdetail.NoOfTransaction__c;
                                        wallet.SumOfPaymentImportImportVol__c += fdetail.Volume__c==null?0:fdetail.Volume__c;
                                        wallet.SumOfPaymentImportVolPercent__c += fdetail.VolumePercent__c==null?0:fdetail.VolumePercent__c;
                                                
                                    }

                    }

                 }

             }






            
            List<String> TableNameList = new List<String>();
            TableNameList.add('Collection Method Domestic');
            TableNameList.add('Collection Method Export');
            TableNameList.add('Payment Method Domestic');
            TableNameList.add('Payment Method Import');
             for(AcctPlanWalletOtherBank__c otherbank : [SELECT Id,AcctPlanWallet__c,TableName__c ,SharedBank1__c,SharedBank1__r.Name, SharedBank2__c,SharedBank2__r.Name, SharedBank3__c,SharedBank3__r.Name, SharedBank4__c, SharedBank4__r.Name  
                                                                                 FROM AcctPlanWalletOtherBank__c 
                                                                                 WHERE AcctPlanWallet__c = :wallet.Id ]){
                  if(otherbank.TableName__c =='Collection Method Domestic'){
                      otherBankCollectionDomestic = otherbank;                                                                   
                  }else if(otherbank.TableName__c =='Collection Method Export'){
                      otherBankCollectionExport = otherbank; 
                  }else if(otherbank.TableName__c =='Payment Method Domestic'){
                      otherBankPaymentDomestic = otherbank; 
                  }else if(otherbank.TableName__c =='Payment Method Import'){
                      otherBankPaymentImport = otherbank; 
                  }
                  existingotherMap.put(otherbank.TableName__c,true);                                                                   
             }
             
             
             for(String key : TableNameList){
                 if(!existingotherMap.containsKey(key)){
                     AcctPlanWalletOtherBank__c otherbank = new AcctPlanWalletOtherBank__c();
                     otherbank.AcctPlanWallet__c = wallet.Id;
                     otherbank.TableName__c = key;
                      if(key =='Collection Method Domestic'){
                          otherBankCollectionDomestic = otherbank;                                                                   
                      }else if(key =='Collection Method Export'){
                          otherBankCollectionExport = otherbank; 
                      }else if(key =='Payment Method Domestic'){
                          otherBankPaymentDomestic = otherbank; 
                      }else if(key =='Payment Method Import'){
                          otherBankPaymentImport = otherbank; 
                      }
                 }
                
             }
             
               
                 
             if( wallet.SumOfCollectionExportStandardFee__c ==null ||wallet.SumOfCollectionExportStandardFee__c ==0){
                wallet.SumOfCollectionExportStandardFee__c = CollectionMethodExportStandardFee; 
             }
             //Case Production issues
             if( wallet.SumOfCollectionExportFeeCharge__c ==null){
                wallet.SumOfCollectionExportFeeCharge__c = CollectionMethodExportStandardFee; 
             }

         }else{
             wallet = new AcctPlanWallet__c();
             wallet.AcctPlanCompanyProfile__c = companyprofile.id;
             
         }
            

               
             
                
                loadCurrency();
                ASFee();

         } //Has ID
      
       
         msgSalesDomestic = Account_Plan_Status_Code__c.GetValues('3102').Status_Message__c;
          msgSalesExport = Account_Plan_Status_Code__c.GetValues('3103').Status_Message__c;
          msgCollectionCurrency = Account_Plan_Status_Code__c.GetValues('3104').Status_Message__c;
          msgPaymentDomestic  = Account_Plan_Status_Code__c.GetValues('3105').Status_Message__c;
          msgPaymentImport = Account_Plan_Status_Code__c.GetValues('3106').Status_Message__c;
          msgPaymentCurrency = Account_Plan_Status_Code__c.GetValues('3107').Status_Message__c;
          msgRequiredBillPayment = Account_Plan_Status_Code__c.GetValues('3108').Status_Message__c;
          msgWarningNewVersion = Account_Plan_Status_Code__c.GetValues('3013').Status_Message__c;
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




    
    //Account Plan Bond  : Jantanee Saetung R5.2
    public void ASFee(){
        Boolean isHasASFee = true;
         SumOfNetAssetValue = 0;
         SumOfASFee = 0;
         SumOfFixedASFee = 0;
         SumOfWalletASFee = 0; 
        
        ASFee = [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__c
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :wallet.Id
                          ORDER BY SEQ__c ASC];
        if(ASFee.size() > 0){
            for(Account_Plan_AS_Fee__c item : ASFee){
                if(item.Net_Asset_Value__c == null){
                    item.Net_Asset_Value__c = 0;
                } 
                if(item.AS_Fee__c == null){
                    item.AS_Fee__c =0;
                }
                if(item.Fixed_AS_Fee__c == null){
                    item.Fixed_AS_Fee__c =0;
                }

                SumOfNetAssetValue += item.Net_Asset_Value__c;
                SumOfASFee += item.AS_Fee__c;    
                SumOfFixedASFee += item.Fixed_AS_Fee__c;  
                if( item.Wallet_AS_Fee__c != null) {
                    SumOfWalletASFee += item.Wallet_AS_Fee__c;    
                }
            }            
        }else{
            isHasASFee = false;
        }
        
        if(!isHasASFee){
            ASFee = new List<Account_Plan_AS_Fee__c>();
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
           
              Double SumOfWalletASFee = 0;

            Double WalletASFee_AgencyService = 0; 
            Double WalletASFee_Custodian  = 0;  
            Double WalletASFee_FundSupervisory  =0;
            Double WalletASFee_MiddleOffice =0;
            Double WalletASFee_RegistrarPaymentAgent =0;
            
           
            
            
            update wallet;            
            
            wallet =  AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id).get(0);
          
                
            DynamicQuestionnaire();
                //
            
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
            
                     
            
           
            Double wallettrade = 0.00;
            wallet.TotalExportAvgPerMonth__c = 0.00;
            wallet.SumOfPaymentDomesticAvgPerMonth__c =0;
            wallet.SumOfPaymentImportImportVol__c = 0;
            wallet.SumOfPaymentImportNoOfTransaction__c = 0;  
            wallet.SumOfCollectionDomesticVolumn__c = 0;          
            //5.2
            //
            //
            //
            Map<String,Account_Plan_Flow_Details__c> HeaderwithDtailMap = new Map<String,Account_Plan_Flow_Details__c>();
            Map<String,List<String>> HeaderwithCloneMap = new Map<String,List<String>>();

            for(String Domain : fdetailMap.keySet()){
               for(Account_Plan_Flow_Details__c fdetails : fdetailMap.get(Domain)){
               
               
               /******************** BAU Issue 00005057 2017-02-27 ********************/
               
               //system.debug('isfeecharge ->'+fheaderMap.get(fdetails.Account_Plan_Flow_Header__c).isFreeCharge__c +' - '+fdetails.FeeCharge__c+' - '+fdetails.StandardFee__c);
               
               if (fheaderMap.get(fdetails.Account_Plan_Flow_Header__c).isFreeCharge__c && fdetails.FeeCharge__c == null)
               {
                   fdetails.FeeCharge__c = fdetails.StandardFee__c;
               }
               
               /******************** BAU Issue 00005057 2017-02-27 ********************/
               
                  //Volume
                   if(Domain == 'Collection Domestic'){
                       if(wallet.TotalDomesticAmtPerYear__c !=null && fdetails.VolumePercent__c !=null){
                             fdetails.Volume__c = (wallet.TotalDomesticAmtPerYear__c * (fdetails.VolumePercent__c/100))/12;
                      }
                   }else if(Domain == 'Collection Export'){
                       if(wallet.TotalExportAmtPerYear__c !=null && fdetails.VolumePercent__c !=null){
                             fdetails.Volume__c = (wallet.TotalExportAmtPerYear__c/12) * (fdetails.VolumePercent__c/100);
                      }
                       
                        
                   }else if(Domain == 'Payment Domestic'){
                       if(wallet.TotalPaymentDomesticAmtPerYear__c !=null && fdetails.VolumePercent__c !=null){
                            fdetails.Volume__c = (wallet.TotalPaymentDomesticAmtPerYear__c /12) * (fdetails.VolumePercent__c/100);


                   
                      }
                    }else if(Domain == 'Payment Import'){
                       if(wallet.TotalPaymentImportAmtPerYear__c !=null 
                        && fdetails.VolumePercent__c !=null
                        && !fdetails.Account_Plan_Flow_Header__r.isHideRow__c
                        ){
                             fdetails.Volume__c = (wallet.TotalPaymentImportAmtPerYear__c /12) * (fdetails.VolumePercent__c/100);
                   
                      }
                    }
                  //
                  
                  //Set Clone Values Map

                  if(fdetails.Account_Plan_Flow_Header__r.Account_Plan_Flow_Clone__c !=null){
                    if(HeaderwithCloneMap.ContainsKey(fdetails.Account_Plan_Flow_Header__r.Account_Plan_Flow_Clone__c)){
                        HeaderwithCloneMap.get(fdetails.Account_Plan_Flow_Header__r.Account_Plan_Flow_Clone__c).add(fdetails.Account_Plan_Flow_Header__c);
                      }else{
                        List<String> cloneList = new List<String>();
                        cloneList.add(fdetails.Account_Plan_Flow_Header__c);
                        HeaderwithCloneMap.put(fdetails.Account_Plan_Flow_Header__r.Account_Plan_Flow_Clone__c,cloneList);
                      }

                  }

                  //


                   HeaderwithDtailMap.put(fdetails.Account_Plan_Flow_Header__c,fdetails);
              }
             }



             //Set Value for clone
             for(String originID : HeaderwithCloneMap.keySet()){
                  if(HeaderwithDtailMap.containsKey(originID)){
                    Account_Plan_Flow_Details__c originRec = HeaderwithDtailMap.get(originID);
                    for(String cloneID : HeaderwithCloneMap.get(OriginID)){
                     if(HeaderwithDtailMap.containsKey(cloneID)){
                       Account_Plan_Flow_Details__c  cloneREC = HeaderwithDtailMap.get(cloneID);
                       cloneREC.TermDays__c = originRec.TermDays__c==null?0:originRec.TermDays__c;
                       cloneREC.Pattern__c = originRec.Pattern__c;
                       cloneREC.Volume__c = originRec.Volume__c==null?0:originRec.Volume__c;
                     }
                    }

                  }
             } 


             //
            
            
            AcctPlanFlowUpsertSet = new Set<Account_Plan_Flow_Details__c>();
            //Sum to Parent
             for(String Domain : fdetailMap.keySet()){
                 System.debug('Domain: '+Domain);
               for(Account_Plan_Flow_Details__c fdetailParent : fdetailMap.get(Domain)){
                   //If this header is Parent
                   if(fParentHeaderMap.containsKey(fdetailParent.Account_Plan_Flow_Header__c)){
                       //Initiate zero for Parent
                      
                      Double Volume=0;
                      Double VolumePercent =0;
                      Double SharedTMB =0;
                      Double SharedBank1  =0;
                      Double SharedBank2 =0;
                      Double SharedBank3  =0;
                      Double SharedBank4 =0;
                      Double NoOfTransaction = 0;
                      boolean isHasIncluded = false;
                       for(String ChildrenID : fParentHeaderMap.get(fdetailParent.Account_Plan_Flow_Header__c)){
                           //Get ALL chliren to SUM UP
                           //
                           Account_Plan_Flow_Details__c fdetailChildren = HeaderwithDtailMap.get(ChildrenID);
                            if(!fheaderMap.get(fdetailChildren.Account_Plan_Flow_Header__c).isExcludeforSum__c){
                                  isHasIncluded = true;
                                  Volume += (fdetailChildren.Volume__c!=null?fdetailChildren.Volume__c:0);
                                  VolumePercent += (fdetailChildren.VolumePercent__c!=null?fdetailChildren.VolumePercent__c:0);
                                  SharedTMB += (fdetailChildren.SharedTMB__c!=null?fdetailChildren.SharedTMB__c:0);
                                  SharedBank1 += (fdetailChildren.SharedBank1__c!=null?fdetailChildren.SharedBank1__c:0) ;
                                  SharedBank2 += (fdetailChildren.SharedBank2__c!=null?fdetailChildren.SharedBank2__c:0);
                                  SharedBank3 += (fdetailChildren.SharedBank3__c!=null?fdetailChildren.SharedBank3__c:0);
                                  SharedBank4 += (fdetailChildren.SharedBank4__c!=null?fdetailChildren.SharedBank4__c:0);
                                  NoOfTransaction +=(fdetailChildren.NoOfTransaction__c!=null?fdetailChildren.NoOfTransaction__c:0);
                            }
                           
                       }
                       

                       if(isHasIncluded){

                          fdetailParent.Volume__c=Volume;
                          fdetailParent.VolumePercent__c =VolumePercent;
                          fdetailParent.SharedTMB__c =SharedTMB;
                          fdetailParent.SharedBank1__c =SharedBank1;
                          fdetailParent.SharedBank2__c=SharedBank2;
                          fdetailParent.SharedBank3__c =SharedBank3;
                          fdetailParent.SharedBank4__c =SharedBank4;
                          //if(fdetailParent.Account_Plan_Flow_Header__r.Method__c =='Payment Import'){
                            fdetailParent.NoOfTransaction__c = NoOfTransaction;
                          //}else{
                          //  fdetailParent.NoOfTransaction__c =0;
                          //}

                       }


                   }
              }
             }
            
            //Sum to wallet
            //
            //
            
             for(String Domain : fdetailMap.keySet()){
                  System.debug('Domain: '+Domain);
                       for(Account_Plan_Flow_Details__c fdetailParent : fdetailMap.get(Domain)){
                        Double volumeTotalPercence = 0;
                          //if TOP-LEVEL
                           if(fheaderMap.get(fdetailParent.Account_Plan_Flow_Header__c).Account_Plan_Flow_Header__c ==null){
                               volumeTotalPercence = fdetailParent.VolumePercent__c!=null? fdetailParent.VolumePercent__c:0;
                               
                               if(Domain =='Collection Domestic'){
                                    wallet.SumOfCollectionDomesticVolumn__c += fdetailParent.Volume__c==null?0:fdetailParent.Volume__c;
                                   
                                TotalnewCMDomestic +=volumeTotalPercence;
                                }
                                if(Domain =='Collection Export'){
                                    if(fdetailParent.Volume__c  !=null ){
                                        wallet.TotalExportAvgPerMonth__c  += fdetailParent.Volume__c.setScale(0) ;
                                     }

                                    TotalnewCMExport +=volumeTotalPercence;
                                    
                                }
                                if(Domain =='Payment Domestic'){
                                    wallet.SumOfPaymentDomesticAvgPerMonth__c += fdetailParent.Volume__c==null?0:fdetailParent.Volume__c;
                                    TotalnewPMDomestic +=volumeTotalPercence;
                                }
                                if(Domain =='Payment Import'){
                                    wallet.SumOfPaymentImportNoOfTransaction__c += fdetailParent.NoOfTransaction__c==null?0:fdetailParent.NoOfTransaction__c;

                                    wallet.SumOfPaymentImportImportVol__c += fdetailParent.Volume__c==null?0:fdetailParent.Volume__c;
                                    TotalnewPMImport +=volumeTotalPercence;
                                }
                           }
                    }
             }
            //
            //
            //
           
            
            
            
            if(wallet.TotalDomesticPercent__c > 100 || wallet.TotalDomesticPercent__c <0 ){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Total Sales Domestic (%) must not be more than 100%')); 
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3001').Status_Message__c));
          }
            if(wallet.COGSPercent__c > 100 || wallet.COGSPercent__c <0){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , '% COGS (from estimated sales) must not be null or equal to or more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3002').Status_Message__c));
        
            }
            if(wallet.TotalPaymentDomesticPercent__c > 100 || wallet.TotalPaymentDomesticPercent__c <0){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR , 'Total Payment Domestic (%) must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3003').Status_Message__c));
        
            }
            
            if(TotalnewCMDomestic >100 || TotalnewCMDomestic <0){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Collection Method (Domestic) table must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3004').Status_Message__c));
        
            }else{
                wallet.SumOfCollectionVolumnPercent__c =TotalnewCMDomestic;
            }
            
            if(TotalnewCMExport >100 || TotalnewCMExport < 0 ){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Collection Method (Export) table must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3005').Status_Message__c));
        
            }else{
        
                wallet.SumOfCollectionExportVolPercent__c = TotalnewCMExport;
            }
            
            if(TotalnewPMDomestic >100 || TotalnewPMDomestic < 0){
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Payment Method (Domestic) table must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3006').Status_Message__c));
        
            }else{
                wallet.SumOfPaymentDomesticVolPercent__c = TotalnewPMDomestic;
            }
            
            if(TotalNewPMImport >100 || TotalNewPMImport < 0 ){ 
                validate = false;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total %Volume in the Payment Method (Import) table must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3007').Status_Message__c));
        
            }else{
                 wallet.SumOfPaymentImportVolPercent__c = TotalNewPMImport;
            }
            
            
           if(validate){
            upsert AllQuestionsupsertList;
            List<Account_Plan_Flow_Details__c> AcctPlanFlowUpsertList = new List<Account_Plan_Flow_Details__c>();
                AcctPlanFlowUpsertList.addAll(HeaderwithDtailMap.values());
                
             upsert AcctPlanFlowUpsertList;     
                
               //UPDATE WALLET CASH FEE
               wallet.SumOfCollectionWalletCashFee__c = 0;  
               wallet.SumOfCollectionExportWalletTradeFee__c = 0;
               wallet.SumOfPaymentDomesticWalletCashFee__c = 0;
               wallet.SumOfPaymentImportWalletTFFee__c = 0;
               for(Account_Plan_Flow_Details__c fdetails : [SELECT ID,CD_WalletFee__c,Account_Plan_Flow_Header__r.method__c, FeeCharge__c ,Account_Plan_Flow_Header__r.isExcludeforSum__c
                                                            from Account_Plan_Flow_Details__c
                                                           WHERE Account_Plan_Wallet__c =: wallet.id
                                                            AND Account_Plan_Flow_Header__r.isActive__c = true
                                                            ORDER BY Account_Plan_Flow_Header__r.SEQ__c ASC,Account_Plan_Flow_Header__r.method__c ASC ]){
                                   
                                                                if(fdetails.Account_Plan_Flow_Header__r.method__c == 'Collection Domestic'){
                                                                    wallet.SumOfCollectionWalletCashFee__c  += fdetails.CD_WalletFee__c==null?0:fdetails.CD_WalletFee__c;
                       
                                                                }else if(fdetails.Account_Plan_Flow_Header__r.method__c == 'Collection Export'){
                                                                    wallet.SumOfCollectionExportWalletTradeFee__c  += fdetails.CD_WalletFee__c==null?0:fdetails.CD_WalletFee__c;
                                                                   
                                                                }else if(fdetails.Account_Plan_Flow_Header__r.method__c == 'Payment Domestic' ){
                                                                    wallet.SumOfPaymentDomesticWalletCashFee__c  += fdetails.CD_WalletFee__c==null?0:fdetails.CD_WalletFee__c;
                                                                   
                                                                }else if(fdetails.Account_Plan_Flow_Header__r.method__c == 'Payment Import'){
                                                                    wallet.SumOfPaymentImportWalletTFFee__c  += fdetails.CD_WalletFee__c==null?0:fdetails.CD_WalletFee__c;
                                                                   
                                                                }
                                                                
                                                                
               }

               //AS Fee
                for(Account_Plan_AS_Fee__c item : [SELECT Id,Account_Plan_Wallet__c,AS_Fee__c,AS_Product_Service__c,Fixed_AS_Fee__c,
                            Net_Asset_Value__c,Type_of_Fee__c,Wallet_AS_Fee__c,SEQ__C
                          FROM Account_Plan_AS_Fee__c  
                          WHERE Account_Plan_Wallet__c = :wallet.id ORDER BY SEQ__C]){
                
                  //Sum value
                  if(item.Net_Asset_Value__c == null){
                      item.Net_Asset_Value__c = 0;
                  } 
                  if(item.AS_Fee__c == null){
                      item.AS_Fee__c =0;
                  }
                  if(item.Fixed_AS_Fee__c == null){
                      item.Fixed_AS_Fee__c =0;
                  }


                  SumOfNetAssetValue += item.Net_Asset_Value__c;
                  SumOfASFee += item.AS_Fee__c;    
                  SumOfFixedASFee += item.Fixed_AS_Fee__c; 
                  if(item.Wallet_AS_Fee__c != null){
                      SumOfWalletASFee += item.Wallet_AS_Fee__c;  
                  }

                  if(item.AS_Product_Service__c!=null && item.AS_Product_Service__c!=''){
                      if(item.AS_Product_Service__c.contains('1)')){
                          item.SEQ__C = '1';
                          if(item.Wallet_AS_Fee__c != null){
                          WalletASFee_Custodian += item.Wallet_AS_Fee__c;  
                          }
                          
                      }else if(item.AS_Product_Service__c.contains('2)')){
                          item.SEQ__C = '2';
                          if(item.Wallet_AS_Fee__c != null){
                              WalletASFee_FundSupervisory += item.Wallet_AS_Fee__c; 
                              } 
                          
                      }else if(item.AS_Product_Service__c.contains('3)')){
                          item.SEQ__C = '3';
                          if(item.Wallet_AS_Fee__c != null){
                              WalletASFee_MiddleOffice += item.Wallet_AS_Fee__c;  
                          }
                          
                      }else if(item.AS_Product_Service__c.contains('4)')){
                          item.SEQ__C = '4';
                          if(item.Wallet_AS_Fee__c != null){
                              WalletASFee_AgencyService += item.Wallet_AS_Fee__c;  
                          }
                           
                      }else if(item.AS_Product_Service__c.contains('5)')){
                          item.SEQ__C = '5';
                          if(item.Wallet_AS_Fee__c != null){
                              WalletASFee_RegistrarPaymentAgent += item.Wallet_AS_Fee__c;  
                          }
                        
                      }    
                  }
              }
                  
                wallet.SumOfWalletASFee__c = SumOfWalletASFee;
                wallet.WalletASFee_AgencyService__c =WalletASFee_AgencyService;
                 wallet.WalletASFee_Custodian__c = WalletASFee_Custodian;
                 wallet.WalletASFee_FundSupervisory__c = WalletASFee_FundSupervisory;
                 wallet.WalletASFee_MiddleOffice__c =WalletASFee_MiddleOffice;
                 wallet.WalletASFee_RegistrarPaymentAgent__c = WalletASFee_RegistrarPaymentAgent; 
                
               
            update wallet;      
            companyprofile.Status__c = 'In progress';
            update companyprofile;    
                 PageReference pr = Page.AccountPlanWalletDomainIViewV2;
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
           //   return null;  
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
         PageReference pr = Page.AccountPlanWalletDomainIViewV2;
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
         PageReference pr = Page.AccountPlanWalletDomainIEditV2;
            
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
         PageReference pr = Page.AccountPlanWalletDomainIViewV2;
        try{
              System.debug('tempEstimatedSalesAmtPerYear :'+tempEstimatedSalesAmtPerYear);
            System.debug('tempTotalDomesticPercent :'+tempTotalDomesticPercent);     
            System.debug('tempCOGSPercent :'+tempCOGSPercent);     
            System.debug('tempOperatingExpAmount :'+tempOperatingExpAmount);     
            System.debug('tempTotalPaymentDomesticPercent :'+tempTotalPaymentDomesticPercent);     
            
                    if(tempEstimatedSalesAmtPerYear ==null || Integer.valueOf(tempEstimatedSalesAmtPerYear)<=0){
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Estimated Sales (Year of account plan ) is required')); 
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3008').Status_Message__c));
                        return null; 
                        
                    }else if(tempTotalDomesticPercent==null || tempTotalDomesticPercent >100 || tempTotalDomesticPercent<0  ){
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Sales Domestic (%) must not be null or  more than 100% ')); 
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3009').Status_Message__c));
                          return null;
                    }
            else if(tempCOGSPercent  >100  || tempCOGSPercent==null ||  tempCOGSPercent<0 ){
                         //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'% COGS (From estimated sales) must not be null or  more than 100%'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3010').Status_Message__c));
        
                        return null;
            }else if(tempOperatingExpAmount ==null){
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Operating Expense (Amount: THB) is required'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3011').Status_Message__c));
        
                        return null;
            }else if(tempOperatingExpAmount <0){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3011').Status_Message__c));
        
                        return null;

            } else if(tempTotalPaymentDomesticPercent  >100 || tempTotalPaymentDomesticPercent==null || tempTotalPaymentDomesticPercent<0 ){
                         //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Payment Domestic (%) must not be null or  more than 100%'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('3012').Status_Message__c));
        
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