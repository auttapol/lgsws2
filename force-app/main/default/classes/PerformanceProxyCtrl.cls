public class PerformanceProxyCtrl {
    
private final ApexPages.StandardController std ;
    public Account tmpAcct {get;set;}
    public boolean isAccountTeam {get;set;}
    private final Account accts; 
    public List<UserRecordAccess> accessList {get;set;}
    
    public PerformanceProxyCtrl(ApexPages.StandardController controller){
        std = controller;
        accts = (account)std.getRecord();
        isAccountTeam = false;

        string accid = apexpages.currentpage().getparameters().get('acctId');

        tmpAcct = [select Loan_Classification__c, SCF_Score__c
                           ,NI_Plan__c,NIIc_Plan__c,NIId_Plan__c,Fee_Plan__c
                           , NI_Wallet__c, NIIc_Wallet__c, NIId_Wallet__c, Fee_Wallet__c
                           ,NI_Actual__c, NIIc_Actual__c, NIId_Actual__c, Fee_Actual__c
                           , NI_SoW__c, NIIc_SoW__c, NIId_SoW__c, Fee_SoW__c
                           , Total_Revenue_Baht__c, Gross_Profit__c, Net_Profit_Baht__c
                           , Last_Activity_Date__c,Supply_Chain_Actual__c,As_of_date_Wallet__c
                           ,No_of_Open_Opportunities__c
                           , owner.UserRoleId
                           from Account where id =: accid]; 
        
        accessList = [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
           ];
        system.debug('accessList : '+accessList.size());
    }
    // Desktop
    public PageReference redirectPage(){
        string accid = apexpages.currentpage().getparameters().get('acctId');

        /*
        tmpAcct = [select Loan_Classification__c, SCF_Score__c
                           ,NI_Plan__c,NIIc_Plan__c,NIId_Plan__c,Fee_Plan__c
                           , NI_Wallet__c, NIIc_Wallet__c, NIId_Wallet__c, Fee_Wallet__c
                           ,NI_Actual__c, NIIc_Actual__c, NIId_Actual__c, Fee_Actual__c
                           , NI_SoW__c, NIIc_SoW__c, NIId_SoW__c, Fee_SoW__c
                           , Total_Revenue_Baht__c, Gross_Profit__c, Net_Profit_Baht__c
                           , Last_Activity_Date__c,Supply_Chain_Actual__c,As_of_date_Wallet__c
                           ,No_of_Open_Opportunities__c
                           from Account where id =: accId]; 
        
       List<UserRecordAccess> accessList = 
           [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
           ];
           */
        
        set<string> AccteamId = new set<String>();
        id currentuserId = Userinfo.getUserId();
        list<AccountTeamMember> accTeam = [select Id,AccountAccessLevel,AccountId,TeamMemberRole,UserId 
                                       from AccountTeamMember 
                                       where AccountId =:accId];
            if(accTeam.size() > 0) {
                for(AccountTeamMember acc : accTeam) {
                    AccteamId.add(acc.UserId);
                }
         }
        if(AccteamId.contains(currentuserId)){
            isAccountTeam = true;
        }
        system.debug('accessList : '+accessList.size());
        

if(accessList.size()>0){
            //if(checkAuthorize() || isAccountTeam == true){ // this condition is duplicate with data partition
            string url = '/apex/Performance_Report2?id='+accid;
            PageReference page = new PageReference(url); 
        page.setRedirect(true); 
        return page; 
        /*}else{
            string url2 = '/apex/DataPartitionDetail?id='+accid+'&type=9';
            PageReference page = new PageReference(url2); 
        page.setRedirect(true); 
        return page; 
        }*/
        }
        return null;
    }
    // Mobile
    public PageReference redirectMobile(){
        string accid = apexpages.currentpage().getparameters().get('acctId');
string CollateralReportId = apexpages.currentpage().getparameters().get('collateral');

        /*
        tmpAcct = [select Loan_Classification__c, SCF_Score__c
                           ,NI_Plan__c,NIIc_Plan__c,NIId_Plan__c,Fee_Plan__c
                           , NI_Wallet__c, NIIc_Wallet__c, NIId_Wallet__c, Fee_Wallet__c
                           ,NI_Actual__c, NIIc_Actual__c, NIId_Actual__c, Fee_Actual__c
                           , NI_SoW__c, NIIc_SoW__c, NIId_SoW__c, Fee_SoW__c
                           , Total_Revenue_Baht__c, Gross_Profit__c, Net_Profit_Baht__c
                           , Last_Activity_Date__c,Supply_Chain_Actual__c,As_of_date_Wallet__c
                           ,No_of_Open_Opportunities__c
                           from Account where id =: accId]; 
            
       List<UserRecordAccess> accessList = 
           [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
           ];
        system.debug('accessList : '+accessList.size());Performance_ReportMobile2 Performance_Report2
        */

if(accessList.size()>0){
            //if(checkAuthorize() || isAccountTeam == true){ // this condition is duplicate with data partition
            string url = '/apex/Performance_Report2?id='+accid+'&sfredirect=true';
            PageReference page = new PageReference(url); 
        page.setRedirect(true); 
        return page;
                
        /*}else{
            string url2 = '/apex/DataPartitionDetail?id='+accid+'&type=9';
            PageReference page = new PageReference(url2); 
        page.setRedirect(true); 
        return page; 
        }
            */
        }
        return null;
    }


    public boolean checkAuthorize()
    {
        boolean validate = false;
        boolean continueVal = true;

        if (accessList.get(0).HasEditAccess) {
            validate = true;
        } else {
            user u = [select UserRoleId from user where id =: UserInfo.getUserId()];
            string accOwnerRole = tmpAcct.owner.UserRoleId;
            string currentUserRole = '';
            if (u != null) currentUserRole = u.UserRoleId;

            if (currentUserRole != '' && currentUserRole != null)
            {
                while (continueVal)
                {
                    string accOwnerParentRole = '';
                    if (accOwnerRole != '' && accOwnerRole != null) {
                        UserRole ur = [select ParentRoleId from UserRole where id =: accOwnerRole];
                        if (ur != null) accOwnerParentRole = ur.ParentRoleId;
                    }
                    
                    if (accOwnerParentRole != '' && accOwnerParentRole != null) {
                        if (accOwnerParentRole != currentUserRole) {
                            accOwnerRole = accOwnerParentRole;
                        } else {
                            validate = true;
                            continueVal = false;
                        }
                    } else {
                        continueVal = false;
                    }
                }
            }
        }

        return validate;
    }

    
}