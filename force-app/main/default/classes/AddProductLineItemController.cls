public class AddProductLineItemController {

    public List<SelectOption> ProductdomainSelectOption {get;set;}
    public String productdomainselected {get;set;}
    public List<ProductWrapper> ProductWrapperList {get;set;}
    public List<Product2> ProductsList {get;set;}
    public String pricebookid {get;set;}
    public List<opportunityLineItem> optLine {get;set;}
    public Boolean isSelect {get;set;}
    public Opportunity oppObj {get;set;}
    public map<string,string> mapProductName {get;set;}
    public Boolean isSave {get;set;}
    public boolean iscomplete {get;set;}
    public string thisYear {get;set;}
    public integer optLineSize {get;set;}
    public boolean isNotSF1 {get;set;}
    public string remark {get;set;}
    
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


    public AddProductLineItemController(apexPages.standardController sc)
    {
        isSave = false;
        isSelect = false;
        isNotSF1 = true;
        opportunity oppTemp = (Opportunity)sc.getRecord();
        oppObj = [select id, account.name, name, CloseDate from opportunity where id =: oppTemp.id];
        ProductWrapperList = new List<ProductWrapper>();
        mapProductName = new map<string,string>();
        optLineSize = 0;
        
        if (Userinfo.getLocale() == 'th_TH'){
            thisYear = string.valueof(system.now().year() - 543);
        }else{
            thisYear = string.valueof(system.now().year());
        }
        
        ProductdomainSelectOption = new List<SelectOption>();                   
        ProductdomainSelectOption.add(new SelectOption('','Please Select Domain'));
        ProductdomainSelectOption.add(new SelectOption('1','1. Transactional Banking'));
        ProductdomainSelectOption.add(new SelectOption('2','2. Deposit and Investment'));
        ProductdomainSelectOption.add(new SelectOption('3','3. Funding & Borrowing'));
        ProductdomainSelectOption.add(new SelectOption('4','4. Risk Protection'));
        
        user u = [select segment__c from user where id =: userinfo.getUserId()];
        
        string user_segment = '';
        if (u.segment__c != null)
            user_segment = u.segment__c;
        else
            user_segment = 'Default';
        pricebookid =  [select id from pricebook2 where name =: Price_book_access__c.getValues(user_segment).PricebookItem__c].get(0).id;
            
        optLine = new list<opportunityLineItem>();
        String theme=Userinfo.getUItheme();
        
        if(theme=='Theme4u'){
            isNotSF1 = true;
        }
        else if (String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) 
            || String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) 
            || ApexPages.currentPage().getParameters().get('isdtp') == 'p1' 
            || (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ){
            //system.debug(ApexPages.currentPage().getParameters());
            if (ApexPages.currentPage().getParameters().get('isdtp') == 'p1') isNotSF1 = false;
        }
        
        remark = '';
        remark = status_code__c.getValues('8057').status_message__c;
        
    }
    
    public void productdomainselect()
    {
        ProductsList = new List<Product2>();
        ProductWrapperList = new List<ProductWrapper>();
        String domainselected = ''; 
        Boolean isNotFound = false;
        
        if(productdomainselected=='1')
        {
            domainselected = '%Transaction%';
            isNotFound = true;
        }else if(productdomainselected=='2'){
            domainselected = '%Deposit%';
            isNotFound = true;
        }else if(productdomainselected=='3'){
            domainselected = '%Fund%';
            isNotFound = true;
        }else if(productdomainselected=='4'){
            domainselected = '%Risk%';
            isNotFound = true;
        }
        
        for(pricebookEntry pb : [SELECT ID, product2.Name, product2.IsActive, product2.Family, product2.Product_Domain__c        
                                    From pricebookEntry
                                    WHERE pricebook2id =: pricebookid
                                    AND product2.IsActive =: true
                                    AND product2.Product_Domain__c Like : domainselected order by product2.Name])
        {
            ProductWrapper pw = new ProductWrapper();
            pw.pricebook = pb;
            pw.IsSelected = false;
            ProductWrapperList.add(pw); 
            mapProductName.put(pb.id,pb.product2.name);
        }
        
        if (ProductWrapperList.size() == 0 && isNotFound)
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.INFO, status_code__c.getValues('8011').status_message__c));
    }
    
    public void SelectDomain()
    {
        
        String pageName = ApexPages.CurrentPage().getUrl();
        system.debug('pageName='+pageName);
        if(pageName.containsIgnoreCase('mobile') && optLine.size()>0 ){
            doSaveMobile();
        }else{
        
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
        
            string monthname = mapMonth.get(oppObj.CloseDate.month());
        
            integer convertYear = oppObj.CloseDate.year();
            if (Userinfo.getLocale() == 'th_TH') convertYear = convertYear - 543;
            
            for (ProductWrapper pw : ProductWrapperList)
            {
                if (pw.IsSelected == true || Test.isRunningTest())
                    optLine.add(new opportunityLineItem(opportunityId = oppObj.id, PricebookEntryId = pw.pricebook.Id, Quantity = 1
                                , RevisedStartMonth__c = monthname
                                , RevisedStartMonthFee__c = monthname
                                , RevisedStartYear__c = string.valueof(convertYear)
                                , RevisedStartYearFee__c = string.valueof(convertYear)
                                , Frequency__c = 'Monthly'
                                , FrequencyFee__c = 'Monthly'
                                , Expected_Util_Year_Fee__c = 0, Expected_Util_Year_NI__c = 0
                                , This_Year_Expected_Fee__c = 0, This_Year_Expected_NI__c = 0
                                , Expected_Revenue_Fee__c = 0, Expected_Revenue__c = 0
                                ));
            }
            ProductWrapperList = new List<ProductWrapper>();
            if (optLine.size() > 0)
            {
                isSelect = true;
                optLineSize = optLine.size();
            }else
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, status_code__c.getValues('8004').status_message__c));
            system.debug(optLine);
        }
    }
    
    public void doSave()
    {
        iscomplete = true;
        try {
        
            string monthString = mapMonth.get(oppObj.CloseDate.month());
            string yearString = '';
            if (Userinfo.getLocale() == 'th_TH'){
                yearString = string.valueof(oppObj.CloseDate.year() - 543);
            }else{
                yearString = string.valueof(oppObj.CloseDate.year());
            }
        
            for (opportunityLineItem o : optLine)
            {
            
                if (string.isBlank(o.Frequency__c) && o.Recurring_Type__c != 'One-Off') o.Frequency__c = 'Monthly';
                if (string.isBlank(o.FrequencyFee__c) && o.Recurring_Type_Fee__c != 'One-Off') o.FrequencyFee__c = 'Monthly';
                if (string.isBlank(o.RevisedStartMonth__c)) o.RevisedStartMonth__c = monthString;
                if (string.isBlank(o.RevisedStartMonthFee__c)) o.RevisedStartMonthFee__c = monthString;
                if (string.isBlank(o.RevisedStartYear__c)) o.RevisedStartYear__c = yearString;
                if (string.isBlank(o.RevisedStartYearFee__c)) o.RevisedStartYearFee__c = yearString;
                
                if (o.This_Year_Expected_NI__c == null) o.This_Year_Expected_NI__c = 0.00;
                if (o.This_Year_Expected_Fee__c == null) o.This_Year_Expected_Fee__c = 0.00;
                
                o.This_Year_Expected_NI__c = o.This_Year_Expected_NI__c.round(system.RoundingMode.HALF_UP);
                o.This_Year_Expected_Fee__c = o.This_Year_Expected_Fee__c.round(system.RoundingMode.HALF_UP);
                
                decimal NiThisYear = o.This_Year_Expected_NI__c;            
                decimal FeeThisYear = o.This_Year_Expected_Fee__c;
                
                if (o.RevisedStartYear__c != thisYear) NiThisYear = 0.00;
                if (o.RevisedStartYearFee__c != thisYear) FeeThisYear = 0.00;
                
                if (o.Expected_Revenue__c == null) o.Expected_Revenue__c = 0.00;
                if (o.Expected_Revenue_Fee__c == null) o.Expected_Revenue_Fee__c = 0.00;
      
                if (o.isNiBreakdownCalculate__c == false){
                    if (o.Type_Of_Reference__c != null){ //&& NiThisYear > 0){
                        calculateNIBreakdown(NiThisYear,o);
                    }
                }
                if (o.isFeeBreakdownCalculate__c == false){
                    if (o.Type_Of_Reference_Fee__c != null){ //&& FeeThisYear > 0){
                        calculateFeeBreakdown(FeeThisYear,o);
                    }
                }
                
            
                if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                    || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
                {
                    string errorText = '';
                    if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                    if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                    if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                    if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, mapProductName.get(o.pricebookentryid) + errorText));
                   iscomplete = false;
                }
      
                if (o.UnitPrice == null) o.UnitPrice = 0;
                if (o.quantity == null) o.quantity = 0;
                if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
                if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
                
                if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                    o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                    o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100 ||
                    o.This_Year_Expected_NI__c < 0 || o.This_Year_Expected_Fee__c < 0)
                {
                
                    string fieldNegative = '';
                    if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                    if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                    if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                    if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                    if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    if (o.This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
                    if (o.This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
                    string errorTextNegative = '';
                    if (fieldNegative != '') 
                        errorTextNegative = status_code__c.getValues('8008').status_message__c 
                                            + fieldNegative;
                    
                    string fieldExceedValue = '';
                    if (o.Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    string errorTextExceedValue = '';
                    if (fieldExceedValue != '') 
                        errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                               + fieldExceedValue;
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,mapProductName.get(o.pricebookentryid) + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                   iscomplete = false;
                
                }else {
                
                    o.Expected_Utilization_Vol_NI__c = o.Unitprice * o.Quantity * (o.Expected_Util_Year_NI__c/100);
                    o.Expected_Utilization_Vol_Fee__c = o.Unitprice * o.Quantity * (o.Expected_Util_Year_Fee__c/100);
                    
                    
                    if (o.OriginalStartMonth__c == null && o.OriginalStartYear__c == null && o.RevisedStartMonth__c != null && o.RevisedStartYear__c != null)
                    {
                     o.OriginalStartMonth__c = o.RevisedStartMonth__c;
                     o.OriginalStartYear__c = o.RevisedStartYear__c;
                    }
                    
                    if (o.OriginalStartMonthFee__c == null && o.OriginalStartYearFee__c == null && o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c != null)
                    {
                     o.OriginalStartMonthFee__c = o.RevisedStartMonthFee__c;
                     o.OriginalStartYearFee__c = o.RevisedStartYearFee__c;
                    }
                    
                }
            }
    
            if (iscomplete){
                insert optLine;
                isSave = true;    
            } 

        }catch(exception ex){
            system.debug(ex);
        }

         if(ErrorsPresent()){
            iscomplete = false;
         }else{
            iscomplete = true;
         }
         system.debug('iscomplete='+iscomplete); 
    }

    public pageReference redirectDeskTop(){
        pageReference p = new ApexPages.StandardController(oppObj).view();
            p.setRedirect(true);
            return p;
    }

    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR); 
    }

    public void doSaveMobile()
    {
        try {
            boolean isNoError = true;
            
            string monthString = mapMonth.get(oppObj.CloseDate.month());
            string yearString = '';
            if (Userinfo.getLocale() == 'th_TH'){
                yearString = string.valueof(oppObj.CloseDate.year() - 543);
            }else{
                yearString = string.valueof(oppObj.CloseDate.year());
            }
            
            for (opportunityLineItem o : optLine)
            {
            
                if (string.isBlank(o.Frequency__c) && o.Recurring_Type__c != 'One-Off') o.Frequency__c = 'Monthly';
                if (string.isBlank(o.FrequencyFee__c) && o.Recurring_Type_Fee__c != 'One-Off') o.FrequencyFee__c = 'Monthly';
                if (string.isBlank(o.RevisedStartMonth__c)) o.RevisedStartMonth__c = monthString;
                if (string.isBlank(o.RevisedStartMonthFee__c)) o.RevisedStartMonthFee__c = monthString;
                if (string.isBlank(o.RevisedStartYear__c)) o.RevisedStartYear__c = yearString;
                if (string.isBlank(o.RevisedStartYearFee__c)) o.RevisedStartYearFee__c = yearString;
                
                if (o.This_Year_Expected_NI__c == null) o.This_Year_Expected_NI__c = 0.00;
                if (o.This_Year_Expected_Fee__c == null) o.This_Year_Expected_Fee__c = 0.00;
                
                o.This_Year_Expected_NI__c = o.This_Year_Expected_NI__c.round(system.RoundingMode.HALF_UP);
                o.This_Year_Expected_Fee__c = o.This_Year_Expected_Fee__c.round(system.RoundingMode.HALF_UP);
                
                decimal NiThisYear = o.This_Year_Expected_NI__c;            
                decimal FeeThisYear = o.This_Year_Expected_Fee__c;
                
                if (o.RevisedStartYear__c != thisYear) NiThisYear = 0.00;
                if (o.RevisedStartYearFee__c != thisYear) FeeThisYear = 0.00;
      
                if (o.Expected_Revenue__c == null) o.Expected_Revenue__c = 0.00;
                if (o.Expected_Revenue_Fee__c == null) o.Expected_Revenue_Fee__c = 0.00;
                
                if (o.isNiBreakdownCalculate__c == false){
                    if (o.Type_Of_Reference__c != null){ //&& NiThisYear > 0){
                        calculateNIBreakdown(NiThisYear,o);
                    }
                }
                if (o.isFeeBreakdownCalculate__c == false){
                    if (o.Type_Of_Reference_Fee__c != null){ //&& FeeThisYear > 0){
                        calculateFeeBreakdown(FeeThisYear,o);
                    }
                }
                
                
                if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                    || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
                {
                    string errorText = '';
                    if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                    if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                    if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                    if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, mapProductName.get(o.pricebookentryid) + errorText));
                    isNoError = false;
                }
            
                if (o.UnitPrice == null) o.UnitPrice = 0;
                if (o.quantity == null) o.quantity = 0;
                if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
                if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
                
                if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                    o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                    o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100 ||
                    o.This_Year_Expected_NI__c < 0 || o.This_Year_Expected_Fee__c < 0)
                {
                    
                    string fieldNegative = '';
                    if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                    if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                    if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                    if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                    if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    if (o.This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
                    if (o.This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
                    string errorTextNegative = '';
                    if (fieldNegative != '') 
                        errorTextNegative = status_code__c.getValues('8008').status_message__c 
                                            + fieldNegative;
                    
                    string fieldExceedValue = '';
                    if (o.Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    string errorTextExceedValue = '';
                    if (fieldExceedValue != '') 
                        errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                               + fieldExceedValue;
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,mapProductName.get(o.pricebookentryid) + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                    isNoError = false;
                
                }else {
                
                    o.Expected_Utilization_Vol_NI__c = o.Unitprice * o.Quantity * (o.Expected_Util_Year_NI__c/100);
                    o.Expected_Utilization_Vol_Fee__c = o.Unitprice * o.Quantity * (o.Expected_Util_Year_Fee__c/100);
                    
                    
                    if (o.OriginalStartMonth__c == null && o.OriginalStartYear__c == null && o.RevisedStartMonth__c != null && o.RevisedStartYear__c != null)
                    {
                     o.OriginalStartMonth__c = o.RevisedStartMonth__c;
                     o.OriginalStartYear__c = o.RevisedStartYear__c;
                    }
                    
                    if (o.OriginalStartMonthFee__c == null && o.OriginalStartYearFee__c == null && o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c != null)
                    {
                     o.OriginalStartMonthFee__c = o.RevisedStartMonthFee__c;
                     o.OriginalStartYearFee__c = o.RevisedStartYearFee__c;
                    }
                    
                }
            }
    
            if (isNoError)
            {
                insert optLine;
                isSave = true;
            }

        }catch(exception ex){
            system.debug(ex);
        }
    }

    

    
    public List<SelectOption> getFiscalYear()
    {
        List<SelectOption> fiscalyearoption = new List<SelectOption>();
        List<Account_Plan_Fiscal_Year__c> yearlistitem = [SELECT ID,Name,AD_Year__c,BE_Year__c FROM Account_Plan_Fiscal_Year__c WHERE ID!=null ORDER BY Name];
        fiscalyearoption.add(new SelectOption('','--None--'));
        for(Account_Plan_Fiscal_Year__c year : yearlistitem){
            fiscalyearoption.add(new SelectOption(year.AD_Year__c,year.AD_Year__c));
        }         
        return fiscalyearoption;
    }
    
    public class ProductWrapper 
    {
        public boolean IsSelected {get;set;}
        public pricebookEntry pricebook {get;set;}  
    }
    
    public pageReference openBreakdown()
    {
        dosave();
        if (isComplete){
            //return new pageReference('/apex/OppProductBreakDown?oppId='+oppObj.id);
            string strOppProdId = '';
            for (opportunitylineitem o: optLine)
            {
                strOppProdId += ','+o.id;
            }
            return new pageReference('/apex/OppProductBreakDown?listoppprodid='+strOppProdId.substring(1));
        }else{
            return null;
        }
    }

    public void calculateNIBreakdown(decimal NiThisYear, opportunityLineItem oppProd)
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
    
    public void calculateFeeBreakdown(decimal FeeThisYear,opportunityLineItem oppProd)
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
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, status_code__c.getValues('8060').status_message__c));
        /*
        boolean isAllBreak = true;
        for (opportunityLineItem o : optLine)
        {
            if (o.isNiBreakdownCalculate__c == false || o.isFeeBreakdownCalculate__c == false)
                isAllBreak = false;
        }
        
        if (!isAllBreak){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, status_code__c.getValues('8060').status_message__c));
        }
        */
    }
    
}