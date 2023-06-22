public inherited sharing class reassignBRCCustomerCTL {
    public reassignBRCCustomerCTL() {

    }

    public static User currentUser = [Select Id,Employee_ID__c, RTL_Branch_Code__c, Zone_Code__c FROM user WHERE id =: UserInfo.getUserId()];

    public static Branch_and_Zone__c branchId = New Branch_and_Zone__c();
    public static List<Account> accBRCList = New List<Account>();
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getBRCCustomerList() {

        //Query all customer that have 'Most Operating Branch' equal user branch code
        if(currentUser.RTL_Branch_Code__c != null){
            branchId = [Select id, Branch_Code__c from Branch_and_Zone__c where Branch_Code__c =: currentUser.RTL_Branch_Code__c];
            if(branchId.id != null ){
                accBRCList = [SELECT Id, Name, TMB_Customer_ID_PE__c, RTL_Customer_Title__c,
                    Core_Banking_Suggested_Segment__c, Sub_segment__c, RTL_Suitability__c,RTL_AUM__c,
                    RTL_AUM_Last_Calculated_Date__c,RTL_Most_Operating_Branch__c, Most_Operating_Branch_Name__c,
                    RTL_Assigned_BRC__c,Assigned_BRC_User_Name__c,RTL_Wealth_RM__c, Wealth_RM_BM_Name__c
                    FROM Account WHERE RTL_Most_Operating_Branch__c =: branchId.id ORDER BY Assigned_BRC_User_Name__c ASC NULLS LAST];
            }
        }      
        return accBRCList;
    }
    
    @AuraEnabled
    public static String recordReassign(list<Account> lstAcc, Id newBRCId){
        String result = '';
        Integer successRecord = 0;
        Integer failRecord = 0;
        String ErrorMessege = '';
        try {
            List<Account> assignBRCList = new List<Account>();
            Set<String> custIDSet = new Set<string>();
            List<Main_Bank_List_View__c> mainBankSelectList = New List<Main_Bank_List_View__c>();
            List<Main_Bank_List_View__c> mainBankUpdateList = New List<Main_Bank_List_View__c>();
            Id branchBRCId;
            for(Account acc: lstAcc){
                acc.RTL_Assigned_BRC__c = newBRCId;
                if(branchBRCId == null){
                    branchBRCId = acc.RTL_Most_Operating_Branch__c;
                }

                assignBRCList.add(acc);
                custIDSet.add(acc.TMB_Customer_ID_PE__c);
            }
            
            mainBankSelectList = [SELECT id, Customer_ID__c, Assigned_BRC_User__c,Most_Operating_Branch__c 
                FROM Main_Bank_List_View__c WHERE Customer_ID__c in: custIDSet ];

            if(mainBankSelectList.size() > 0){
                for(Main_Bank_List_View__c mbl: mainBankSelectList ){
                    mbl.Assigned_BRC_User__c = newBRCId;
                    mbl.Most_Operating_Branch__c = branchBRCId;
                    mainBankUpdateList.add(mbl);

                }

            }
            
            if(assignBRCList.size() > 0){                
                Database.SaveResult[] srList = Database.update(assignBRCList,false); //partial update
                Integer i = 0;
                
                for (Database.SaveResult sr : srList) {

                    if (sr.isSuccess()) {
                        successRecord = successRecord + 1;
                        
                    }
                    else {
                        failRecord = failRecord + 1;
                        //assignBRCList[i].TMB_Customer_ID_PE__c;   
                        String tempMS = '';
                        for(Database.Error err : sr.getErrors()) {  
                            tempMS =  err.getStatusCode() + ': ' + err.getMessage();                                           
                        }

                        ErrorMessege = ErrorMessege + failRecord+'. '+assignBRCList[i].TMB_Customer_ID_PE__c + ': ' + tempMS +'\n';
                    }
                    i++;
                }
            }
            if(mainBankUpdateList.size() > 0){               
                Database.update(mainBankUpdateList,false); //partial update
            }
            result = 'Total = ' + lstAcc.size()+ ' Records.\n';
            result = result + 'Success = '+ successRecord + ' Records.\n';
            result = result + 'Failed = '+failRecord + ' Records.\n';
            if(ErrorMessege != ''){
                result = result + 'Error message \n'+ErrorMessege;
            }
            
            
        }
        catch(Exception ex) {   
            system.debug(ex.getMessage()); 
            result = ex.getMessage();       
            //throw new AuraHandledException(ex.getMessage());
            
        } 
        return result;

    }

    @AuraEnabled(cacheable=true)  
    public static List<sobject> findBRCUserRecords(String searchBRCKey, String objectName) {  
        string searchText = '\'' + String.escapeSingleQuotes(searchBRCKey) + '%\'';  
        string queryString = 'SELECT Id, Name, Employee_id__c FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' OR Employee_id__c LIKE '+searchText+' LIMIT 5';  
        return Database.query(queryString);  
    } 

}