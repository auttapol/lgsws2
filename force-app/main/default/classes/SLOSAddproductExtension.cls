public class SLOSAddproductExtension {

    public opportunity oppty {get;set;}
    public opportunitylineitem oppProd {get;set;}
    public host_product_mapping__c hostTemp {get;set;}
    public string sfproduct {get;set;}
    public string page {get;set;}
    public string pricebookentryid {get;set;}
    public string hostproductmapid {get;set;}
    public boolean isHasProduct {get;set;}
    public boolean isSERecordType {get;set;}
    public boolean iscomplete {get;set;}
    public boolean isNotSF1 {get;set;}
    public boolean toggleScript {get;set;}
    public string thisYear {get;set;}
    public string remark {get;set;}
    
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
    
    public map<integer,string> mapMonth {get{
        if (mapMonth == null){
            map<integer,string> retDat = new map<integer,string>();
            retDat.put(1,'Jan');
            retDat.put(2,'Feb');
            retDat.put(3,'Mar');
            retDat.put(4,'Apr');
            retDat.put(5,'May');
            retDat.put(6,'Jun');
            retDat.put(7,'Jul');
            retDat.put(8,'Aug');
            retDat.put(9,'Sep');
            retDat.put(10,'Oct');
            retDat.put(11,'Nov');
            retDat.put(12,'Dec');
            return retDat;
        }else{
            return mapMonth;
        }
    }set;}

    public SLOSAddProductExtension(apexpages.standardcontroller std)
    {
        opportunity opptystd = new opportunity();
        opportunity opptystdTemp = new opportunity();
        isNotSF1=true;
        String theme=Userinfo.getUItheme();
        if(theme=='Theme4t'){
            isNotSF1 = false;
        }
        
        if (test.isRunningTest()){
            opportunity ost = (opportunity)std.getRecord();
            opptystdTemp = [select id,pricebook2id,host_system__c,host_product_group__c 
                            from opportunity where id =: ost.id];
        }else{
            list<string> fields = new list<string>{'pricebook2id', 'Host_System__c', 'Host_Product_Group__c'};
            std.addFields(fields);
            opptystdTemp = (opportunity)std.getRecord();
        }
        opptystd = opptystdTemp;    
            
        if (Userinfo.getLocale() == 'th_TH'){
            thisYear = string.valueof(system.now().year() - 543);
        }else{
            thisYear = string.valueof(system.now().year());
        }
        
        oppty = [select id,name, Host_Product_Group__c, Host_System__c, Submit_To_System__c
                     , account.TMB_Customer_ID_PE__c, account.Customer_Type__c
                     , account.ID_Type_PE__c, account.ID_Number_PE__c
                     , account.name
                     , CAID__c
                     , owner.name, owner.Employee_ID__c
                     , owner.zone_code__c, owner.region_code__c
                     , pricebook2id,App_Ref_Number__c ,Expected_submit_date__c
                     , CloseDate
                     , RecordTypeId
                     , (select host_product_mapping__c, host_product_mapping__r.host_name__c, host_product_mapping__r.host_product_group__c
                        from opportunitylineitems)
                     from opportunity where id = : opptystd.id];
        page = 'page1';
        pricebookentryid = '';
        hostproductmapid = '';
        isHasProduct = false;
        toggleScript =false;
        
        oppProd = new opportunitylineitem(opportunityid = oppty.id);
        hostTemp = new host_product_mapping__c();
        if (string.isNotBlank(oppty.Host_System__c))
        {
            hostTemp.Host_Name__c = oppty.Host_System__c;
            //oppProd.Host_System__c = oppty.Host_System__c;
            if (string.isNotBlank(oppty.Host_Product_Group__c)){
                hostTemp.Host_Product_Group__c = oppty.Host_Product_Group__c;
                //oppProd.Host_Product_Group__c = oppty.Host_Product_Group__c;
            }
        }
        
        integer i = [select count() from opportunitylineitem where opportunityid =: oppty.id];
        if (i > 0){ isHasProduct = true;}

        List<RecordType> recTypes = [select Id, Name, sobjectType, DeveloperName from RecordType where Id = :oppty.RecordTypeId];
            if (recTypes[0].DeveloperName == 'SE_Credit_Product') {
                isSERecordType = true;
            }else if (recTypes[0].DeveloperName == 'WBG_Non_credit_Product' || recTypes[0].DeveloperName == 'WBG_Credit_Product') {
                isSERecordType = false;
            }
            
        remark = '';
        remark = status_code__c.getValues('8057').status_message__c;

    }
    
    public pageReference updateProductGroup()
    {
        string productGroup = '';
        string hostName = '';
        boolean isNeedUpdate = false;
        for (opportunitylineitem ol : oppty.opportunitylineitems)
        {
            if (string.isNotBlank(ol.host_product_mapping__c) && string.isNotBlank(ol.host_product_mapping__r.host_name__c)){
                hostName = ol.host_product_mapping__r.host_name__c;
            }
            if (string.isNotBlank(ol.host_product_mapping__c) && string.isNotBlank(ol.host_product_mapping__r.host_product_group__c)){
                productGroup = ol.host_product_mapping__r.host_product_group__c;
            }
        }
        
        if (string.isBlank(oppty.Host_System__c) && string.isNotBlank(hostName)){
            oppty.Host_System__c = hostName;
            hostTemp.Host_Name__c = oppty.Host_System__c ;
            isNeedUpdate = true;
        }
        if (string.isBlank(oppty.Host_Product_Group__c) && string.isNotBlank(productGroup)){
            oppty.Host_Product_Group__c = productGroup;
            hostTemp.Host_Product_Group__c = oppty.Host_Product_Group__c;
            isNeedUpdate = true;
        }
        
        if (isNeedUpdate){
            try {
                update oppty;
            }catch(exception ex){
                return new pageReference('/'+oppty.id);
            }
        }
        return null;
        
    }
    
    public void displayProduct()
    {
        try {
            host_product_mapping__c h = [select id, salesforce_product__c from host_product_mapping__c 
                                         where Host_Name__c =: hostTemp.Host_Name__c 
                                           and Host_Product_Group__c =: hostTemp.Host_Product_Group__c
                                           and Product_Program__c =: hostTemp.Product_Program__c
                                           and Host_Prod_Name_Credit_Facility__c =: hostTemp.Host_Prod_Name_Credit_Facility__c
                                           and active_flag__c = true].get(0);
            list<pricebookentry> p = [select id, product2id, product2.name from pricebookentry 
                                where product2id =: h.salesforce_product__c
                                  and pricebook2id =: oppty.pricebook2id];
            if (p.size() > 0)
            {
                hostTemp.salesforce_product__c = p.get(0).product2id;
                sfproduct = p.get(0).product2.name;
                pricebookentryid = p.get(0).id;
                hostproductmapid = h.id;
            }else{
                hostTemp.Salesforce_Product__c = null;
                sfproduct = '';
                pricebookentryid = '';
                hostproductmapid = '';
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8001').status_message__c));
                             
                        
            }
        }catch(exception ex){
            // system.debug(ex.getMessage());
            hostTemp.Salesforce_Product__c = null;
            sfproduct = '';
            pricebookentryid = '';
        }
    }
    
    public void addProduct()
    {
        string prop = (isSERecordType == true) ? '75%' : null;
        if (hostTemp.salesforce_product__c == null)
        {
            //Please select at least 1 product --> Selected Program/Credit Facility is not matched with the pre-selected Salesforce Product
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8023').status_message__c));
        }else{
            page = 'page2';
            oppProd.pricebookentryid = pricebookentryid;
            oppProd.quantity = 1;
            
            oppProd.Expected_Util_Year_Fee__c = 0;
            oppProd.Expected_Util_Year_NI__c = 0;
            oppProd.This_Year_Expected_Fee__c = 0;
            oppProd.This_Year_Expected_NI__c = 0;
            oppProd.Expected_Revenue_Fee__c = 0;
            oppProd.Expected_Revenue__c = 0;
            
            oppProd.FrequencyFee__c = 'Monthly';
            oppProd.Frequency__c = 'Monthly';
            
            oppProd.host_product_mapping__c = hostproductmapid;

            oppProd.Deal_Probability__c = prop;
            
            map<integer,string> mapMonth = new map<integer,string>();
            mapMonth.put(1, 'Jan');
            mapMonth.put(2, 'Feb');
            mapMonth.put(3, 'Mar');
            mapMonth.put(4, 'Apr');
            mapMonth.put(5, 'May'); 
            mapMonth.put(6, 'Jun');
            mapMonth.put(7, 'Jul');
            mapMonth.put(8, 'Aug');
            mapMonth.put(9, 'Sep');
            mapMonth.put(10, 'Oct');
            mapMonth.put(11, 'Nov');
            mapMonth.put(12, 'Dec');
            
            string monthname = mapMonth.get(oppty.CloseDate.month());
            
            integer convertYear = oppty.CloseDate.year();
            if (Userinfo.getLocale() == 'th_TH') convertYear = convertYear - 543;
            
            oppProd.RevisedStartMonth__c = monthname;
            oppProd.RevisedStartMonthFee__c = monthname;
            oppProd.RevisedStartYear__c = string.valueof(convertYear);
            oppProd.RevisedStartYearFee__c = string.valueof(convertYear);            
        }
    }
    
    
    public void dosave()
    {
        iscomplete = true;
            
        try {
  
            string monthString = mapMonth.get(oppty.CloseDate.month());
            string yearString = '';
            if (Userinfo.getLocale() == 'th_TH'){
                yearString = string.valueof(oppty.CloseDate.year() - 543);
            }else{
                yearString = string.valueof(oppty.CloseDate.year());
            }
            
            if (string.isBlank(oppProd.Frequency__c) && oppProd.Recurring_Type__c != 'One-Off') oppProd.Frequency__c = 'Monthly';
            if (string.isBlank(oppProd.FrequencyFee__c) && oppProd.Recurring_Type_Fee__c != 'One-Off') oppProd.FrequencyFee__c = 'Monthly';
            if (string.isBlank(oppProd.RevisedStartMonth__c)) oppProd.RevisedStartMonth__c = monthString;
            if (string.isBlank(oppProd.RevisedStartMonthFee__c)) oppProd.RevisedStartMonthFee__c = monthString;
            if (string.isBlank(oppProd.RevisedStartYear__c)) oppProd.RevisedStartYear__c = yearString;
            if (string.isBlank(oppProd.RevisedStartYearFee__c)) oppProd.RevisedStartYearFee__c = yearString;
            //if (string.isBlank(oppProd.RevisedStartMonth__c)) oppProd.RevisedStartMonth__c = 'Jan';
            //if (string.isBlank(oppProd.RevisedStartMonthFee__c)) oppProd.RevisedStartMonthFee__c = 'Jan';
            //if (string.isBlank(oppProd.RevisedStartYear__c)) oppProd.RevisedStartYear__c = string.valueof(system.today().year());
            //if (string.isBlank(oppProd.RevisedStartYearFee__c)) oppProd.RevisedStartYearFee__c = string.valueof(system.today().year());
            
            if (oppProd.This_Year_Expected_NI__c == null) oppProd.This_Year_Expected_NI__c = 0.00;
            if (oppProd.This_Year_Expected_Fee__c == null) oppProd.This_Year_Expected_Fee__c = 0.00;
            
            oppProd.This_Year_Expected_NI__c = oppProd.This_Year_Expected_NI__c.round(system.RoundingMode.HALF_UP);
            oppProd.This_Year_Expected_Fee__c = oppProd.This_Year_Expected_Fee__c.round(system.RoundingMode.HALF_UP);
            
            decimal NiThisYear = oppProd.This_Year_Expected_NI__c;            
            decimal FeeThisYear = oppProd.This_Year_Expected_Fee__c;
            
            //if (oppProd.RevisedStartYear__c != string.valueof(system.today().year())) NiThisYear = 0.00;
            //if (oppProd.RevisedStartYearFee__c != string.valueof(system.today().year())) FeeThisYear = 0.00;
            if (oppProd.RevisedStartYear__c != thisYear) NiThisYear = 0.00;
            if (oppProd.RevisedStartYearFee__c != thisYear) FeeThisYear = 0.00;
            
            if (oppProd.Expected_Revenue__c == null) oppProd.Expected_Revenue__c = 0.00;
            if (oppProd.Expected_Revenue_Fee__c == null) oppProd.Expected_Revenue_Fee__c = 0.00;
  
            if (oppProd.isNiBreakdownCalculate__c == false){
                if (oppProd.Type_Of_Reference__c != null){ //&& NiThisYear > 0){
                    calculateNIBreakdown(NiThisYear);
                }
            }
            if (oppProd.isFeeBreakdownCalculate__c == false){
                if (oppProd.Type_Of_Reference_Fee__c != null){ //&& FeeThisYear > 0){
                    calculateFeeBreakdown(FeeThisYear);
                }
            }
            
            
            if ((oppProd.RevisedStartMonth__c != null && oppProd.RevisedStartYear__c == null) || (oppProd.RevisedStartMonth__c == null && oppProd.RevisedStartYear__c != null)
                || (oppProd.RevisedStartMonthFee__c != null && oppProd.RevisedStartYearFee__c == null) || (oppProd.RevisedStartMonthFee__c == null && oppProd.RevisedStartYearFee__c != null))
            {
                string errorText = '';
                //Please Select NI Expected Start Year
                if (oppProd.RevisedStartMonth__c != null && oppProd.RevisedStartYear__c == null) errorText += '<br/>'+status_code__c.getValues('8045').status_message__c ;
                //Please Select NI Expected Start Month
                if (oppProd.RevisedStartMonth__c == null && oppProd.RevisedStartYear__c != null) errorText += '<br/>'+status_code__c.getValues('8046').status_message__c ;
                //Please Select Fee Expected Start Year
                if (oppProd.RevisedStartMonthFee__c != null && oppProd.RevisedStartYearFee__c == null) errorText += '<br/>'+status_code__c.getValues('8047').status_message__c ;
                //Please Select Fee Expected Start Month
                if (oppProd.RevisedStartMonthFee__c == null && oppProd.RevisedStartYearFee__c != null) errorText += '<br/>'+status_code__c.getValues('8048').status_message__c ;
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, sfproduct + errorText));
                iscomplete = false;
                //return null;
            }
  
            if (oppProd.UnitPrice == null) oppProd.UnitPrice = 0;
            if (oppProd.quantity == null) oppProd.quantity = 0;
            if (oppProd.Expected_Util_Year_NI__c == null) oppProd.Expected_Util_Year_NI__c = 0.00;
            if (oppProd.Expected_Util_Year_Fee__c == null) oppProd.Expected_Util_Year_Fee__c = 0.00;
            
            if (oppProd.UnitPrice < 0 || oppProd.quantity < 0 || oppProd.Tenor_Years__c < 0 || 
                oppProd.Notional_Amount__c < 0 || oppProd.Expected_Util_Year_NI__c < 0 || oppProd.Expected_Util_Year_Fee__c < 0 || 
                oppProd.Expected_Util_Year_NI__c > 100 || oppProd.Expected_Util_Year_Fee__c > 100 ||
                oppProd.This_Year_Expected_NI__c < 0 || oppProd.This_Year_Expected_Fee__c < 0)
            {
            
                string fieldNegative = '';
                if (oppProd.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                if (oppProd.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                if (oppProd.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                if (oppProd.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-TMB Account No';
                if (oppProd.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                if (oppProd.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                if (oppProd.This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
                if (oppProd.This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
                string errorTextNegative = '';
                if (fieldNegative != '') 
                    errorTextNegative = status_code__c.getValues('8050').status_message__c 
                                        + fieldNegative; 
                
                string fieldExceedValue = '';
                if (oppProd.Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                if (oppProd.Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                string errorTextExceedValue = '';
                if (fieldExceedValue != '') 
                    errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                           + fieldExceedValue;
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, sfproduct + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
               //return null;
               iscomplete = false;
            
            }else {
            
                oppProd.Expected_Utilization_Vol_NI__c = oppProd.Unitprice * oppProd.Quantity * (oppProd.Expected_Util_Year_NI__c/100);
                oppProd.Expected_Utilization_Vol_Fee__c = oppProd.Unitprice * oppProd.Quantity * (oppProd.Expected_Util_Year_Fee__c/100);
                
                
                if (oppProd.OriginalStartMonth__c == null && oppProd.OriginalStartYear__c == null && oppProd.RevisedStartMonth__c != null && oppProd.RevisedStartYear__c != null)
                {
                 oppProd.OriginalStartMonth__c = oppProd.RevisedStartMonth__c;
                 oppProd.OriginalStartYear__c = oppProd.RevisedStartYear__c;
                }
                
                if (oppProd.OriginalStartMonthFee__c == null && oppProd.OriginalStartYearFee__c == null && oppProd.RevisedStartMonthFee__c != null && oppProd.RevisedStartYearFee__c != null)
                {
                 oppProd.OriginalStartMonthFee__c = oppProd.RevisedStartMonthFee__c;
                 oppProd.OriginalStartYearFee__c = oppProd.RevisedStartYearFee__c;
                }
                
            } 

            list<host_product_mapping__c> h = [select id 
                                                    , Product_Group_ID__c
                                                    , Product_Program_ID__c
                                                    , Credit_Type_ID__c
                                                    from host_product_mapping__c 
                                                    where id =: oppProd.Host_Product_Mapping__c
                                                    and Active_Flag__c = true];
                                                    /*
                                                    where Host_Name__c = : oppProd.Host_System__c
                                                       and Host_Product_Group__c = : oppProd.Host_Product_Group__c
                                                               and Product_Program__c = : oppProd.Host_Product_Program__c
                                                                       and Host_Prod_Name_Credit_Facility__c = : oppProd.Host_Prod_Name_Credit_Facility__c
                                                                               and Salesforce_product__c = : hostTemp.Salesforce_product__c
                                                                                    and Active_Flag__c = true];
                                                    */
                                                    
                    //  system.debug('h size ='+h.size() );
                     if (h.size() > 0){ 
                        //oppProd.Host_Product_Mapping__c = h.get(0).id;
                        oppProd.Product_Group_ID__c = h.get(0).Product_Group_ID__c;
                        oppProd.Product_Program_ID__c = h.get(0).Product_Program_ID__c;
                        oppProd.Credit_Type_ID__c = h.get(0).Credit_Type_ID__c;
                    }else{
                        //Product has been inactive
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8040').status_message__c));
                        iscomplete = false;
                    }

            if (iscomplete){     
                upsert oppProd;
                if ((oppty.Host_System__c != hostTemp.Host_Name__c) && string.isnotBlank(hostTemp.Host_Name__c))
                {
                    oppty.Host_System__c = hostTemp.Host_Name__c;
                    update oppty;
                }
                if ((oppty.Host_Product_Group__c != hostTemp.Host_Product_Group__c) && string.isnotBlank(hostTemp.Host_Product_Group__c))
                {
                    oppty.Host_Product_Group__c = hostTemp.Host_Product_Group__c;
                    oppty.Product_Group_ID__c = mapProductGroupID.get(oppty.Host_Product_Group__c);
                    update oppty;
                }  
                toggleScript =true; 
            } 
    
        }catch(exception ex){
            // system.debug(ex);
        }

        if(ErrorsPresent()){
            iscomplete = false;
        }else{
            iscomplete = true;
        }
        // system.debug('iscomplete='+iscomplete); 

    }

    public pageReference redirectDeskTop(){
        pageReference p = new ApexPages.StandardController(oppty).view();
            p.setRedirect(true);
            return p;
    }

    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR); 
    }

    public pageReference openBreakdown()
    {
        dosave();
        if (isComplete){
            //return new pageReference('/apex/OppProductBreakDown?id='+oppProd.id);
            return new pageReference('/apex/OppProductBreakDown?listoppprodid='+oppProd.id);
        }else{
            return null;
        }
    }
    
    public void calculateNIBreakdown(decimal NiThisYear)
    {
        //if (NiThisYear > 0.00){
            
            oppProd.isNiBreakdownCalculate__c = true;
            oppProd.niBreakdownDate__c = system.now();
            
            decimal totalMonth = 12;
            decimal divideVal = 1;
            decimal eachVal = 0;
            decimal diffVal = 0;
            
            if (oppProd.RevisedStartMonth__c == 'Jan') totalMonth = totalMonth - 1;
            else if (oppProd.RevisedStartMonth__c == 'Feb') totalMonth = totalMonth - 2;
            else if (oppProd.RevisedStartMonth__c == 'Mar') totalMonth = totalMonth - 3;
            else if (oppProd.RevisedStartMonth__c == 'Apr') totalMonth = totalMonth - 4;
            else if (oppProd.RevisedStartMonth__c == 'May') totalMonth = totalMonth - 5;
            else if (oppProd.RevisedStartMonth__c == 'Jun') totalMonth = totalMonth - 6;
            else if (oppProd.RevisedStartMonth__c == 'Jul') totalMonth = totalMonth - 7;
            else if (oppProd.RevisedStartMonth__c == 'Aug') totalMonth = totalMonth - 8;
            else if (oppProd.RevisedStartMonth__c == 'Sep') totalMonth = totalMonth - 9;
            else if (oppProd.RevisedStartMonth__c == 'Oct') totalMonth = totalMonth - 10;
            else if (oppProd.RevisedStartMonth__c == 'Nov') totalMonth = totalMonth - 11;
            else if (oppProd.RevisedStartMonth__c == 'Dec') totalMonth = totalMonth - 12;
            
            if (oppProd.Frequency__c == 'Monthly'){
                divideVal = totalMonth/1;
            }else if (oppProd.Frequency__c == 'Quarterly'){
                divideVal = totalMonth/3;
            }else if (oppProd.Frequency__c == 'Half-yearly'){
                divideVal = totalMonth/6;
            }else if (oppProd.Frequency__c == 'Annually'){
                divideVal = 0;
            }else{
                divideVal = 0;
            }
            
            divideVal = divideVal.round(System.RoundingMode.FLOOR) + 1;
            eachVal = (NiThisYear / divideVal).round(System.RoundingMode.FLOOR);
            diffVal = NiThisYear - (eachVal * divideVal);
            
            if (oppProd.RevisedStartMonth__c == 'Jan'){
                oppProd.NI_January__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_February__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_March__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_April__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_May__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_July__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Feb'){
                oppProd.NI_February__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_March__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_April__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_May__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_August__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Mar'){
                oppProd.NI_March__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_April__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_May__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_September__c = eachVal + diffVal;
                
            }else if (oppProd.RevisedStartMonth__c == 'Apr'){
                oppProd.NI_April__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_May__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_October__c = eachVal + diffVal;
                
            }else if (oppProd.RevisedStartMonth__c == 'May'){
                oppProd.NI_May__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_November__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Jun'){
                oppProd.NI_June__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly' || oppProd.Frequency__c == 'Half-yearly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_December__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Jul'){
                oppProd.NI_July__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_July__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Aug'){
                oppProd.NI_August__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_August__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Sep'){
                oppProd.NI_September__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly' || oppProd.Frequency__c == 'Quarterly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_September__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Oct'){
                oppProd.NI_October__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_October__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_October__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Nov'){
                oppProd.NI_November__c = eachVal;
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal;
                
                if (oppProd.Frequency__c == 'Monthly') oppProd.NI_December__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Quarterly') oppProd.NI_November__c = eachVal + diffVal;
                else if (oppProd.Frequency__c == 'Half-yearly') oppProd.NI_November__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonth__c == 'Dec'){
                oppProd.NI_December__c = eachVal + diffVal;
            
            }
            
            
        //}
    }
    
    public void calculateFeeBreakdown(decimal FeeThisYear)
    {
        //if (FeeThisYear > 0.00){
            
            oppProd.isFeeBreakdownCalculate__c = true;
            oppProd.feeBreakdownDate__c = system.now();
            
            decimal totalMonth = 12;
            decimal divideVal = 1;
            decimal eachVal = 0;
            decimal diffVal = 0;
            
            if (oppProd.RevisedStartMonthFee__c == 'Jan') totalMonth = totalMonth - 1;
            else if (oppProd.RevisedStartMonthFee__c == 'Feb') totalMonth = totalMonth - 2;
            else if (oppProd.RevisedStartMonthFee__c == 'Mar') totalMonth = totalMonth - 3;
            else if (oppProd.RevisedStartMonthFee__c == 'Apr') totalMonth = totalMonth - 4;
            else if (oppProd.RevisedStartMonthFee__c == 'May') totalMonth = totalMonth - 5;
            else if (oppProd.RevisedStartMonthFee__c == 'Jun') totalMonth = totalMonth - 6;
            else if (oppProd.RevisedStartMonthFee__c == 'Jul') totalMonth = totalMonth - 7;
            else if (oppProd.RevisedStartMonthFee__c == 'Aug') totalMonth = totalMonth - 8;
            else if (oppProd.RevisedStartMonthFee__c == 'Sep') totalMonth = totalMonth - 9;
            else if (oppProd.RevisedStartMonthFee__c == 'Oct') totalMonth = totalMonth - 10;
            else if (oppProd.RevisedStartMonthFee__c == 'Nov') totalMonth = totalMonth - 11;
            else if (oppProd.RevisedStartMonthFee__c == 'Dec') totalMonth = totalMonth - 12;
            
            if (oppProd.FrequencyFee__c == 'Monthly'){
                divideVal = totalMonth/1;
            }else if (oppProd.FrequencyFee__c == 'Quarterly'){
                divideVal = totalMonth/3;
            }else if (oppProd.FrequencyFee__c == 'Half-yearly'){
                divideVal = totalMonth/6;
            }else if (oppProd.FrequencyFee__c == 'Annually'){
                divideVal = 0;
            }else{
                divideVal = 0;
            }
            
            divideVal = divideVal.round(System.RoundingMode.FLOOR) + 1;
            eachVal = (FeeThisYear / divideVal).round(System.RoundingMode.FLOOR);
            diffVal = FeeThisYear - (eachVal * divideVal);
        
            if (oppProd.RevisedStartMonthFee__c == 'Jan'){
                oppProd.Fee_January__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_February__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_March__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_April__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_May__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_July__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Feb'){
                oppProd.Fee_February__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_March__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_April__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_May__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_August__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Mar'){
                oppProd.Fee_March__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_April__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_May__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_September__c = eachVal + diffVal;
                
            }else if (oppProd.RevisedStartMonthFee__c == 'Apr'){
                oppProd.Fee_April__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_May__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_October__c = eachVal + diffVal;
                
            }else if (oppProd.RevisedStartMonthFee__c == 'May'){
                oppProd.Fee_May__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_November__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Jun'){
                oppProd.Fee_June__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly' || oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_December__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Jul'){
                oppProd.Fee_July__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_July__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Aug'){
                oppProd.Fee_August__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_August__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Sep'){
                oppProd.Fee_September__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly' || oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_September__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Oct'){
                oppProd.Fee_October__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_October__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_October__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Nov'){
                oppProd.Fee_November__c = eachVal;
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal;
                
                if (oppProd.FrequencyFee__c == 'Monthly') oppProd.Fee_December__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Quarterly') oppProd.Fee_November__c = eachVal + diffVal;
                else if (oppProd.FrequencyFee__c == 'Half-yearly') oppProd.Fee_November__c = eachVal + diffVal;
            
            }else if (oppProd.RevisedStartMonthFee__c == 'Dec'){
                oppProd.Fee_December__c = eachVal + diffVal;
            
            }
            
            
        //}
    }

    public void validateYear()
    {
        //if (oppProd.isNiBreakdownCalculate__c == false || oppProd.isFeeBreakdownCalculate__c == false){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, status_code__c.getValues('8060').status_message__c));
        //}
    }
        
}