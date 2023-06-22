public with sharing class AcctPlanProStrGrpWalletCtrl {}
    
    /*Comment Cleansing Code private ApexPages.StandardController standardController;
    public  ViewState ViewState{ get; set; }  
    public String InfoMessage {get;set;}
    
    public boolean IsLock {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public Boolean isMiniView {get;set;} 
    
    /*Account Team*/
    /*Comment Cleansing Code public List<Account> AccountList {get;set;}
    public Set<Account> AccountSet {get;set;} 
    public Set<ID> AuthorizedSet {get;set;}
    public AcctPlanGroupProfile__c groupprofile {get;set;}
    public  List<AcctPlanCompanyProfile__c> CustomerProfileList {get;set;}
    public String MasterGroupID {get;set;}
    public boolean isDisabled {get;set;}
    public boolean isHasPermission {get;set;}
    Map<ID,String> AccountTeamMap {get;set;}
    public Group__c mGroup {get;set;}
    public boolean isHasAuthorized {get{
        
        isHasAuthorized = false;
        if(AuthorizedSet.contains(Userinfo.getUserId())){
            isHasAuthorized = true;
        }
        
        return isHasAuthorized;
        
    }set;}
    /*End Account Team*/
    
    /*Comment Cleansing Code public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public AcctPlanProStrGrpWalletCtrl(ApexPages.StandardController controller){
        this.ViewState = new ViewState();        
        this.standardController = controller;       
        getUrlParams();
        createViewModel();       
    }
    
    private void getUrlParams(){
        ViewState.CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        ViewState.GroupID   = ApexPages.currentPage().getParameters().get('GroupID');
        ViewState.WalletID  = ApexPages.currentPage().getParameters().get('WalletID');
        MasterGroupID = ApexPages.currentPage().getParameters().get('MasterGroup');
        mode = ApexPages.currentPage().getParameters().get('mode');
        if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        
          if(ViewState.CompanyID !=null && ViewState.CompanyID !=''){
            companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(ViewState.CompanyID);
       
             ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
            System.debug(AccountPlanUtilities.OWNERSEGMENT);
            if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
        }
        /*Account Team*/
       
        //Check Permission
       /*Comment Cleansing Code isHasPermission = false;
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        List<ObjectPermissions> obplist = [SELECT Id, SObjectType, PermissionsRead,PermissionsEdit, PermissionsCreate
                                           FROM ObjectPermissions
                                           WHERE SObjectType =:'AcctPlanGroupProfile__c' AND parentid in (select id from permissionset where
                                                                                                          PermissionSet.Profile.Name =: MyProflieName) ];
        
        if( obplist.get(0).PermissionsEdit || obplist.get(0).PermissionsCreate){
            isHasPermission = true;
        }
       
        AuthorizedSet = new Set<ID>();
        system.debug('ViewState.GroupID='+ViewState.GroupID);
        if(ViewState.GroupID  !=null && ViewState.GroupID !='' ){
            groupprofile = AccountPlanUtilities.QueryGroupProfileByID(ViewState.GroupID).get(0);            
            AccountList = AccountPlanUtilities.QueryAccountByGroupID(groupprofile.Group__c);     
            
            if(AccountList.size()>0){ 
                AccountSet = new Set<Account>();
                AccountSet.addAll(AccountList);
                AccountTeamMap = new Map<ID,String>();
                
                List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                                                    IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                                                    WHERE AccountId IN: AccountSet 
                                                    AND USerId=: Userinfo.getUserId()
                                                   ];
                
                for(AccountTeamMember acctT : AcctTeam){
                    AccountTeamMap.put(acctT.AccountId,acctT.AccountAccessLevel);
                    if(acctT.AccountAccessLevel == 'Edit' || acctT.AccountAccessLevel =='All'){
                        AuthorizedSet.add(acctT.UserId);
                    }
                }
                
                for(Account acct: AccountSet){
                    AuthorizedSet.add(acct.OwnerId); 
                } 
            }
        }else if(MasterGroupID !=null &&MasterGroupID !=''){ 
            isDisabled = false;
            List<Group__c> mastergroup = [SELECT ID,Name, GroupCompany__c 
                                          , GroupIndustry__c 
                                          , Parent_Company__c 
                                          , ParentIndustry__c 
                                          ,UltimateParent__c 
                                   FROM Group__c
                                   WHERE ID =:MasterGroupID];
            if(mastergroup.size()<=0){
                isDisabled=true;
            }
 
        }else{
            isDisabled=true;
        }
        system.debug('isDisabled='+isDisabled);
        system.debug('isHasPermission='+isHasPermission);
        system.debug('isHasAuthorized='+isHasAuthorized);
    }
    
    private void createViewModel(){
        try{
            if(AccountList.size() >60){
                isDisabled = true;
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO,'Number of customers in the group exceeds the system threshold. Please contact administrator for this problem.'));
                //return null;
            }else{
                ViewState.ViewModel  =  AccountPlanProductStrategyService.getGroupCompaniesProductStrategyInfoV2(ViewState.GroupID);        
                
                IsLock =  AcctPlanGroupWalletLockService.IsLock(ViewState.ViewModel.GroupId);
                System.debug('::: IsLock = ' + IsLock);
                
            }
        }
        catch(Exception ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
            system.debug(ex.getMessage()  );
        }       
    }
    
    public PageReference Refresh(){
        InfoMessage ='';
        try{
             IsLock =  AcctPlanGroupWalletLockService.IsLock(ViewState.ViewModel.GroupId);
             if(!IsLock){                
                   // Lock 
                   AcctPlanGroupWalletLockService.Lock(ViewState.ViewModel.GroupId);
                   GroupWalletRefreshEntranceBatch batch = 
                       new GroupWalletRefreshEntranceBatch( ViewState.ViewModel.AccountWithAccountPlan
                                                          , ViewState.ViewModel.AccountWithoutAccountPlan
                                                          ,ViewState.ViewModel.GroupId
                                                          , ViewState.ViewModel.Year
                                                          , ViewState.GroupID  );  
                   /*Comment Cleansing Code Database.executeBatch(batch ,25);   
                   IsLock = true; 
            }                                                           
        }
        catch(Exception ex){
            createNotificationMessageError(ex.getMessage());        
        }        
        createNotificationMessage();      
        return null;
    }
    
    public void createNotificationMessageError(string message){
         InfoMessage =  ' <div class="alert alert-danger"> '
      + '     <a href="#" class="close" data-dismiss="alert">&times;</a> '
      + '    <b>'+message+'</b>'
      + ' </div> ';    
    }
    
     private void createNotificationMessage(){    
        InfoMessage =  ' <div class="alert alert-danger" style="clear:both;   text-align: left;    color: white;    background-color: #FF4000;"> '
            + '<a href="#" class="close" data-dismiss="alert">&times;</a> '
            + '<p><b>System will take approx 5-10 mins to refresh data. Email notification will be sent after finished. Please click the link from an email or Press F5 on screen.</b></p> '
            + '<p><b>(ระบบได้รับ request แล้ว  จะใช้เวลาประมาณ 5-10 นาที คุณจะได้รับอีเมล์หลังจากระบบประมวลผลเสร็จ   กรุณาคลิกลิงค์จากอีเมล์ หรือ กด F5 จากหน้าจอเพื่อดูข้อมูลใหม่)</b> </p> '
            + ' </div><script> jsHideToggle();  </script> ';
    }
    /*  Data Model For This Page */
    /*Comment Cleansing Code public class ViewState{
        //Account Navigation information
        public  String CompanyID {get;set;}
        public  String GroupID {get;set;}
        public  String WalletID {get;set;}
        //DTO
        public  AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo ViewModel {get;set;} 
    }  
}*/