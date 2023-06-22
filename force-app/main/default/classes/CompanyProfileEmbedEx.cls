global without sharing  class CompanyProfileEmbedEx {
	public ApexPages.StandardController ctrl;
    public Account acct {get;set;}
    public String ownerId {get;set;}
    public List <AcctPlanCompanyProfile__c> companyList {get;set;} 
    public Account tmpAcct {get;set;}
    public List<UserRecordAccess> accessList {get;set;}
    public boolean isAccessible {get;set;}
        
    public CompanyProfileEmbedEx(ApexPages.StandardController controller){
          ctrl = controller;
     	  acct= (Account)controller.getRecord();
       	  isAccessible = true;
                
       	companyList_Accountplan(acct.id);
            
        tmpAcct = [select owner.UserRoleId from Account where id =: acct.ID]; 
        
        accessList = [SELECT RecordId, 
            HasAllAccess,HasEditAccess, HasReadAccess  
            FROM UserRecordAccess 
            WHERE UserId =: Userinfo.getUserId()
            AND RecordId =: tmpAcct.id
           ];
		campaignLead_RelatedList(acct.id);
    }
 //-------------------------------------------------------------------------------------------------------
 	public integer totalPageCompro {get;set;}
    public integer currentPageCompro {get;set;}
    public decimal recPerPageCompro  = 5;
    public integer startOffsetCompro {get;set;}
    public string accidCompro {get;set;}
    
    public void companyList_Accountplan(string acc_id)
    {
      
        accidCompro = acc_id;
        integer totalRecCompro = [select count() from AcctPlanCompanyProfile__c where Account__c =: accidCompro];
        totalPageCompro = integer.valueof((totalRecCompro/recPerPageCompro).round(system.roundingmode.ceiling));
        system.debug(totalPageCompro);
        totalPageCompro = (totalPageCompro < 1) ? 1 : totalPageCompro;
        currentPageCompro = 1;
        startOffsetCompro = 0;
        
        queryAccountPlan();

    }
    
    public void nextPageCompro()
    {
        currentPageCompro = (currentPageCompro != totalPageCompro) ? (currentPageCompro+1) : totalPageCompro;
        startOffsetCompro = (currentPageCompro - 1) * integer.valueof(recPerPageCompro);
     
        queryAccountPlan();
    }
    
    public void previousPageCompro()
    {
        currentPageCompro = (currentPageCompro != 1) ? (currentPageCompro-1) : 1;
        startOffsetCompro = (currentPageCompro - 1) * integer.valueof(recPerPageCompro);

        queryAccountPlan();
    }
    
    Public void queryAccountPlan()
    {
         companyList = [SELECT ID,AccountName__c,Account__c,AcctPlanGroup__c,Name,AcctPlanGroup__r.Name,LastModifiedDate,
                       Year__c,Status__c,OwnerID,Owner.Name,LastModifiedByID,LastModifiedBy.name  FROM AcctPlanCompanyProfile__c
                      WHERE Account__c =:acct.id limit: integer.valueof(recPerPageCompro) offset: startOffsetCompro];
        
    }
       
//--------------------------------------------------------------------------------------------------------
    public boolean getCheckAuthorize()
    {
        boolean validate = false;
        boolean continueVal = true;
        boolean validAccess = false;

        if (accessList.size() > 0) {
            if (accessList.get(0).HasEditAccess) {
                validAccess = true;
            }
        }
        
        List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                             IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                             WHERE AccountId =: tmpAcct.id
                             AND USerId=: Userinfo.getUserId()
                             LIMIT 1];
            
            if(acctTeam.size()>0){
                // if(acctTeam.get(0).AccountAccessLevel=='Edit' || acctTeam.get(0).AccountAccessLevel=='All'){
                        validAccess = true;
                  //  }
            }

        if (validAccess) {
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
    
    //-----------------------------------------------------------------------------------------------------
    public integer totalPage {get;set;}
    public integer currentPage {get;set;}
    public decimal recPerPage  = 5;
    public integer startOffset {get;set;}
    public string accid {get;set;}
    public list<lead> listLead {get;set;}
    
    public void campaignLead_RelatedList(string acc_id)
    {
        //leadTemp = new list<lead>();
        //account Acc = (account)sc.getRecord();
        //accid = Acc.id;
        accid = acc_id;
        //leadTemp = [select id from lead where account__c =: Acc.id];
        
        //integer totalRec = [select count() from campaignMember where leadid in: leadTemp];
        integer totalRec = [select count() from lead where account__c =: accid];
        totalPage = integer.valueof((totalRec/recPerPage).round(system.roundingmode.ceiling));
        system.debug(totalPage);
        totalPage = (totalPage < 1) ? 1 : totalPage;
        currentPage = 1;
        startOffset = 0;
        
        //queryCampaignLeadHistory();
        queryLeadHistory();

    }
    
    public void nextPage()
    {
        currentPage = (currentPage != totalPage) ? (currentPage+1) : totalPage;
        startOffset = (currentPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryLeadHistory();
    }
    
    public void previousPage()
    {
        currentPage = (currentPage != 1) ? (currentPage-1) : 1;
        startOffset = (currentPage - 1) * integer.valueof(recPerPage);
        //queryCampaignLeadHistory();
        queryLeadHistory();
    }
    
    /*
    public void queryCampaignLeadHistory()
    {
        campMemTemp = new list<string>();
        mapCampMember = new map<string,campaignMember>();
        campList = new map<string,campaign>();
        
        for (campaignMember a : [select campaignId,lead.name,lead.status,leadid,lead.lastmodifieddate from campaignMember 
                                 where leadid in: leadTemp order by lead.lastmodifieddate desc
                                 limit: integer.valueof(recPerPage) offset: startOffset])
        {
            campMemTemp.add(a.campaignId);
            mapCampMember.put(a.campaignId,a);
        }
        for (campaign a : [select id,name,startdate,enddate,isActive,lastmodifieddate from campaign where id in: campMemTemp])
        {
            campList.put(a.id,a);
        }
    }
    */
    
    public void queryLeadHistory()
    {
        listLead = [select id, Primary_Campaign__r.name, Pri_Campaign_Active__c, Pri_Campaign_Start_Date__c, Pri_Campaign_End_Date__c
                    , Status, Name, lastmodifieddate
                    from lead where account__c =: accid order by lastmodifieddate desc
                    limit: integer.valueof(recPerPage) offset: startOffset];
    }
    
    
    // --------------------------------------------------------------------------------------
    public String section {get;set;}
    public String sectionLeadList {get;set;}

    
    public String section1 {get;set;}
    public String section2 {get;set;}
    public Boolean isLoading {get;set;}
    public Boolean isVisible {get;set;}
    public Boolean isVisibleLeadList {get;set;}
    public Boolean isVisible_product {get;set;}
    public Boolean isVisible_total {get;set;}
    public Boolean isLoadSuccess {get;set;}    
    public Boolean isRenderaccountPlan {get;set;}
    public String checkIsAccessible {get;set;}
    
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
                notAuthorizedMsg = '';
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

    public void loadData()
    {
            try{
                section = apexpages.currentPage().getParameters().get('sectionName');
                sectionLeadList = apexpages.currentPage().getParameters().get('sectionNameLeadList');
            }catch(Exception e){
                this.section = section;
            }

            Account acctDetail = new Account(); 
            Profile userProfile = new Profile();

            try
            {
                acctDetail = [SELECT id,recordType.name,RTL_RM_Name__c,OwnerId FROM Account WHERE id = :acct.id ];
                userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            }
            catch (Exception e)
            {
                isVisible = false;
            }

            isVisible = RTL_AccountUtility.verifyFieldSecurity(section,userProfile.name, acctDetail.id);
            isVisibleLeadList = RTL_AccountUtility.verifyFieldSecurity(sectionLeadList,userProfile.name, acctDetail.id);

                
            notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
        
            if(!isVisible){
                try{
                    checkIsAccessible = apexpages.currentPage().getParameters().get('checkIsAccessible');                    
                }catch (Exception e){
                	checkIsAccessible = '0';
            	}
                if (checkIsAccessible == '1' && !Schema.sObjectType.AcctPlanCompanyProfile__c.isAccessible()) {
                    isAccessible = false;                    
        		}else{
                    isAccessible = true;
                }
                	//notAuthorizedMsg = system.Label.Data_Condition_NotAuthorizedMsg; 
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));
            }

            if(!isVisibleLeadList)
            {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, notAuthorizedMsg));   
            }
        
    }
    
}