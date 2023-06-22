public class SLOSPrescreenController2 {

    public Host_Product_Mapping__c productMap {get; set;}
    public string requestAmt {get; set;}
    //public string unitOfAcct {get; set;}
    //public string totalVol {get; set;}
    public boolean showpopup {get; set;}
    //public list<wrapdata> ListProductDisplay {get; set;}
    public list<wrapdata2> listOpportunityProduct2 {get; set;}
    private string opportunityId {get; set;}
    public opportunity oppty {get; set;}
    public string pricebookid {get; set;}
    public string index {get; set;}
    public string page {get; set;}
    public string opplineindex {get; set;}
    public string opplineindex2 {get; set;}
    public boolean isCanSelectProductGroup {get; set;}
    public map<string, opportunitylineitem> mapOpportunitylineitem {get; set;}
    public integer indexList2 {get; set;}
    public string host {get; set;}
    public string productGroup {get; set;}
    public string programid {get; set;}
    public string facilityid {get; set;}
    public list<opportunitylineitem> listDeleteOpportunityLineItem {get; set;}
    public boolean isHasProductGroup {get;set;}
    public Account acct {get;set;}
    public List<Account> acctList {get;set;}
    public list<wrapdata2> Addw2temp  {get;set;}
    public String mode {get;set;}
    public boolean isConsoleMode {get;set;}
    public boolean isError {get;set;}
    public string oldProductGroup {get;set;}
    public string oldHost {get;set;}
    //public opportunitylineitem oppProductTemp {get;set;}
    
    public map<string,string> mapProductGroupID {get{
        if (mapProductGroupID != null){
            return mapProductGroupID;
        }else{
            map<string,string> retDat = new map<string,string>();
            for (host_product_mapping__c hp :[select Host_Product_Group__c
                                              , Product_Group_ID__c 
                                              from host_product_mapping__c where active_flag__c = true])
            {
                retDat.put(hp.Host_Product_Group__c, hp.Product_Group_ID__c);
            }
            return retDat;
        }
    }set;}
    
    public map<string,string> mapProductName {get{
    
        if (mapProductName != null){
            return mapProductName;
        }else{
            map<string,string> retDat = new map<string,string>();
            for (host_product_mapping__c hp :[select salesforce_product__c, salesforce_product__r.name 
                                              from host_product_mapping__c where active_flag__c = true])
            {
                retDat.put(hp.salesforce_product__c, hp.salesforce_product__r.name);
            }
            return retDat;
        }
    }set;}

    public SLOSPrescreenController2() {
        opportunityId = Apexpages.CurrentPage().getParameters().get('id');
        host = Apexpages.CurrentPage().getParameters().get('host');
        mode = Apexpages.CurrentPage().getParameters().get('mode');
        string productGroup2 = Apexpages.CurrentPage().getParameters().get('productGroup');

        isCanSelectProductGroup = true;
        isHasProductGroup = true;
        oldProductGroup = '';
        oldHost = '';

        isConsoleMode = false;
        if(mode!=null && mode !=''){
            if(mode == 'console'){
                isConsoleMode = true;
            }
        }

        if (opportunityId != null){
            oppty = [select id,name, Host_Product_Group__c, Host_System__c, Submit_To_System__c
                     , account.TMB_Customer_ID_PE__c, account.Customer_Type__c
                     , account.ID_Type_PE__c, account.ID_Number_PE__c
                     , account.name
                     , CAID__c
                     , owner.name, owner.Employee_ID__c
                     , owner.zone_code__c, owner.region_code__c
                     , pricebook2id,App_Ref_Number__c ,Expected_submit_date__c
                     , product_group_id__c
                     from opportunity where id = : opportunityId];
        } else{
            oppty = new opportunity();
        }

        productMap = new Host_Product_Mapping__c();
        productMap.Host_Name__c = host;
        //oppProductTemp = new opportunitylineitem();
        //oppProductTemp.Host_System__c = host;
        if (oppty.Host_System__c != null) {
            oldHost = oppty.Host_System__c;
        }
        oppty.Host_System__c = host;
        
        if (oppty.Host_Product_Group__c != '' && oppty.Host_Product_Group__c != null) {
            productGroup  = oppty.Host_Product_Group__c;
            isCanSelectProductGroup = false;
            oldProductGroup = oppty.Host_Product_Group__c;
        }
        if (productGroup2 != null && productGroup2 != '') {
            productGroup = productGroup2;
        }
        productMap.Host_Product_Group__c = productGroup;
        oppty.Host_Product_Group__c = productGroup;

        showpopup = false;
        index = '';
        opplineindex = '';
        opplineindex2 = '';
        page = '1';

        requestAmt = '0';
        programid = '';
        facilityid = '';

        string hpm = '';
        string peid = '';
        string chkprod2id = '';

        listDeleteOpportunityLineItem = new list<opportunitylineitem>();

        //ListProductDisplay = new list<wrapdata>();

        indexList2 = 0;
        listOpportunityProduct2 = new list<wrapdata2>();
        for (opportunitylineitem ol : [select id, name
                                       , Product2.name, product2id
                                       , Host_Product_Mapping__c
                                       , Host_Product_Mapping__r.Host_Name__c
                                       , Host_Product_Mapping__r.Host_Product_Group__c
                                       , Host_Product_Mapping__r.Product_Program__c
                                       , Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c
                                       , Host_Product_Mapping__r.Salesforce_Product__c
                                       , Host_Product_Mapping__r.Salesforce_Product__r.name
                                       , Quantity
                                       , UnitPrice
                                       , PricebookEntryId
                                       , opportunity.Host_Product_Group__c
                                       /*
                                       , Host_System__c
                                       , Host_Product_Group__c
                                       , Host_Product_Program__c
                                       , Host_Prod_Name_Credit_Facility__c
                                       */
                                       from opportunitylineitem
                                       where opportunityid = : opportunityid ]) { 
            Host_Product_Mapping__c hp = new Host_Product_Mapping__c();
            if (ol.Host_Product_Mapping__c != null) {
                hp.Host_Name__c = ol.Host_Product_Mapping__r.Host_Name__c;
                hp.Host_Product_Group__c = ol.Host_Product_Mapping__r.Host_Product_Group__c;
                hp.Product_Program__c = ol.Host_Product_Mapping__r.Product_Program__c;
                hp.Host_Prod_Name_Credit_Facility__c = ol.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c;
                hp.salesforce_product__c = ol.Host_Product_Mapping__r.salesforce_product__c;
            } else {
                hp.Host_Name__c = host;
                hp.Host_Product_Group__c = productGroup;
            }
            /*2017-05-09: comment
            ol.Host_System__c = hp.Host_Name__c;
            ol.Host_Product_Group__c = hp.Host_Product_Group__c;*/
            string productNameTmp = (string.isNotBlank(ol.Host_Product_Mapping__r.Salesforce_Product__r.name)) ? ol.Host_Product_Mapping__r.Salesforce_Product__r.name : ol.product2.name;
            listOpportunityProduct2.add(new wrapdata2(string.valueof(indexList2), string.valueof(ol.id), ol, hp, string.valueof(ol.unitprice), productNameTmp));
            indexList2++;
        }

        if (indexList2 == 0) isCanSelectProductGroup = true;

        mapOpportunitylineitem = new map<string, opportunitylineitem>();

        user u = [select segment__c from user where id = : userinfo.getUserId()];
        string user_segment = '';
        if (u.segment__c != null)
            user_segment = u.segment__c;
        else
            user_segment = 'Default';
        pricebookid =  [select id from pricebook2 where name = : Price_book_access__c.getValues(user_segment).PricebookItem__c].get(0).id;

        acctList = [ select Id,Name,Account_Type__c,ID_Number_PE__c,ID_Type_PE__c,Customer_Type__c from Account where Id = :oppty.AccountId ];
        if(acctList.size()>0){
            acct = acctList.get(0);

                     if( acct.Account_Type__c == 'Existing Customer'){       
                        if(acct.ID_Type_PE__c == null && acct.ID_Number_PE__c == null){     
                           if(acct.Customer_Type__c =='Individual') {
                               acct.ID_Type_PE__c ='Citizen ID';   
                           }else if(acct.Customer_Type__c =='Juristic'){
                               acct.ID_Type_PE__c ='BRN ID';   
                           }
                           acct.ID_Number_PE__c ='1111111111111';
                        }
                   }
               }
    }


    /*public class wrapdata {
        public string program {get; set;}
        public string facility {get; set;}
        public decimal requestamt {get; set;}
        public decimal unitofacct {get; set;}
        public decimal totalvol {get; set;}
        public string sfpricebookentryid {get; set;}
        public string hostproductmapid {get; set;}
        public string opplineid {get; set;}
        public string sfproductname {get; set;}
        public wrapdata(string p, string f, decimal r, decimal u, decimal t, string s, string h, string o, string sf) {
            program = p;
            facility = f;
            requestamt = r;
            unitofacct = u;
            totalvol = t;
            sfpricebookentryid = s;
            hostproductmapid = h;
            opplineid = o;
            sfproductname = sf;
        }
    }*/

    public class wrapdata2 {
        public string Index {get; set;}
        public string oppProdId {get; set;}
        public opportunitylineitem oppProd {get; set;}
        public Host_Product_Mapping__c hostMapTemp {get; set;}
        public string amount {get; set;}
        public string productName {get;set;}
        public wrapdata2(string i, string o, opportunitylineitem ol, Host_Product_Mapping__c h, string a, string p) {
            Index = i;
            oppProdId = o;
            oppProd = ol;
            hostMapTemp = h;
            amount = a;
            productName = p;
        }
    }
    public PageReference cancel() {
        return new PageReference('/' + opportunityid);
    }
    /*public void editProduct() {
        index = Apexpages.currentPage().getParameters().get('index');
        opplineindex = Apexpages.currentPage().getParameters().get('opplineindex');
        opplineindex2 = Apexpages.currentPage().getParameters().get('opplineindex2');

        if (index != '' && opplineindex == '') {
            wrapdata w = ListProductDisplay.get(integer.valueof(index));
            productMap.Product_Program__c = w.program;
            productMap.Host_Prod_Name_Credit_Facility__c = w.facility;
            requestAmt = string.valueof(w.requestamt);
        } else if (index == '' && opplineindex != '') {
            opportunitylineitem o = mapOpportunitylineitem.get(opplineindex);
            if (o.Host_Product_Mapping__r.Product_Program__c != null && o.Host_Product_Mapping__r.Product_Program__c != '')
                productMap.Product_Program__c = o.Host_Product_Mapping__r.Product_Program__c;
            if (o.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c != null && o.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c != '')
                productMap.Host_Prod_Name_Credit_Facility__c = o.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c;
            requestAmt = string.valueof(o.UnitPrice);
        }
       
    }*/
    public void saveToList() {
        list<opportunitylineitem> listEditable = new list<opportunitylineitem>();
        list<opportunitylineitem> listDeleteAfterClone = new list<opportunitylineitem>();
        isError = false;
        boolean isErrorProgram = false;
        boolean isErrorCredit = false;
        boolean isErrorUnit = false;
        boolean isErrorProdutSF = false;
        boolean isSelectProductGroup = false;
        
        string errorMsg = status_code__c.getValues('8043').status_message__c; // statuscode
        for (wrapdata2 w : listOpportunityProduct2) {
        
            //w.hostMapTemp.Product_Program__c = w.oppProd.Host_Product_Program__c;
            //w.hostMapTemp.Host_Prod_Name_Credit_Facility__c = w.oppProd.Host_Prod_Name_Credit_Facility__c;
        
            system.debug('w.hostMapTemp.Product_Program__c ='+w.hostMapTemp.Product_Program__c);
            system.debug('w.hostMapTemp.Host_Prod_Name_Credit_Facility__c ='+w.hostMapTemp.Host_Prod_Name_Credit_Facility__c);
            system.debug('w.oppProd.unitprice ='+w.oppProd.unitprice);

//            boolean byPassProductFromConvertLead = false;

//            if (w.oppProd.product2id != null && string.isBlank(w.oppProd.host_product_mapping__c)){
                //&& (w.oppProd.Host_Product_Program__c == null || w.oppProd.Host_Product_Program__c == '')
                //&& (w.oppProd.Host_Prod_Name_Credit_Facility__c == null || w.oppProd.Host_Prod_Name_Credit_Facility__c == '')){
                
//                byPassProductFromConvertLead = true;
                
//            }else{

                if (w.hostMapTemp.Product_Program__c == null || w.hostMapTemp.Product_Program__c == '') {
                    isErrorProgram = true;
                    //Please selecr Product Program
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8037').status_message__c));
                }
                if (w.hostMapTemp.Host_Prod_Name_Credit_Facility__c == null || w.hostMapTemp.Host_Prod_Name_Credit_Facility__c == '') {
                    isErrorCredit = true;
                    //Please select Credit Facility
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8038').status_message__c));
                }
                
//            }
            
            if (w.oppProd.unitprice == null || w.oppProd.unitprice <= 0) {
                isErrorUnit = true;
                //Please input Request Amount
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8039').status_message__c));
            }


            if (w.oppProdId != '') {
//                if (byPassProductFromConvertLead) {
                
//                    listEditable.add(w.oppProd);
                    
//                } else if ((w.hostMapTemp.Salesforce_Product__c != w.oppProd.product2id) && w.hostMapTemp.Salesforce_Product__c != null) {
                if (((w.hostMapTemp.Salesforce_Product__c != w.oppProd.product2id) && w.hostMapTemp.Salesforce_Product__c != null)
                || (string.isBlank(w.oppProd.host_product_mapping__c) && string.isNotBlank(w.hostMapTemp.Salesforce_Product__c))) {
                    opportunitylineitem o = w.oppProd.clone(false, true, true, false);
                    
                    list<pricebookentry> p = [select id from pricebookentry where product2id = : w.hostMapTemp.Salesforce_Product__c
                                              and pricebook2id = : oppty.pricebook2id];
                    if (p.size() > 0) o.pricebookentryid = p.get(0).id;

                    list<host_product_mapping__c> h = [select id 
                                                       , Product_Group_ID__c
                                                       , Product_Program_ID__c
                                                       , Credit_Type_ID__c
                                                       from host_product_mapping__c where Host_Name__c = : w.hostMapTemp.Host_Name__c
                                                       and Host_Product_Group__c = : w.hostMapTemp.Host_Product_Group__c
                                                               and Product_Program__c = : w.hostMapTemp.Product_Program__c
                                                                       and Host_Prod_Name_Credit_Facility__c = : w.hostMapTemp.Host_Prod_Name_Credit_Facility__c
                                                                               and Salesforce_product__c = : w.hostMapTemp.Salesforce_product__c
                                                                                    and Active_Flag__c = true];
                     system.debug('h size ='+h.size() );
                     if (h.size() > 0){ 
                        o.Host_Product_Mapping__c = h.get(0).id;
                        o.Product_Group_ID__c = h.get(0).Product_Group_ID__c;
                        o.Product_Program_ID__c = h.get(0).Product_Program_ID__c;
                        o.Credit_Type_ID__c = h.get(0).Credit_Type_ID__c;
                    }else{
                         isErrorUnit = true;
                         //Product has been inactive
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8040').status_message__c));
                    }

                    listEditable.add(o);
                    listDeleteAfterClone.add(w.oppProd);
                    isSelectProductGroup = true;
                } else if (w.hostMapTemp.Salesforce_Product__c != null) {
                    listEditable.add(w.oppProd);
                }
                
            }

            if (w.oppProdId == '') {
                opportunityLineItem o = w.oppProd;

                o.opportunityId = oppty.Id;
                o.quantity = 1;
               

                list<pricebookentry> p = [select id from pricebookentry where product2id = : w.hostMapTemp.Salesforce_Product__c
                                          and pricebook2id = : oppty.pricebook2id];
                if (p.size() > 0) o.pricebookentryid = p.get(0).id;
                list<host_product_mapping__c> h = [select id,Active_Flag__c  
                                                   , Product_Group_ID__c
                                                   , Product_Program_ID__c
                                                   , Credit_Type_ID__c
                                                   from host_product_mapping__c where Host_Name__c = : w.hostMapTemp.Host_Name__c
                                                   and Host_Product_Group__c = : w.hostMapTemp.Host_Product_Group__c
                                                           and Product_Program__c = : w.hostMapTemp.Product_Program__c
                                                                   and Host_Prod_Name_Credit_Facility__c = : w.hostMapTemp.Host_Prod_Name_Credit_Facility__c
                                                                           and Salesforce_product__c = : w.hostMapTemp.Salesforce_product__c
                                                                             and Active_Flag__c = true];
                system.debug('h size ='+h.size() );
                if (h.size() > 0){ 
                    o.Host_Product_Mapping__c = h.get(0).id;
                    o.Product_Group_ID__c = h.get(0).Product_Group_ID__c;
                    o.Product_Program_ID__c = h.get(0).Product_Program_ID__c;
                    o.Credit_Type_ID__c = h.get(0).Credit_Type_ID__c;
                }else{
                    isErrorUnit = true;
                    //Product has been inactive
                    if (!isErrorProgram && !isErrorCredit && !isErrorUnit){
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8040').status_message__c));
                    }                
                }
                listEditable.add(o);
                w.oppProdId = 'exist';
                isSelectProductGroup = true;
            }

            system.debug('w.hostMapTemp.Salesforce_Product__c ='+w.hostMapTemp.Salesforce_Product__c );
            if (w.hostMapTemp.Salesforce_Product__c == null){ //&& !byPassProductFromConvertLead) {
                isErrorProdutSF = true;
                //Selected Program/Credit Facility is not matched with the pre-selected Salesforce Product
                if (!isErrorProgram && !isErrorCredit && !isErrorUnit){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8023').status_message__c));
                }    
            }
            
            if (w.productName == '-' && !isErrorUnit){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8040').status_message__c));
                isErrorProdutSF = true;
            }
           
        }
        if (isErrorProgram || isErrorCredit || isErrorUnit || isErrorProdutSF) {
            isError = true;
        }

        if (!isError) {
            try {
                
                if (listEditable.size() > 0) { delete listDeleteAfterClone; upsert listEditable;}
                if (listDeleteOpportunityLineItem.size() > 0){ delete listDeleteOpportunityLineItem;}
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, errorMsg));

                system.debug(oppty.host_product_group__c);
                system.debug(productGroup);

                //if (oppty.host_product_group__c != productGroup || oppty.host_product_group__c == null) {
                if (oldProductGroup != productGroup && productGroup != null && productGroup != '') {
                    oppty.host_product_group__c = productGroup;
                    oppty.Product_Group_ID__c = mapProductGroupID.get(productGroup);
                    if (isSelectProductGroup) update oppty;
                    
                }
              
                //if (oppty.host_system__c != host || oppty.host_system__c == null) {
                if (oldHost != host && host != null && host != '') {
                    oppty.host_system__c = host;
                    update oppty;
                }
            } catch (exception ex) {
                
                system.debug(listEditable);
                system.debug(listDeleteOpportunityLineItem);
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
            listDeleteOpportunityLineItem = new List<opportunitylineitem>();
            listOpportunityProduct2 = new List<wrapdata2>();
           
            for (opportunitylineitem ol : [select id, name
                                       , Product2.name, product2id
                                       , Host_Product_Mapping__c
                                       , Host_Product_Mapping__r.Host_Name__c
                                       , Host_Product_Mapping__r.Host_Product_Group__c
                                       , Host_Product_Mapping__r.Product_Program__c
                                       , Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c
                                       , Host_Product_Mapping__r.Salesforce_Product__c
                                       , Host_Product_Mapping__r.Salesforce_Product__r.name
                                       , Quantity
                                       , UnitPrice
                                       , PricebookEntryId
                                       , opportunity.Host_Product_Group__c
                                       /*
                                       , Host_System__c
                                       , Host_Product_Group__c
                                       , Host_Product_Program__c
                                       , Host_Prod_Name_Credit_Facility__c
                                       */
                                       from opportunitylineitem
                                       where opportunityid = : opportunityid ]) { 
            Host_Product_Mapping__c hp = new Host_Product_Mapping__c();
            if (ol.Host_Product_Mapping__c != null) {
                hp.Host_Name__c = ol.Host_Product_Mapping__r.Host_Name__c;
                hp.Host_Product_Group__c = ol.Host_Product_Mapping__r.Host_Product_Group__c;
                hp.Product_Program__c = ol.Host_Product_Mapping__r.Product_Program__c;
                hp.Host_Prod_Name_Credit_Facility__c = ol.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c;
                hp.salesforce_product__c = ol.Host_Product_Mapping__r.salesforce_product__c;
            } else {
                hp.Host_Name__c = host;
                hp.Host_Product_Group__c = productGroup;
            }
            /*2017-05-09: comment
            ol.Host_System__c = hp.Host_Name__c;
            ol.Host_Product_Group__c = hp.Host_Product_Group__c;*/
            string productNameTmp = (string.isNotBlank(ol.Host_Product_Mapping__r.Salesforce_Product__r.name)) ? ol.Host_Product_Mapping__r.Salesforce_Product__r.name : ol.product2.name;
            listOpportunityProduct2.add(new wrapdata2(string.valueof(indexList2), string.valueof(ol.id), ol, hp, string.valueof(ol.unitprice), productNameTmp));
            indexList2++;
            }
        }       
    }
    public void chgCanSelectProductGroupVal() {
        isCanSelectProductGroup = true;
        list<opportunitylineitem> ol = [select opportunity.host_product_group__c from opportunitylineitem where opportunityid = : oppty.id];
        if (ol.size() > 0) {
            if (ol.get(0).opportunity.host_product_group__c != '') isCanSelectProductGroup = false;
        }

    }
    public void addProduct() {
        indexList2++;
        Addw2temp = new list<wrapdata2>();

        Addw2temp.add(new wrapdata2(string.valueof(indexList2), '', new opportunitylineitem()
                                 , new host_product_mapping__c(Host_Name__c = host, Host_Product_Group__c = productGroup), '0', ''));
        Addw2temp.addAll(listOpportunityProduct2);
        listOpportunityProduct2 = Addw2temp;
    }
    public void removeProduct() {
        list<wrapdata2> w2temp = new list<wrapdata2>();
        for (wrapdata2 w : listOpportunityProduct2) {
            if (w.index != opplineindex) {
                w2temp.add(w);
            } else {
                if (w.oppProd.id != null){ listDeleteOpportunityLineItem.add(w.oppProd);}
            }
        }
        listOpportunityProduct2 = w2temp; 
    }
    public pageReference previewProduct() {

        boolean isAllProductValid = true;
        boolean isHasProduct = false;
        
        for (opportunitylineitem ol : [select host_product_mapping__c from opportunitylineitem where opportunityid =: opportunityid])
        {
            if (string.isBlank(ol.host_product_mapping__c)){
                isAllProductValid = false;
            }
            isHasProduct = true;
        }

        if (!isAllProductValid) {    
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8054').status_message__c));
            return null;
        } else if (!isHasProduct) {    
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8055').status_message__c));
            return null;
        } else {
            page = '2';
            //Please review the information at below, then click Submit to Opportunity button
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, status_code__c.getValues('8041').status_message__c));
            return new pageReference('/apex/SLOSPreview?id=' + opportunityid +'&host='+host); 
        }
    }
    public void checkProductGroup(){
         if(productMap.Host_Product_Group__c == null || productMap.Host_Product_Group__c == ''){
            isHasProductGroup = false;
            //Please select Product Group
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8042').status_message__c));
        
        }
    }
    
    public pageReference submitToHost() {
        /**
         *  Added by ktc@ii.co.th
         *  Date : 2017-02-01
         */
        try {
            /*******************************************************
            *     Only Host = SLOS
            ********************************************************/
            if (string.isNotBlank(oppty.host_product_group__c) && string.isBlank(oppty.Product_Group_ID__c)) {
                oppty.Product_Group_ID__c = mapProductGroupID.get(oppty.host_product_group__c);
            }
                    
            if (oppty.Host_System__c == 'SLS') {
                SLOSContext.SLOSRequest req = new SLOSContext.SLOSRequest(oppty , null);
                SLOSContext.SLOSRespond resp = SLOSServiceBroker.sendRequest(req);
                if (resp.Status == true) {
                    oppty.App_Ref_Number__c = resp.AppRefNo;
                    /*******************************************************
                    *    Change Record to SE Credit Product 2
                    ********************************************************/
                   
                    Id seCreditPproduct2RecordType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product2').getRecordTypeId();
                    oppty.RecordTypeId = seCreditPproduct2RecordType;
                    oppty.stageName ='Submit to Credit Process';
                    update oppty;
                } else {
                    //SLOS Error with Code :
                    string errMsg = status_code__c.getValues('8044').status_message__c +'' + resp.ErrorCode + '.Error: ' + resp.Message;
                    ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
                    ApexPages.addMessage(msg);
                }
            }else if (oppty.Host_System__c.toLowerCase().contains('excel')) {
                oppty.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product2').getRecordTypeId();
                oppty.stageName ='Submit to Credit Process';
                update oppty;
            }
             
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return ApexPages.hasMessages() ? null : new pageReference('/apex/SLOSResult?id=' + oppty.Id + '&host=' + oppty.Host_System__c);
    }

    public pageReference back() {
        page = '1';
        return new pageReference('/apex/SLOSSelectProductGroup?id='+ oppty.Id + '&host=' + oppty.Host_System__c);
    }

    public void changeTemp() {
        productGroup = productMap.Host_Product_Group__c;
    }
    public void showProduct() { 
        for (wrapdata2 w : listOpportunityProduct2) {
            system.debug('w index ='+w.index);
            system.debug('opplineindex ='+opplineindex);
            if (w.index == opplineindex) {
            
                //w.hostMapTemp.Product_Program__c = w.oppProd.Host_Product_Program__c;
                //w.hostMapTemp.Host_Prod_Name_Credit_Facility__c = w.oppProd.Host_Prod_Name_Credit_Facility__c;
            
                w.hostMapTemp.Salesforce_Product__c = null;
                if (w.hostMapTemp.Host_Name__c != null && w.hostMapTemp.Host_Name__c != ''
                        && w.hostMapTemp.Host_Product_Group__c != null && w.hostMapTemp.Host_Product_Group__c != ''
                        && w.hostMapTemp.Product_Program__c != null && w.hostMapTemp.Product_Program__c != ''
                        && w.hostMapTemp.Host_Prod_Name_Credit_Facility__c != null && w.hostMapTemp.Host_Prod_Name_Credit_Facility__c != '') {
                    try {
                        host_product_mapping__c h = [select salesforce_product__c, salesforce_product__r.name from host_product_mapping__c
                                                     where Host_Name__c = : w.hostMapTemp.Host_Name__c
                                                             and Host_Product_Group__c = : w.hostMapTemp.Host_Product_Group__c
                                                                     and Product_Program__c = : w.hostMapTemp.Product_Program__c
                                                                             and Host_Prod_Name_Credit_Facility__c = : w.hostMapTemp.Host_Prod_Name_Credit_Facility__c].get(0);
                        system.debug('salesforce_product__c ='+h.salesforce_product__c);
                        system.debug('oppty.pricebook2id ='+oppty.pricebook2id);
                        list<pricebookentry> p = [select product2id from pricebookentry
                                                  where product2id = : h.salesforce_product__c
                                                          and pricebook2id = : oppty.pricebook2id];
                        system.debug('p size ='+p.size());
                        if (p.size() > 0){
                            w.hostMapTemp.Salesforce_Product__c = p.get(0).product2id;
                            w.productName = h.salesforce_product__r.name;
                        }else{
                             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8001').status_message__c));
                             w.productName = '-';
                        }
                    } catch (exception ex) {
                        w.hostMapTemp.Salesforce_Product__c = null;
                        w.productName = '-';
                    }
                }

            }

        }
    }


}