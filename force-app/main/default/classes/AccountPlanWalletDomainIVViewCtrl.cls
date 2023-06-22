public class AccountPlanWalletDomainIVViewCtrl {
    public String CompanyID {get;set;}
    public String GroupID {get;set;}
    public String WalletID {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;} 
    public boolean isHasPermission {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isSystemAdmin {get;set;}
    public Decimal SumOfHedgedAmount {get;set;}
    public Decimal SumWalletFX {get;set;}
    public Double SumFxMargin {get;set;}
        public Double SumDeAmount {get;set;}
        public Double SumDeHedging {get;set;}
        public Double SumDeFee {get;set;}
    public AcctPlanWallet__c wallet {get;set;}
    public List<AcctPlanQuestionnaire__c > QuestionnaireList {get;set;} 
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public Map<String,List<AcctPlanQuestionnaire__c>> QuestionnaireMap {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> CollectionList {get;set;}
    public List<AcctPlanCollectionOrPaymentCurrency__c> PaymentList {get;set;}
    public List<AcctPlanForeignTrans__c> ForeignTransList {get;set;}
    public List<AcctPlanOtherRevenueExpenditure__c> ExdenditureList {get;set;} 
    public List<AcctPlan_Questionnaire_Template__c> QTemplateList {get;set;}
    public Map<String,List< AcctPlan_Questionnaire_Template__c> > QTemplateMap {get;set;}
    public List<AcctPlanExistingLongTermLoan__c> APExisitngLongTermLoan {get;set;}
    public List<AcctPlanCapitalExpenditurePlan__c> APCapitalExpenditurePlan {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public Boolean isMiniView {get;set;}
    public AccountPlanWalletDomainIVViewCtrl(){
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
          if(CompanyID !=null && CompanyID != ''){
               companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);
              ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
                isHasPermission = AccountPlanUtilities.ISHASPERMISSION;
                isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
                isSystemAdmin = AccountPlanUtilities.isSystemAdmin;
               if(AccountPlanUtilities.OWNERSEGMENT != null){
                    isMiniView = AccountPlanUtilities.ISMINIVIEW;
                }else{
                    isMiniView = false;
                }
               List <AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyprofile.id);
              if(WalletID ==null || WalletID == ''){
                  WalletID = companyprofile.AccountPlanWalletID__c;
              }
         if(walletList.size() > 0){
             
             wallet = walletList.get(0);
             QuestionnaireList = AccountPlanUtilities.QueryQuestionnaireByWalletID(wallet.id);
             QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
             String strurl = ApexPages.currentPage().getUrl();
             strurl = strurl.split('apex/')[1]; 
             loadCurrency();
             
             loadforeign();
             loadquestionnaire();
             
             ExisitngLongTermLoan();
             CapitalExpenditurePlan();
             
              if(strurl.containsIgnoreCase('View')){
                  List<Account_Plan_Completion__c> CompleteList= [SELECT
                     Account_Plan_Company_Profile__c,
                     Step_3_Percentage__c,
                      Account_Plan_Completion_Percentage__c                                             
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                     if(CompleteList.size()>0){
                         Acctplancompletion = CompleteList.get(0);
                     }
              }
             
            
         }
              
              
          }
              
     }
    
    public void FICustomerFlagAction(){
      System.debug('Wallet FI Customer : '+wallet.FI_Customer_FX__c);

      if(!Wallet.FI_Customer_FX__c){
        wallet.FX_Volume_per_Year_THB__c = null;
        wallet.Spread__c =null;
      }
    }

    public PageReference updateSumOfWalletFXFeePerYear(){

         // Ktc Add To Support Step 4
          if(SumWalletFX == null){
                SumWalletFX = 0;
            }
            try{
                AcctPlanWallet__c wall = new AcctPlanWallet__c(Id = wallet.id,
                                                                SumOfWalletFXFeePerYear__c = SumWalletFX,
                                                                SumOfAcctPlanForeignWalletFXFeePerYear__c 
                                                                = SumWalletFX + wallet.Wallet_FX_Fee_Yearly_THB__c);
        
                update wall;
                return null;
            }catch(Exception E){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,e.getMessage())); 
                System.debug(e.getMessage());
                return null;
            }
    }
    
    public void loadCurrency(){
        //Query Currency ShortName
        //
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
    
    
     public void loadforeign(){
        
       ForeignTransList = [SELECT ID,AmtPerYear__c ,CCY__c, CCY__r.Name,CCY__r.ShortName__c,
                                 FXMarginStg__c,HedgingPolicy__c ,HedgingRatio__c, PropsectHedgedAmount__c,
                                 WalletFXFeePerYear__c, exchangerateofTHB__c
                                FROM AcctPlanForeignTrans__c 
                                WHERE AcctPlanWallet__c =: wallet.id
                                ORDER BY CCY__r.NAME ASC];
         
         SumOfHedgedAmount = 0;
        SumWalletFX = 0;
        SumFxMargin = 0.00;
        Double SumFXmarginvalue = 0.00;
        for(AcctPlanForeignTrans__c ft : ForeignTransList){
            SumOfHedgedAmount+= ft.PropsectHedgedAmount__c;
            SumWalletFX += ft.WalletFXFeePerYear__c;
            //SumFxMargin += ft.FXMarginStg__c;
            Double FXmarginvalue = ft.PropsectHedgedAmount__c *  ft.FXMarginStg__c;

            SumFXmarginvalue +=FXmarginvalue;
           
        }
      
         if(ForeignTransList.size()>0){
                       
             if(SumOfHedgedAmount !=0 && SumOfHedgedAmount !=null){
                  SumFxMargin = SumFXmarginvalue/SumOfHedgedAmount;
             }else{
                 SumFxMargin = SumFXmarginvalue/1;
             }
         }

      
    }


    
     public void loadquestionnaire(){
        
      QuestionnaireList = AccountPlanUtilities.QueryQuestionnaireByWalletID(wallet.id);
      QuestionnaireMap = new Map<String,List<AcctPlanQuestionnaire__c>>();
      QTemplateList = AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain IV');
      QTemplateMap = new Map<String,List< AcctPlan_Questionnaire_Template__c> >();
         
         Set<String> QSegmentList = new Set<String>();         
                 for(AcctPlan_Questionnaire_Template__c QT : QTemplateList){
                     String Segment =  qt.Segment__c;
                     
                     if(QTemplateMap.containsKey(Segment)){
                         QTemplateMap.get(Segment).add(qt);
                     }else{
                        QSegmentList.add(Segment); 
                        List< AcctPlan_Questionnaire_Template__c>  QTList = new List< AcctPlan_Questionnaire_Template__c>();
                         QTList.add(qt);
                         QTemplateMap.put(Segment,QTList);
                     }
                     
                 }
         
         
                         System.debug('QuestionnaireList : '+QuestionnaireList);
         
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
             System.debug('segment : '+segment);
                 if(!QuestionnaireMap.containsKey(segment)){
                          List<AcctPlanQuestionnaire__c> qList = new List<AcctPlanQuestionnaire__c>();
                          
                          for(integer i =0;i<QTemplateMap.get(segment).size();i++){
                              
                              AcctPlanQuestionnaire__c question = new AcctPlanQuestionnaire__c ();
                              question.Question__c = QTemplateMap.get(segment).get(i).Question__c;
                              question.Segment__c = segment;
                               question.Product_Label__c = QTemplateMap.get(segment).get(i).Product_Label__c;
                             question.Sub_Domain__c = QTemplateMap.get(segment).get(i).Sub_Domain__c;
                              question.Question_TH__c = QTemplateMap.get(segment).get(i).Question_TH__C;
                              question.Opportunity__c = QTemplateMap.get(segment).get(i).Opportunity__c;
                              /*if(QTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c  !=null){
                                  question.SEQ__c = QTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c ;
                              }else{
                                  question.SEQ__c = QTemplateMap.get(segment).get(i).SEQ__c;
                              }*/
                              question.Sub_Segment_SEQ__c = QTemplateMap.get(segment).get(i).Sub_Segment_SEQ__c;
                              question.Answer_Type__c  = QTemplateMap.get(segment).get(i).Answer_Field_Type__c;
                              question.SEQ__c  = QTemplateMap.get(segment).get(i).SEQ__C;
                              
                              question.AcctPlanWallet__c = wallet.id;
                              qList.add(question);
                          }
                     
                          QuestionnaireMap.put(segment, qList);
                 }
             }
         
         System.debug('QuestionnaireMap : '+QuestionnaireMap);

        ExdenditureList =  [SELECT Id,
                          AcctPlanWallet__c  ,
                          Currency__c    ,
                          currency__r.Name   ,
                          ExpectedAmountOrHistoricalAmount__c    ,
                          HedgingPolicy__c   ,
                          MismatchCurrency__c  ,
                          Opportunity__c  ,
                          RevenueOrExpenditure__c   ,
                          Timeline__c   
                      FROM AcctPlanOtherRevenueExpenditure__c     
                      WHERE AcctPlanWallet__c   = :wallet.id
                      ];
             
    }
    
    public pagereference save(){
        try{
            boolean isvaliate = true;
             Set<AcctPlanQuestionnaire__c> QuestionsSet = new Set<AcctPlanQuestionnaire__c>();
            Boolean internetbanking = true;
             for(String segment : QuestionnaireMap.keySet()){
               
                for(AcctPlanQuestionnaire__c acctquestion : QuestionnaireMap.get(segment)){
                    if(acctquestion.Segment__c == 'Credit life insurance' && acctquestion.Answer__c != 'Yes'){
                        wallet.AmtOfCreditFaciWithTMB__c = null;
                        wallet.ProtectionPercent__c = null;
                        wallet.BA_Premium__c = null;
                    }
                    if(acctquestion.Segment__c=='Internet Banking' && acctquestion.SEQ__c == 1 && acctquestion.Answer__c != 'Yes'){
                        internetbanking = false;
                    }
                    if(acctquestion.Segment__c == 'Internet Banking' && acctquestion.SEQ__c != 1 && !internetbanking){
                        acctquestion.Answer__c = null;
                    }
                     QuestionsSet.add(acctquestion);                
                }
            }


            if(wallet.Spread__c >100){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Spread (%) must not be more than 100%.'));
                isvaliate = false;

            }
            
            List <AcctPlanQuestionnaire__c> AllQuestionsupsertList = new List<AcctPlanQuestionnaire__c>();
                     
            AllQuestionsupsertList.addAll(QuestionsSet);
            
            
            if(isvaliate){



            upsert AllQuestionsupsertList;
            
            update wallet;      


             AcctPlanWallet__c afterwallet = [SELECT ID,SumOfWalletFXFeePerYear__c,
                                                                SumOfAcctPlanForeignWalletFXFeePerYear__c,
                                                                Wallet_FX_Fee_Yearly_THB__c
                                                                FROM AcctPlanWallet__c
                                                                WHERE ID =: wallet.id LIMIT 1];
                                                                loadforeign();
            afterwallet.SumOfAcctPlanForeignWalletFXFeePerYear__c =   SumWalletFX +afterwallet.Wallet_FX_Fee_Yearly_THB__c ;                                    
        
              update afterwallet;
                  

            if(APExisitngLongTermLoan.size() >0){
                upsert APExisitngLongTermLoan;    
            }
            if(APCapitalExpenditurePlan.size() > 0){
                upsert APCapitalExpenditurePlan;
            }
                companyprofile.Status__c = 'In Progress';
                update companyprofile;
            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(wallet.AcctPlanCompanyProfile__c); 
                
                
            PageReference pr = Page.AccountPlanWalletDomainIVView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            pr.getParameters().put('GroupID',GroupId);
            pr.getParameters().put('WalletID',WalletId);
            if(mode !=null && mode !=''){
                pr.getParameters().put('mode',mode);
            }
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
         PageReference pr = Page.AccountPlanWalletDomainIVView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            pr.getParameters().put('GroupID',GroupId);
            pr.getParameters().put('WalletID',WalletId);
          if(mode !=null && mode !=''){
                pr.getParameters().put('mode',mode);
            }
            return pr;
        
    }
    
     public pageReference EditPage(){       
        PageReference redirectPage = Page.AccountPlanWalletDomainIVEdit;
        redirectPage.getParameters().put('GroupID',GroupID);
        redirectPage.getParameters().put('CompanyID',CompanyID);
        redirectPage.getParameters().put('WalletID',WalletID);
        if(mode !=null && mode !=''){
            redirectPage.getParameters().put('mode',mode);
        }
        redirectPage.setRedirect(true);
        return redirectPage; 
    }
    
    public void ExisitngLongTermLoan(){      
        Boolean isHasExisitngLongTermLoan = true;
        
        APExisitngLongTermLoan = [SELECT Id,Bank__c,Bank__r.Name, CCY__c,CCY__r.Name, Collateral__c, EquivalentAmount__c, 
                                  InterestFixedRate__c,InterestFloatingRate__c , InterestType__c, LTVPercent__c, NimcPercent__c, RemainingTenorsYear__c,
                                  Remark__c, TypeOfLoan__c,WalletNiicYearly__c,CCYAmtFullyHedge__c ,InterestFullyHedge__c , 
                                  HedgingTenor__c, Opportunity__c 
                                  FROM AcctPlanExistingLongTermLoan__c 
                                  WHERE AcctPlanWallet__c = :wallet.id];
        if(APExisitngLongTermLoan.size() <= 0){
            isHasExisitngLongTermLoan = false;
        }       
        if(!isHasExisitngLongTermLoan){
            APExisitngLongTermLoan = new List<AcctPlanExistingLongTermLoan__c>();      
        }
    }
    public void CapitalExpenditurePlan(){
        Boolean isHasCapitalExpenditurePlan = true;
        
        APCapitalExpenditurePlan = [SELECT Id,Purpose__c,ProjectAmount__c,InvestmentLocation__c,FinancingRation__c,
                                    TenorYearly__c,NimcPercent__c,WalletNiicYearly__c,FrontEndFee__c,CreditFee__c,
                                    OppForForeignCCY__c, MisMatchCCY__c, NeedToHedgeInterest__c , Opportunity__c 
                                    FROM AcctPlanCapitalExpenditurePlan__c  
                                    WHERE AcctPlanWallet__c = :wallet.Id];
        if(APCapitalExpenditurePlan.size() <= 0){
            isHasCapitalExpenditurePlan = false;
        }
        
        if(!isHasCapitalExpenditurePlan){
            APCapitalExpenditurePlan = new List<AcctPlanCapitalExpenditurePlan__c>();
        }
    }
}