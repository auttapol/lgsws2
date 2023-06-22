public class BDM_Customer_data {
    private final integer limitoffset = 2000;
    public String filterTypeId {get; set;}
    
    public Id OwnerId { get; set; }
    public Id refAccountId { get; set; }
    public String refType { get; set; }
    public String refReturnPage { get; set; }
    // public Account acct { get;set; }
    public Integer countAccounts { get; set; }
    public List<Account> accounts { get; set; }
    // List<Account> SOSLaccts { get; set; }
    // List<Lead> leads;

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
    public Set<Id> accountTeamId {
        get {
            if(accountTeamId == null) {
                accountTeamId = new Set<Id>();
                for (AccountTeamMember accteam : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE UserId =: this.OwnerId]){
                    accountTeamId.add(accteam.AccountId);
                }
            }
            return accountTeamId;
        }
        set;
    }

    public String Deeplink_iOS { get; set; }
    public String Deeplink_Android { get; set; }

    public String searchKey {get; set;}

    public BDM_Customer_data(){
        try {
            this.OwnerId = UserInfo.getUserId();
            // this.OwnerId = '00590000003xlDyAAI';
            
            if(limitSelect == null){
                Smart_BDM_Setting__mdt settings = [SELECT Id, Number_of_Records__c, Deep_link_iOS__c, Deep_link_Android__c
                    FROM Smart_BDM_Setting__mdt 
                    WHERE DeveloperName = 'Smart_BDM_Setting'];
                this.limitSelect = integer.valueOf(settings.Number_of_Records__c);
                this.Deeplink_iOS = settings.Deep_link_iOS__c;
                this.Deeplink_Android = settings.Deep_link_Android__c;
                
            }
            if (countAccounts == null){
                resetShowingPages();
            }
            
            // get customer list and display
            System.debug('BDM_Customer_data: ');
            this.accounts = getAccounts();
            this.refReturnPage =  ApexPages.currentPage().getUrl();
            // this.refReturnPage =  '/lightning/n/Smart_BDM_Customer';

        }catch(Exception e){
            System.debug('constructor BDM_Customer_data error: ' + e.getMessage());
        }
    }

    public List<SelectOption> getselectValues(){
        List<SelectOption> sO = new List<SelectOption>();
        // Set Default empty value
        sO.add(new SelectOption('', 'View all Customer Type'));
        List<aggregateResult> results = [SELECT Customer_Type__c
                    FROM Account WHERE RecordType.Name in ('Existing Customer', 'Prospect')
                    AND OwnerId =: this.OwnerId 
                    GROUP BY Customer_Type__c];
        for (aggregateResult ar : results) {
            if(ar.get('Customer_Type__c') != null){
                sO.add(new SelectOption((String)ar.get('Customer_Type__c'), (String)ar.get('Customer_Type__c')));
            }
        }
        return sO;
    }

    public List<Account> getAccounts() {
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
                String andCustomerType = '';
                if(filterTypeId != null){
                    andCustomerType = ' AND Customer_Type__c = \'' + filterTypeId + '\'';
                }
                
                

                if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
                    String searchQuery = 'FIND \'' + searchKey + '* OR 0011*' + searchKey + '*\' IN ALL FIELDS RETURNING  Account(Id, Name, Customer_Type__c, TMB_Customer_ID_PE__c, ID_Number_PE__c WHERE (OwnerID = :OwnerId OR Id IN :accountTeamId ) AND RecordType.Name IN (\'Existing Customer\', \'Prospect\')' + andCustomerType + sorting + ' OFFSET ' + this.offset +') LIMIT ' + this.limitSelect;
                    System.debug('searchQuery :::: ' + searchQuery);
                                        
                    // SOSLaccts = search.query(searchQuery)[0];
                    // System.debug('Get Account');
                    // System.debug(SOSLaccts.size());
                    accounts = search.query(searchQuery)[0];
                }
                else{
                    String query = 'SELECT Id, Name, Customer_Type__c FROM Account WHERE RecordType.Name IN (\'Existing Customer\', \'Prospect\') AND (OwnerID = :OwnerId OR Id IN :accountTeamId )' + andCustomerType + sorting + ' LIMIT ' + this.limitSelect + ' OFFSET '+ this.offset;
                    accounts = Database.query(query);
                }
                
            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        	
        }else{
            accounts = null;
        }
        return accounts;
    }

    public Integer getCountAccount(){
        String andCustomerType = '';
        String query = '';
        List<Account> acct_list = new List<Account>();

        if(filterTypeId != null){
            andCustomerType = ' AND Customer_Type__c = \'' + filterTypeId + '\'';
        }
        // List<Account> acct_list = [SELECT Id, Name, Customer_Type__c FROM Account WHERE RecordType.Name in ('Existing Customer', 'Prospect') AND OwnerId =: this.OwnerId];
        query = 'SELECT Id, Name, Customer_Type__c FROM Account WHERE RecordType.Name in (\'Existing Customer\', \'Prospect\') AND (OwnerID = :OwnerId OR Id IN :accountTeamId )' + andCustomerType;
        
        if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
            String searchQuery = 'FIND \'' + searchKey + '* OR 0011*' + searchKey + '*\' IN ALL FIELDS RETURNING  Account(Id, Name, Customer_Type__c, TMB_Customer_ID_PE__c, ID_Number_PE__c WHERE (OwnerID = :OwnerId OR Id IN :accountTeamId ) AND RecordType.Name IN (\'Existing Customer\', \'Prospect\')' + andCustomerType + ')';
            acct_list = search.query(searchQuery)[0];
        }else{
            acct_list = Database.query(query);
        }

        System.debug('Get Count Account ::: ' + acct_list.size());
        if(acct_list.size() <= this.limitoffset)
        {
            return acct_list.size();
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
        accounts = getAccounts();
    }

    public void filterCustomerType(){
        this.currentPage = 1;
        resetShowingPages();
        accounts = getAccounts();
    }

    public void NextPage(){
        // Limitation of offset is 2000
        if(this.currentPage <= this.pages && this.offset <= this.limitoffset){
            this.currentPage = this.currentPage + 1;
            accounts = getAccounts();
        }
    }
    public void PreviousPage(){
        if(this.currentPage > 1 ){
            this.currentPage = this.currentPage - 1;
            accounts = getAccounts();
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