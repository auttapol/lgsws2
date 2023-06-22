public with sharing class RelatedListExtension {
    public List<Opportunity> oppt;
    public List<Contact> cont; 
    public List<Product_Campaign_Recommend__c> camp; 
    public List<Call_Report__c> visit; 
    public Account acct {get;set;}
    public boolean isVisit {get;set;}
    public boolean isOpt {get;set;}
    public boolean isCont {get;set;}
    public boolean isProd {get;set;}
 
    public RelatedListExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        Id userId = UserInfo.getUserId();
        system.debug('userId '+userId);
        isVisit= false;
        isOpt = false;
        isCont= false;
        isProd = false;
        isVisit=checkPermission(userId,'Call_Report__c');
        isOpt=checkPermission(userId,'Opportunity');
        isCont=checkPermission(userId,'Contact');
        isProd=checkPermission(userId,'Product_Campaign_Recommend__c');
         
    }
    
    public boolean checkPermission(Id userId,String obj){
        boolean check = false;
     List<ObjectPermissions> permission = [SELECT Id, SObjectType, PermissionsCreate FROM ObjectPermissions
            WHERE (ParentId IN (SELECT PermissionSetId
                       FROM PermissionSetAssignment
                       WHERE Assignee.Id = : userId))
            AND (SobjectType = : obj) ];
        for(ObjectPermissions o : permission){
           check = o.PermissionsCreate;
        } 
        
        return check;
        
    /*boolean permission =  [SELECT Id, SObjectType, PermissionsCreate FROM ObjectPermissions
            WHERE (ParentId IN (SELECT PermissionSetId
                       FROM PermissionSetAssignment
                       WHERE Assignee.Id = : userId))
            AND (SobjectType = : obj) ].PermissionsCreate;
        
      return permission;*/
    }

     public List<Opportunity> getOppt()
    {
        oppt = [Select id, Name, StageName, CloseDate, Amount from Opportunity where Account.id = :acct.id];
        return oppt;
    }
    
         public List<Contact> getCont()
    {
        cont = [Select id, Name, Position__c, MobilePhone, Decision_Map__c from Contact where Account.id = :acct.id];
        return cont;
    }
    
    
          public List<Call_Report__c> getVisit()
    {
       visit = [Select id, Name, Date_of_Visit__c, Reporting_Purpose__c, Status__c from Call_Report__c where Customer_name__c = :acct.id];
        return visit;
    }  
    
           public List<Product_Campaign_Recommend__c> getCamp()
    {
        camp = [Select id, Name,Product_name__c, Campaign_Name__c, Status__c, Product_Name_Medium_Priority__c, Product_Name_Low_Priority__c from Product_Campaign_Recommend__c where AccountAccount__c = :acct.id order by Validity_Period_Ending__c DESC, id DESC Limit 5];
        return camp;
    }  
    
}