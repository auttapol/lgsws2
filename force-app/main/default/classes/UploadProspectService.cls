@RestResource(urlMapping='/UploadProspectService/v1/*')
global  without sharing  class UploadProspectService {
    @HttpPost
    global static UploadProspect[]  Upload(UploadProspect[] prospects) {            
        // Call check duplicate here
        List<DisqualifiedProcessBuilder.ProspectWrapperSOAP> prospectList = new List<DisqualifiedProcessBuilder.ProspectWrapperSOAP>();
        Set<String> employeeIDSet = new Set<String>();
        set<String> branchCodeSet = new Set<String>();
        List<UploadProspect> Uploadresult = new List<UploadProspect>();
        Map<Integer,UploadProspect> prospectMap = new Map<Integer,UploadProspect>();
        
        for(UploadProspect item :prospects ){   
            employeeIDSet.add(item.OwnerEmployeeID);
            prospectMap.put(Integer.valueof(item.Row),item);
            
            if(item.BranchReferredBranchCode !=null && item.BranchReferredBranchCode !='' && item.BranchReferredBranchCode!='null'){
                branchCodeSet.add(item.BranchReferredBranchCode);
            }
           
        }
        List<User> ownerList = [SELECT ID,Name,Employee_ID__c FROM User WHERE Employee_ID__c  IN:employeeIDSet];
        List<Branch_and_Zone__c> branchList = [SELECT ID,Name,Branch_code__c, Branch_Name__c  FROM Branch_and_Zone__c
                                              WHERE Branch_code__c IN:branchCodeSet];
		Map<String,User> employeeIdMap = new Map<String,User>();
        for(User us : ownerList){
            employeeIdMap.put(us.Employee_ID__c,us);
           
        }
        Map<String,ID> branchAndZoneMap = new Map<String,ID>();
        for(Branch_and_Zone__c bz : branchList){
            branchAndZoneMap.put(bz.Branch_code__c,bz.id);
        }
        for(UploadProspect item : prospects){
			Account acct  = new Account();
            
            
            

            
            
            //
			acct.Name = item.Name==null?'':Item.Name;
            acct.Customer_Type__c  = item.CustomerType==null?'':item.CustomerType;
            acct.Customer_Name_PE_Eng__c = item.CustomerNamePEEng==null?'':item.CustomerNamePEEng;
			acct.First_Name_ENG_PE__c = item.FirstNameENGPE==null?'':item.FirstNameENGPE;
            acct.Last_Name_PE_Eng__c = item.LastNamePEEng==null?'':item.LastNamePEEng;
            if(item.IDTypePE !=null&& item.IDTypePE !=''){
             	if(item.IDTypePE.tolowerCase() =='work permit id'){
               		acct.ID_Type_PE__c = 'Work permit ID';
                }else{
                    acct.ID_Type_PE__c = item.IDTypePE==null?'':item.IDTypePE;
                }
                
            }else{
                acct.ID_Type_PE__c = null;
            }
            acct.ID_Number_PE__c = item.IDNumberPE==null?'':item.IDNumberPE;
            acct.OwnerId = employeeIdMap.get(item.OwnerEmployeeID).id;
            acct.TMB_Employee_ID__c = item.TMBEmployeeID;
            acct.TMB_Employee_Name__c = item.TMBEmployeeName;
			acct.Industry = 	item.Industry;   
            acct.Business_Type__c =     item.BusinessType;        
            acct.Nationality__c =    item.Nationality;                        
            acct.No_of_years_business_run__c =  item.Noofyearsbusinessrun=='' ? null : decimal.valueOf(item.Noofyearsbusinessrun);      
            acct.Sales_amount_per_year__c = item.Salesamountperyear=='' ? null : decimal.valueOf(item.Salesamountperyear);  //   decimal.valueof(item.Salesamountperyear);             
            acct.Customer_Age__c =  item.CustomerAge=='' ? null : decimal.valueOf(item.CustomerAge); //decimal.valueof(item.CustomerAge);
            acct.Product_Group_1__c =   item.ProductGroup1;                   
            acct.Amount_1__c =   item.Amount1=='' ? null : decimal.valueOf(item.Amount1); //decimal.valueof( item.Amount1);               
            acct.Product_Group_2__c =    item.ProductGroup2;                 
            acct.Amount_2__c =     item.Amount2=='' ? null : decimal.valueOf(item.Amount2);  //decimal.valueof(item.Amount2);                           
            acct.Product_Group_3__c =   item.ProductGroup3;   
            acct.Amount_3__c =    item.Amount3=='' ? null : decimal.valueOf(item.Amount3); //decimal.valueof(item.Amount3);                     
            acct.Channel__c =    item.Channel;                       
            acct.Other_Channel__c =    item.OtherChannel;                     
            //acct.Branch_Referred__c =    item.BranchReferredBranchCode;     // if blank set to null
            if(item.BranchReferredBranchCode !=null && item.BranchReferredBranchCode !='' && item.BranchReferredBranchCode!='null'){
                if(branchAndZoneMap.containsKey(item.BranchReferredBranchCode)){
                    acct.Branch_Referred__c  =  branchAndZoneMap.get(item.BranchReferredBranchCode);
                }
            }else{
                 acct.Branch_Referred__c  =null;
            }
            acct.Campaign_ID__c =    item.CampaignID;   
            acct.Primary_Address_Line_1_PE__c = item.PrimaryAddressLine1PE;
            acct.Primary_Address_Line_2_PE__c =    item.PrimaryAddressLine2PE;
            acct.Primary_Address_Line_3_PE__c =    item.PrimaryAddressLine3PE; 
            acct.Province_Primary_PE__c =   item.ProvincePrimaryPE;
            acct.Zip_Code_Primary_PE__c =    item.ZipCodePrimaryPE;          
            acct.Country_Primary_PE__c =    item.CountryPrimaryPE;             
            acct.Mobile_Number_PE__c =     item.MobileNumberPE;
            acct.Phone =     item.Phone;                           
            acct.Fax =     item.Fax;                            
            acct.Email_Address_PE__c =    item.EmailAddressPE;              
            acct.Rating =     item.Rating;                      
            acct.Remark__c =    item.Remark;                      
            acct.ID_populated__c =  (item.IDpopulated == null) ?  false :  boolean.valueof(item.IDpopulated);                  
            acct.RecordTypeId =    item.RecordTypeId;
            

            
            
            
            
            
            
            
            
            //Temp row Index to CRM_ID__c  field
            //
            acct.CRM_ID__c = item.row;
            //
            //
            DisqualifiedProcessBuilder.ProspectWrapperSOAP wrapperSOAP = new DisqualifiedProcessBuilder.ProspectWrapperSOAP();
            wrapperSOAP.prospect = acct;
            wrapperSOAP.index = Integer.valueOf(item.Row);
            
            prospectList.add(wrapperSOAP);
        }
        
        
        List<Account> passCheckDup = new List<account>();
        Map<Integer,Integer> rowandIndexMap = new Map<Integer,Integer>();
        Integer row = 0;
        for(DisqualifiedProcessBuilder.ProspectWrapperSOAP wrapperSOAP : DisqualifiedProcessBuilder.CheckDisqualifiedSOAP(prospectList)){
            System.debug(wrapperSOAP.isfoundDuplicate);
            System.debug(wrapperSOAP.ErrorMessage);
            System.debug(wrapperSOAP.index);
            System.debug(wrapperSOAP.Prospect.CRM_ID__c);
            if(!wrapperSOAP.isfoundDuplicate){
                    //Temp row Index to CRM_ID__c  field
                    //
                    wrapperSOAP.prospect.CRM_ID__c = null;
                    //
                    //
                passCheckDup.add(wrapperSOAP.prospect);
                rowandIndexMap.put(row,wrapperSOAP.index);
                row++;
            }else{
                
                UploadProspect item = prospectMap.get(wrapperSOAP.index);
                item.Success = 'false';
        		item.Created = 'false';
                item.Error = 'Disqualified Prospect';
                item.ErrorMessage =wrapperSOAP.ErrorMessage;
                Uploadresult.add(item);
            }
            
        }
        
        
            Database.SaveResult[] srList = Database.insert(passCheckDup, false);//Database method to insert the records in List

            Integer databaseRow =0;
            for (Database.SaveResult sr : srList) {
                
                System.debug('row : '+databaseRow);
                System.debug('result : '+sr.isSuccess());
                
                UploadProspect item =	prospectMap.get(rowandIndexMap.get(databaseRow));
                if (sr.isSuccess()) {

                    item.id = sr.getID();
                    item.Success = 'true';
                    item.Created = 'true';
                    item.Error = null;
                    item.ErrorMessage =null;
                    
                }
                else {
                   	item.id = null;
                        item.Success = 'false';
                        item.Created = 'false';
                    String ErrorField = '';
                    String ErrorMessage = '';
                    for(Database.Error objErr : sr.getErrors()) {
                       
                        ErrorField += objErr.getFields()+'';
                        ErrorMessage+= objErr.getMessage()+'';
                    }
                       item.Error = ErrorField;
                       item.ErrorMessage = ErrorMessage;
                }
                    
                Uploadresult.add(item);
                    databaseRow++;
            }
            
        
        
        
        /************************
            * IF success record let set this
            * ***********************
            Id = id
            Success= "true" or "false"
            Created =  "true" or "false"
            Error  =  "true" or "false"         
            * **********************/
        //Return Back to .NET        
        return Uploadresult;
    }
    
    
    
}