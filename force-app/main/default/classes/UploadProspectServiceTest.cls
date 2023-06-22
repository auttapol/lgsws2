@isTest
public class UploadProspectServiceTest {

    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
         List<Status_Code__C> statusList = new List<Status_Code__C>();
         Status_Code__c error61 = new Status_Code__c();
        error61.isError__c = false;
        error61.Name = '6001';
        error61.Status_Message__c = 'Prospect Duplicate in the system'; 
         Status_Code__c error62 = new Status_Code__c();
        error62.isError__c = false;
        error62.Name = '6002';
        error62.Status_Message__c = 'Prospect name is Duplicate in the system'; 
        statusList.add(error61);
        statusList.add(error62);
        
        insert statusList;
    }

    public static testmethod void TestCreateProspectPositive(){
        List<UploadProspect> uploadProspectList = new List<UploadProspect>();
        User us = TestUtils.createUsers(1,'Upload','Prospect','canvas@tmbbank.com',true).get(0);
        Id RecordTypeID = [SELECT ID,Name, SobjectType FROM RecordType 
                           WHERE Name ='Prospect' AND sObjectType ='Account' LIMIT 1].get(0).id;
        system.runAs(us){
        for(Integer i=1;i<5;i++){
           UploadProspect prospect = new UploadProspect();
           prospect.row = i+'';
           prospect.CustomerType = 'Individual';
           prospect.TMBEmployeeID = us.Employee_ID__c;
           prospect.TMBEmployeeName = us.Name;
           prospect.OwnerEmployeeID = us.Employee_ID__c;
           prospect.Name ='Upload Prospect '+i;
            prospect.Industry   ='Test';   
            Prospect.BusinessType   ='Test';        
            Prospect.Nationality     ='Test';                        
            Prospect.Noofyearsbusinessrun       ='5';      
            Prospect.Salesamountperyear       ='100000000000';             
            Prospect.CustomerAge                  ='53';               
            Prospect.ProductGroup1                ='Test';                   
            Prospect.Amount1                      ='500';               
            Prospect.ProductGroup2                 ='Test';                 
            Prospect.Amount2                        ='1000';                           
            Prospect.ProductGroup3                 ='Test';   
            Prospect.Amount3                        ='1000';                     
            Prospect.Channel                      ='Test';                       
            Prospect.OtherChannel                  ='Test';                     
            //Prospect.BranchReferredBranchCode        ='Test';     
            //Prospect.CampaignID                     ='Test';     
            
                prospect.TMBEmployeeID = 'test';           
                prospect.TMBEmployeeName = 'test';         
                prospect.PrimaryAddressLine1PE = 'test';
                prospect.PrimaryAddressLine2PE = 'test';
                prospect.PrimaryAddressLine3PE = 'test'; 
                prospect.ProvincePrimaryPE  = 'test';
                prospect.ZipCodePrimaryPE   = 'test';          
                prospect.CountryPrimaryPE    = 'test';             
                prospect.MobileNumberPE   = '053532198';
                prospect.Phone          = '053532198';                           
                prospect.Fax             = '053532198';                            
                prospect.EmailAddressPE   = 'test@canvas.com';              
                prospect.Rating   = 'test';                      
                prospect.Remark   = 'test';                      
                prospect.IDpopulated  = 'false';                  
                prospect.RecordTypeId    =RecordTypeID;
           uploadProspectList.add(prospect);
        }
        List<Account> acctList = TestUtils.createAccounts(2,'TestDupbyName','UploadProspect',false);
        //Test dup by name
        acctList.get(0).Name = 'TestDupbyName';
        acctList.get(0).OwnerID = us.id;
        
        //Test dup by ID
	    acctList.get(1).ID_type_PE__c ='Work permit ID';
        acctList.get(1).ID_Number_PE__c  ='112232323334';
        acctList.get(1).OwnerID = us.id;
        insert acctlist;
        
        
        
        uploadProspectList.get(0).Name ='TestDupbyName';
        uploadProspectList.get(0).TMBEmployeeID = us.Employee_ID__c;
            
        uploadProspectList.get(1).MobileNumberPE = null;
		uploadProspectList.get(1).Phone = null;
             
        
        uploadProspectList.get(2).IDTypePE ='Work permit ID';
        uploadProspectList.get(2).IDNumberPE ='112232323334';
        uploadProspectList.get(2).TMBEmployeeID = us.Employee_ID__c;
        
  		Id [] fixedSearchResults2= new Id[2];
           fixedSearchResults2[0] = acctList.get(0).id;
           fixedSearchResults2[1] = acctList.get(1).id;
           Test.setFixedSearchResults(fixedSearchResults2);
            for(UploadProspect prospect : UploadProspectService.Upload(uploadProspectList))
            {
                System.debug(prospect.Id);
                System.debug(prospect.Success);
                System.debug(prospect.Created);
    			System.debug(prospect.Error);
    			System.debug(prospect.ErrorMessage);
            }
       
          
        
        
       
        }
        
    }
}