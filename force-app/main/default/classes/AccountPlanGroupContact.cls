public without sharing class AccountPlanGroupContact extends EditableList {
    String ComID {get;set;}
    String GroupID {get;set;}
    Public Map<ID,Account> AccountMap {get;set;}




        //Start Pagination
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setcon;

    public List<Contact> GroupContactList {get{
        GroupContactList = new List<Contact>();
        if(setCon !=null){
            
            for (Contact conREc : (List<Contact>)setCon.getRecords()){
                GroupContactList.add(conREc );
            }
        }
        
        return GroupContactList;
        
    }set;}
    public Boolean hasNext {
        get {
            if(setCon !=null){
                return setCon.getHasNext();
            }else{
                return false;
            }
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            
            if(setCon !=null){
                return setCon.getHasPrevious();
            }else{
                return false;
            }
        }
        set;
    }  
    public Integer pageNumber {
        get {
            if(setCon !=null){
                return setCon.getPageNumber();
            }else{
                return 0;
            }
           
        }
        set;
    }  
    public void first() {
        setCon.first();
    }  
    public void last() {
        setCon.last();
    }  
    public void previous() {
        setCon.previous();
    }  
    public void next() {
        system.debug('= next = ');
        setCon.next();
    }



    public AccountPlanGroupContact(ApexPages.StandardController stdController) {
    super(stdController);
    size = 100; 

    ComID = ApexPages.currentPage().getParameters().get('ComID');
    GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        AccountMap = new Map<ID,Account>();
   
     if(GroupID !='' && GroupID !=null){
             
              ID GroupmasterID = [SELECT ID,Group__c from AcctPlanGroupProfile__c  WHERE ID=:GroupID LIMIT 1 ].GRoup__c;    
        List <Account> AccountList = [SELECT ID,Name,Group__c from Account WHERE Group__c =: GroupmasterID];
            for(Account acct : AccountList){
                AccountMap.put(acct.id,acct);
            }
        
        this.childList = [Select id,Salutation__c,Name,FirstName,
                          LastName,Group_Contact__c ,AccountID,
                          Position__c,
                          Product_Decision__c,Product_Decision2__c,Product_Decision_2_2__c,Product_Decision_3_2__c,
                          Product_Decision3__c, Decision_Map__c,
                          Decision_Map2__c,Decision_Map3__c from Contact where AccountID IN:AccountList LIMIT 2000
                        ];
    
    
         if(childList.size()==2000){
            Integer childlistsize = [SELECT count() from Contact WHERE AccountID IN:AccountList ];
                if(childlistsize>2000){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING ,'System can display up to 2,000 contacts in group.'));
                }
         }
    
            setCon = new ApexPages.StandardSetController(childList);
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();


     }
        
      
  }
    
    
    public List<Contact> getChildren()
  {

    return (List<Contact>)childList;
  }
  
  

}