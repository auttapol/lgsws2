public class CollateralProxyCtrl {
    
private final ApexPages.StandardController std ;
    public Account tmpAcct {get;set;}
    private Account accts; 
    public boolean isAccountTeam {get;set;}
    public List<UserRecordAccess> accessList {get;set;}
    public id CollateralReportId {get;set;}
    public id CollateralReportId_Partition {get;set;}
    public String tabId {get;set;}
    
    public CollateralProxyCtrl(ApexPages.StandardController std){
        accts = (Account)std.getRecord();
        //std = controller;
        //accts = (account)std.getRecord();
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
        
         try{
            CustSingleView__c CustSingleView7 = CustSingleView__c.GetValues('CollateralReport');
            String collateral = CustSingleView7.ReportName__c;
            CollateralReportId = [SELECT id FROM report where name = : collateral ].Id;
             
            CustSingleView__c CustSingleView7_2 = CustSingleView__c.GetValues('CollateralReport_Partition');
            String collateral_Partition = CustSingleView7_2.ReportName__c;
            CollateralReportId_Partition = [SELECT id FROM report where name = : collateral_Partition ].Id;
         }catch(Exception Ex){
           	system.debug('::::::Exception Domain5Id::::::');
         }
        
    }
    // Desktop
    public PageReference redirectPage(){
        string accid = apexpages.currentpage().getparameters().get('acctId');
		//string CollateralReportId = apexpages.currentpage().getparameters().get('collateral');
        try{
        	tabId = apexpages.currentPage().getParameters().get('tabId');
        }catch(Exception e){
            tabId = '';
        }
        //string types = apexpages.currentpage().getparameters().get('type');
        system.debug('accid :'+accid);
        system.debug('CollateralReportId :'+CollateralReportId);
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
        system.debug('accessList : '+accessList.size());
        */
        
		//set<string> AccteamId = new set<String>();
  //      id currentuserId = Userinfo.getUserId();
  //      list<AccountTeamMember> accTeam = [select Id,AccountAccessLevel,AccountId,TeamMemberRole,UserId 
  //                                     from AccountTeamMember 
  //                                     where AccountId =:accId];
  //          if(accTeam.size() > 0) {
  //              for(AccountTeamMember acc : accTeam) {
  //                  AccteamId.add(acc.UserId);
  //              }
  //       	}
  //      if(AccteamId.contains(currentuserId)){
  //          isAccountTeam = true;
  //      }
        // Remove old logic and check only from data partition
		//if(accessList.size()>0){
            //if(checkAuthorize() || isAccountTeam == true){
                string url = '';
                if(checkAuthorizeMatrix()){
                    // url = '/'+CollateralReportId+'?pv0='+accid.left(15);
                    url = '/lightning/r/Report/'+CollateralReportId+'/view?fv0='+accid;
                }else{            
                    //url = '/'+CollateralReportId_Partition+'?pv0='+accid.left(15);
                	url = '/apex/DataPartitionDetail?id='+accid+'&type=8&isVisible=false&tabId='+tabId;
                }
            PageReference page = new PageReference(url); 
        	page.setRedirect(true); 
        	return page; 
        	//}
            //else{
         //   //string url2 = '/apex/DataPartitionDetail?id='+accid+'&type=8';
         //   string url2 = '/apex/DataPartitionDetail?id='+accid+'&type=8&isVisible=false&tabId='+tabId;
         //   PageReference page = new PageReference(url2); 
        	//page.setRedirect(true); 
        	//return page; 
        	//}
        //}
        //return null;
    }
    // Mobile
    public PageReference redirectMobile(){        
        string accid = apexpages.currentpage().getparameters().get('acctId');
		string CollateralReportId = apexpages.currentpage().getparameters().get('collateral');
        //string types = apexpages.currentpage().getparameters().get('type');
        system.debug('accid :'+accid);

        /*
        system.debug('CollateralReportId :'+CollateralReportId);
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
        system.debug('accessList : '+accessList.size());
        */

		//if(accessList.size()>0){
  //          if(checkAuthorize() || isAccountTeam == true){
                string url = '';
                if(checkAuthorizeMatrix()){
            		url = '/apex/Collateral_Report_Mobile?id='+accid+'&sfredirect=true';     
                }else{            
                    //url = '/apex/Collateral_Report_Mobile_Partition?id='+accid+'&sfredirect=true';
                	url = '/apex/DataPartitionDetail?id='+accid+'&type=8&isVisible=false';
                }
            PageReference page = new PageReference(url); 
        	page.setRedirect(true); 
        	return page;
                
        //	}else{
        //        string url2 = '/apex/DataPartitionDetail?id='+accid+'&type=8&isVisible=false';
        //    PageReference page = new PageReference(url2); 
        //	page.setRedirect(true); 
        //	return page; 
        //	}
        //}
        //return null;
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
                    if (accOwnerRole != '' && accOwnerRole != null) {
                        UserRole ur = [select ParentRoleId from UserRole where id =: accOwnerRole];
                        string accOwnerParentRole = '';
                        if (ur != null) accOwnerParentRole = ur.ParentRoleId;
                        
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
                    } else {
                      continueVal = false;
                    }
                }
            }
        }

        return validate;
    }
    
            // --------------------------------------------------------------------------------------
    
    public String section {get;set;}
    public String section1 {get;set;}
    public String section2 {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isVisible_product {get;set;}
    public Boolean isVisible_total {get;set;}
    public Boolean isLoadSuccess {get;set;}
    //public Account acct;

    public String hiddenText {
        get{
            if( hiddenText == null )
            {
                hiddenText = system.Label.Data_Condition_Hidden_Text;
            }
            return hiddenText;
        }
        set;
    }
	public String notAuthorizedMsg {
        get{
            if( notAuthorizedMsg == null )
            {
                notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
            }
            return notAuthorizedMsg;
        }
        set;
    }
    /*public AccountDataPartitionExtension(ApexPages.StandardController std){
        acct = (Account)std.getRecord();
        //isLoading = true; 
        //isLoadSuccess = false;
    }*/

    public boolean checkAuthorizeMatrix()
    {        
        try{
        	section = apexpages.currentPage().getParameters().get('sectionName');
        }catch(Exception e){
            this.section = section;
        }
        
        Account acctDetail = new Account();
        Profile userProfile = new Profile();

        try
        {
            acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :tmpAcct.id ];
            userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        }
        catch (Exception e)
        { 
            //exception here
        }
        
        isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
            system.debug('isVisible = '+isVisible+ '/'+ tmpAcct.id);
        
        return isVisible;
    }

    
}