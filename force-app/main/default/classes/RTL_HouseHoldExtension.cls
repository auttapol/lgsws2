public class RTL_HouseHoldExtension {

    public RTL_HouseHold__c household {get;set;}
    public RTL_HouseHold_Member__c member {get;set;}
    public String ManagerName {get;set;}
    public String ManagerId {get;set;}
    private List<RTL_Household__C> householdList;
    private List<User> rmUserList;
    public Boolean hasError {get;set;}
    public Boolean render {get;set;}    
    public String acctid {get;set;}
    
    private Account acct;
    private String EmpBrCode;
    private RTL_Branch_Manager_Title__c branchTitle;
    private List<RTL_Household_Number_Store__c> latestRunningNumb;
   	private Decimal runningNumb;
    
    public RTL_HouseHoldExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        acctid =  ApexPages.currentPage().getParameters().get('acctid');
        acct = [SELECT ID,Name,First_Name_PE__c,Last_Name_PE__c,RTL_RM_Name__c  FROM Account WHERE id=:acctid];
        branchTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager');
        EmpBrCode = acct.RTL_RM_Name__c;
        runningNumb = 1;
        latestRunningNumb = [SELECT ID,Name,RTL_Number__c FROM RTL_Household_Number_Store__c WHERE RTL_Account__c =:acctid LIMIT 1];
        if(latestRunningNumb != null && latestRunningNumb.size() > 0){
            latestRunningNumb[0].RTL_Number__c += 1;
            runningNumb = latestRunningNumb[0].RTL_Number__c;
        }
        
        //If it is branch code
        if(EmpBrCode != null && EmpBrCode.startsWith('00')){
            EmpBrCode = EmpBrCode.substring(2);
            System.debug('EMR / BR '+empbrCode);
            rmUserList = [SELECT ID,Name,ManagerId,Manager.Name FROM User 
                            WHERE RTL_Branch_Code__c = : EmpBrCode 
                            AND RTL_Branch_Code__c  != null 
                            AND IsActive = true
                            AND title =:branchTitle.RTL_Value__c];
        }else{
            rmUserList = [SELECT ID,Name,ManagerId,Manager.Name FROM User WHERE Employee_ID__c  = : EmpBrCode 
                            AND Employee_ID__c != null 
                            AND IsActive = true];
        }
        
        household = new RTL_HouseHold__c();
        
        if(rmUserList.size() >0){
            household.RTL_RM__c = rmUserList[0].id;
            managerName = rmUserList[0].Manager.Name;
            managerId = rmUserList[0].Manager.Id;
        } 

          if (UserInfo.getUserId() != managerId){
                        
            household.name = generateHouseholdName(acct.Last_Name_PE__C,acct.First_name_PE__c);
            //String compareName = '%'+household.name+'%';
            //householdList = [SELECT ID,Name FROM RTL_Household__c WHERE Name like:compareName];
            String runningNumbString = String.ValueOf(runningNumb);
            household.name = household.name+' '+runningNumbString.leftPad(3).replace(' ', '0'); 
            household.RTL_Household_Name_Duplicate_Checker__c  = household.name;
        
            member = new RTL_HouseHold_Member__c();
            member.Name = acct.Name;
            member.RTL_Primary__c = true;
            member.RTL_Benefit__c = true;
            member.RTL_Household_Member_Name__c = acct.id;
            render = true;
          }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.RTL_Household_ERR05));
            render = false;
          }
        
        
    }
    
    public PageReference save(){
        hasError = false;
        Savepoint sp;
        try{
            //create savepoint in case DML error and want to rollback all DML action.
            sp = Database.setSavepoint();
            //insert household first to get ID to attach to household member : household is master of household member
            insert household;
            
            if(latestRunningNumb != null && latestRunningNumb.size() >0){
                update latestRunningNumb;
            }else{
                insert new RTL_Household_Number_Store__c(RTL_Number__c=1,RTL_Account__c=acctId);
            }
            
            
            //insert household member after get the household id          
            member.RTL_Household__c = household.id;
            member.RTL_Status__c = 'New';
            insert member;
            
        }catch(DMLException e){
            return showErrorMessage(e.getDmlMessage(0),sp);       
        }
        catch(Exception e){
            return showErrorMessage(e.getMessage(),sp);
        }
        return null;
        //redirect to household detail page
        //return new PageReference('/apex/RTL_HouseHold_Detail?id='+household.id);
    }
    
    public PageReference cancel(){
        return new ApexPages.StandardController(acct).view();
    }
    
    private String generateHouseholdName(String lastname,String firstname){
        if(lastname == null){
            return firstname;
        }
        return lastname+' '+firstname;
    }
    
    private PageReference showErrorMessage(String errMsg,Savepoint sp){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errMsg));
        Database.rollback(sp);
        hasError = true;
        return null;
    }
    
}