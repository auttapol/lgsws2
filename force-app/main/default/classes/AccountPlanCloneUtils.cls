public class AccountPlanCloneUtils {
    public static String WalletID {get;set;}
    
    public static String CloneCompanyID {get;set;} 
    public static String CloneWalletID {get;set;}
    public static String CloneWalletDomainID {get;set;}
    public static String CloneActionPlanID {get;set;}
    public static String CloneNIProjectID {get;set;} 
    public static String CloneActivityID {get;set;}
    public static AcctPlanWallet__c WalletClone {get;set;}
    
    public static List<sObject> getObject(string objName, string criteria,string id) {
        
        String fieldnames = '';
        List<sObject> obj = new List<sObject>();
        
        try {
            Map < String, Schema.SObjectType > m = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            //get fields
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            for (string field: fields.keySet()) {
                if (fieldnames == '') {
                    fieldnames = field;
                } else {
                    fieldnames += ',' + field;
                }
            }
            
            //create SQL
            String sql = 'SELECT ' + fieldnames + ' FROM ' + objName + ' WHERE '+criteria+'=\'' + id + '\'';
            //System.debug(sql);
            if(null != database.query(sql)){
            	obj = database.query(sql);
            }
            System.debug(objName+' : '+obj.size());
            
        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return obj;
    }
    
    public static List<sObject> getObject(string objName, string criteria,Set<id> IDs) {
        
        String fieldnames = '';
        List<sObject> obj;
        
        try {
            Map < String, Schema.SObjectType > m = Schema.getGlobalDescribe();
            Schema.SObjectType s = m.get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            
            //get fields
            Map < String, Schema.SObjectField > fields = r.fields.getMap();
            for (string field: fields.keySet()) {
                if (fieldnames == '') {
                    fieldnames = field;
                } else {
                    fieldnames += ',' + field;
                }
            }
            
            //create SQL
            System.debug(IDs);
            String sql = 'SELECT ' + fieldnames + ' FROM ' + objName + ' WHERE '+criteria+' IN : IDs';
            System.debug(sql);
            obj = database.query(sql);
            
        } catch (Exception e) {
            System.debug('get Fields Error' + e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        return obj;
    }
    
    public static void AccountPlanClone(String CompanyID,String Year){
        //Savepoint sp = Database.setSavepoint();
        //try {
            /*====== Account Plan Company Profile : step 2 =======*/
            String AccountID;
            String GroupID;
            String GroupProfileID;
            String GroupPortID;
            String CompanyPortID;
            String PortfolioID;
            Boolean isShortFrom;
            
            List<AcctPlanCompanyProfile__c> CompanyProfileList =[SELECT ID,
                                                                 Account__c,
                                                                 AccountPlanWalletID__c,
                                                                 Year__c,
                                                                 AcctPlanGroup__r.Group__c,
                                                                 isMiniMode__c 
                                                                 FROM AcctPlanCompanyProfile__c 
                                                                 WHERE ID = :CompanyID];
            if(CompanyProfileList.size()>0){
                AcctPlanCompanyProfile__c CompanyProfile = CompanyProfileList.get(0);
                Account  acct = [SELECT ID,Name,Group__r.Name,Group__c,
                                 Owner.Segment__c, Account_Plan_Form__c,
                                 NIIc_Wallet__c,NIId_Wallet__c,Fee_Wallet__c,
                                 //Group__r.GroupIndustry__c, //mm
                                 //Group__r.ParentIndustry__c, //mm
                                 Group__r.UltimateParent__c,
                                 Group__r.Parent_Company__c,
                                 Group__r.Group_Industry_Info__c,
                                 Group__r.Parent_Industry__c
                                 FROM Account
                                 WHERE ID = :CompanyProfile.Account__c];
                //AccountID
                AccountID = acct.ID;
                //GroupID
                GroupID = acct.Group__c;
                //GroupProfileID
                if(GroupID != null){
                    /*if(GroupID == CompanyProfile.AcctPlanGroup__r.Group__c){
                        GroupProfileID = CompanyProfile.AcctPlanGroup__c;
                    }else{*/
                        List<AcctPlanGroupProfile__c> GroupProfileList = [SELECT ID,Group__c,Year__c,GroupName__c  
                                                                          FROM AcctPlanGroupProfile__c
                                                                          WHERE Group__c = :GroupID
                                                                          AND Year__c = :Year];
                        AcctPlanGroupProfile__c GroupProfile = new AcctPlanGroupProfile__c();
                        if(GroupProfileList.size() > 0){
                            GroupProfile = GroupProfileList.get(0);
                        }else{
                                    
                                    if(null == CompanyProfile.AcctPlanGroup__c ){

                                         groupprofile.Group__c = Acct.Group__c;
                                                        groupprofile.Group_Industry_Info__c =  Acct.Group__r.Group_Industry_Info__c;
                                                        groupprofile.GroupName__c =  Acct.Group__r.Name;
                                                        groupprofile.Year__c = Year; 
                                                        groupprofile.Name = Acct.Group__r.Name;
                                                        groupprofile.OwnerId = Userinfo.getUserId();
                                                        // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                                        groupprofile.Parent_Industry_Info__c = Acct.Group__r.Parent_Industry__c; //mm
                                                        groupprofile.UltimateParent__c = Acct.Group__r.UltimateParent__c;
                                                        groupprofile.Parent_Company__c = Acct.Group__r.Parent_Company__c; 

                                                        insert GroupProfile;
                                    
                                        }else{
                                        /*====== Account Plan Group Profile : step 1 ======*/
                                        List<AcctPlanGroupProfile__c> GroupProfileClone= new List<AcctPlanGroupProfile__c>();
                                            
                                        List<AcctPlanGroupProfile__c> GroupProfileOriginal = (List<AcctPlanGroupProfile__c>) AccountPlanCloneUtils.getObject('AcctPlanGroupProfile__c','ID',CompanyProfile.AcctPlanGroup__c);
                                        if(GroupProfileOriginal.size() > 0){
                                               AcctPlanGroupProfile__c GroupProfileCheck = GroupProfileOriginal.get(0);
                                                if(GroupProfileCheck.Group__c == GroupID){
                                                        for(AcctPlanGroupProfile__c itemOriginal : GroupProfileOriginal){
                                                            AcctPlanGroupProfile__c itemClone= itemOriginal.clone();
                                                            itemClone.Year__c = Year; 
                                                            itemClone.OwnerId = Userinfo.getUserId();
                                                            GroupProfileClone.add(itemClone);
                                                        }
                                                        insert GroupProfileClone;
                                                }else{
                                                        groupprofile.Group__c = Acct.Group__c;
                                                        groupprofile.Group_Industry_Info__c =  Acct.Group__r.Group_Industry_Info__c;
                                                        groupprofile.GroupName__c =  Acct.Group__r.Name;
                                                        groupprofile.Year__c = Year; 
                                                        groupprofile.Name = Acct.Group__r.Name;
                                                        groupprofile.OwnerId = Userinfo.getUserId();
                                                        // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                                        groupprofile.Parent_Industry_Info__c = Acct.Group__r.Parent_Industry__c; //mm
                                                        groupprofile.UltimateParent__c = Acct.Group__r.UltimateParent__c;
                                                        groupprofile.Parent_Company__c = Acct.Group__r.Parent_Company__c; 

                                                        insert GroupProfile;
                                                }
                                            
                                        }

                                        if(GroupProfileClone.size()>0){
                                            GroupProfile = GroupProfileClone.get(0);
                                        }
                                    }

                                
                        } 
                        GroupProfileID = GroupProfile.Id;
                        /*====== Account Plan Contribution : step 1 Group Profile & step 2 Company Profile  ======*/
                        List<AcctPlanCompanyProfile__c> CompanyProfileOriginal = (List<AcctPlanCompanyProfile__c>) AccountPlanCloneUtils.getObject('AcctPlanCompanyProfile__c','Id',CompanyID);
                        String GroupProfileIDOriginal = CompanyProfileOriginal.get(0).AcctPlanGroup__c;
                    if(GroupProfileIDOriginal != null && GroupProfileIDOriginal != ''){
                        List<AcctPlanContribution__c> ContributionOriginal = (List<AcctPlanContribution__c>) AccountPlanCloneUtils.getObject('AcctPlanContribution__c','AccountPlanGroupProfile__c',GroupProfileIDOriginal);
                        if(ContributionOriginal.size() > 0){
                            List<AcctPlanContribution__c> ContributionClone= new List<AcctPlanContribution__c>();
                            for(AcctPlanContribution__c itemOriginal : ContributionOriginal){
                                AcctPlanContribution__c itemClone= itemOriginal.clone();
                                itemClone.Account_Plan_Company_Profile__c = null;
                                //Assign Group profile
                                itemClone.AccountPlanGroupProfile__c = GroupProfileID;
                                itemClone.OwnerId = Userinfo.getUserId();
                                ContributionClone.add(itemClone);
                            }
                            insert ContributionClone; 
                        }
                    }
                    
                    //}
                }else{
                    GroupProfileID = null;
                }
                
                //PortfolioID
                List<AcctPlanPortfolio__c> PortfolioList = [SELECT ID,OwnerID,Year__C
                                                            From AcctPlanPortfolio__c
                                                            WHERE Year__c = :Year
                                                            AND SalesOwner__c =:Userinfo.getUserId()];
                if(PortfolioList.size()>0){
                    AcctPlanPortfolio__c Portfolio = PortfolioList.get(0);
                    PortfolioID = Portfolio.id;
                }else{
                    PortfolioID = null;
                }
                
                
                
                
                
                /*======= Start Clone Function =======*/
                List<AcctPlanCompanyProfile__c> CompanyProfileOriginal = (List<AcctPlanCompanyProfile__c>) AccountPlanCloneUtils.getObject('AcctPlanCompanyProfile__c','Id',CompanyID);
                if(CompanyProfileOriginal.size() > 0){
                    
                    AcctPlanCompanyProfile__c CompanyProfileClone = CompanyProfileOriginal.get(0).clone();
                    //Assign Group Profile
                    CompanyProfileClone.AcctPlanGroup__c = GroupProfileID;
                    //Assign Portfolio
                    CompanyProfileClone.Portfolio__c = PortfolioID;
                    //CompanyProfileClone.isActive__c = true;
                    CompanyProfileClone.Year__c = Year;
                    CompanyProfileClone.CloneSourceId__c = CompanyProfileOriginal.get(0).id;
                    CompanyProfileClone.isHasProdStrategy__c = false;
                    CompanyProfileClone.isHasActionPlan__c = false;
                    CompanyProfileClone.isPendingForApproval__c = false;
                    CompanyProfileClone.isAvailableforApproval__c = false;
                    CompanyProfileClone.Status__c = 'In Progress';
                    CompanyProfileClone.OwnerId = Userinfo.getUserId();
                    Boolean isMiniMode = AcctPlanMode__c.GetValues(Acct.Owner.Segment__c).isMiniMode__c;
                    system.debug('comport.Account__r.Account_Plan_Form__c='+Acct.Account_Plan_Form__c);
                    Boolean isReferToCSV = AcctPlanMode__c.GetValues(Acct.Owner.Segment__c).ReferToCSV__c;
                     if(Acct.Owner.Segment__c !=null){
                        if(isMiniMode){
                            CompanyProfileClone.isMiniMode__c = true;
                            isShortFrom = true;
                            CompanyProfileClone.AccountPlanWalletID__c = null;
                        }else if(isReferToCSV){
                                if(Acct.Account_Plan_Form__c == 'Short Form'){
                                    CompanyProfileClone.isMiniMode__c = true;
                                    isShortFrom = true;
                                    CompanyProfileClone.AccountPlanWalletID__c = null;
                                }else {
                                    CompanyProfileClone.isMiniMode__c = false;
                                    CompanyProfileClone.AccountPlanWalletID__c = null;
                                    isShortFrom = false;
                                } 
                        }else{
                            CompanyProfileClone.isMiniMode__c = false;
                            CompanyProfileClone.AccountPlanWalletID__c = null;
                            isShortFrom = false;
                        }
                    }else{
                            CompanyProfileClone.isMiniMode__c = false;
                            CompanyProfileClone.AccountPlanWalletID__c = null;
                            isShortFrom = false;
                    }
                    system.debug('CompanyProfileClone.isMiniMode__c='+CompanyProfileClone.isMiniMode__c);
                    
                    
                    insert CompanyProfileClone;
                    CloneCompanyID = CompanyProfileClone.Id;
                    
                    
                        /*====== Account Plan Contribution : step 2 Company Profile  ======*/
                        List<AcctPlanContribution__c> ContributionOriginal = (List<AcctPlanContribution__c>) AccountPlanCloneUtils.getObject('AcctPlanContribution__c','Account_Plan_Company_Profile__c',CompanyID);
                        if(ContributionOriginal.size() > 0){
                            List<AcctPlanContribution__c> ContributionClone= new List<AcctPlanContribution__c>();
                            for(AcctPlanContribution__c itemOriginal : ContributionOriginal){
                                AcctPlanContribution__c itemClone= itemOriginal.clone();
                                itemClone.Account_Plan_Company_Profile__c = CloneCompanyID;
                                //Assign Group profile
                                itemClone.AccountPlanGroupProfile__c = GroupProfileID;
                                itemClone.OwnerId = Userinfo.getUserId();
                                ContributionClone.add(itemClone);
                            }
                            insert ContributionClone;
                        }
                    
                    
                    /*====== Account Plan Supplier Or Buyer : step 2 =======*/
                    List<AcctPlanSupplierOrBuyer__c> SupplierOrBuyerOriginal = (List<AcctPlanSupplierOrBuyer__c>) AccountPlanCloneUtils.getObject('AcctPlanSupplierOrBuyer__c','Account_Plan_Company_Profile__c',CompanyID);
                    if(SupplierOrBuyerOriginal.size() > 0){
                        List<AcctPlanSupplierOrBuyer__c> SupplierOrBuyerClone = new List<AcctPlanSupplierOrBuyer__c>();
                        for(AcctPlanSupplierOrBuyer__c itemOriginal : SupplierOrBuyerOriginal){
                            AcctPlanSupplierOrBuyer__c itemClone= itemOriginal.clone();
                            itemClone.Account_Plan_Company_Profile__c = CloneCompanyID;
                            //itemClone.OwnerId = Userinfo.getUserId();
                            SupplierOrBuyerClone.add(itemClone);
                        }
                        insert SupplierOrBuyerClone;
                    }
                    
                    /*====== Account Plan Company Top 5 : step 2 =======*/
                    List<Account_Plan_Company_Top_5__c> CompanyTop5Original = (List<Account_Plan_Company_Top_5__c>) AccountPlanCloneUtils.getObject('Account_Plan_Company_Top_5__c','Account_Plan_Company_Profile__c',CompanyID);
                    if(CompanyTop5Original.size() > 0){
                        List<Account_Plan_Company_Top_5__c> CompanyTop5Clone = new List<Account_Plan_Company_Top_5__c>();
                        for(Account_Plan_Company_Top_5__c itemOriginal : CompanyTop5Original){
                            Account_Plan_Company_Top_5__c itemClone= itemOriginal.clone();
                            itemClone.Account_Plan_Company_Profile__c = CloneCompanyID;
                            //itemClone.OwnerId = Userinfo.getUserId();
                            CompanyTop5Clone.add(itemClone);
                        }
                        insert CompanyTop5Clone;
                    }
                    
                    

                    /*====== Account Plan Company Port ======*/
                    /*List<AcctPlanCompanyPort__c> CompanyPortOriginal = (List<AcctPlanCompanyPort__c>) AccountPlanCloneUtils.getObject('AcctPlanCompanyPort__c','Account_Plan_Company_Profile__c',CompanyID);
                    if(CompanyPortOriginal.size() > 0){
                        AcctPlanCompanyPort__c CompanyPortClone= CompanyPortOriginal.get(0).clone();
                        CompanyPortClone.Account_Plan_Company_Profile__c = CloneCompanyID;
                        //Assign Portfolio
                        CompanyPortClone.Account_Plan_Portfolio__c = PortfolioID;
                        //Assign Group Port
                        CompanyPortClone.AcctPlanGroupPort__c = GroupPortID;
                        insert CompanyPortClone;
                    } */
                    
                    
                    List<AcctPlanWallet__c> WalletOriginal = (List<AcctPlanWallet__c>) AccountPlanCloneUtils.getObject('AcctPlanWallet__c','AcctPlanCompanyProfile__c',CompanyID);
                    
                    if(WalletOriginal.size() >0){
                        /*====== Account Plan Wallet : step 3 ======*/
                        WalletClone = new AcctPlanWallet__c();
                        if(isShortFrom){
                            WalletClone.SumOfWalletNiicYearly__c = Acct.NIIc_Wallet__c;
                            WalletClone.TotalWalletNIID_Mini__c = Acct.NIId_Wallet__c;
                            WalletClone.Total_Fee_Mini__c = Acct.Fee_Wallet__c;  
                            WalletClone.AcctPlanCompanyProfile__c = CloneCompanyID;
                            WalletClone.OwnerId = Userinfo.getUserId();

                            insert WalletClone;  
                            CloneWalletID = WalletClone.Id;
                            CompanyProfileClone.AccountPlanWalletID__c = CloneWalletID;
                            CompanyProfileClone.isHasProdStrategy__c = true;
                            update CompanyProfileClone;                                  
                        }else{
                            if(CompanyProfileOriginal.get(0).isMiniMode__c == false){
                                WalletClone = WalletOriginal.get(0).clone();

                                WalletID = WalletOriginal.get(0).Id;
                                AcctPlanWallet__c walletOriginalObj = WalletOriginal.get(0);
                                WalletClone.AcctPlanCompanyProfile__c = CloneCompanyID;
                                 if(walletOriginalObj.NimdPercent_CashOnHand__c != null && (walletOriginalObj.CashOnHand_Nimd__c==null && walletOriginalObj.InvestmentAmount_NIMd__c == null)){
                                    WalletClone.CashOnHand_Nimd__c = walletOriginalObj.NimdPercent_CashOnHand__c;
                                    WalletClone.InvestmentAmount_NIMd__c = walletOriginalObj.NimdPercent_CashOnHand__c;
                                }
                                walletOriginalObj.NimdPercent_CashOnHand__c = null;
                                WalletClone.OwnerId = Userinfo.getUserId();
                                insert WalletClone;
                                CloneWalletID = WalletClone.Id;
                                CompanyProfileClone.AccountPlanWalletID__c = CloneWalletID;
                                update CompanyProfileClone;

                                /*====== Account Plan Questionnaire  : step 3 =====*/
                                List<AcctPlanQuestionnaire__c> QuestionnaireOriginal = (List<AcctPlanQuestionnaire__c>) AccountPlanCloneUtils.getObject('AcctPlanQuestionnaire__c','AcctPlanWallet__c',WalletID);
                                if(QuestionnaireOriginal.size() > 0){
                                    List<AcctPlanQuestionnaire__c> QuestionnaireClone = new List<AcctPlanQuestionnaire__c>();
                                    for(AcctPlanQuestionnaire__c itemOriginal : QuestionnaireOriginal){
                                        AcctPlanQuestionnaire__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        QuestionnaireClone.add(itemClone);
                                    }
                                    insert QuestionnaireClone;
                                }
                                
                                /*====== Account Plan Wallet Other Bank : step 3 Domain 1&2 ======*/
                                List<AcctPlanWalletOtherBank__c> WalletOtherBankOriginal = (List<AcctPlanWalletOtherBank__c>) AccountPlanCloneUtils.getObject('AcctPlanWalletOtherBank__c','AcctPlanWallet__c',WalletID);
                                if(WalletOtherBankOriginal.size() > 0 ){
                                    List<AcctPlanWalletOtherBank__c> WalletOtherBankClone = new List<AcctPlanWalletOtherBank__c>();
                                    for(AcctPlanWalletOtherBank__c itemOriginal : WalletOtherBankOriginal){
                                        AcctPlanWalletOtherBank__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        WalletOtherBankClone.add(itemClone);
                                    }
                                    insert WalletOtherBankClone;
                                }

                                /*====== Account Plan Collection Or Payment Currency : step 3 Domain 1&4 ======*/
                                List<AcctPlanCollectionOrPaymentCurrency__c> CollectionOrPaymentCurrencyOriginal = (List<AcctPlanCollectionOrPaymentCurrency__c>) AccountPlanCloneUtils.getObject('AcctPlanCollectionOrPaymentCurrency__c','AcctPlanWallet__c',WalletID);
                                if(CollectionOrPaymentCurrencyOriginal.size() > 0){
                                    List<AcctPlanCollectionOrPaymentCurrency__c> CollectionOrPaymentCurrencyClone = new List<AcctPlanCollectionOrPaymentCurrency__c>();
                                    for(AcctPlanCollectionOrPaymentCurrency__c itemOriginal : CollectionOrPaymentCurrencyOriginal){
                                        AcctPlanCollectionOrPaymentCurrency__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        CollectionOrPaymentCurrencyClone.add(itemClone);
                                    }
                                    insert CollectionOrPaymentCurrencyClone;
                                }

                                //New Object : Account Plan Flow Detail
                                /*====== Account Plan Payment Import : step 3 Domain 1 ======*/
                                List<Account_Plan_Flow_Details__c> FlowDetailOriginal = (List<Account_Plan_Flow_Details__c>) AccountPlanCloneUtils.getObject('Account_Plan_Flow_Details__c','Account_Plan_Wallet__c',WalletID);
                                if(FlowDetailOriginal.size() > 0){
                                    List<Account_Plan_Flow_Details__c> FlowDetailClone = new List<Account_Plan_Flow_Details__c>();
                                    for(Account_Plan_Flow_Details__c itemOriginal : FlowDetailOriginal){
                                        Account_Plan_Flow_Details__c itemClone = itemOriginal.clone();
                                        itemClone.Account_Plan_Wallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        FlowDetailClone.add(itemClone);
                                    }
                                    insert FlowDetailClone;
                                }else{
                                    //CloneStep3Domain1(WalletID);
                                    /*====== Account Plan Collection Domestic : step 3 Domain 1 ======*/
                                    List<AcctPlanCollectionDomestic__c> CollectionDomesticOriginal = (List<AcctPlanCollectionDomestic__c>) AccountPlanCloneUtils.getObject('AcctPlanCollectionDomestic__c','AcctPlanCollectionMethodDomestic__c',WalletID);
                                    if(CollectionDomesticOriginal.size() > 0){
                                        List<AcctPlanCollectionDomestic__c> CollectionDomesticClone = new List<AcctPlanCollectionDomestic__c>();
                                        for(AcctPlanCollectionDomestic__c itemOriginal : CollectionDomesticOriginal){
                                            AcctPlanCollectionDomestic__c itemClone = itemOriginal.clone();
                                            itemClone.AcctPlanCollectionMethodDomestic__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            CollectionDomesticClone.add(itemClone);
                                        }
                                        insert CollectionDomesticClone;   
                                    }
                                    
                                    /*====== Account Plan Collection Export : step 3 Domain 1 ======*/
                                    List<AcctPlanCollectionExport__c> CollectionExportOriginal = (List<AcctPlanCollectionExport__c>) AccountPlanCloneUtils.getObject('AcctPlanCollectionExport__c','AcctPlanCollectionMethodExport__c',WalletID);
                                    if(CollectionExportOriginal.size() > 0){
                                        List<AcctPlanCollectionExport__c> CollectionExportClone = new List<AcctPlanCollectionExport__c>();
                                        for(AcctPlanCollectionExport__c itemOriginal : CollectionExportOriginal){
                                            AcctPlanCollectionExport__c itemClone = itemOriginal.clone();
                                            itemClone.AcctPlanCollectionMethodExport__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            CollectionExportClone.add(itemClone);
                                        }
                                        insert CollectionExportClone; 
                                    }
                                    
                                    /*====== Account Plan Collection Export : step 3 Domain 1 ======*/
                                    List<AcctPlanPaymentDomestic__c> PaymentDomesticOriginal = (List<AcctPlanPaymentDomestic__c>) AccountPlanCloneUtils.getObject('AcctPlanPaymentDomestic__c','AcctPlanPaymentMethodDomestic__c',WalletID);
                                    if(PaymentDomesticOriginal.size() > 0){
                                        List<AcctPlanPaymentDomestic__c> PaymentDomesticClone = new List<AcctPlanPaymentDomestic__c>();
                                        for(AcctPlanPaymentDomestic__c itemOriginal : PaymentDomesticOriginal){
                                            AcctPlanPaymentDomestic__c itemClone = itemOriginal.clone();
                                            itemClone.AcctPlanPaymentMethodDomestic__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            PaymentDomesticClone.add(itemClone);
                                        }
                                        insert PaymentDomesticClone;
                                    }
                                    
                                    /*====== Account Plan Payment Import : step 3 Domain 1 ======*/
                                    List<AcctPlanPaymentImport__c> PaymentImportOriginal = (List<AcctPlanPaymentImport__c>) AccountPlanCloneUtils.getObject('AcctPlanPaymentImport__c','AcctPlanPaymentMethodImport__c',WalletID);
                                    if(PaymentImportOriginal.size() > 0){
                                        List<AcctPlanPaymentImport__c> PaymentImportClone = new List<AcctPlanPaymentImport__c>();
                                        for(AcctPlanPaymentImport__c itemOriginal : PaymentImportOriginal){
                                            AcctPlanPaymentImport__c itemClone = itemOriginal.clone();
                                            itemClone.AcctPlanPaymentMethodImport__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            PaymentImportClone.add(itemClone);
                                        }
                                        insert PaymentImportClone;
                                    }
                                }
                                    
                                    /*====== Account Plan Deposit Domestic : step 3 Domain 2 ======*/
                                    List<AcctPlanDepositDomestic__c> DepositDomesticOriginal = (List<AcctPlanDepositDomestic__c>) AccountPlanCloneUtils.getObject('AcctPlanDepositDomestic__c','AccountPlanDepositDomesticDeposit__c',WalletID);
                                    if(DepositDomesticOriginal.size() > 0){
                                        List<AcctPlanDepositDomestic__c> DepositDomesticClone = new List<AcctPlanDepositDomestic__c>();
                                        for(AcctPlanDepositDomestic__c itemOriginal : DepositDomesticOriginal){
                                            AcctPlanDepositDomestic__c itemClone = itemOriginal.clone();
                                            itemClone.AccountPlanDepositDomesticDeposit__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            DepositDomesticClone.add(itemClone);
                                        }
                                        insert DepositDomesticClone;
                                    }
                                    
                                    /*====== Account Plan Deposit International : step 3 Domain 2 ======*/
                                    List<AcctPlanDepositInternational__c> DepositInternationalOriginal = (List<AcctPlanDepositInternational__c>) AccountPlanCloneUtils.getObject('AcctPlanDepositInternational__c','AccountPlanDepositInternationalDeposit__c',WalletID);
                                    if(DepositInternationalOriginal.size() > 0){
                                        List<AcctPlanDepositInternational__c> DepositInternationalClone = new List<AcctPlanDepositInternational__c>();
                                        for(AcctPlanDepositInternational__c itemOriginal : DepositInternationalOriginal){
                                            AcctPlanDepositInternational__c itemClone = itemOriginal.clone();
                                            itemClone.AccountPlanDepositInternationalDeposit__c  = CloneWalletID;
                                            //itemClone.OwnerId = Userinfo.getUserId();
                                            DepositInternationalClone.add(itemClone);
                                        }
                                        insert DepositInternationalClone;
                                }

                                //New Object : Account Plan AS Fee
                                /*====== Account Plan AS Fee : step 3 Domain 2 ======*/
                                List<Account_Plan_AS_Fee__c> ASFeeOriginal = (List<Account_Plan_AS_Fee__c>) AccountPlanCloneUtils.getObject('Account_Plan_AS_Fee__c','Account_Plan_Wallet__c',WalletID);
                                if(ASFeeOriginal.size() > 0){
                                    List<Account_Plan_AS_Fee__c> ASFeeClone = new List<Account_Plan_AS_Fee__c>();
                                    for(Account_Plan_AS_Fee__c itemOriginal : ASFeeOriginal){
                                        Account_Plan_AS_Fee__c itemClone = itemOriginal.clone();
                                        itemClone.Account_Plan_Wallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        ASFeeClone.add(itemClone);
                                    }
                                    insert ASFeeClone;
                                }else{
                                    List<Account_Plan_AS_Fee__c> ASFeeList = new List<Account_Plan_AS_Fee__c>();  
                                    //insert ASFeeClone;
                                }
                                
                                /*====== Account Plan Working Capital : step 3 Domain 3 ======*/
                                List<AcctPlanWorkingCapital__c> WorkingCapitalOriginal = (List<AcctPlanWorkingCapital__c>) AccountPlanCloneUtils.getObject('AcctPlanWorkingCapital__c','AcctPlanWallet__c',WalletID);
                                if(WorkingCapitalOriginal.size() > 0){
                                    List<AcctPlanWorkingCapital__c> WorkingCapitalClone = new List<AcctPlanWorkingCapital__c>();
                                    for(AcctPlanWorkingCapital__c itemOriginal : WorkingCapitalOriginal){
                                        AcctPlanWorkingCapital__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        WorkingCapitalClone.add(itemClone);
                                    }
                                    insert WorkingCapitalClone;
                                }

                                /*====== Account Plan Wallet Credit Facility : step 3 Domain 3 ======*/
                                List<AcctPlanWalletCreditFacility__c> WalletCreditFacilityOriginal = (List<AcctPlanWalletCreditFacility__c>) AccountPlanCloneUtils.getObject('AcctPlanWalletCreditFacility__c','AcctPlanWallet__c',WalletID);
                                if(WalletCreditFacilityOriginal.size() > 0){
                                    List<AcctPlanWalletCreditFacility__c> WalletCreditFacilityClone = new List<AcctPlanWalletCreditFacility__c>();
                                    for(AcctPlanWalletCreditFacility__c itemOriginal : WalletCreditFacilityOriginal){
                                        AcctPlanWalletCreditFacility__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        WalletCreditFacilityClone.add(itemClone);
                                    }
                                    insert WalletCreditFacilityClone;
                                }

                                 /*====== Account Plan Existing Long Term Loan : step 3 Domain 3 ======*/
                                List<AcctPlanExistingLongTermLoan__c> ExistingLongTermLoanOriginal = (List<AcctPlanExistingLongTermLoan__c>) AccountPlanCloneUtils.getObject('AcctPlanExistingLongTermLoan__c','AcctPlanWallet__c',WalletID);
                                if(ExistingLongTermLoanOriginal.size() > 0){
                                    List<AcctPlanExistingLongTermLoan__c> ExistingLongTermLoanClone = new List<AcctPlanExistingLongTermLoan__c>();
                                    for(AcctPlanExistingLongTermLoan__c itemOriginal : ExistingLongTermLoanOriginal){
                                        AcctPlanExistingLongTermLoan__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        ExistingLongTermLoanClone.add(itemClone);
                                    }
                                    insert ExistingLongTermLoanClone;
                                }
                                
                                /*====== Account Plan Capital Expenditure Plan : step 3 Domain 3 ======*/
                                List<AcctPlanCapitalExpenditurePlan__c> CapitalExpenditurePlanOriginal = (List<AcctPlanCapitalExpenditurePlan__c>) AccountPlanCloneUtils.getObject('AcctPlanCapitalExpenditurePlan__c','AcctPlanWallet__c',WalletID);
                                if(CapitalExpenditurePlanOriginal.size() > 0){
                                    List<AcctPlanCapitalExpenditurePlan__c> CapitalExpenditurePlanClone = new List<AcctPlanCapitalExpenditurePlan__c>();
                                    for(AcctPlanCapitalExpenditurePlan__c itemOriginal : CapitalExpenditurePlanOriginal){
                                        AcctPlanCapitalExpenditurePlan__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        CapitalExpenditurePlanClone.add(itemClone);
                                    }
                                    insert CapitalExpenditurePlanClone; 
                                }
                                
                                /*====== Account Plan LG Project : step 3 Domain 3 ======*/
                                List<AcctPlanLGProject__c> LGProjectOriginal = (List<AcctPlanLGProject__c>) AccountPlanCloneUtils.getObject('AcctPlanLGProject__c','AcctPlanWallet__c',WalletID);
                                if(LGProjectOriginal.size() > 0){
                                    List<AcctPlanLGProject__c> LGProjectClone = new List<AcctPlanLGProject__c>();
                                    for(AcctPlanLGProject__c itemOriginal : LGProjectOriginal){
                                        AcctPlanLGProject__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        LGProjectClone.add(itemClone);
                                    }
                                    insert LGProjectClone;
                                }

                                /*====== Account Plan Foreign Trans : step 3 Domain 4 ======*/
                                List<AcctPlanForeignTrans__c> ForeignTransOriginal = (List<AcctPlanForeignTrans__c>) AccountPlanCloneUtils.getObject('AcctPlanForeignTrans__c','AcctPlanWallet__c',WalletID);
                                if(ForeignTransOriginal.size() > 0){
                                    List<AcctPlanForeignTrans__c> ForeignTransClone = new List<AcctPlanForeignTrans__c>();
                                    for(AcctPlanForeignTrans__c itemOriginal : ForeignTransOriginal){
                                        AcctPlanForeignTrans__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        ForeignTransClone.add(itemClone);
                                    }
                                    insert ForeignTransClone;
                                }
                                
                                /*====== Account Plan Other Revenue Expenditure  : step 3 Domain 4 ======*/
                                List<AcctPlanOtherRevenueExpenditure__c> OtherRevenueExpenditureOriginal = (List<AcctPlanOtherRevenueExpenditure__c>) AccountPlanCloneUtils.getObject('AcctPlanOtherRevenueExpenditure__c','AcctPlanWallet__c',WalletID);
                                if(OtherRevenueExpenditureOriginal.size() > 0){
                                    List<AcctPlanOtherRevenueExpenditure__c> OtherRevenueExpenditureClone = new List<AcctPlanOtherRevenueExpenditure__c>();
                                    for(AcctPlanOtherRevenueExpenditure__c itemOriginal : OtherRevenueExpenditureOriginal){
                                        AcctPlanOtherRevenueExpenditure__c itemClone = itemOriginal.clone();
                                        itemClone.AcctPlanWallet__c  = CloneWalletID;
                                        //itemClone.OwnerId = Userinfo.getUserId();
                                        OtherRevenueExpenditureClone.add(itemClone);
                                    }
                                    insert OtherRevenueExpenditureClone;
                                }
                                
                                /*====== Account Plan Other Derivative : step 3 Domain 4 ======*/
                               /* List<Account_Plan_Other_Derivative__c > OtherDerivativeOriginal = (List<Account_Plan_Other_Derivative__c >) AccountPlanCloneUtils.getObject('Account_Plan_Other_Derivative__c','Account_Plan_Wallet__c',WalletID);
                                if(OtherDerivativeOriginal.size() > 0 ){
                                    List<Account_Plan_Other_Derivative__c > OtherDerivativeClone = new List<Account_Plan_Other_Derivative__c >();
                                    for(Account_Plan_Other_Derivative__c  itemOriginal : OtherDerivativeOriginal){
                                        Account_Plan_Other_Derivative__c  itemClone = itemOriginal.clone();
                                        itemClone.Account_Plan_Wallet__c   = CloneWalletID;
                                        OtherDerivativeClone.add(itemClone);
                                    }
                                    insert OtherDerivativeClone;
                                }*/

                                /*====== Account Plan Completion ======*/
                                /*List<Account_Plan_Completion__c> CompletionOriginal = (List<Account_Plan_Completion__c>) AccountPlanCloneUtils.getObject('Account_Plan_Completion__c','Account_Plan_Company_Profile__c',CompanyID);
                                if(CompletionOriginal.size() > 0){
                                    Account_Plan_Completion__c CompletionClone= CompletionOriginal.get(0).clone();
                                    CompletionClone.Account_Plan_Company_Profile__c = CloneCompanyID;
                                    //Assign Group Profile
                                    CompletionClone.Account_Plan_Group_Profile__c = GroupProfileID;
                                    insert CompletionClone;
                                }   */
                                          
                            
                            }   
                        }
                    }

                        
                        
                }

                //Update Group Port & Company Port
                 if(PortfolioID!= null && PortfolioID != ''){
                   
                    AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();
                    List<AcctPlanCompanyPort__c> comportlistquery = [SELECT ID,
                                                                        Account__c,
                                                                        Account_Plan_Company_Profile__c,
                                                                        Account_Plan_Portfolio__c,
                                                                        AcctPlanGroupPort__c
                                                                        FROM AcctPlanCompanyPort__c
                                                                        WHERE Account_Plan_Portfolio__c = :PortfolioID
                                                                        AND Account__c  = :AccountID];
                    if(comportlistquery.size()>0){
                        comport = comportlistquery.get(0);
                        comport.Account_Plan_Company_Profile__c = CloneCompanyID;
                        update comport;
                    
                    
                            if(null != comport.AcctPlanGroupPort__c){
                                AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                                      From AcctPlanGroupPort__c
                                                                      WHERE ID=: comport.AcctPlanGroupPort__c
                                                                      ORDER BY Group__c,createddate];
                                    
                                groupport.Account_Plan_Group_Profile__c = GroupProfileID;
                                update groupport;
                            }
                    }
              
                }
                AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CloneCompanyID); 
            }
        /*}catch(Exception e){
            // roll everything back in case of error
            Database.rollback(sp);
            ApexPages.addMessages(e);
        }*/
    }
    
    
    public static PageReference GotoAccountPlanClonePage(String AccountID,String CompanyPortID,String GroupID,String CompanyID,String WalletIDParam){
        PageReference pager = Page.AccountPlanClone;
        if(AccountID != null && AccountID != ''){
            pager.getParameters().put('AccountID',AccountID);
        } 
        if(GroupID != null && GroupID != ''){
            pager.getParameters().put('GroupID',GroupID);
        }
        if(CompanyPortID != null && CompanyPortID != ''){
            pager.getParameters().put('CompanyPortID',CompanyPortID);
        }
        if(CompanyID != null && CompanyID != ''){
            pager.getParameters().put('CompanyID',CompanyID);
        }
        if(WalletIDParam != null && WalletIDParam != ''){
            pager.getParameters().put('WalletID',WalletIDParam);
        }
        pager.setRedirect(true);
        return pager; 
    }



}