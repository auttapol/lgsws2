public with sharing class QCA_ConvertLeadController {
    @AuraEnabled
    public static Id recId{get;set;}

    @AuraEnabled
    public static Boolean IsAllowToConvert{get;set;}

    @AuraEnabled
    public static Boolean IsownerAllowed{get;set;}

    @AuraEnabled
    public static Account originalAccount {get;set;}

    @AuraEnabled
    public static Set<Id> AccountPermissionSet {get;set;}

    @AuraEnabled
    public static Date expected_submit_date {get;set;}
    
    @AuraEnabled
    public static Date expected_complete_date {get;set;}

    @AuraEnabled
    public static Boolean isDuplicateWithAccount {get;set;}

    @AuraEnabled
    public static Opportunity stdConvertOppty {get;set;}
    
    @AuraEnabled
    public static User currentUser{
        get{
            if(currentUser == null){
                currentUser = [SELECT ID,Segment__c from User Where ID =: Userinfo.getUserId() LIMIT 1];
            }
            return currentUser;
        }
        set;
    }
    
    @AuraEnabled
    public static ID PricebookAccess{
        get{
            if(PricebookAccess==null){
                String PricebookAccessName;
                
                if(currentUser.Segment__c !=null){
                    PricebookAccessName = currentUser.Segment__c;
                }else{
                    PricebookAccessName = 'Default';
                }
                
                Pricebook2 Pricebook = [SELECT Id, Name FROM Pricebook2 WHERE IsStandard = false AND Name = :Price_book_access__c.GetValues(PricebookAccessName).PricebookItem__c LIMIT 1];
                PricebookAccess = pricebook.id;
            }
            
            
            return PricebookAccess;
        }
        set;
    }
    
    @AuraEnabled
    public static map<Integer, String> mapMonth {
        get{
            if(mapMonth == null){
                mapMonth = new map<Integer, String> ();
                mapMonth.put(1, 'Jan');
                mapMonth.put(2, 'Feb');
                mapMonth.put(3, 'Mar');
                mapMonth.put(4, 'Apr');
                mapMonth.put(5, 'May');
                mapMonth.put(6, 'Jun');
                mapMonth.put(7, 'Jul');
                mapMonth.put(8, 'Aug');
                mapMonth.put(9, 'Sep');
                mapMonth.put(10, 'Oct');
                mapMonth.put(11, 'Nov');
                mapMonth.put(12, 'Dec');
            }
            return mapMonth;
        }
        set;
    }


    @AuraEnabled
    public static RecordType creditSEOpptyRecordType {
        get{
            if(creditSEOpptyRecordType == null){
                creditSEOpptyRecordType = [SELECT Id, Name FROM RecordType WHERE Name LIKE 'SE Credit Product' AND SobjectType = 'Opportunity' LIMIT 1];
            }
            return creditSEOpptyRecordType;
        }set;
    }

    @AuraEnabled
    public static RecordType CommercialLeadRecordType {
        get{
            if(CommercialLeadRecordType == null){
                CommercialLeadRecordType = [SELECT id, Name FROM RecordType WHERE Name = 'Commercial Lead' AND sObjectType = 'Lead' LIMIT 1];
            }
            return CommercialLeadRecordType;
        }set;
    }

    @AuraEnabled
    public static RecordType CompletedRecordType {
        get{
            if(CompletedRecordType == null){
                CompletedRecordType = [SELECT id,Name FROM RecordType WHERE Name='Commercial Completed' AND sObjectType = 'Lead' LIMIT 1];
            }
            return CompletedRecordType;
        }
        set;
    }

    @AuraEnabled
    public static RecordType AccountRecordType {
        get{
            if(AccountRecordType ==null){
                AccountRecordType = [SELECT id, Name FROM RecordType WHERE Name = 'Commercial Account' AND sObjectType = 'Lead' LIMIT 1];
            }
            return AccountRecordType;
        }set;
    }

    @AuraEnabled
    public static List<Product_Interest__c> ProductList {
        get{
            if(ProductList == null){
                ProductList = [SELECT Id, Name, Amount__c, Opportunity_Type__c, Lead__c, Product__c, Product__r.Name, Related_Account__c, Status__c, Host_Product_Mapping__c, Host_Product_Mapping__r.Name, Host_Product_Mapping__r.Host_Product_Group__c, Host_Product_Mapping__r.Product_Program__c, Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c, Host_Product_Mapping__r.Salesforce_Product__c, Host_Product_Mapping__r.Salesforce_Product__r.Name 
                                FROM Product_Interest__c 
                                WHERE Lead__c =: recId];
            }
            return ProductList;
        }
        set;
    }

    @AuraEnabled
    public static String hostproductGroup {get;set;}

    @AuraEnabled
    public static Lead leadObj {
        get{
            if(leadObj == null){
                leadObj = [SELECT Name, Unqualified_Reasons__c, Remark__c, RecordType.Name, MobilePhone, Phone, Primary_Campaign__c, Customer_Type__c, Salutation, FirstName, LastName, company, Customer_Name_EN__c, ID_Type__c, ID_Number__c, Exception_Flag__c, OwnerID, Contacted_Flag__c, Interest_result__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Ext__c, email, Email__c, RecordTypeId, Mobile_No__c, Office_No__c ,Unqualified_Action__c, Parent_Company__c, Total_Expected_Revenue__c, LeadSource, Other_Source__c, Preferred_Branch__c, Branch_Referred__c, Referral_Staff_ID__c, Referral_Staff_Name__c, Rating, Industry__c, Account__c, Account__r.OwnerID, Account__r.Name, Owner_Segment__c, Title, Decision_Map__c, Phone__c, Province__c, Zipcode__c, Country__c, Sales_amount_per_year__c, No_of_Years_Business_Run__c, Group__c, Original_Referral_Staff_ID__c, Original_Referral_Staff__c, Suggested_Segment__c, Suggested_Team__c, Pre_screen_passed__c, Sub_Unqualified_Reason__c, RTL_Referral__c, Link_Document__c, Other_Reason__c, Lead_Segment__c
                            FROM lead 
                            WHERE id =: recId];
            }
            return leadObj;
        }
        set;
    }

    public QCA_ConvertLeadController() {
        System.debug('QCA_ConvertLeadController CONS');
    }

    
    
    @AuraEnabled
    public static List<Product_Interest__c> InitData(Id objleadid){
        System.debug('objleadid : ' + objleadid);

        if(objleadid == null){
            throw new AuraHandledException('Lead id is null.');
        }

        recId = objleadid;
        
        System.debug('ID: ' + recId);
        System.debug('leadObj: ' + leadObj);
        System.debug('ProductList: ' + ProductList);

        return ProductList;
    }

    @AuraEnabled
    public static Id getStdConvertOpptyId(Id leadId){
        Opportunity opty;
        try {
            opty = [SELECT Id, Converted_Lead_ID__c FROM Opportunity WHERE Converted_Lead_ID__c = :leadId LIMIT 1];
        } catch (Exception e) {
            System.debug('errormessage : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return opty.id;

    }

    @AuraEnabled
    public static void convertLead(Id objleadid, Date submit_date, Date complete_date){
        isDuplicateWithAccount = false;
        System.debug('objleadid : ' + objleadid);

        if(objleadid == null){
            AuraHandledException ex = new AuraHandledException('Lead id is null.');
            ex.setMessage('Lead id is null.');
            system.debug(ex);
            throw ex;
        }

        recId = objleadid;

        System.debug('submit_date');
        System.debug(submit_date);
        System.debug('complete_date');
        System.debug(complete_date);

        expected_submit_date = submit_date;
        expected_complete_date = complete_date;

        System.debug('expected_submit_date');
        System.debug(expected_submit_date);
        System.debug('expected_complete_date');
        System.debug(expected_complete_date);

        System.debug('leadObj: ' + leadObj);

        if(leadObj != null){
            IsAllowToConvert = CheckValidLead();
            IsownerAllowed = checkCreateOptyPermission();
            AccountPermissionSet = new Set<Id> ();

            System.debug(leadObj.RecordType.Name);
            if(leadObj.RecordTypeID == AccountRecordType.id){
                // AccountPermissionSet
            }else if(leadObj.RecordTypeID == CommercialLeadRecordType.id){
                isDuplicateWithAccount = checkLeadDuplicateAccount();
                System.debug('isDuplicateWithAccount : ' + isDuplicateWithAccount);
                if(isDuplicateWithAccount == true){
                    originalAccount = getDuplicateAccount();

                    leadObj.RecordTypeId = AccountRecordType.id;
                    leadObj.Company = originalAccount.Name;
                    leadObj.Customer_Name_EN__c = originalAccount.Customer_Name_PE_Eng__c;
                    leadObj.Customer_Type__c = originalAccount.Customer_Type__c;
                    leadobj.ID_Type__c = originalAccount.ID_Type_PE__c;
                    leadobj.ID_Number__c = originalAccount.ID_Number_PE__c;
                    leadobj.Account__c = originalAccount.id;
                    leadObj.Mobile_No__c = originalAccount.Mobile_Number_PE__c;
                    leadobj.Office_No__c = originalAccount.Phone;
                    leadobj.Ext__c = originalAccount.Primary_Phone_Ext_PE__c;
                    leadobj.Email__c = originalAccount.Email_Address_PE__c;
                    leadobj.Address_Line_1__c = originalAccount.Primary_Address_Line_1_PE__c == 'None' ? '' : originalAccount.Primary_Address_Line_1_PE__c;
                    leadobj.Address_Line_2__c = originalAccount.Primary_Address_Line_2_PE__c == 'None' ? '' : originalAccount.Primary_Address_Line_2_PE__c;
                    leadobj.Address_Line_3__c = originalAccount.Primary_Address_Line_3_PE__c == 'None' ? '' : originalAccount.Primary_Address_Line_3_PE__c;
                    leadobj.Province__c = originalAccount.Province_Primary_PE__c;
                    leadobj.Zipcode__c = originalAccount.Zip_Code_Primary_PE__c;
                    leadobj.Country__c = originalAccount.Country_Primary_PE__c;
                    leadobj.Industry__c = originalAccount.Industry__c;
                    leadobj.Parent_Company__c = originalAccount.ParentId;
                    leadobj.Sales_amount_per_year__c = originalAccount.Sales_amount_per_year__c;
                    leadobj.Group__c = originalAccount.Group__c;
                    leadobj.No_of_Years_Business_Run__c = originalAccount.No_of_years_business_run__c;

                    AccountPermissionSet.add(originalAccount.OwnerId);
                    System.debug('AccountPermissionSet Add Original acc owner : ' + AccountPermissionSet);
                                  
                    for(AccountTeamMember acctTeam : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId =: originalAccount.id]){
                        AccountPermissionSet.add(acctTeam.UserId); 
                    }
                    System.debug('AccountPermissionSet Add Original acc team : ' + AccountPermissionSet);
                    
                }else{
                    System.debug('READY TO CONVERT :: COMMERCIAL LEAD');
                    convertLeadAction();
                }
            }else{
                throw new AuraHandledException('LEAD : Incorrect lead recordtype.');
            }

            //Convert Lead Commercial Account And Dup Commercial Lead
            if(leadObj.RecordTypeID == AccountRecordType.id){
                //If has permission or Exception Flag
                IsownerAllowed = checkCreateOptyPermission();
                System.debug('AccountPermissionSet : ' + AccountPermissionSet);
                System.debug('IsownerAllowed : ' + IsownerAllowed);
                if(AccountPermissionSet.contains(leadObj.OwnerId) || IsownerAllowed){
                    System.debug('READY TO CONVERT :: COMMERCIAL ACCOUNT');
                    convertLeadAction();
                }else if(leadobj.Exception_Flag__c == true){
                    throw new AuraHandledException(Status_Code__c.GetValues('6011').Status_Message__c);
                }else{
                    System.debug('UNQUALIFIED BY DUPLICATED');
                    
                    try {
                        //Unqualified because do not have permissions
                        leadObj.Status = 'Unqualified';
                        leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                        leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                        leadObj.RecordTypeId = CompletedRecordType.id;
                        
                        System.debug('Update leadObj: ' + leadObj);
                        update leadObj;
                        System.debug('Update leadObj: ' + leadObj);
                        System.debug('UNQUALIFIED BY DUPLICATED :: DONE' );
                    } catch (Exception e) {
                        System.debug('UNQUALIFIED Lead Error : ' + e.getMessage());
                        System.debug('line : ' + e.getLineNumber());
                        System.debug('errormessage : ' + e.getMessage());
                        
                        AuraHandledException ex = new AuraHandledException(e.getMessage());
                        ex.setMessage(e.getMessage());
                        system.debug(ex);
                        throw ex;
                    }
					AuraHandledException ex = new AuraHandledException('ERROR Lead is unqualified because do not have permissions.');
                    ex.setMessage('ERROR Lead is unqualified because do not have permissions.');
                    
                    throw ex;
                }
            }else if(leadObj.RecordTypeID != CommercialLeadRecordType.id && leadObj.RecordTypeID != CompletedRecordType.id ){
                throw new AuraHandledException('LEAD : Incorrect lead recordtype.');
            }
        }else{
            throw new AuraHandledException('LEAD : NULL');
        }
    }


    private static void convertLeadAction(){
        Savepoint sp = Database.setSavepoint();
        Set<Id> Product2set = new Set<Id>();
        String NewCreditOpptyName;
        
        Account acct;
        Contact con;


        try {
            System.debug('isDuplicateWithAccount : ' + isDuplicateWithAccount);
            if(isDuplicateWithAccount){
                System.debug('Update leadObj: ' + leadObj);
                update leadObj;
                System.debug('Update leadObj: ' + leadObj);
            }
            
            System.debug('leadObj.RecordTypeId : ' + leadObj.RecordTypeId);
            if(leadObj.RecordTypeId == CommercialLeadRecordType.id){
                acct = LeadToAccount(leadObj);
                
                insert acct;
                System.debug('Create new acct: ' + acct);
                
                con =  LeadToContact(leadobj, acct.id);

                insert con;
                System.debug('Create new con: ' + con);
            }else{
                boolean isMatched = false;

                acct = [SELECT ID, Name FROM Account WHERE ID = :leadObj.Account__c LIMIT 1];

                List<Contact> ExistingConList = [SELECT Id, FirstName, LastName, AccountID FROM Contact WHERE AccountID = :leadObj.Account__c];

                for(contact existingCon : ExistingConList){
                    if(existingCon.FirstName == Leadobj.FirstName && existingCon.LastName == Leadobj.LastName){
                        isMatched = true;
                        con = existingCon;
                    }
                }
                
                if(!isMatched){
                    con =  LeadToContact(leadobj, acct.id);
                    insert con;
                }
            }

            leadobj.Account__c = acct.id;
            leadobj.Contacted_Flag__c = true;
            leadobj.RecordTypeId = CompletedRecordType.id;
            System.debug('Update leadObj: ' + leadObj);
            update leadobj;
            System.debug('Update leadObj: ' + leadObj);
            
            Database.LeadConvert lc = new database.LeadConvert();

            lc.setDoNotCreateOpportunity(false);                
            lc.setLeadId(leadObj.id);
            lc.setAccountId(acct.id);
            lc.setContactId(con.id);
            System.debug('lc : ' + lc);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            Database.LeadConvertResult lcr;

            //:::::::::::::::::::::::::::Generate Opportunity Step:::::::::::::::::::::::::::
            Id recordIdSECreditProduct;
    
            lc.setConvertedStatus(convertStatus.MasterLabel);
            
            lcr = Database.convertLead(lc);

            //Query Temporary Opportunity
            Opportunity stdConvertOppty = [SELECT ID, Branch_Referred__c, Other_Source__c, LeadSource, OwnerId, Converted_Lead_ID__c, CampaignId, CloseDate, Lead_Expect_Revenue__c, Referral_Staff_Name__c, Referral_Staff_ID__c, AccountId, Expected_submit_date__c, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE ID = :lcr.getOpportunityID() LIMIT 1];
    
            stdConvertOppty.CloseDate = expected_complete_date;
            stdConvertOppty.Expected_submit_date__c = expected_submit_date;
        
            stdConvertOppty.StageName = 'Analysis';
            
            if(leadobj.Primary_Campaign__c != null){
                stdConvertOppty.CampaignId  = leadobj.Primary_Campaign__c;  
            }
        
            for(Product_Interest__c prdIn : ProductList){
                Product2set.add(prdIn.Product__c);

                if(NewCreditOpptyName == null){
                    NewCreditOpptyName = prdIn.Product__r.Name;
                }

                if(hostproductGroup == null){
                    System.debug('prdIn : ' + prdIn);
                    System.debug('prdIn.Host_Product_Mapping__r.Host_Product_Group__c : ' + prdIn.Host_Product_Mapping__r.Host_Product_Group__c);
                    hostproductGroup = prdIn.Host_Product_Mapping__r.Host_Product_Group__c;
                }
            }

            //Opportunity Field Mapping
            stdConvertOppty.AccountId = acct.id;
            stdConvertOppty.OwnerId = leadobj.OwnerID;
            stdConvertOppty.Lead_Expect_Revenue__c  = leadobj.Total_Expected_Revenue__c;
            stdConvertOppty.LeadSource = leadobj.LeadSource;
            stdConvertOppty.Other_Source__c = leadobj.Other_Source__c;
            stdConvertOppty.Branch_Referred__c = leadobj.Branch_Referred__c;
            stdConvertOppty.Referral_Staff_ID__c = leadobj.Referral_Staff_ID__c;
            stdConvertOppty.Referral_Staff_Name__c = leadobj.Referral_Staff_Name__c;
            stdConvertOppty.Converted_Lead_ID__c = leadobj.id;
            stdConvertOppty.Remark__c = leadObj.Remark__c;
            stdConvertOppty.Host_Product_Group__c = hostproductGroup;
            stdConvertOppty.Host_System__c = 'SLS';

            /*********** CR Referral  *******************/
            stdConvertOppty.RTL_Referral__c = leadobj.RTL_Referral__c;
            
            system.debug('stdConvertOppty: ' + stdConvertOppty);
            
            //Get PricebookEntry
            // Mapping Product with PricebookEntry ID

            Map<Id, pricebookentry> ProductWithPEMap = new  Map<ID, pricebookentry>();
        
            for(pricebookentry Pe : [SELECT Id, product2id, pricebook2id, pricebook2.Name FROM pricebookentry WHERE product2id IN :Product2set AND pricebook2id = :PricebookAccess]){
                System.debug(Pe.pricebook2.Name);
                ProductWithPEMap.put(Pe.Product2Id, Pe);            
            }
			
            system.debug('ProductWithPEMap: ' + ProductWithPEMap);
            
            //Query VisitPlan for Create Visit Report Opportunities
            List<Call_Report__c> VisitPlanList = [SELECT ID, Customer_Name__c, Lead__c FROM Call_report__c WHERE Lead__c = :leadobj.id];
			
            system.debug('VisitPlanList: ' + VisitPlanList);
            
            List<opportunityLineitem> CreditOpplineInsertList = new List<opportunityLineitem>();
        
            if(ProductList.size() > 0){
                List< Visit_Report_Opportunity__c > newVisitOppTyList = new List<Visit_Report_Opportunity__c>();
                system.debug('newVisitOppTyList: ' + newVisitOppTyList);
                
                //Link VisitPlan Oppty
                for(Call_Report__c visitplan : VisitPlanList){
                    visitplan.Customer_name__c = acct.id;
                    Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
                    visitopp.Customer__c  = visitplan.id;
                    newVisitOppTyList.add(visitopp);
                }
                system.debug('newVisitOppTyList: ' + newVisitOppTyList);
            
                //Set Name
                String OppName = Acct.Name + ' : ' + NewCreditOpptyName;
                stdConvertOppty.Name = OppName.left(180);

            
                Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Opportunity;    
                List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
                
                for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                    if(rtInfo.isDefaultRecordTypeMapping()) {               
                        stdConvertOppty.RecordTypeId = rtInfo.getRecordTypeId();
                    }
                }
            
                // Insert Oppty before references to Oppline
                for(Visit_Report_Opportunity__c visitopp : newVisitOppTyList){
                    //visitopp.Opportunity__c = oppty.id;
                    visitopp.Opportunity__c = stdConvertOppty.id;
                }

                system.debug('VisitPlanList: ' + VisitPlanList);
                update VisitPlanList;
                system.debug('VisitPlanList: ' + VisitPlanList);

                system.debug('newVisitOppTyList: ' + newVisitOppTyList);
                insert newVisitOppTyList;
				system.debug('newVisitOppTyList: ' + newVisitOppTyList);
                
                for(Product_Interest__c PI : ProductList){
                    opportunityLineitem oppLine = new opportunityLineitem();
                    
                    if(ProductWithPEMap.containsKey(PI.Product__c)){
                        oppLine.PricebookEntryId = ProductWithPEMap.get(PI.Product__c).id;
                    }
                    oppLine.Host_Product_Mapping__c = PI.Host_Product_Mapping__c;

                    oppline.OpportunityId = stdConvertOppty.id;
                    oppLine.Quantity = 1;
                    oppline.Expected_Revenue__c = PI.amount__c == null ? 0 : PI.amount__c;
                    oppLine.UnitPrice = PI.amount__c;
                    oppLine.RevisedStartMonth__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                    oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year());
                    oppLine.RevisedStartMonthFee__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                    oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year());
                    oppLine.Frequency__c = 'Monthly';
                    oppLine.FrequencyFee__c = 'Monthly';

                    PI.Opportunity__c = stdConvertOppty.id;
                    PI.status__c = 'Opp Created';
                    
                    system.debug('oppline: ' + oppline);

                    CreditOpplineInsertList.add(oppline);
                }
            }
			
            system.debug('stdConvertOppty: ' + stdConvertOppty);

            if(Test.isRunningTest()){
                stdConvertOppty.Pricebook2Id = [SELECT ID, Name FROM Pricebook2 WHERE Name = 'Commercial Pricebook' LIMIT 1 ].Id;
            }

            update stdConvertOppty;
            system.debug('PricebookAccess: ' + PricebookAccess);
            system.debug('stdConvertOppty: ' + stdConvertOppty);
            system.debug('stdConvertOppty Pricebook2Id: ' + stdConvertOppty.Pricebook2Id);
            system.debug('stdConvertOppty Pricebook2Id.Name: ' + stdConvertOppty.Pricebook2.Name);


            // Opportunity stdConvertOppty2 = [SELECT ID, Branch_Referred__c, Other_Source__c, LeadSource, OwnerId, Converted_Lead_ID__c, CampaignId, CloseDate, Lead_Expect_Revenue__c, Referral_Staff_Name__c, Referral_Staff_ID__c, AccountId, Expected_submit_date__c, Pricebook2Id, Pricebook2.Name FROM Opportunity WHERE ID = :lcr.getOpportunityID() LIMIT 1];

            // System.debug('Pricebook2Id : ' + stdConvertOppty2.Pricebook2Id);
            // System.debug('Pricebook2.Name : ' + stdConvertOppty2.Pricebook2.Name);
        
            if(CreditOpplineInsertList.size() > 0){
                system.debug('CreditOpplineInsertList: ' + CreditOpplineInsertList);
                insert CreditOpplineInsertList;
                system.debug('ProductList: ' + ProductList);
                update ProductList;
            }

            System.debug('Convert FINISH ::::::: Opportunity Id : ' + stdConvertOppty.id);
            // Database.rollback(sp);
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('line : ' + ex.getLineNumber());
            System.debug('errormessage : ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static Contact LeadToContact(Lead leadrecord,ID AccountID){
        Contact con = new Contact();

        con.Title = leadrecord.Salutation;
        con.FirstName = leadrecord.FirstName;
        con.LastName = leadrecord.LastName;
        con.Last_Name__c = leadrecord.LastName;
        con.Position__c = leadrecord.Title;
        con.Decision_Map__c = leadrecord.Decision_Map__c;
        con.MobilePhone = leadrecord.Phone__c;
        con.OwnerId = leadrecord.OwnerId;
        con.AccountId = AccountID;
        con.Account__c = AccountID;
        con.C_Country_PE__c = 'Thailand';
        
        return con;
    }

    public static Account LeadToAccount(Lead Leadrecord){
        Account acct = new Account();

        acct.Customer_Type__c = leadObj.Customer_Type__c;
        acct.OwnerId = Leadrecord.OwnerId;
        acct.Account_Type__c  = 'Qualified Prospect';
        acct.Name = leadObj.Company;
        acct.Customer_Name_PE_Eng__c = leadObj.Customer_Name_EN__c;
        acct.ID_Type_PE__c = leadobj.ID_Type__c ;
        acct.ID_Number_PE__c = leadobj.ID_Number__c;
        acct.Mobile_Number_PE__c = leadObj.Mobile_No__c;
        acct.Phone = leadobj.Office_No__c;
        acct.Primary_Phone_Ext_PE__c = leadobj.Ext__c;
        acct.Primary_Address_Line_1_PE__c = leadobj.Address_Line_1__c=='None'?'':leadobj.Address_Line_1__c;
        acct.Primary_Address_Line_2_PE__c = leadobj.Address_Line_2__c=='None'?'':leadobj.Address_Line_2__c;
        acct.Primary_Address_Line_3_PE__c = leadobj.Address_Line_3__c=='None'?'':leadobj.Address_Line_3__c;
        acct.Province_Primary_PE__c = leadobj.Province__c;
        acct.Zip_Code_Primary_PE__c = leadobj.Zipcode__c;
        acct.Country_Primary_PE__c = leadobj.Country__c;
        acct.Rating = leadobj.Rating;
        acct.Industry__c =  leadobj.Industry__c;
        acct.ParentId = leadobj.Parent_Company__c;
        acct.Sales_amount_per_year__c = leadobj.Sales_amount_per_year__c;
        acct.Group__c = leadobj.Group__c;
        acct.No_of_years_business_run__c = leadobj.No_of_Years_Business_Run__c;
        acct.Branch_Referred__c = leadobj.Branch_Referred__c;
        acct.TMB_Employee_ID__c  = leadobj.Original_Referral_Staff_ID__c ;
        acct.TMB_Employee_Name__c = leadobj.Original_Referral_Staff__c;
        acct.Remark__c = leadobj.Remark__c;
        acct.Suggested_Segment__c = leadobj.Suggested_Segment__c;
        acct.Suggested_Sub_Segment__c = leadobj.Suggested_Team__c;
        acct.Branch_and_Zone__c = leadobj.Preferred_Branch__c;
        acct.ParentId = leadobj.Parent_Company__c;
        acct.Email_Address_PE__c = Leadobj.Email__c;
                       
        return acct;
    }

    public static Boolean checkLeadDuplicateAccount(){
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,leadObj);
        CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);

        return LeadWrapper.isfoundDuplicate;
    }

    public static Account getDuplicateAccount(){
        Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,leadObj);
        CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);


        String AcctID = String.valueof(LeadWrapper.Originalrecord.get('ID'));
        
        //Query Account detail for populate data
        originalAccount = [SELECT ID,Customer_Type__c, Customer_Name_PE_ENg__c, ParentId, Suggested_Sub_Segment__c, Name, Mobile_Number_PE__c, phone, ID_Type_PE__c, OwnerID, ID_Number_PE__c, Primary_Address_Line_1_PE__c, Primary_Address_Line_2_PE__c, Primary_Address_Line_3_PE__c, Province_Primary_PE__c, Zip_Code_Primary_PE__c, Country_Primary_PE__c, Industry, Sales_amount_per_year__c, No_of_years_business_run__c, TMB_Employee_ID__c, TMB_Employee_Name__c, Remark__c, Rating, Industry__c, Group__c, Branch_Referred__c, Suggested_Segment__c, Email_Address_PE__c, Primary_Phone_Ext_PE__c
                            FROM Account
                            WHERE ID =: AcctID
                            LIMIT 1];

        return originalAccount;
    }

    public static Boolean CheckValidLead(){
        if(leadObj != null){
            System.debug('leadobj.Contacted_Flag__c: ' + leadobj.Contacted_Flag__c  + ' leadobj.RecordType.Name: ' + leadobj.RecordType.Name);
            if(!leadobj.Contacted_Flag__c && leadobj.RecordType.Name == 'Commercial Lead'){
                throw new AuraHandledException(Status_Code__c.GetValues('6004').Status_Message__c);
            }
            System.debug('leadobj.Contacted_Flag__c: ' + leadobj.Contacted_Flag__c  + ' leadobj.RecordType.Name: ' + leadobj.RecordType.Name + ' ::: PASS');

            System.debug('leadobj.Customer_Type__c: ' + leadobj.Customer_Type__c );   
            if(leadobj.Customer_Type__c == null || leadobj.Customer_Type__c == ''){
                throw new AuraHandledException(Status_Code__c.GetValues('6005').Status_Message__c);
            }
            System.debug('leadobj.Customer_Type__c: ' + leadobj.Customer_Type__c  + ' ::: PASS');   

            System.debug('leadobj.LastName.containsIgnoreCase("N/A"): ' + leadobj.LastName);
            if(leadobj.LastName.containsIgnoreCase('N/A') || (leadobj.LastName == null || leadobj.LastName == '') ){
                throw new AuraHandledException(Status_Code__c.GetValues('6006').Status_Message__c);
            }
            System.debug('leadobj.LastName.containsIgnoreCase("N/A"): ' + leadobj.LastName + ' ::: PASS');

            System.debug('leadobj.leadobj.FirstName: ' + leadobj.FirstName );
            if((leadobj.FirstName == null || leadobj.FirstName == '')){
                throw new AuraHandledException(Status_Code__c.GetValues('6007').Status_Message__c);
            }
            System.debug('leadobj.leadobj.FirstName: ' + leadobj.FirstName + ' ::: PASS' );
             
            System.debug('leadobj.ID_Type__c: ' + leadobj.ID_Type__c + ' leadobj.ID_Number__c: ' + leadobj.ID_Number__c);
            if((leadobj.ID_Type__c == null || leadobj.ID_Type__c == '') || (leadobj.ID_Number__c == null || leadobj.ID_Number__c == '') ){
                throw new AuraHandledException(Status_Code__c.GetValues('6008').Status_Message__c);
            }
            System.debug('leadobj.ID_Type__c: ' + leadobj.ID_Type__c + ' leadobj.ID_Number__c: ' + leadobj.ID_Number__c + ' ::: PASS');

            System.debug('leadobj.Office_No__c: ' + leadobj.Office_No__c + ' leadobj.Mobile_No__c: ' + leadobj.Mobile_No__c + ' leadobj.RecordType.Name (Commercial Lead): ' + leadobj.RecordType.Name);
            if(leadobj.Office_No__c == null && leadobj.Mobile_No__c == null && leadobj.RecordType.Name == 'Commercial Lead'){
                throw new AuraHandledException(Status_Code__c.GetValues('6009').Status_Message__c);
            }
            System.debug('leadobj.Office_No__c: ' + leadobj.Office_No__c + ' leadobj.Mobile_No__c: ' + leadobj.Mobile_No__c + ' leadobj.RecordType.Name (Commercial Lead): ' + leadobj.RecordType.Name + ' ::: PASS');
            
            System.debug('leadobj.ProductList.size(): ' + ProductList.size() );
            if(ProductList.size() < 1){
                throw new AuraHandledException(Status_Code__c.GetValues('6010').Status_Message__c);
            }
            System.debug('leadobj.ProductList.size(): ' + ProductList.size() + ' ::: PASS');

            System.debug('leadobj.Pre_screen_passed__c  :' + leadobj.Pre_screen_passed__c );
            if(!leadobj.Pre_screen_passed__c ){
                throw new AuraHandledException(Status_Code__c.GetValues('6020').Status_Message__c);
            }
            System.debug('leadobj.Pre_screen_passed__c  :' + leadobj.Pre_screen_passed__c + ' ::: PASS');
            
            System.debug('expected_submit_date__c: ' + expected_submit_date);
            if(expected_submit_date == null || expected_submit_date < System.today()){
                throw new  AuraHandledException(Status_Code__c.GetValues('6022').Status_Message__c);
            }
            System.debug('expected_submit_date__c: ' + expected_submit_date + ' ::: PASS');

            System.debug('expected_complete_date  :' + expected_complete_date);
            if(expected_complete_date == null || expected_complete_date < expected_submit_date){
                throw new  AuraHandledException(Status_Code__c.GetValues('6023').Status_Message__c);
            }
            System.debug('expected_complete_date  :' + expected_complete_date + ' ::: PASS');
            return true;
        }
        throw new AuraHandledException('LEAD : NULL');
    }

    public static Boolean checkCreateOptyPermission(){
        if(leadObj != null){
            if(leadObj.Account__c != null){
                List<AccountTeamMember> acctteam = [SELECT ID, AccountId, UserId FROM AccountTeamMember WHERE AccountId =: leadObj.Account__c AND UserId =: leadobj.OwnerId LIMIT 1];
                System.debug('acctteam: ' + acctteam);

                //Owner Or Account Owner or Account Team allow
                if((leadObj.ownerID == leadObj.Account__r.OwnerID) || (acctTeam.size() > 0)){
                    return true;
                }else{
                    //RMC Allow
                    List<Account__c> privilegeList = Account__c.getall().values();
                    User LeadOwner = [SELECT Id, UserRole.Name, Segment__c FROM user WHERE ID =: leadobj.OwnerId LIMIT 1];

                    for(Account__c eachPrivilege : privilegeList){
                        if(LeadOwner.UserRole.Name == eachPrivilege.Role__c ){
                            return true;
                        }                    
                    }
                    return false;
                }
            }else{
                return true;
            }
        }
        throw new AuraHandledException('LEAD : NULL');
    }
}