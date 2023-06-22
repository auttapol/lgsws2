/*
CH01: CR Refer within Commercial
 */
public class LeadActionController {
    
    public lead leadObj {get;set;}
    public Account originalAccount {get;set;}
    public Lead originalLead {get;set;}
    public boolean IsownerAllowed {get;set;}
    public boolean launchNextPage {get;set;}
    public boolean isMobilePage {get;set;}
    public boolean IsAllowToConvert {get;set;}
    public boolean isComLead {get;set;}
    public boolean isDuplicated {get;set;}
    public boolean isNotInterest {get;set;}
    public boolean isRequiredOpp {get;set;}
    public boolean isDuplicatedbyAccount {get;set;}
    public boolean isDuplicatedbyLead {get;set;}
    public boolean isNeedtobeMember {get;set;}
    public boolean isCommercialLead {get;set;}
    public boolean isNeedtoConfirmContacted {get;set;}
    public boolean isConfirmAnyway {get;set;}
    public boolean isFromSurvey {get;set;}
    public boolean toggleScript {get;set;}
    public boolean isOppNotCreated {get;set;}
    public boolean isCompleteSurvey {get;set;}
    public boolean isneedBackToLead {get;set;}
    public List<Lead> oldvalueList;
    public List<Lead> newvalueList;
    public List<Product_Interest__c> ProductList {get;set;}   
    public Opportunity oppty {get;set;}
    public Opportunity stdConvertOppty {get;set;}
    public List<ProductWrapper> ProductWrapperList {get;set;}
    public List<RecordType> recordTypeList {get{
        if(recordTypeList==null){
           recordTypeList = [ select Id,Name 
                                           from RecordType 
                                           where Name IN ('SE Credit Product',
                                                          'Non-credit Product',
                                                          'WBG Credit Product')
                                          and SobjectType = 'Opportunity'];
        }
        return recordTypeList;
        
    }set;} 
    //CR Link to Oppty Lead
    public ID ConvertedOpportunityID {get;set;}
    //CR Link to Oppty Lead
    public ID PricebookAccess{get{
        
        if(PricebookAccess==null){
            User currentUser = [SELECT ID,Segment__c from User Where ID =: Userinfo.getUserId() LIMIT 1];
            String PricebookAccessName;
            if(currentUser.Segment__c !=null){
                PricebookAccessName = currentUser.Segment__c;
            }else{
                PricebookAccessName = 'Default';
            }
            
            Pricebook2 Pricebook = [SELECT ID,Name from Pricebook2
                                       WHERE IsStandard = false
                                       AND Name =: Price_book_access__c.GetValues(PricebookAccessName).PricebookItem__c
                                       LIMIT 1];
            
            PricebookAccess = pricebook.id;
        }
        
        
        return PricebookAccess;
    }set;}
    
    
    public static RecordType CompletedRecordType {get{
        if(CompletedRecordType ==null){
           CompletedRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Completed' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CompletedRecordType;
    }set;}

    
    
        public static RecordType AccountRecordType {get{
        if(AccountRecordType ==null){
           AccountRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Account' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return AccountRecordType;
    }set;}
    
    
        public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
    public List<AccountTeamMember> acctTeam {get;set;}
    public Set<ID> AccountPermissionSet {get;set;}
    
    public String convertLeadWarning {get{
        if(convertLeadWarning==null){
            convertLeadWarning = Status_Code__c.GetValues('6018').Status_Message__c;
        }                                 
         return       convertLeadWarning;                                    
    }set;}
    
    public String convertOppornuityMessage{get{
        if(convertOppornuityMessage==null){
            convertOppornuityMessage = Status_Code__c.GetValues('6019').Status_Message__c;
        }                                 
         return       convertOppornuityMessage;                                    
    }set;}

    public String SurveyID {get;set;}
    public Survey__c surveyobj {get;set;}
    public static RecordType CompletedSurvey {get{
        if(CompletedSurvey==null){
                CompletedSurvey = [SELECT id,Name FROM RecordType 
                                 WHERE Name='NPS Survey Complete' 
                                 AND sObjectType='Survey__c' LIMIT 1];
            }
        return CompletedSurvey;
    }set;}


    public LeadActionController (ApexPages.StandardController sc)
    {
        lead tempLead = (lead)sc.getRecord();
        isNotInterest =false;
        IsownerAllowed= false;
        IsAllowToConvert= true;
        isRequiredOpp = false;
        isDuplicatedbyAccount =  false;
        isDuplicatedbyLead = false;
        isCommercialLead = false;
        isNeedtobeMember = false;
        isMobilePage =false;
        launchNextPage = false;
        isNeedtoConfirmContacted = false;
        isConfirmAnyway = false;
        isFromSurvey = false;
        toggleScript = false;
        isOppNotCreated = false;
        isCompleteSurvey = false;
        isneedBackToLead =false;
        leadObj = [select Name ,Unqualified_Reasons__c  ,Remark__c ,RecordType.Name,MobilePhone ,Phone,Primary_Campaign__c,
                       Customer_Type__c, Salutation, FirstName, LastName, company, Customer_Name_EN__c, ID_Type__c
                       , ID_Number__c, Exception_Flag__c,OwnerID, Contacted_Flag__c,Interest_result__c
                       ,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Ext__c,email,Email__c
                       , RecordTypeId,Mobile_No__c, Office_No__c ,Unqualified_Action__c,Parent_Company__c
                       ,Total_Expected_Revenue__c,LeadSource,Other_Source__c,Preferred_Branch__c
                       , Branch_Referred__c,Referral_Staff_ID__c,Referral_Staff_Name__c,Rating
                       , Industry__c,Account__c,Account__r.OwnerID,Account__r.Name, Owner_Segment__c
                       ,Title, Decision_Map__c, Phone__c,Province__c,Zipcode__c,Country__c
                       ,Sales_amount_per_year__c,No_of_Years_Business_Run__c,Group__c,Original_Referral_Staff_ID__c
                       ,Original_Referral_Staff__c,Suggested_Segment__c,Suggested_Team__c,Pre_screen_passed__c,Sub_Unqualified_Reason__c,
                       FNA_Activity__c,Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c, Fna_Product_Holding__c,Fna_Product_Interested__c
                       ,RTL_Referral__c,Link_Document__c, Other_Reason__c, Lead_Segment__c
                       from lead where id =: tempLead.id];
        
        
        if(leadobj.RecordType.Name == 'Commercial Lead'){
                isCommercialLead =true;
            }

       //Survey
        SurveyID = ApexPages.currentPage().getParameters().get('SurveyID');

        if(SurveyID !=null && SurveyID !=''){
                surveyobj = [SELECT ID,result__c,Customer__c from Survey__c WHERE ID =:SurveyID LIMIT 1];
                isFromSurvey = true;
                isCompleteSurvey = true;
                isneedBackToLead =true;
                //surveyobj.result__c = 'Completed';
                System.debug('surveyobj : '+surveyobj.id);
        }
        
        
        System.debug(!isFromSurvey);
        if(!leadobj.Contacted_Flag__c && !isFromSurvey){
            
            if(!isCommercialLead){
                isNeedtoConfirmContacted = true;
                isConfirmAnyway =false;
            }
           
           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Status_Code__c.GetValues('6004').Status_Message__c));
           
            
        }
        
        
        
        String pageName = ApexPages.CurrentPage().getUrl();  
        pageName = pageName.replaceFirst('/apex/','');         
        pageName = EncodingUtil.urlEncode(pageName, 'UTF-8'); 
        string[] pageNameExtra = pageName.split('%3F',0);   
        
        pageName = pageNameExtra[0]; 
        
        if(pageName.containsIgnoreCase('Mobile')){
            isMobilePage = true;
        }


       


       

        
    }
    

