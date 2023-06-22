public class SubmitForApprovalExtensionV2 {
    public Opportunity oppt {get;set;}
    //public boolean isClassic {get;set;}
    public boolean isError {get;set;}
   // public boolean isAddProduct {get;set;}
    public final ApexPages.StandardController std;
    public boolean isHasProduct {get;set;}
    public boolean isCanSelectProductGroup {get; set;}
    public host_product_mapping__c hostTemp {get;set;}
    public Account acct {get;set;}
    public opportunitylineitem oppProductTemp {get;set;}
    
    public SubmitForApprovalExtensionV2(ApexPages.StandardController controller){
        isError = false;
        std = controller; 
        isCanSelectProductGroup = true;
        
        Opportunity opptStd =  (Opportunity)std.getRecord();
        oppt = [select id,name,AccountId,recordtypeid,recordtype.name,ownerid,Submit_To_System__c ,Host_Product_Group__c,Host_System__c 
                       , (select host_product_mapping__c, host_product_mapping__r.host_name__c, host_product_mapping__r.host_product_group__c
                       from opportunitylineitems)
                from Opportunity where id =: opptStd.id];
       
        integer ol = [select count() from opportunitylineitem where opportunityid =: oppt.id];
        if (ol > 0){
            isHasProduct = true;
        }

        acct = [ select Id,Name,Account_Type__c,ID_Number_PE__c,ID_Type_PE__c,Customer_Type__c from Account where Id = :oppt.AccountId ];
        User opptyOwner = [SELECT ID,Employee_ID__c,Zone_Code__c,Region_Code__c FROM User WHERE ID = :oppt.OwnerId LIMIT 1];
         List<Visit_Report_Opportunity__c> visitOppList = [SELECT ID,Opportunity__c,Status__c
                                                          FROM Visit_Report_Opportunity__c
                                                         WHERE Opportunity__c =:oppt.id];
        boolean isCompleted = false; 
        if(VisitOppList.size()>0){
            //isCompleted =true;
            for(Visit_Report_Opportunity__c visitOpp : visitOppList){
                //if(visitOpp.Status__c =='2 - Completed'){
                //    isCompleted =true;
                //}
                // change condition to just have at least 1 visit plan
                isCompleted = true;
            }
        }

                   if( acct.Account_Type__c == 'Qualified Prospect' ){

                        if(acct.ID_Type_PE__c == null && acct.ID_Number_PE__c == null){
                           isError = true;
                           System.debug('Customer must have ID Type/ID Number');
                           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8053').status_message__c));
                        }else{
                           if(acct.ID_Type_PE__c !='BRN ID' && acct.ID_Type_PE__c !='Citizen ID'){
                               isError = true;
                               System.debug('Customer’s ID Type must be either BRN or National ID');
                               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8018').status_message__c));
                           }
                        }
                   }

        if(opptyOwner.Employee_ID__c == null){
            isError = true;
            System.debug('Opp Owner must have Employee ID');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8020').status_message__c));
        }
        if(opptyOwner.Zone_Code__c ==null ){
            isError = true;
            System.debug('Opp Owner must have Zone Code ');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8021').status_message__c));
        }
         if(opptyOwner.Region_Code__c == null){
            isError = true;
            System.debug('Opp Owner must have Region Code');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8022').status_message__c));
        }
        if(!isCompleted){
            isError = true;
            System.debug('Opportunity must have at least 1 visit');
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8019').status_message__c));
        }

        hostTemp = new host_product_mapping__c();
        //oppProductTemp = new opportunitylineitem();
        if (string.isNotBlank(oppt.Host_System__c))
        {
            hostTemp.Host_Name__c = oppt.Host_System__c;
            //oppProductTemp.Host_System__c = oppt.Host_System__c;
        }
        
    }   
    
    public void updateProductGroup()
    {
        string productGroup = '';
        string hostName = '';
        boolean isNeedUpdate = false;
        for (opportunitylineitem ol : oppt.opportunitylineitems)
        {
            if (string.isNotBlank(ol.host_product_mapping__c) && string.isNotBlank(ol.host_product_mapping__r.host_name__c)){
                hostName = ol.host_product_mapping__r.host_name__c;
            }
            if (string.isNotBlank(ol.host_product_mapping__c) && string.isNotBlank(ol.host_product_mapping__r.host_product_group__c)){
                productGroup = ol.host_product_mapping__r.host_product_group__c;
            }
        }
       
        if (string.isBlank(oppt.Host_System__c) && string.isNotBlank(hostName)){
            oppt.Host_System__c = hostName;
            hostTemp.Host_Name__c = oppt.Host_System__c ;
            isNeedUpdate = true;
        }
        if (string.isBlank(oppt.Host_Product_Group__c) && string.isNotBlank(productGroup)){
            oppt.Host_Product_Group__c = productGroup;
            hostTemp.Host_Product_Group__c = oppt.Host_Product_Group__c;
            isNeedUpdate = true;
        }
       
        if (isNeedUpdate){
            try {
                update oppt;
            }catch(exception ex){
                isError = true;
                //return new pageReference('/'+oppt.id);
            }
        }
        //return null;
        
    } 
     
    public PageReference submitSystem(){
        if (string.isNotBlank(hostTemp.Host_Name__c))
        {
             oppt.Host_System__c = hostTemp.Host_Name__c;
        }
        isError = false;
        try{  
            if(string.isNotBlank(oppt.Host_System__c)){
                if(oppt.Host_System__c.contains('SLS')){
                    //submitToSLOS
                   return new pagereference('/apex/SLOSSelectProductGroup?id=' + oppt.id + '&host=SLS');
                }
                else{
                    //submitToExcel
                    return new pagereference('/apex/SLOSSelectProductGroup?id=' + oppt.id + '&host=Excel');
                } 
            }   
            else{
                //Please select host for submit tosystem
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,status_code__c.getValues('8036').status_message__c)); 
            }  
        }   
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));            
        }
        return null;
    }
    public PageReference cancel() { 
        return new PageReference('/' + oppt.id);
    }
}