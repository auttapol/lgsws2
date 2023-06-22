public class SubmitForApprovalExtension {
    
    public Opportunity oppInput;
    public ApexPages.StandardController std;
    public String strCallAlert{        
        get;set;
    }
    public SubmitForApprovalExtension(ApexPages.StandardController controller){
        oppInput = (Opportunity)controller.getRecord();
        oppInput = [ select Id,Name,StageName,RecordType.Name,RecordTypeId,AccountId,Application_Status__c, No_of_Product__c from Opportunity where Id =: oppInput.Id ];
        std = controller;
    }
    
    public void checkSubmitForApproval(){
        Boolean oppSave = false;
        String strResult = Trigger_Msg__c.getValues('Submit_Approval_Success').Description__c;
        Account queryAccount = [ select Id,Name,Account_Type__c,ID_Number_PE__c,ID_Type_PE__c  from Account where Id = :oppInput.AccountId ];
        if( oppInput.no_of_product__c == 0){
            strResult = Trigger_Msg__c.getValues('Missing_Product').Description__c;
        }else{
            if( queryAccount.Account_Type__c == 'Existing Customer' ){
                oppInput.StageName = Stage_Approval__c.getValues('Approval').Stage_Name__c;
                oppInput.Application_Status__c = Stage_Approval__c.getValues('Sent_For_Approval').Stage_Name__c;
                oppSave = true;
            }else{            
                if( queryAccount.Account_Type__c == 'Qualified Prospect'
                   || queryAccount.Account_Type__c =='Retail Customer'
                  || queryAccount.Account_Type__c == 'Retail Prospect'){
                    if( queryAccount.ID_Number_PE__c !=null && queryAccount.ID_Type_PE__c !=null){
                        oppInput.StageName = Stage_Approval__c.getValues('Approval').Stage_Name__c; 
                        oppInput.Application_Status__c = Stage_Approval__c.getValues('Sent_For_Approval').Stage_Name__c;
                        oppSave = true;
                    }else{
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ID_populated__c is false'));
                        strResult = Trigger_Msg__c.getValues('Not_Found_ID_Populated').Description__c;
                    }
                }else{
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Qualified Prospect Only'));
                    strResult = Trigger_Msg__c.getValues('Approval_Qualified_Prospect_Only').Description__c;
                }
            }
        }
        
        if( oppInput.StageName == 'Closed Lost' ){
            oppSave = false;
            strResult = Trigger_Msg__c.getValues('Permission_Approval_ClosedLost').Description__c;
        }
        
        List<Visit_Report_Opportunity__c> visitOppList = [SELECT ID,Opportunity__c,Status__c
                                                          FROM Visit_Report_Opportunity__c
                                                         WHERE Opportunity__c =:oppInput.id];
        
        if(VisitOppList.size()>0){
            boolean isCompleted = false;
            for(Visit_Report_Opportunity__c visitOpp : visitOppList){
                if(visitOpp.Status__c =='2 - Completed'){
                    isCompleted =true;
                }
            }
            
            if(!isCompleted){
             oppSave = false;
             strResult = Trigger_Msg__c.getValues('Visit_Plan_Not_Completed').Description__c;
            }
            
        }else{
             oppSave = false;
             strResult = Trigger_Msg__c.getValues('Not_found_Visit_Plan').Description__c;
        }
        
        
 
        if( oppSave ){
            try{
                
                List<RecordType> recordTypeList = [ select Id,Name 
                                           from RecordType 
                                           where Name IN ('SE Credit Product','WBG Credit Product','SE Credit Product2','WBG Credit Product2')
                                          and SobjectType = 'Opportunity'];  
        
        Id recordIdSECreditProduct;
        Id recordIdWBGCreditProduct;
        Id recordIdSECreditProduct2;
        Id recordIdWBGCreditProduct2;
                
                for( RecordType eachRecordType : recordTypeList ){
            System.debug('eachRecordType : '+eachRecordType.Name);
            if( eachRecordType.Name == 'SE Credit Product' ){
                recordIdSECreditProduct = eachRecordType.Id;
            }else if( eachRecordType.Name == 'WBG Credit Product' ){
                recordIdWBGCreditProduct = eachRecordType.Id;
            }else if( eachRecordType.Name == 'SE Credit Product2' ){
                recordIdSECreditProduct2 = eachRecordType.Id;
            }else if( eachRecordType.Name == 'WBG Credit Product2' ){
                recordIdWBGCreditProduct2 = eachRecordType.Id;
            }
        }
        
                if( oppInput.RecordTypeId == recordIdSECreditProduct ){
                    oppInput.RecordTypeId = recordIdSECreditProduct2;
                     System.debug('SE Credit Product Change to 2 :');
                }else if( oppInput.RecordTypeId == recordIdWBGCreditProduct ){
                    System.debug('WBG Credit Product Change to 2 :');
                    oppInput.RecordTypeId = recordIdWBGCreditProduct2;
                }
                
                
                update oppInput;
            }catch(DmlException e){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }            
        }
        
        strCallAlert = '<script>checkResult(\'' +strResult+ '\');</script>';
        
        
        System.debug(':::: Account_Type__c : '+queryAccount.Account_Type__c);
    }

}