public without sharing class SmartBDM_MyOpportunity_QuickCACtrl {
    
    private final integer limitoffset = 2000;
    public String filterStageName {get; set;}
    
    public Id OwnerId { get; set; }
    public Id refAccountId { get; set; }
    public String refType { get; set; }
    public String refReturnPage { get; set; }
    public Id accId { get;set; }
    public Id recordTypeIdOppty { get;set; }
    public Integer countAccounts { get; set; }
    // public List<Account> oppties { get; set; }
    public List<Opportunity> oppties { get; set; }
    // List<Account> SOSLaccts { get; set; }
    // List<Lead> leads;
    public Account acct {get;set;}
    
    private String column;
    // Sorting and Offset456
    public String sortDirection;
    public String sortcolumn;
    
    private Integer limitSelect { get; set; }
    public Integer pages { get; set; }
    public Integer currentPage {
        get
        {
            if(currentPage != null){
                if(currentPage < 0){
                    currentPage = 1;
                }
                else if(currentPage > this.pages)
                {
                    currentPage = this.pages;
                }
            }
            else
            {
                currentPage = 1;
            }
            return currentPage;
        }
        set;
    }
    public Integer offset { get; set; }
    public Integer records { 
        get {
            if(currentPage != null && limitSelect != null){
                if(currentPage * limitSelect < countAccounts){
                    records = currentPage * limitSelect;
                }
                else
                {
                    records = countAccounts;
                }
            }
            else
            {
                records = limitSelect;
            }
            return records;
        }
        set; 
    }

    public String Deeplink_iOS { get; set; }
    public String Deeplink_Android { get; set; }

    public String searchKey {get; set;}

    public SmartBDM_MyOpportunity_QuickCACtrl(){
        try {
            this.OwnerId = UserInfo.getUserId();
            this.accId = ApexPages.currentPage().getParameters().get('accId');
            acct = [SELECT Id, Name, customer_type__c, Core_Banking_Suggested_Segment__c, TMB_Customer_ID_PE__c  FROM Account WHERE id =: this.accId LIMIT 1];
        
            if(limitSelect == null){
                Smart_BDM_Setting__mdt settings = [SELECT Id, Number_of_Records__c, Deep_link_iOS__c, Deep_link_Android__c
                    FROM Smart_BDM_Setting__mdt 
                    WHERE DeveloperName = 'Smart_BDM_Setting'];
                this.limitSelect = integer.valueOf(settings.Number_of_Records__c);
                this.Deeplink_iOS = Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
                this.Deeplink_Android = Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
                
            }
            if (countAccounts == null){
                resetShowingPages();
            }
            
            // get customer list and display
            this.oppties = getOpportunities();
            this.recordTypeIdOppty = Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY;
            this.refReturnPage =  ApexPages.currentPage().getUrl();
            // this.refReturnPage =  '/lightning/n/Smart_BDM_Customer';

        }catch(Exception e){
            System.debug('constructor SmartBDM_MyOpportunity_QuickCACtrl error: ' + e.getMessage());
        }
    }

    public List<SelectOption> getselectValues(){
        List<SelectOption> sO = new List<SelectOption>();
        // Set Default empty value
        sO.add(new SelectOption('', 'View all Stage'));
        // List<aggregateResult> results = [SELECT StageName
        //             FROM Opportunity WHERE StageName != 'Submit to Credit Process'
        //             GROUP BY StageName Order By StageName ];
        List<SmartBDM_PicklistOption> results = SmartBDM_PicklistDescriber.describe('Opportunity', recordTypeIdOppty, 'StageName');
        for (SmartBDM_PicklistOption ar : results) {
            // if(ar.get('StageName') != null ){
            //     sO.add(new SelectOption((String)ar.get('StageName'), (String)ar.get('StageName')));
            // }
            if(ar.value != null && ar.value != 'Submit to Credit Process'){
                 sO.add(new SelectOption(((String)ar.value).unescapeHtml4(), ((String)ar.label).unescapeHtml4()));
            }
        }
        return sO;
    }

    public List<Opportunity> getOpportunities() {
        if(OwnerId != null){
            try{
                String sorting = '';
                if(sortDirection != null){
                    sorting = ' ORDER BY ' + sortcolumn + ' ' + sortDirection;
                }
                
                if(currentPage != null){
                    if(currentPage - 1 >= 0){
                        this.offset = (currentPage - 1) * limitSelect;
                    }
                    else
                    {
                        this.offset = currentPage * limitSelect;
                    }

                }
                String stageNameSearchKey = '';
                String query ='';
                if(filterStageName != null){
                    stageNameSearchKey = ' AND StageName = \'' + filterStageName + '\'';
                }
                
                if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
                    query = 'SELECT Id, Name, StageName,Segment2__c FROM Opportunity WHERE Name LIKE\'%'+searchKey+'%\' AND AccountId = \''+ this.accId + '\' ' + stageNameSearchKey +' AND RecordTypeId = \''+Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY +'\' '+ sorting + ' LIMIT ' + this.limitSelect + ' OFFSET '+ this.offset;
                }else{
                    query = 'SELECT Id, Name, StageName,Segment2__c FROM Opportunity WHERE AccountId = \''+ this.accId + '\' ' + stageNameSearchKey +' AND RecordTypeId = \''+Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY +'\' '+ sorting + ' LIMIT ' + this.limitSelect + ' OFFSET '+ this.offset;
                }
                System.debug('query 1:'+query);
                oppties = Database.query(query);

                // if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
                //     String searchQuery = 'FIND \'' + searchKey + '* OR 0011*' + searchKey + '*\' IN ALL FIELDS RETURNING  Account(Id, Name, Customer_Type__c, TMB_Customer_ID_PE__c, ID_Number_PE__c WHERE OwnerID = \'' + this.OwnerId + '\'  AND RecordType.Name IN (\'Existing Customer\', \'Prospect\')' + andCustomerType + sorting + ' OFFSET ' + this.offset +') LIMIT ' + this.limitSelect;
                //     System.debug('searchQuery :::: ' + searchQuery);
                                        
                //     // SOSLaccts = search.query(searchQuery)[0];
                //     // System.debug('Get Account');
                //     // System.debug(SOSLaccts.size());
                //     oppties = search.query(searchQuery)[0];
                // }
                // else{
                //     String query = 'SELECT Id, Name, StageName FROM Opportunity WHERE AccountId =: '+ this.ac+'\'Prospect\') AND OwnerId = \''+ this.OwnerId +'\'' + andCustomerType + sorting + ' LIMIT ' + this.limitSelect + ' OFFSET '+ this.offset;
                //     oppties = Database.query(query);
                // }
                
            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        	
        }else{
            oppties = null;
        }
        return oppties;
    }

    public Integer getCountAccount(){
        // String andCustomerType = '';
        String query = '';
        List<Opportunity> oppty_list = new List<Opportunity>();

         String stageNameSearchKey = '';
        if(filterStageName != null){
            stageNameSearchKey = ' AND StageName = \'' + filterStageName + '\'';
        }
        
        if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
            query = 'SELECT Id, Name, StageName,Segment2__c FROM Opportunity WHERE Name LIKE\'%'+searchKey+'%\' AND AccountId = \''+ this.accId + '\' ' + stageNameSearchKey +' AND RecordTypeId = \''+Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY +'\'';
            
        }else{
            query = 'SELECT Id, Name, StageName,Segment2__c FROM Opportunity WHERE  AccountId = \''+ this.accId + '\' ' + stageNameSearchKey +' AND RecordTypeId = \''+Smart_BDM_Constant.SE_CREDIT_PRODUCT_RECORDTYPE_ID_OPPTY +'\' ';
        }
        System.debug('query :'+query);
        oppty_list = Database.query(query);

        System.debug('Get Count Opportunity ::: ' + oppty_list.size());
        if(oppty_list.size() <= this.limitoffset)
        {
            return oppty_list.size();
        }
        else
        {
            return this.limitoffset;
        }
    }

    public String toggleSortDirection() {
        if(sortDirection == 'asc')
        {
            sortDirection = 'desc';
        }
        else if(sortDirection == 'desc')
        {
            sortDirection = 'asc';
        }
        else
        {
            sortDirection = 'desc';
        }
        return sortDirection;
    }

    /* check if the VF page is display by SF1 */
    public Boolean isSF1 {
        get {                   
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }

    public void resetShowingPages(){
        countAccounts = getCountAccount();
        if(Math.mod(countAccounts, limitSelect) == 0){
            pages = countAccounts / limitSelect;
        }
        else
        {
            pages = (countAccounts / limitSelect) + 1;
        }
    }
        
    public void sortAccColumn(){
        this.sortDirection = toggleSortDirection();
        this.sortcolumn = ApexPages.currentPage().getParameters().get('column');
        oppties = getOpportunities();
    }

    public void filterCustomerType(){
        this.currentPage = 1;
        resetShowingPages();
        oppties = getOpportunities();
    }

    public void NextPage(){
        // Limitation of offset is 2000
        if(this.currentPage <= this.pages && this.offset <= this.limitoffset){
            this.currentPage = this.currentPage + 1;
            oppties = getOpportunities();
        }
    }
    public void PreviousPage(){
        if(this.currentPage > 1 ){
            this.currentPage = this.currentPage - 1;
            oppties = getOpportunities();
        }
    }
    
    // public PageReference open_minicsv(){
    //     this.refAccountId = ApexPages.currentPage().getParameters().get('refAccountId');
    //     this.refType = ApexPages.currentPage().getParameters().get('refType');
    //     // PageReference mini_CSV = new PageReference('/apex/Mini_CSV?id=' + refAccountId);
    //     //PageReference mini_CSV = new PageReference('/apex/Mini_CSV?id=' + this.refAccountId + '&retURL='+ this.refReturnPage + '&refType='+ this.refType);
    //     PageReference mini_CSV = new PageReference('/' + this.refAccountId );
    //     mini_CSV.setRedirect(true);
    //     return mini_CSV;
    // }
}