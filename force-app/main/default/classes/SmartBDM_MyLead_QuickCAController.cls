public class SmartBDM_MyLead_QuickCAController {
    private final integer limitoffset = 2000;
	public String filter_customerType {get; set;}
    public String filter_primaryCampaign {get; set;}
    
    public Id OwnerId { get; set; }
    private Id refLeadId { get; set; }
    public String refType { get; set; }
    public String refReturnPage { get; set; }
    // public Lead lead { get;set; }
    public Integer countLeads { get; set; }
    public List<Lead> leads { get; set; }
    // List<Lead> SOSLleads { get; set; }
    
    public String searchKey{get;set;}

	// Sorting and Offset
    private String column;
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
                if(currentPage * limitSelect < countLeads){
                    records = currentPage * limitSelect;
                }
                else
                {
                    records = countLeads;
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

    public final Set<Id> LeadRecordTypeCriteria {
        get {
            if(LeadRecordTypeCriteria == null) {
                LeadRecordTypeCriteria = new Set<Id> {
                    QCA_LeadSimplifiedController.CommercialLeadRecordTypeId, QCA_LeadSimplifiedController.CommercialAccountRecordTypeId
                };
            }
            return LeadRecordTypeCriteria;
        }
        set;
    }
    public final List<String> LeadStatusCriteria = new List<String> { 'Open', 'Passed Prescreening', 'Contacted', 'Qualified' };
    
	public SmartBDM_MyLead_QuickCAController() {
		try {
			this.OwnerId = UserInfo.getUserId();

            if(limitSelect == null){
                // shuold be set custom meta or custome setting
                Smart_BDM_Setting__mdt settings = [SELECT Id, Number_of_Records__c, Deep_link_iOS__c, Deep_link_Android__c
                    FROM Smart_BDM_Setting__mdt 
                    WHERE DeveloperName = 'Smart_BDM_Setting'];
                this.limitSelect = integer.valueOf(settings.Number_of_Records__c);
                this.Deeplink_iOS = Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
                this.Deeplink_Android = Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;
                
            }

            // get customer list and display
            this.leads = getLeads();
            if (countLeads == null)
            {
                resetShowingPages();
            }

            this.refReturnPage =  ApexPages.currentPage().getUrl();
            // this.refReturnPage =  '/lightning/n/Smart_BDM_Lead';

        }catch(Exception e){
            System.debug('constructor SmartBDM_MyLead_QuickCAController error: ' + e.getMessage());
        }
	}

	public List<SelectOption> getselectValues_customerType(){
        List<SelectOption> sO = new List<SelectOption>();
        // Set Default empty value
        sO.add(new SelectOption('', 'View all Customer Type'));
        List<aggregateResult> results = [SELECT Customer_Type__c
                    FROM Lead WHERE RecordTypeId IN :LeadRecordTypeCriteria
                    AND OwnerId =: this.OwnerId 
                    GROUP BY Customer_Type__c];
        for (aggregateResult ar : results) {
           if(ar.get('Customer_Type__c') != null){
                sO.add(new SelectOption((String)ar.get('Customer_Type__c'), (String)ar.get('Customer_Type__c')));
            }
        }
        return sO;
    }

    public List<SelectOption> getselectValues_primaryCampaign(){
        List<SelectOption> sO = new List<SelectOption>();
        // Set Default empty value
        sO.add(new SelectOption('', 'View all Primary Campaign'));
        List<aggregateResult> results = [SELECT Primary_Campaign__c, Primary_Campaign__r.Name
                    FROM Lead WHERE RecordTypeId IN :LeadRecordTypeCriteria AND Primary_Campaign__c != null
                    AND OwnerId =: this.OwnerId 
                    GROUP BY Primary_Campaign__r.Name, Primary_Campaign__c];
        for (aggregateResult ar : results)
        {
           sO.add(new SelectOption((String)ar.get('Primary_Campaign__c'), (String)ar.get('Name')));
        }
        return sO;
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

	public List<Lead> getLeads() {
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
                if(filter_customerType != null){
                    andCustomerType = ' AND Customer_Type__c = \'' + filter_customerType + '\'';
                }

                String andPrimaryCampaign = '';
                if(filter_primaryCampaign != null){
                    andPrimaryCampaign = ' AND Primary_Campaign__c = \'' + filter_primaryCampaign + '\'';
                }

                if(searchKey != null && searchKey != '' && searchKey.length() >= 3){
                    String searchQuery = 'FIND \'' + searchKey + '* OR 0011*' + searchKey + '*\' IN ALL FIELDS RETURNING Lead(Id, Name, Customer_Type__c, CreatedDate, Primary_Campaign__c, Primary_Campaign__r.Name,TMB_Cust_ID__c, Account__c, Account__r.TMB_Customer_ID_PE__c WHERE OwnerID = :OwnerId AND RecordTypeId IN :LeadRecordTypeCriteria AND Status IN :LeadStatusCriteria' + andCustomerType + andPrimaryCampaign + sorting + ' OFFSET ' + this.offset +') LIMIT ' + this.limitSelect;
                    System.debug(searchQuery);
                    leads = search.query(searchQuery)[0];
                }
                else
                {
                    String query = 'SELECT Id, Name, Customer_Type__c, CreatedDate, Primary_Campaign__c, Primary_Campaign__r.Name, Account__c FROM Lead WHERE RecordTypeId IN :LeadRecordTypeCriteria AND Status IN :LeadStatusCriteria AND OwnerId = :OwnerId'+ andCustomerType + andPrimaryCampaign + sorting + ' LIMIT ' + this.limitSelect + ' OFFSET '+ this.offset;
                    leads = Database.query(query);
                }
                // System.debug(query);
            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }else{
            leads = null;
        }
        return leads;
    }

    public Integer getCountLeads(){
		String andCustomerType = '';
        List<Lead> lead_list = new List<Lead>();
        if(filter_customerType != null){
            andCustomerType = ' AND Customer_Type__c = \'' + filter_customerType + '\'';
        }

        String andPrimaryCampaign = '';
        if(filter_primaryCampaign != null){
            andPrimaryCampaign = ' AND Primary_Campaign__c = \'' + filter_primaryCampaign + '\'';
        }

        if(searchKey != null && searchKey != '' && searchKey.length() >= 3) {
            String searchQuery = 'FIND \'' + searchKey + '* OR 0011*' + searchKey + '*\' IN ALL FIELDS RETURNING Lead(Id, Name, Customer_Type__c, CreatedDate, Primary_Campaign__c, Primary_Campaign__r.Name, Account__c WHERE OwnerID = :OwnerId AND RecordTypeId IN :LeadRecordTypeCriteria AND Status IN :LeadStatusCriteria' + andCustomerType + andPrimaryCampaign + ')';
            lead_list = search.query(searchQuery)[0];
        } else {
            String query = 'SELECT Id, Name, Customer_Type__c FROM Lead WHERE OwnerId = :OwnerId AND RecordTypeId IN :LeadRecordTypeCriteria AND Status IN :LeadStatusCriteria' + andCustomerType + andPrimaryCampaign;
            lead_list = Database.query(query);
        }

        if(lead_list.size() <= this.limitoffset)
        {
            return lead_list.size();
        }
        else
        {
            return this.limitoffset;
        }
    }

	public void resetShowingPages(){
        countLeads = getCountLeads();
		if(Math.mod(countLeads, limitSelect) == 0){
			pages = countLeads / limitSelect;
		}
		else
		{
			pages = (countLeads / limitSelect) + 1;
		}
    }

	public void sortLeadColumn(){
        this.sortDirection = toggleSortDirection();
        this.sortcolumn = ApexPages.currentPage().getParameters().get('column');
        leads = getLeads();
    }

	public void filterCustomerType(){
        this.currentPage = 1;
        resetShowingPages();
        leads = getLeads();
    }

    public void filterPrimaryCampaign(){
        this.currentPage = 1;
        resetShowingPages();
        leads = getLeads();   
    }

	// public PageReference open_minicsv(){
    //     this.refLeadId = ApexPages.currentPage().getParameters().get('refLeadId');
    //     this.refType = ApexPages.currentPage().getParameters().get('refType');
    //     PageReference mini_CSV = new PageReference('/apex/Mini_CSV?id=' + this.refLeadId + '&retURL='+ this.refReturnPage + '&refType='+ this.refType);
    //     mini_CSV.setRedirect(true);
    //     return mini_CSV;
    // }

	public void NextPage(){
        if(this.currentPage <= this.pages && this.offset <= this.limitoffset){
            this.currentPage = this.currentPage + 1;
            leads = getLeads();
        }
    }

    public void PreviousPage(){
        if(this.currentPage > 1 ){
            this.currentPage = this.currentPage - 1;
            leads = getLeads();
        }
    }
	
}