   public PageReference completeSurvey(){
     if(surveyobj.Result__c ==null){
 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6202').Status_Message__c));
      IsAllowToConvert = false;
      return null;
     }else{

      IsAllowToConvert = true;

            if(isCompleteSurvey){

             isCompleteSurvey = false;

             Integer productcount =  [SELECT count() from Product_Interest__c WHERE Lead__c =: leadobj.id];

             if(productcount>0){
              return null;
             }else{
              isCompleteSurvey =true;

              leadObj.Interest_result__c ='Yes';
              return convertlead();
             }

                
           }else{
              return convertLead();

           }


     }    
      
   } 
   
    
    public Pagereference convertLead(){
        
        ProductList =  [SELECT Amount__c ,Opportunity__c ,Opportunity_Type__c ,
                        Product__c ,Product__r.Name,Status__c  from Product_Interest__c 
                        WHERE Lead__c =: leadobj.id];
        
        System.debug(leadObj.Interest_result__c);
        
        if(leadObj.Interest_result__c =='Yes'){
            
            //Check Criteria
            if(leadObj.Account__c !=null){
                 acctteam = [SELECT ID,AccountId,
                             UserId FROM  AccountTeamMember
                             WHERE AccountId =: leadObj.Account__c
                             AND UserId =:leadobj.OwnerId LIMIT 1];
                
                              
                
                
                
                                          
        //Owner Or Account Owner or Account Team allow
                if((leadObj.ownerID ==leadObj.Account__r.OwnerID)
                  || (acctTeam.size()>0)
                  ){
                   IsownerAllowed = true;
                  }else{
                      //RMC Allow
                    //
                    List<Account__c> privilegeList = Account__c.getall().values();

                     User LeadOwner = [select Id,UserRole.Name,Segment__c from user where ID =:leadobj.OwnerId LIMIt 1];

                    for( Account__c eachPrivilege : privilegeList ){
                                if(LeadOwner.UserRole.Name == eachPrivilege.Role__c ){
                                       IsownerAllowed = true;
                                   }                    
                    }  
                      
                      
                  }
                
                
                
                
                
                
            }else{
                IsownerAllowed = true;
            }
        
        
        System.debug('leadobj.Pre_screen_passed__c  :'+leadobj.Pre_screen_passed__c );
         if(!leadobj.Pre_screen_passed__c ){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6020').Status_Message__c));
          
                IsAllowToConvert = false;
            
        }
       
        
            
        if(!leadobj.Contacted_Flag__c && isCommercialLead && !isFromSurvey){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6004').Status_Message__c));
          
                IsAllowToConvert = false;
            
        }
                    
        
        if(leadobj.Customer_Type__c ==null || leadobj.Customer_Type__c ==''){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6005').Status_Message__c));
           
            IsAllowToConvert =false;
        }
        if(leadobj.LastName.containsIgnoreCase('N/A') || (leadobj.LastName ==null || leadobj.LastName =='') ){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6006').Status_Message__c));
           IsAllowToConvert =false; 
        }
        if((leadobj.FirstName==null || leadobj.FirstName =='')){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6007').Status_Message__c));
          IsAllowToConvert =false; 
        }    
        if((leadobj.ID_Type__c ==null || leadobj.ID_Type__c =='') 
           || (leadobj.ID_Number__c ==null || leadobj.ID_Number__c =='') ){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6008').Status_Message__c));
           IsAllowToConvert = false;
        }
        if(leadobj.Office_No__c ==null && leadobj.Mobile_No__c ==null && leadobj.RecordType.Name == 'Commercial Lead'){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6009').Status_Message__c));
          IsAllowToConvert = false;
        }
        if(ProductList.size()==0 && !isFromSurvey){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6010').Status_Message__c));
           IsAllowToConvert = false;
            
        }
            
            
            //Check Opportunity Condition to Create
            //
             List<Product_Interest__c> CreditProductList = new List<Product_Interest__c>();
            List<Product_Interest__c> NonCreditProductList = new List<Product_Interest__c>();
            ProductWrapperList = new List<ProductWrapper>();
            oppty = new Opportunity();
            for(Product_Interest__c PI : ProductList){
                if(PI.Opportunity_Type__c =='Credit'){
                    CreditProductList.add(PI);
                }else if(PI.Opportunity_Type__c =='Non-Credit'){
                    NonCreditProductList.add(PI);
                }
                ProductWrapper pw = new  ProductWrapper();
                    pw.ProductIN = PI;
                   ProductWrapperList.add(pw);
            }
            //
            //
            
            if(CreditProductList.size()> 0 ||NonCreditProductList.size()>0){
                 isRequiredOpp =true; 
            }
            
            
            
            
            
        if(!IsownerAllowed  && isRequiredOpp){
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6011').Status_Message__c));
          IsAllowToConvert = false; 
        }




        if(isAllowToConvert){


                          oldvalueList = new List<Lead>();
                          newvalueList = new List<Lead>();
                          oldvalueList.add(new Lead());
                          newvaluelist.add(leadObj);
                        // Old Check dup
                         // isDuplicated = DisqualifiedProcessBuilder.CheckDisqualifiedAction(newvalueList,oldvalueList,'insert');
                          // List<Account> DisqualifiedResult = DisqualifiedProcessBuilder.AccountResultList;
                      //System.debug('DisqualifiedResult: '+DisqualifiedResult.size());
                      //
                      //New Check dup 
                      Map<Integer,CommercialDuplicateCheck.LeadWrapper> leadwrapperMap = 
                          CommercialDuplicateCheck.DuplicateCheckLeadSingleRecord(leadObj,leadObj);
                          CommercialDuplicateCheck.LeadWrapper LeadWrapper = leadwrapperMap.get(0);
                        System.debug('results : '+LeadWrapper);
                      System.debug('results : '+LeadWrapper.isfoundDuplicate);
                      System.debug('results : '+LeadWrapper.OrgininalrecordType);
                      System.debug('results : '+LeadWrapper.Originalrecord);
                          
                       
                  if(LeadWrapper.isfoundDuplicate  
                     && IsAllowToConvert
                     && leadObj.RecordTypeID ==CommercialLeadRecordType.id
                     ){
                     
                         AccountPermissionSet = new Set<ID>();
                         // LEAD IS DUPLICATE IN THE SYSTEM
                         // 
                          
                         
                    
                         //DUPLICATED WITH EXISTING ACCOUNT IN THE SYSTEM
                         if(LeadWrapper.isfoundDuplicate && LeadWrapper.OrgininalrecordType=='Account' ){
                             
                             String AcctID = String.valueof(LeadWrapper.Originalrecord.get('ID'));
                             //Query Account detail for populate data
                                     originalAccount = [SELECT ID,Customer_Type__c,Customer_Name_PE_ENg__c, ParentId, Suggested_Sub_Segment__c  
                                                             ,Name, Mobile_Number_PE__c,phone, ID_Type_PE__c,OwnerID
                                                             ,ID_Number_PE__c,Primary_Address_Line_1_PE__c,Primary_Address_Line_2_PE__c,Primary_Address_Line_3_PE__c
                                                             ,Province_Primary_PE__c,Zip_Code_Primary_PE__c,Country_Primary_PE__c
                                                             ,Industry,Sales_amount_per_year__c,No_of_years_business_run__c
                                                             ,TMB_Employee_ID__c,TMB_Employee_Name__c,Remark__c,Rating,Industry__c
                                                             ,Group__c,Branch_Referred__c,Suggested_Segment__c
                                                            ,Email_Address_PE__c,Primary_Phone_Ext_PE__c
                                                            FROM Account
                                                            WHERE ID =:AcctID
                                                            LIMIT 1];
                             //Add OwnerID to permissionset    
                                  AccountPermissionSet.add(originalAccount.OwnerId);
                                  
                             for(AccountTeamMember acctTeam :[SELECT ID,AccountId,
                                       UserId FROM  AccountTeamMember
                                                                    WHERE AccountId =: originalAccount.id]){
                                                                       AccountPermissionSet.add(acctTeam.UserId); 
                                                                    }

                            isDuplicatedbyAccount = true;
                            isDuplicated = true;
                             
                             
                         }
                
                  }
                     
                      
                      System.debug('isDuplicatedbyAccount: '+isDuplicatedbyAccount);  
                      System.debug('IsAllowToConvert: '+IsAllowToConvert);
                      
                      //EndCheck Criteria
                      

        }
            
            if(isDuplicatedbyAccount){
                   
                       //Populate Data from Original Account record

                      leadObj.Company = originalAccount.Name;
                        leadObj.Customer_Name_EN__c = originalAccount.Customer_Name_PE_Eng__c;
                        leadObj.Customer_Type__c = originalAccount.Customer_Type__c;
                        leadobj.ID_Type__c = originalAccount.ID_Type_PE__c;
                        leadobj.ID_Number__c = originalAccount.ID_Number_PE__c;
                      //leadobj.TMB_Cust_ID__c = originalAccount.TMB_Customer_ID_PE__c;
            leadobj.Account__c = originalAccount.id;
                        leadObj.Mobile_No__c = originalAccount.Mobile_Number_PE__c;
                        leadobj.Office_No__c = originalAccount.Phone;
                      leadobj.Ext__c = originalAccount.Primary_Phone_Ext_PE__c;
                      leadobj.Email__c = originalAccount.Email_Address_PE__c;
                      leadobj.Address_Line_1__c = originalAccount.Primary_Address_Line_1_PE__c=='None'?'':originalAccount.Primary_Address_Line_1_PE__c;
                        leadobj.Address_Line_2__c = originalAccount.Primary_Address_Line_2_PE__c=='None'?'':originalAccount.Primary_Address_Line_2_PE__c;
                        leadobj.Address_Line_3__c = originalAccount.Primary_Address_Line_3_PE__c=='None'?'':originalAccount.Primary_Address_Line_3_PE__c;
                        leadobj.Province__c = originalAccount.Province_Primary_PE__c;
                        leadobj.Zipcode__c = originalAccount.Zip_Code_Primary_PE__c;
                        leadobj.Country__c = originalAccount.Country_Primary_PE__c;
                        //leadobj.Industry = originalAccount.Industry;
                        leadobj.Industry__c = originalAccount.Industry__c;
                        leadobj.Parent_Company__c = originalAccount.ParentId;
                        leadobj.Sales_amount_per_year__c = originalAccount.Sales_amount_per_year__c;
                      leadobj.Group__c = originalAccount.Group__c;
                        leadobj.No_of_Years_Business_Run__c = originalAccount.No_of_years_business_run__c;

                    
                            //If has permission or Exception Flag
                            if(AccountPermissionSet.contains(Leadobj.OwnerId) || leadobj.Exception_Flag__c ==true){
                               isCommercialLead =false;
                                leadObj.RecordTypeId = AccountRecordType.id;
                            }else{
                                System.debug('UNQUALIFIED BY DUPLICATED');
                                //Unqualified because do not have permissions
                                leadObj.Status = 'Unqualified';
                                leadobj.Unqualified_Rejected_List__c = 'Owned by another RM';
                                leadobj.Unqualified_Reasons__c = 'Owned by another RM';
                                leadObj.RecordTypeId = CompletedRecordType.id;
                                IsAllowToConvert =false;
                           }
                        
                    
                   
                    
                if(!IsAllowToConvert){
                    
                    update leadObj;
                    
                    if(isMobilePage){
                    launchNextPage = true;
                    return null;
                    }else{
                        return cancel();
                    }
                    
                }
                    
                }
            
            
            
            
            if(IsAllowToConvert){
                
                system.debug(' isRequiredOpp : ' + isRequiredOpp);
                if(isRequiredOpp){
                    if(!isCommercialLead){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Status_Code__c.GetValues('6013').Status_Message__c));
                
                    }
                    
                    return null;
                    
                }else{
                    
                    
                    return ConvertAction();
                }
                
            }else{
                //Other False cases
                //
               
                /*if (isDuplicatedbyAccount && leadObj.Exception_flag__c == true){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6003').Status_Message__c));
                }*/
                
                 return null;
                
               
            }
            
          
            
           
        //Not Interested
        }else{
            try{
                
                if(leadObj.Unqualified_Reasons__c ==null || leadObj.Unqualified_Reasons__c==''){
                    
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Status_Code__c.GetValues('6016').Status_Message__c));
                    return null;
                }else{
                    leadObj.Status = 'Not Converted';
                leadobj.RecordTypeId = CompletedRecordType.id;
                
                update leadObj;
                
                
                //Update Product Interest
                 for(Product_Interest__c PI : ProductList){
                     
                     PI.status__c = 'Not Interested';
                 }
                
                
                update ProductList;
                
                //Update Visit Plan/Report
                //
                if(leadobj.Account__c !=null){
                     List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c
                                                 FROM Call_report__c 
                                                 WHERE Lead__c =: leadobj.id];
                    for(Call_report__c visit : VisitPlanList){
                        visit.Customer_name__c = leadobj.Account__c;
                    }
                    
                    update VisitPlanList;
                }


                if(isFromSurvey){
                   surveyobj.RecordTypeID = CompletedSurvey.id;    
                  update surveyobj;
                }
                
                
                if(isMobilePage){
                    launchNextPage = true;
                    return null;
                }else{
                    return cancel();
                }
                }
                 
                
                
            }catch(DMLException e){
               
                
                System.debug(e.getMessage());
                // ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage())); 
                return null;
            }
        }
        
            
                
                
    }
    
    
    
    
    public PageReference ConvertAction(){
            Savepoint sp = Database.setSavepoint();
            Boolean isSelectProduct = false;
            Boolean isValidOppStage = true;
            Integer selectedSize = 0;
              List<Product_Interest__c> CreditProductList = new List<Product_Interest__c>();
                List<Product_Interest__c> NonCreditProductList = new List<Product_Interest__c>();
            List<Opportunity> UpdateLinkToOppList = new List<Opportunity>();
                Set<ID> Product2List = new Set<ID>();
                Map<ID,ID> LinkToOppMap = new Map<Id,ID>();
                boolean isCreateNewCreditOpp = false;
                boolean isCreateNewNonCreditOpp = false;
            String NewCreditOpptyName;
          if(isRequiredOpp){

            System.debug('oppty.Expected_submit_date__c : '+oppty.Expected_submit_date__c);
            System.debug('oppty.CloseDate : '+oppty.CloseDate);
              for(ProductWrapper pw : ProductWrapperList){
                   if(pw.IsSelected){
                       selectedSize++;
                       isSelectProduct = true;
                       if(pw.ProductIN.Opportunity_Type__c =='Credit'){
                            CreditProductList.add(pw.ProductIN);
                           if(pw.ProductIN.Opportunity__c !=null){
                                LinkToOppMap.Put(pw.ProductIN.id,pw.ProductIN.Opportunity__c);
                           }else{
                               if(NewCreditOpptyName==null){
                                   NewCreditOpptyName = pw.ProductIN.Product__r.Name;
                               }
                               isCreateNewCreditOpp =true;
                           }
                           
                        }else if(pw.ProductIN.Opportunity_Type__c =='Non-Credit'){
                             NonCreditProductList.add(pw.ProductIN);
                            
                            if(pw.ProductIN.Opportunity__c !=null){
                                LinkToOppMap.Put(pw.ProductIN.id,pw.ProductIN.Opportunity__c);
                           }else{
                               isCreateNewNonCreditOpp =true;
                           }
                        } 
                        Product2List.add(pw.ProductIn.Product__c);
                   }
                   
               }
          }

        
             Set<String> ValidStageOppty = new Set<String>();
             ValidStageOppty.add('Analysis');
             ValidStageOppty.add('Develop & Propose Solution');
             ValidStageOppty.add('Follow Up');
             if(LinkToOppMap.values().size()>0){
                 for(Opportunity opp : [SELECT ID,ownerID,StageName,CampaignID,Converted_Lead_ID__c from Opportunity WHERE ID IN: LinkToOppMap.values()]){
                   opp.Expected_submit_date__c = oppty.Expected_submit_date__c;
                   opp.CloseDate = oppty.CloseDate;
                   opp.Converted_Lead_ID__c = leadObj.id;

                     if(leadobj.Primary_Campaign__c !=null){
                             opp.CampaignId  = leadobj.Primary_Campaign__c;  
                           }
                     
                     if(ValidStageOppty.contains(opp.StageName)){
                         UpdateLinkToOppList.add(opp);
                     }else{
                         isValidOppStage =false;
                     }
                   
               }
             }
        
        
        if(!isSelectProduct &&isRequiredOpp){
            
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6012').Status_Message__c));
           return null;
        }else if(isRequiredOpp && !isValidOppStage){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6015').Status_Message__c));
           return null;
        }else if(oppty.Expected_submit_date__c < System.today() &&isRequiredOpp){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6022').Status_Message__c));
           return null;
        }else if(oppty.CloseDate < oppty.Expected_submit_date__c && isRequiredOpp){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6023').Status_Message__c));
           return null;
        }else if(selectedSize>20){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6017').Status_Message__c));
           return null;
        }
        else if(isDuplicatedbyAccount  
                 && !AccountPermissionSet.contains(leadobj.OwnerId)
                 &&(
                     leadobj.Exception_Flag__c ==false
                  ||
                    ( 
                        leadobj.Exception_Flag__c ==true
                        &&
                        (isCreateNewNonCreditOpp || isCreateNewCreditOpp || LinkToOppMap.size()>0) 
                    )
                    
                    )
                    
                ){
            leadobj.Interest_result__c = null;
            leadobj.Remark__c = null;
            update leadObj;
            isNeedtobeMember = true;
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,Status_Code__c.GetValues('6011').Status_Message__c));
           return null;            
        }else{
         try{
             if(isDuplicatedbyAccount){
                        update leadObj;
             }
                
                 Account acct;
                 Contact con;
                if(leadObj.RecordTypeId == CommercialLeadRecordType.id){
                    acct = LeadToAccount(leadObj);
                    acct.OwnerID = leadobj.OwnerID;
                    
                    insert acct;
                    
                    con =  LeadToContact(leadobj,acct.id);
                    
                    System.debug('con : '+con);
                                      
                }else{
                    
                    acct = [SELECT ID,Name from Account WHERE ID=:  leadObj.Account__c LIMIT 1];
                    List<Contact> ExistingConList = [SELECT Id, FirstName, LastName, AccountID, IsActive__c, Recordtype.Name
                                                    FROM Contact WHERE AccountID =: leadObj.Account__c];
                    boolean isMatched = false;
                    for(contact existingCon : ExistingConList){
                        if(existingCon.Recordtype.Name == 'Core bank' && !existingCon.IsActive__c) continue;
                        if(existingCon.FirstName == Leadobj.FirstName && existingCon.LastName == Leadobj.LastName){
                            isMatched = true;
                            con = existingCon;
                        }
                    }
                    
                    if(!isMatched){
                        con =  LeadToContact(leadobj,acct.id);
                        
                    }
                    
                    
                    
                    
                }


                 leadobj.Account__c = acct.id;
              //Issue Pre-screen automated : Jantanee comment
                //leadobj.Pre_screening_Result__c = 'Passed';
                leadobj.Contacted_Flag__c = true;
                leadobj.RecordTypeId = CompletedRecordType.id;
                //leadObj.Uninterested_Reason__c =null;
                update leadobj;

               
          //CONVERT PROCESS
          Database.LeadConvert lc = new database.LeadConvert();

            lc.setDoNotCreateOpportunity(false);                
            lc.setLeadId(leadObj.id);
            lc.setAccountId(acct.id);
            lc.setContactId(con.id);
             
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Database.LeadConvertResult lcr;

                
                //Generate Opportunity
           if(isRequiredOpp && isValidOppStage){
               
               if(UpdateLinkToOppList.size()>0){
                   update UpdateLinkToOppList;
               }
               
               
              
                Id recordIdSECreditProduct;
                Id recordIdSENonCreditProduct;
                Id recordIdWBGCreditProduct;
                Id recordIdWBGNonCreditProduct;
        
                for( RecordType eachRecordType : recordTypeList ){
                    
                    if( eachRecordType.Name == 'SE Credit Product' ){
                        recordIdSECreditProduct = eachRecordType.Id;
                    }else if( eachRecordType.Name == 'Non-credit Product' ){
                        recordIdSENonCreditProduct = eachRecordType.Id;
                        recordIdWBGNonCreditProduct = eachRecordType.Id;
                    }else if( eachRecordType.Name == 'WBG Credit Product' ){
                        recordIdWBGCreditProduct = eachRecordType.Id;
                    }
                  }
               
            lc.setConvertedStatus(convertStatus.MasterLabel);
                  
            lcr = Database.convertLead(lc);
          //CONVERT PROCESS


          //Query Temporary Opportunity
          stdConvertOppty =[SELECT ID,Branch_Referred__c,Other_Source__c,LeadSource,OwnerId,Converted_Lead_ID__c,CampaignId,CloseDate
                                                         ,Lead_Expect_Revenue__c,Referral_Staff_Name__c,Referral_Staff_ID__c,AccountId,Expected_submit_date__c
                                                        from Opportunity 
                                                        WHERE ID =: lcr.getOpportunityID()
                                                        LIMIT 1];
          
          /*********** CR Referral  *******************/
          if(leadObj.RTL_Referral__c != null){
              
            RTL_Referral__c referral = [SELECT Id,Name,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Stage__c,RTL_Type__c
                                      FROM RTL_Referral__c 
                                      WHERE ID=:leadObj.RTL_Referral__c LIMIT 1];

            System.debug('LEAD ::::: '+lcr.getAccountID());
            referral.RTL_Account_Name__c = lcr.getAccountID();

            //CH01:CR Refer within Commercial 9 May 2018 , do not auto update referral status to Closed(Interested) for Type = To Product Team
            if(referral.RTL_Stage__c != 'Closed (Interested)' && referral.RTL_Type__c != 'To Product Team (เพื่อส่งให้ทีม Product)'){
                referral.RTL_Stage__c = 'Closed (Interested)';
            }
               
            update referral;        
          }
            System.Debug('leadObj.FNA_Activity__c ' + leadObj.FNA_Activity__c ); 
            if(leadObj.FNA_Activity__c != null){
                FNA_activity__c fna = new FNA_activity__c();
                fna.id = leadObj.FNA_Activity__c;
                fna.Customer__c = lcr.getAccountID();
                update fna;

                List<Account> account = [SELECT Id, RecordTypeId, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c,
                            Fna_Product_Holding__c, Fna_Product_Interested__c FROM Account WHERE Id =:lcr.getAccountID()];
                System.Debug('account' + account ); 
                if(account.size() > 0){
                    System.Debug('Fna_Avatar_Name__c afterUpdate' + leadObj.Fna_Avatar_Name__c ); 
                    System.Debug('Fna_Avatar_Url__c afterUpdate' + leadObj.Fna_Avatar_Url__c ); 
                    System.Debug('Fna_Create_Date__c afterUpdate' + leadObj.Fna_Create_Date__c ); 
                    System.Debug('Fna_Have_Referral__c afterUpdate' + leadObj.Fna_Have_Referral__c ); 
                    System.Debug('Fna_Product_Holding__c afterUpdate' + leadObj.Fna_Product_Holding__c ); 
                    System.Debug('Fna_Product_Interested__c afterUpdate' + leadObj.Fna_Product_Interested__c ); 

                    if(account[0].Fna_Avatar_Name__c == null || account[0].Fna_Avatar_Name__c == ''){
                        if(leadObj.Fna_Avatar_Name__c != null){
                            account[0].Fna_Avatar_Name__c = leadObj.Fna_Avatar_Name__c; //Avatar Name
                        }
                    }

                    if(account[0].Fna_Avatar_Url__c == null || account[0].Fna_Avatar_Url__c == ''){
                        if(leadObj.Fna_Avatar_Url__c != null){
                            account[0].Fna_Avatar_Url__c = leadObj.Fna_Avatar_Url__c; //URL Avatar Image
                        }
                    }

                    if(account[0].Fna_Create_Date__c == null ){
                        if(leadObj.Fna_Create_Date__c != null){
                            account[0].Fna_Create_Date__c = leadObj.Fna_Create_Date__c; //FNA Create date
                        }
                    }

                    account[0].Fna_Have_Referral__c = leadObj.Fna_Have_Referral__c; //FNA Have Referral

                    if(account[0].Fna_Product_Holding__c == null || account[0].Fna_Product_Holding__c == ''){
                        if(leadObj.Fna_Product_Holding__c != null){
                            account[0].Fna_Product_Holding__c = leadObj.Fna_Product_Holding__c; //FNA Product Holding
                        }
                    }
                    if(account[0].Fna_Product_Interested__c == null || account[0].Fna_Product_Interested__c == ''){
                        if(leadObj.Fna_Product_Interested__c != null){
                            account[0].Fna_Product_Interested__c = leadObj.Fna_Product_Interested__c; //FNA Interested Product
                        }
                    }

                    update account;
                }
            }
          
                           
              //Get 2 values from Screen//
              stdConvertOppty.CloseDate = oppty.CloseDate;

              System.debug('stdConvertOppty.CloseDate::'+stdConvertOppty.CloseDate);
              System.debug('stdConvertOppty.CloseDate Year::'+stdConvertOppty.CloseDate.year());
              
              stdConvertOppty.Expected_submit_date__c = oppty.Expected_submit_date__c;
               
                stdConvertOppty.StageName = 'Analysis';
               if(leadobj.Primary_Campaign__c !=null){
                 stdConvertOppty.CampaignId  = leadobj.Primary_Campaign__c;  
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
               
               /*********** CR Referral  *******************/
               stdConvertOppty.RTL_Referral__c = leadobj.RTL_Referral__c;
              

               
               //Get PricebookEntry
                   // Mapping Product with PricebookEntry ID
                   
                   Map<ID,pricebookentry> ProductWithPEMap = new  Map<ID,pricebookentry>();
               
                   for(pricebookentry Pe : [select id,product2id,pricebook2id from pricebookentry 
                                                    where 
                                                 product2id IN:Product2List
                                               AND pricebook2id =: PricebookAccess]){
                          ProductWithPEMap.put(Pe.Product2Id,Pe);            
                                                   
                   }
               
               //
                                //Query VisitPlan for Create Visit Report Opportunities
                               List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c
                                                 FROM Call_report__c 
                                                 WHERE Lead__c =: leadobj.id];
               
              
               
               
               
               //
               List<opportunityLineitem> CreditOpplineInsertList = new List<opportunityLineitem>();
               //Credit Opportunity 1:N
               //
               //
               
               if(CreditProductList.size()>0){
                    List< Visit_Report_Opportunity__c > newVisitOppTyList = new List<Visit_Report_Opportunity__c>();
                   //Link VisitPlan Oppty
                   for(Call_Report__c visitplan : VisitPlanList){
                       Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
                       visitopp.Customer__c  = visitplan.id;
                       newVisitOppTyList.add(visitopp);
                   }
                   
                   
                   //Set Name
                   String OppName = Acct.Name+' : '+NewCreditOpptyName;
                    stdConvertOppty.Name = OppName.left(180);

                    //Add Remark to Oppty 
                    // System.debug(leadObj.Remark__c);
                    // System.debug('leadObj.Remark__c');
                    stdConvertOppty.Remark__c = leadObj.Remark__c;
                    
                    
                    
                   //Set RecordType following Segment
                   /********** change condition following BAU Issue 2017-06-26 *****************
                   if(leadobj.Owner_Segment__c =='SE'){
                       stdConvertOppty.RecordTypeId = recordIdSECreditProduct;
                   }else{
                        stdConvertOppty.RecordTypeId = recordIdWBGCreditProduct;
                   }
                   */
                   Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.Opportunity;    
                   List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
                   for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                       if(rtInfo.isDefaultRecordTypeMapping()) {               
                           stdConvertOppty.RecordTypeId = rtInfo.getRecordTypeId();
                       }
                   }
                   
                   
                   
                   // Insert Oppty before references to Oppline
                   if(isCreateNewCreditOpp){
                       for(Visit_Report_Opportunity__c visitopp : newVisitOppTyList){
                           //visitopp.Opportunity__c = oppty.id;
                           visitopp.Opportunity__c = stdConvertOppty.id;
                       }
                       insert newVisitOppTyList;
                   }
                   

                   //Create oppline
                   Id pricebookEntryID;
                   for(Product_Interest__c PI : CreditProductList){
                       opportunityLineitem oppLine = new opportunityLineitem();
                       
                       if(ProductWithPEMap.containsKey(Pi.Product__c)){
                           oppLine.PricebookEntryId = ProductWithPEMap.get(Pi.Product__c).id;
                           pricebookEntryID = ProductWithPEMap.get(Pi.Product__c).id;
                       }
                        oppLine.Quantity = 1;
                        Oppline.Expected_Revenue__c = pi.amount__c==null?0:pi.amount__c;
                        oppLine.UnitPrice = 0;
                        //oppline.TotalPrice = pi.amount__c==null?0:pi.amount__c;

                       // ************** CR Modify Opportunity Template ************** //
                       map<integer,string> mapMonth = new map<integer,string>();
                       mapMonth.put(1,'Jan');
                       mapMonth.put(2,'Feb');
                       mapMonth.put(3,'Mar');
                       mapMonth.put(4,'Apr');
                       mapMonth.put(5,'May');
                       mapMonth.put(6,'Jun');
                       mapMonth.put(7,'Jul');
                       mapMonth.put(8,'Aug');
                       mapMonth.put(9,'Sep');
                       mapMonth.put(10,'Oct');
                       mapMonth.put(11,'Nov');
                       mapMonth.put(12,'Dec');
                       
                       oppLine.RevisedStartMonth__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                       oppLine.RevisedStartMonthFee__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                       //*********** Becuase CloseDate.year() = B.E. **********/
                       if(Userinfo.getLocale() == 'th_TH'){
                        oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                        oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                        System.debug('getLocale :: th_TH');
                       }else{
                       oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year());
                       oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year());
                       System.debug('getLocale :: else');
                    }

                    System.debug('oppLine.RevisedStartYear__c ::'+oppLine.RevisedStartYear__c);
                    System.debug('oppLine.RevisedStartYearFee__c ::'+oppLine.RevisedStartYearFee__c);
                       oppLine.Frequency__c = 'Monthly';
                       oppLine.FrequencyFee__c = 'Monthly';
                       // ************** CR Modify Opportunity Template ************** //
                                              
                       CreditOpplineInsertList.add(oppline);
                       PI.status__c = 'Opp Created';
                       
                       if(LinkToOppMap.containsKey(PI.id)){
                            PI.Opportunity__c = LinkToOppMap.get(PI.id);
                            oppline.OpportunityId = LinkToOppMap.get(PI.id);
                       }else{
                           // PI.Opportunity__c = oppty.id;
                            oppline.OpportunityId =stdConvertOppty.id;
                            PI.Opportunity__c = stdConvertOppty.id;
                            oppline.OpportunityId =stdConvertOppty.id;
                       }
                       
                   }
                   
                   

               }


               
               
               update stdConvertOppty;
               
                //Create Opp  1:1
                List<opportunityLineitem> NonCreditOpplineInsertList = new List<opportunityLineitem>();
               List<Opportunity> NonCreditOpptyInsertList = new List<Opportunity>();

               
              
               if(NonCreditProductList.size()>0){
                      
                     List< Visit_Report_Opportunity__c > newVisitOppTyList = new List<Visit_Report_Opportunity__c>();
                
                   
                   
                    Integer countOpptyIndex =1;
                    for(Product_Interest__c PI : NonCreditProductList){
                       //SetOppty
                        if(!LinkToOppMap.containsKey(PI.ID)){
                            Opportunity eachopp;
                           if(countOpptyIndex==1 && !isCreateNewCreditOpp){
                              eachopp = new Opportunity(id=stdConvertOppty.id);
                            }else{
                               eachopp = new Opportunity();
                            }
                            countOpptyIndex++;
                               
                           //eachopp.CloseDate = oppty.CloseDate;
                           eachopp.CloseDate = stdConvertOppty.CloseDate;
                           eachopp.StageName = 'Analysis';
                           eachopp.Converted_Lead_ID__c = leadobj.id;
                            if(leadobj.Primary_Campaign__c !=null){
                             eachOpp.CampaignId  = leadobj.Primary_Campaign__c;  
                           }

                           eachopp.AccountId = acct.id;
                           eachopp.Lead_Expect_Revenue__c  = leadobj.Total_Expected_Revenue__c;
                           eachopp.LeadSource = leadobj.LeadSource;
                           eachopp.Other_Source__c = leadobj.Other_Source__c;
                           eachopp.Branch_Referred__c = leadobj.Branch_Referred__c;
                           eachopp.Referral_Staff_ID__c = leadobj.Referral_Staff_ID__c;
                           eachopp.Referral_Staff_Name__c = leadobj.Referral_Staff_Name__c;
                           //eachopp.Expected_submit_date__c = oppty.Expected_submit_date__c;
                           eachopp.Expected_submit_date__c = stdConvertOppty.Expected_submit_date__c;
                           eachOpp.OwnerID = leadobj.OwnerID;
                           eachOpp.AccountId = acct.id;
                           
                           /*********** CR Referral  *******************/
                           eachOpp.RTL_Referral__c = leadobj.RTL_Referral__c;
                            
                            if(Test.isRunningTest()){
                                eachOpp.Pricebook2Id = [SELECT ID,Name from Pricebook2 WHERE Name ='Commercial Pricebook' LIMIT 1 ].ID;
                            }
                            
                            
                            if(leadobj.Owner_Segment__c =='SE'){
                                eachOpp.RecordTypeId = recordIdSENonCreditProduct;
                           }else{
                                eachOpp.RecordTypeId = recordIdWBGNonCreditProduct;
                           }
                           //String OppName = Acct.Name+' : '+PI.Product__r.Name;
                           //eachOpp.Name = OppName.left(180);
                           eachOpp.Name = PI.Product__c;
                           NonCreditOpptyInsertList.add(eachOpp); 
                        }
                   }
                   
                   //CR Link to Opportunity Lead
                   //
                   
                   
                   upsert NonCreditOpptyInsertList;
                   
                   if(NonCreditOpptyInsertList.size()>0){
                       //get First Non-credit Oppty
                       Opportunity NonCreditOpp = NonCreditOpptyInsertList.get(0);
                       ConvertedOpportunityID = NonCreditOpp.id;
                   }
                   //
                   //CR link to Opportunity Lead
                   
                   Map<String,Opportunity> ProductIDwithOppMap = new Map<String,Opportunity>();
                   for(Opportunity oppty : NonCreditOpptyInsertList){
                       ProductIDwithOppMap.put(oppty.Name,Oppty);
                        //Link Visit Oppty
                        for(Call_Report__c visitplan : VisitPlanList){
                               Visit_Report_Opportunity__c visitopp = new Visit_Report_Opportunity__c();
                               visitopp.Customer__c  = visitplan.id;
                               visitopp.Opportunity__c = oppty.id;
                               newVisitOppTyList.add(visitopp);
                           }
                    }
                                                                       
                   insert newVisitOppTyList;
                   for(Product_Interest__c PInterest : NonCreditProductList){
                    //SetOppLine
                       opportunityLineitem oppLine = new opportunityLineitem();
                       if(ProductWithPEMap.containsKey(PInterest.Product__c)){
                           oppLine.PricebookEntryId = ProductWithPEMap.get(PInterest.Product__c).id;
                       }
                        oppLine.Quantity = 1;
                        oppline.Expected_Revenue__c = PInterest.amount__c==null?0:PInterest.amount__c;
                        oppLine.UnitPrice = 0;
                       // oppLine.TotalPrice= PInterest.amount__c==null?0:PInterest.amount__c;
                       if(LinktoOppMap.containsKey(PInterest.id)){
                           oppline.OpportunityId = LinktoOppMap.get(PInterest.id);
                           PInterest.Opportunity__c = LinktoOppMap.get(PInterest.id);
                       }else{
                            oppline.OpportunityId = ProductIDwithOppMap.get(PInterest.Product__c).id;
                            PInterest.Opportunity__c = ProductIDwithOppMap.get(PInterest.Product__c).id;
                               
                              Opportunity oppty = ProductIDwithOppMap.get(PInterest.Product__c);
                              String OppName = Acct.Name+' : '+PInterest.Product__r.Name;
                              oppty.Name = OppName.left(180);
                       }
                        PInterest.status__c = 'Opp Created';
                       
                      // 
                      // 
                      // 

                      // ************** CR Modify Opportunity Template ************** //
                       map<integer,string> mapMonth = new map<integer,string>();
                       mapMonth.put(1,'Jan');
                       mapMonth.put(2,'Feb');
                       mapMonth.put(3,'Mar');
                       mapMonth.put(4,'Apr');
                       mapMonth.put(5,'May');
                       mapMonth.put(6,'Jun');
                       mapMonth.put(7,'Jul');
                       mapMonth.put(8,'Aug');
                       mapMonth.put(9,'Sep');
                       mapMonth.put(10,'Oct');
                       mapMonth.put(11,'Nov');
                       mapMonth.put(12,'Dec');
                       
                       oppLine.RevisedStartMonth__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                       oppLine.RevisedStartMonthFee__c = mapMonth.get(stdConvertOppty.CloseDate.month());
                       if(Userinfo.getLocale() == 'th_TH'){
                        oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                        oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year()-543);
                        System.debug('getLocale :: th_TH');
                       }else{
                       oppLine.RevisedStartYear__c = string.valueof(stdConvertOppty.CloseDate.year());
                       oppLine.RevisedStartYearFee__c = string.valueof(stdConvertOppty.CloseDate.year());
                       System.debug('getLocale :: else');
                    }
                       oppLine.Frequency__c = 'Monthly';
                       oppLine.FrequencyFee__c = 'Monthly';
                       // ************** CR Modify Opportunity Template ************** //
                                             
                      NonCreditOpplineInsertList.add(oppLine);
                   }
                }
               
              
               
               
               
               
               
               //DML Oprations
               //
               

               if(CreditOpplineInsertList.size()>0){
                   insert CreditOpplineInsertList;
                   update CreditProductList;
               }
               
               
               if(NonCreditProductList.size() >0){
                   update NonCreditOpptyInsertList;
                   insert NonCreditOpplineInsertList;
                   update NonCreditProductList;
               }
               
               
               
                  
            
           
           }else{
               lc.setDoNotCreateOpportunity(true);
               lc.setConvertedStatus(convertStatus.MasterLabel);
               isOppNotCreated = true;
               lcr = Database.convertLead(lc);
              //CONVERT PROCESS
              //
              /*********** CR Referral  *******************/
                if(leadObj.RTL_Referral__c != null){
              
                    RTL_Referral__c referral = [SELECT Id,Name,RTL_EmployeeId__c,RTL_Employee_Name__c,RTL_Stage__c
                                                FROM RTL_Referral__c 
                                                WHERE ID=:leadObj.RTL_Referral__c LIMIT 1];

                    System.debug('LEAD ::::: '+lcr.getAccountID());
                    referral.RTL_Account_Name__c = lcr.getAccountID();
                    referral.RTL_Stage__c = 'In progress_Contacted';
                    update referral;        
                }

                System.debug('FNA ::::: '+ leadObj.FNA_Activity__c);
                if(leadObj.FNA_Activity__c != null){
                    FNA_activity__c fna = new FNA_activity__c();
                    fna.id = leadObj.FNA_Activity__c;
                    fna.Customer__c = lcr.getAccountID();
                    update fna;

                    List<Account> account = [SELECT Id, RecordTypeId, Fna_Avatar_Name__c, Fna_Avatar_Url__c, Fna_Create_Date__c, Fna_Have_Referral__c,
                            Fna_Product_Holding__c, Fna_Product_Interested__c FROM Account WHERE Id =:lcr.getAccountID()];
                     System.debug('FNA account::::: '+ account);
                    if(account.size() > 0){
                        System.Debug('Fna_Avatar_Name__c afterUpdate' + leadObj.Fna_Avatar_Name__c ); 
                        System.Debug('Fna_Avatar_Url__c afterUpdate' + leadObj.Fna_Avatar_Url__c ); 
                        System.Debug('Fna_Create_Date__c afterUpdate' + leadObj.Fna_Create_Date__c ); 
                        System.Debug('Fna_Have_Referral__c afterUpdate' + leadObj.Fna_Have_Referral__c ); 
                        System.Debug('Fna_Product_Holding__c afterUpdate' + leadObj.Fna_Product_Holding__c ); 
                        System.Debug('Fna_Product_Interested__c afterUpdate' + leadObj.Fna_Product_Interested__c ); 
                        if(account[0].Fna_Avatar_Name__c == null || account[0].Fna_Avatar_Name__c == ''){
                            if(leadObj.Fna_Avatar_Name__c != null){
                                account[0].Fna_Avatar_Name__c = leadObj.Fna_Avatar_Name__c; //Avatar Name
                            }
                        }

                        if(account[0].Fna_Avatar_Url__c == null || account[0].Fna_Avatar_Url__c == ''){
                            if(leadObj.Fna_Avatar_Url__c != null){
                                account[0].Fna_Avatar_Url__c = leadObj.Fna_Avatar_Url__c; //URL Avatar Image
                            }
                        }

                        if(account[0].Fna_Create_Date__c == null ){
                            if(leadObj.Fna_Create_Date__c != null){
                                account[0].Fna_Create_Date__c = leadObj.Fna_Create_Date__c; //FNA Create date
                            }
                        }

                        account[0].Fna_Have_Referral__c = leadObj.Fna_Have_Referral__c; //FNA Have Referral

                        if(account[0].Fna_Product_Holding__c == null || account[0].Fna_Product_Holding__c == ''){
                            if(leadObj.Fna_Product_Holding__c != null){
                                account[0].Fna_Product_Holding__c = leadObj.Fna_Product_Holding__c; //FNA Product Holding
                            }
                        }
                        if(account[0].Fna_Product_Interested__c == null || account[0].Fna_Product_Interested__c == ''){
                            if(leadObj.Fna_Product_Interested__c != null){
                                account[0].Fna_Product_Interested__c = leadObj.Fna_Product_Interested__c; //FNA Interested Product
                            }
                        }

                        update account;
                    }
                }
                
                for(Product_Interest__c PI : ProductList){
                    PI.Status__c  = 'Opp Not Created';
                    
                }
                
                update ProductList;
            } 

             
               
               
               
                
                
                List<Call_Report__c> VisitPlanList = [SELECT ID,Customer_Name__c,Lead__c
                                                 FROM Call_report__c 
                                                 WHERE Lead__c =: leadobj.id];
                for(Call_report__c visit : VisitPlanList){
                    visit.Customer_name__c = leadobj.Account__c;
                }
                
                update VisitPlanList;


                if(isFromSurvey){
                 surveyobj.Customer__c = lcr.getAccountId();
                surveyobj.RecordTypeId = CompletedSurvey.id;

                update surveyobj;
                toggleScript = true;
                isneedBackToLead = false;
             }
                
            System.debug('Convert Success');
            if(lcr.isSuccess()){
                String theme = UserInfo.getUIThemeDisplayed();
                PageReference accpage;
                if(theme == 'Theme4t'){
                    System.debug('Mobile Redirect');
                    // Account accOb = [SELECT Id FROM Account WHERE Id =: leadobj.Account__c];
                    // accpage = new PageReference('/'+accOb.id);
                    // accpage.setRedirect(true);
                    // return accpage;
                    return null;
                }else{
                    //return cancel();
                    System.debug('Redirect to Customer');
                    Account accOb = [SELECT Id FROM Account WHERE Id =: leadobj.Account__c];
                    accpage = new ApexPages.StandardController(accOb).view();
                    accpage.setRedirect(true);
                    return accpage;
                }


            }else{
                Database.rollback(sp);
                System.debug(lcr.getErrors()+'');
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,lcr.getErrors()+'' )); 
                 return null;
            }

            }catch(Exception ex){
                Database.rollback(sp);
                   
                    System.debug('line : '+ex.getLineNumber());
                    System.debug('errormessage : '+ex.getMessage());
                
                //System.debug(ex.getMessage());
                
                 //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
                 return null;
            }
        }
        
        
        
        
    }
    
    public void interestAction(){
        //Fixed: 2018Jan
        string valInterestResult = apexpages.currentPage().getParameters().get('inpInterestResult');
        system.debug('val InterestResult ==== '+valInterestResult);
        leadobj.Interest_result__c = valInterestResult;
        
        if(leadobj.Interest_result__c =='No'){
            if(leadobj.Lead_Segment__c == 'SE')
            {
                leadobj.Unqualified_Action__c = 'For SE Not Interested';
            }
            else
            {
                leadobj.Unqualified_Action__c = 'For Not Interested';
            }
            leadobj.Unqualified_Reasons__c = null;
            isNotInterest = true;
        }else{
            leadobj.Unqualified_Action__c = null;
            leadobj.Unqualified_Reasons__c = null;
            isNotInterest = false;
        }
    }
    
    public void confirmContacted(){
        isNeedtoConfirmContacted = false;
        isConfirmAnyway = true;
    }
    
    public Contact LeadToContact(Lead leadrecord,ID AccountID){
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
        //fix issues 23/08/2016
        con.Account__c = AccountID;
        //fix issues 23/08/2016
        con.C_Country_PE__c = 'Thailand';
        insert con;
        
        return con;
        
        
    }
    
 
    
    
    public Account LeadToAccount(Lead Leadrecord){
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
                //(Lead)Email__c = Email_Address_PE__c (Account) 
            //(Lead)Parent_Company__c = Parent (Account)
            acct.ParentId = leadobj.Parent_Company__c;
                acct.Email_Address_PE__c = Leadobj.Email__c;
                       
        return acct;
        
        
    }
    
   
    
    public PageReference cancel(){
        
          PageReference leadpage;

          System.debug('isFromSurvey : '+isFromSurvey);
          System.debug('toggleScript : '+toggleScript);
          System.debug('launchNextPage :'+launchNextPage);
          System.debug('isneedBackToLead :'+isneedBackToLead);

          if(isFromSurvey && !toggleScript && !launchNextPage && !isneedBackToLead ){
            leadpage = new ApexPages.StandardController(surveyobj).view();

          }else{
            leadpage = new ApexPages.StandardController(leadObj).view();
          }

           
        leadpage.setRedirect(true);
        return leadpage;
        
    }
    
    public class ProductWrapper {
        public Product_Interest__c productIn {get;set;}
        public boolean isSelected {get;set;}
      
    }

}