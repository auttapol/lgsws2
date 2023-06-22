global with sharing class SmartBDM_EnliteSearchCompanyCtrl {
    public String deeplinkToKony {get {return Smart_BDM_Constant.DEEP_LINK_TO_KONY_LANDING;}}
    public String lightningBaseURL {get;set;}
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

    public class Company extends AbstractCoreClass implements Comparable {
        public Account account {get; set;}
        public Boolean SF {get; set;}
        public Boolean Enlite {get; set;}
        public String OnwerName {get; set;}
        public Boolean isOnwer {get; set;}

        public String accountName {
            get {
                return this.account.Name;
            }
        }
        public String registerId {
            get {
                return this.account.ID_Number_PE__c;
            }
        }

        public String param {get; set;}
        public String order {get; set;}

        public Company() {
            this.account = new Account();
            this.SF = false;
            this.Enlite = false;
            this.OnwerName = '';
            this.isOnwer = false;
        }

        public Integer compareTo(Object compareTo) {
            Company compareToCompany = (Company)compareTo;

            String thisCompare = (String)this.getProperty(this.param);
            String toCompare = (String)compareToCompany.getProperty(this.param);

            // Inverse ordering
            if(this.order == 'asc') 
                return thisCompare < toCompare ? 1 : (thisCompare > toCompare ? -1 : 0); // Descending
            else 
                return thisCompare < toCompare ? -1 : (thisCompare > toCompare ? 1 : 0); // Ascending
        }
    }

    // setting limit record for display
    public final integer limitOffset { get{ return Smart_BDM_Constant.LIMIT_OFFSET_RECORD; } } // 200;
    public final integer limitRecord { get{ return Smart_BDM_Constant.LIMIT_DISPLAY_RECORD; } } // 20;
    public Integer offset { 
        get {
            if(currentPage - 1 >= 0){
                offset = (currentPage - 1) * this.limitRecord;
            }
            else
            {
                offset = currentPage * this.limitRecord;
            }
            return offset;
        }
        set;
    }
    public Integer to { 
        get {
            if(offset + this.limitRecord <= records){
                to = offset + this.limitRecord;
            }
            else {
                to = offset + Math.mod(records, this.limitRecord);
            }
            return to;
        }
        set;
    }
    public Integer records { 
        get {
            if(this.companyList.size() < this.limitOffset){
                records = this.companyList.size();
            }
            else
            {
                records = this.limitOffset;
            }
            return records;
        }
        set; 
    }
    public Integer currentPage {
        get
        {
            if(currentPage == null || currentPage <= 0) {
                currentPage = 1;
            }
            else if(currentPage >= this.pages)
            {
                currentPage = this.pages;
            }
            return currentPage;
        }
        set;
    }
    public Integer pages { 
        get {
            if(Math.mod(records, this.limitRecord) == 0){
                return records / this.limitRecord;
            }
            else
            {
                return (records / this.limitRecord) + 1;
            }
        }   
    }
    
    // public String searchCompanyKey {get; set;}
    // public Boolean showErrorMessage {get{if(showErrorMessage == null) showErrorMessage = false; return showErrorMessage;} set;}
    public String orderCompanyKey {get; set;}
    public String resultCompany {get; set;}
    public List<Company> companyList {get { if(companyList == null) companyList = new List<Company>(); return companyList; } set;}
    public List<Company> companyListDisplay {get { if(companyListDisplay == null) companyListDisplay = new List<Company>(); return companyListDisplay; } set;}
    public Id currentUserId { get{ if(currentUserId == null) currentUserId = UserInfo.getUserId(); return currentUserId;} set;}
    public SmartBDM_EnliteSearchCompanyCtrl() {
        if (!isSF1) {
            String hostname = Url.getSalesforceBaseUrl().getHost();
            String myDomain = hostname.split('\\.')[0];
            if(myDomain.contains('--')) {
                //uses lastIndex to exclude namespace but include sandbox names
                // e.g. https://mydomain--sandbox--namespace.visualforce.com
                // and https://mydomain--namespace.visualforce.com
                myDomain = myDomain.substring(0, hostname.lastIndexOf('--'));
            }
            lightningBaseURL = 'https://' + myDomain + '.lightning.force.com';
            ApexPages.currentPage().getHeaders().put('X-Frame-Options', 'ALLOW-FROM ' + lightningBaseURL);
            ApexPages.currentPage().getHeaders().put('Content-Security-Policy', 'frame-ancestors ' + lightningBaseURL);
        }
    }

    @AuraEnabled
    public static List<String> getVFBaseURL() {
        String hostname = Url.getSalesforceBaseUrl().getHost();
        // will support prod and sandboxes
        // e.g. https://mydomain--sandbox.lightning.force.com
            // and https://mydomain.lightning.force.com
        System.debug(hostname);
        String myDomain = hostname.split('\\.')[0];
        // String namespace = SmartBDM_CalculateWCController.class.getName().split('\\.')[0];
        String namespace = 'c';

        System.debug('namespace :: ' + namespace);
        String pod = [SELECT InstanceName FROM Organization].InstanceName.toLowerCase();
        return new List<String>{
                'https://' + myDomain + '--' + namespace + '.visualforce.com',
                'https://' + myDomain + '--' + namespace + '.' + pod + '.visual.force.com'
        };
    }
    
    @AuraEnabled
    public static Integer getLimitOffsetRecord() {
        return Smart_BDM_Constant.LIMIT_OFFSET_RECORD;
    }

    public void refreshCompanyTable() {
        try {
            SmartBDMEnliteCompany.CompanyResponse companyResponse = (SmartBDMEnliteCompany.CompanyResponse)JSON.deserialize(resultCompany, SmartBDMEnliteCompany.CompanyResponse.class);
            Map<String, List<String>> listSearchDesc = new Map<String, List<String>>();
            for (SmartBDMEnliteCompany.ResultSearchDesc r : companyResponse.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs) {
                listSearchDesc.put(r.ResultDesc, r.Value);
            }

            String key = String.join(listSearchDesc.get('REGISTRATION_ID'), ' OR ');
            String searchQuery = 'FIND {' + key + '} IN ALL FIELDS RETURNING Account(Id, Name, Customer_Type__c, Core_Banking_Suggested_Segment__c, TMB_Customer_ID_PE__c, ID_Number_PE__c, OwnerId, Customer_Owner__c)';
            List<Account> tmpAccount = (List<Account>)Search.query(searchQuery)[0];
            
            Map<String, Account> mapAccount = new Map<String, Account>();
            for (Account a : tmpAccount) {
                mapAccount.put(a.ID_Number_PE__c, a);
            }

            companyList = new List<Company>();
            for (SmartBDMEnliteCompany.Company c : companyResponse.parseList()) {
                Company tmp_c = new Company();
                if(mapAccount.containsKey(c.REGISTRATION_ID)){
                    tmp_c.SF = true;
                    tmp_c.Enlite = true;
                    tmp_c.account = new Account(Id=mapAccount.get(c.REGISTRATION_ID).Id, Name=mapAccount.get(c.REGISTRATION_ID).Name, Customer_Name_PE_Eng__c=c.NAME_EN, ID_Number_PE__c=c.REGISTRATION_ID);
                    tmp_c.OnwerName = mapAccount.get(c.REGISTRATION_ID).Customer_Owner__c;
                    tmp_c.isOnwer = currentUserId == mapAccount.get(c.REGISTRATION_ID).OwnerId ? true : false;
                }
                else {
                    tmp_c.Enlite = true;
                    tmp_c.account = new Account(Name=c.NAME_TH, Customer_Name_PE_Eng__c=c.NAME_EN, ID_Number_PE__c=c.REGISTRATION_ID);
                }
                companyList.add(tmp_c);
            }

            companyListDisplay = new List<Company>();
            for (Integer i = 0; i < this.to && i < companyList.size(); i++) {
                companyListDisplay.add(companyList.get(i));
            }
            this.currentPage = 1;
        } catch (Exception e) {
            System.debug('System error: ' + e.getMessage());
            System.debug('There is error during processing : ' + e.getStackTraceString());
            companyList = new List<Company>();
            companyListDisplay = new List<Company>();
        }
    }

    public void NextPage(){
        if(this.currentPage <= this.pages && this.offset <= this.limitOffset){
            this.currentPage = this.currentPage + 1;
            reCompanyTable();
        }
    }

    public void PreviousPage(){
        if(this.currentPage > 1 ){
            this.currentPage = this.currentPage - 1;
            reCompanyTable();
        }
    }

    public void SortCompany(){
        for (Company c : this.companyList) {
            c.param = this.orderCompanyKey;
            c.order = c.order == null ? 'asc' : (c.order == 'asc' ? 'desc' : 'asc');
        }
        this.companyList.sort();
        reCompanyTable();
    }

    public void reCompanyTable(){
        companyListDisplay = new List<Company>();
        for (Integer i = this.offset; i < this.to && i < companyList.size(); i++) {
            companyListDisplay.add(companyList.get(i));
        }
    }

    public class CompanyWrapper {
        public SmartBDMEnliteCompany.CompanyResponse companyList {get; set;}
        public SmartBDMEnliteCompanyDetail.CompanyProfile companyDetail {get; set;}
        
        @AuraEnabled
        public Map<String, Object> tempCompanyList {get { return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this.companyList)); } }
        @AuraEnabled
        public Map<String, Object> tempCompanyDetail {get { return (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this.companyDetail)); } }
        @AuraEnabled
        public Account tempCompanyDetailAccount { get { return this.companyDetail != null ? this.companyDetail.parseToAccount() : null; } }
        @AuraEnabled
        public Boolean isSuccess {get; set;}
        @AuraEnabled
        public String errorMessage {get; set;}
    }

    // Action method
    @RemoteAction
    global static Object startCallGetCompanyListService(String searchCompanyKey) {
        SmartBDMEnliteCompany smartBDMEnlite = new SmartBDMEnliteCompany();
        SmartBDMEnliteCompany.Request request = new SmartBDMEnliteCompany.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RequiredTable = 'COMPANY_PROFILE';
        request.ResultFields = 'REGISTRATION_ID, NAME_EN, NAME_TH';
        request.CriteriaField0 = 'REGISTRATION_ID';
        request.CriteriaOperator0 = 'contains';
        request.CriteriaValues0 = searchCompanyKey;
        request.CriteriaAndOr0 = 'Or';
        request.CriteriaField1 = 'NAME_EN';
        request.CriteriaOperator1 = 'contains';
        request.CriteriaValues1 = searchCompanyKey;
        request.CriteriaAndOr1 = 'Or';
        request.CriteriaField2 = 'NAME_TH';
        request.CriteriaOperator2 = 'contains';
        request.CriteriaValues2 = searchCompanyKey;
        smartBDMEnlite.companyRequest.GetExcuteSearchRequest = request;
        return SmartBDM_EnliteService.startCallGetCompanyListService(smartBDMEnlite);
    }

    // Get Company Profile on Quick CA for Search list
    @AuraEnabled(continuation=true)
    global static Object startCallGetCompanyListServiceContinuation(String searchCompanyKey, Boolean combineTable) {
        SmartBDMEnliteCompany smartBDMEnlite = new SmartBDMEnliteCompany();
        SmartBDMEnliteCompany.Request request = new SmartBDMEnliteCompany.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RequiredTable = 'COMPANY_PROFILE' + (combineTable ?  ', FINANCIAL_CURRENT': '');
        request.ResultFields = 'REGISTRATION_ID, NAME_EN, NAME_TH' + (combineTable ?  ', FS_YEAR': '');
        request.CriteriaField0 = 'REGISTRATION_ID';
        request.CriteriaOperator0 = 'contains';
        request.CriteriaValues0 = searchCompanyKey;
        request.CriteriaAndOr0 = 'Or';
        request.CriteriaField1 = 'NAME_EN';
        request.CriteriaOperator1 = 'contains';
        request.CriteriaValues1 = searchCompanyKey;
        request.CriteriaAndOr1 = 'Or';
        request.CriteriaField2 = 'NAME_TH';
        request.CriteriaOperator2 = 'contains';
        request.CriteriaValues2 = searchCompanyKey;
        smartBDMEnlite.companyRequest.GetExcuteSearchRequest = request;
        return SmartBDM_EnliteService.startCallGetCompanyListService(smartBDMEnlite);
    }
        
    @AuraEnabled
    global static Object callBackGetCompanyListServiceContinuation(Object state) { 
        return SmartBDM_EnliteService.callBackGetCompanyListServiceContinuation(state);
    }
    
    @AuraEnabled(continuation=true)
    global static Object startCallGetCompanyDetailService(String registerId, String fiscalYear) {
        SmartBDMEnliteCompanyDetail smartBDMEnlite = new SmartBDMEnliteCompanyDetail();
        SmartBDMEnliteCompanyDetail.Request request = new SmartBDMEnliteCompanyDetail.Request();
        request.ToKenKey = SmartBDM_Utility.tokenKeyEnliteRequestBody;
        request.RegistrationID = registerId;
        request.CompanyName = '?';
        request.FiscalYear = String.isNotBlank(fiscalYear) ? fiscalYear : String.valueOf(Datetime.now().year());
        request.Language = Smart_BDM_Constant.SMARTBDM_ENLITE_LANGUAGE_SEARCHING;
        request.TagRequired = 'company profile';
        smartBDMEnlite.enliteDataRequest.GetEnliteDataRequest = request;
        return SmartBDM_EnliteService.startCallGetCompanyDetailService(smartBDMEnlite);
    }

    @AuraEnabled
    global static Object callBackGetCompanyDetailServiceContinuation(Object state) { 
        return SmartBDM_EnliteService.callBackGetCompanyDetailServiceContinuation(state);
    }
}