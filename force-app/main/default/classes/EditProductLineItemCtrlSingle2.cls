public class EditProductLineItemCtrlSingle2 {

    public Opportunity opty {get;set;}
    public OpportunityLineItem optyline {get;set;}

    public List<OpportunityLineItem> OptLine {get;set;}
    public boolean launchNavigate {get;set;}

    public boolean isSERecordType {get;set;}
    public boolean isSE3RecordType {get;set;}
    public boolean iscomplete {get;set;}
    public boolean toggleScript {get;set;}
    public boolean isNotSF1 {get;set;}

    public string thisYear {get;set;}
    public boolean isOppClose {get;set;}
    public string remark {get;set;}
    
    public map<string,decimal> mapOldNI {get;set;}
    public map<string,decimal> mapOldFee {get;set;}
    
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

    
    public EditProductLineItemCtrlSingle2(ApexPages.StandardController stdController){

        isNotSF1 = true;
        mapOldNI = new map<string,decimal>();
        mapOldFee = new map<string,decimal>();
        optyline = (OpportunityLineItem)stdController.getRecord();
        opportunityLineitem tempOptyLine = [select opportunityid from opportunityLineitem where id =: optyline.id];
        //[Fah] opty = [select id,stagename,probability,Total_Vol__c from Opportunity where id =: tempOptyLine.opportunityId];
        opty = [select id,name,stagename,probability,RecordTypeId,isClosed,closeDate from Opportunity where id =: tempOptyLine.opportunityId];
        isOppClose = false;
        toggleScript =false;
        
        String theme=Userinfo.getUItheme();
        if(theme=='Theme4t'){
            isNotSF1 = false;
        }
        if (opty.isClosed) isOppClose = opty.isClosed;
        OptLine = getChildren();
        launchNavigate = false; 
        if (Userinfo.getLocale() == 'th_TH'){
            thisYear = string.valueof(system.now().year() - 543);
        }else{
            thisYear = string.valueof(system.now().year());
        }
        
        for (opportunitylineitem ol : OptLine)
        {
            mapOldNI.put(ol.id,(ol.This_Year_Expected_NI__c != null) ? ol.This_Year_Expected_NI__c : 0);
            mapOldFee.put(ol.id,(ol.This_Year_Expected_Fee__c != null) ? ol.This_Year_Expected_Fee__c : 0);
        }

        List<RecordType> recTypes = [select Id, Name, sobjectType, DeveloperName from RecordType where Id = :opty.RecordTypeId];
        
        isSE3RecordType = false;
            if (recTypes[0].DeveloperName == 'SE_Credit_Product' || recTypes[0].DeveloperName == 'SE_Credit_Product2' || recTypes[0].DeveloperName == 'SE_Credit_Product3') {
                isSERecordType = true;
                if(recTypes[0].DeveloperName == 'SE_Credit_Product3'){
                    isSE3RecordType = true;
                }
            }else if (recTypes[0].DeveloperName == 'WBG_Non_credit_Product' || recTypes[0].DeveloperName == 'WBG_Credit_Product') {
                isSERecordType = false;
            }
            
        remark = '';
        remark = status_code__c.getValues('8057').status_message__c;
        
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
    

    public List<OpportunityLineItem> getChildren()
    {
        
        return [SELECT ID,PricebookEntryId,Tenor_Years__c,UnitPrice,Type_Of_Reference__c,Recurring_Type__c,FrequencyFee__c,Frequency__c,Expected_NI__c
                 , Expected_Revenue__c
                 , RevisedStartMonth__c,RevisedStartYear__c,Type_Of_Reference_Fee__c,Recurring_Type_Fee__c,Expected_Fee__c
                 , Expected_Revenue_Fee__c
                 , RevisedStartMonthFee__c,RevisedStartYearFee__c 
                 , Quantity, Notional_Amount__c
                 , Expected_NIM__c, Deal_Probability__c, Expected_Fee_Rate__c
                 , PricebookEntry.Product2.Name
                 , Description, Expected_Util_Year_NI__c, Expected_Utilization_Vol_NI__c, This_Year_Expected_NI__c 
                 , Expected_Util_Year_Fee__c, This_Year_Expected_Fee__c , Expected_Utilization_Vol_Fee__c 
                 , OriginalStartMonth__c, OriginalStartYear__c, OriginalStartMonthFee__c, OriginalStartYearFee__c
                 , Host_Product_Mapping__c, Host_Product_Mapping__r.Host_Product_Group__c
                 , Host_Product_Mapping__r.Product_Program__c, Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c
                 , opportunity.recordtype.name
                 , Host_Product_Status__c
                 , TMB_Account_ID__c
                 , Approved_Amount__c
                 , Actual_Amount__c
                 , ni_january__c, ni_february__c, ni_march__c, ni_april__c
                 , ni_may__c, ni_june__c, ni_july__c, ni_august__c
                 , ni_september__c, ni_october__c, ni_november__c, ni_december__c
                 , fee_january__c, fee_february__c, fee_march__c, fee_april__c
                 , fee_may__c, fee_june__c, fee_july__c, fee_august__c
                 , fee_september__c, fee_october__c, fee_november__c, fee_december__c
                 , isNiBreakdownCalculate__c, isFeeBreakdownCalculate__c
                 , niBreakdownDate__c, feeBreakdownDate__c
                  from OpportunityLineItem where id =: optyline.id];
    }
    
    public PageReference back(){
    
        PageReference Page = new ApexPages.StandardController(opty).view();
        Page.setRedirect(true);
        return Page;   
    
    }
 
    public void dosave(){
        iscomplete = true;
     try{
     
        string monthString = mapMonth.get(opty.CloseDate.month());
        string yearString = '';
        if (Userinfo.getLocale() == 'th_TH'){
            yearString = string.valueof(opty.CloseDate.year() - 543);
        }else{
            yearString = string.valueof(opty.CloseDate.year());
        }
     
        if (string.isBlank(OptLine.get(0).Frequency__c) && OptLine.get(0).Recurring_Type__c != 'One-Off') OptLine.get(0).Frequency__c = 'Monthly';
        if (string.isBlank(OptLine.get(0).FrequencyFee__c) && OptLine.get(0).Recurring_Type_Fee__c != 'One-Off') OptLine.get(0).FrequencyFee__c = 'Monthly';
        if (string.isBlank(OptLine.get(0).RevisedStartMonth__c)) OptLine.get(0).RevisedStartMonth__c = monthString;
        if (string.isBlank(OptLine.get(0).RevisedStartMonthFee__c)) OptLine.get(0).RevisedStartMonthFee__c = monthString;
        if (string.isBlank(OptLine.get(0).RevisedStartYear__c)) OptLine.get(0).RevisedStartYear__c = yearString;
        if (string.isBlank(OptLine.get(0).RevisedStartYearFee__c)) OptLine.get(0).RevisedStartYearFee__c = yearString;
        //if (string.isBlank(OptLine.get(0).RevisedStartMonth__c)) OptLine.get(0).RevisedStartMonth__c = 'Jan';
        //if (string.isBlank(OptLine.get(0).RevisedStartMonthFee__c)) OptLine.get(0).RevisedStartMonthFee__c = 'Jan';
        //if (string.isBlank(OptLine.get(0).RevisedStartYear__c)) OptLine.get(0).RevisedStartYear__c = string.valueof(system.today().year());
        //if (string.isBlank(OptLine.get(0).RevisedStartYearFee__c)) OptLine.get(0).RevisedStartYearFee__c = string.valueof(system.today().year());
     
        if (OptLine.get(0).This_Year_Expected_NI__c == null) OptLine.get(0).This_Year_Expected_NI__c = 0.00;
        if (OptLine.get(0).This_Year_Expected_Fee__c == null) OptLine.get(0).This_Year_Expected_Fee__c = 0.00;
        
        OptLine.get(0).This_Year_Expected_NI__c = OptLine.get(0).This_Year_Expected_NI__c.round(system.RoundingMode.HALF_UP);
        OptLine.get(0).This_Year_Expected_Fee__c = OptLine.get(0).This_Year_Expected_Fee__c.round(system.RoundingMode.HALF_UP);
        
        decimal NiThisYear = OptLine.get(0).This_Year_Expected_NI__c;            
        decimal FeeThisYear = OptLine.get(0).This_Year_Expected_Fee__c;
        
        //if (OptLine.get(0).RevisedStartYear__c != string.valueof(system.today().year())) NiThisYear = 0.00;
        //if (OptLine.get(0).RevisedStartYearFee__c != string.valueof(system.today().year())) FeeThisYear = 0.00;
        if (OptLine.get(0).RevisedStartYear__c != thisYear) NiThisYear = 0.00;
        if (OptLine.get(0).RevisedStartYearFee__c != thisYear) FeeThisYear = 0.00;
        
        if (OptLine.get(0).Expected_Revenue__c == null) OptLine.get(0).Expected_Revenue__c = 0.00;
        if (OptLine.get(0).Expected_Revenue_Fee__c == null) OptLine.get(0).Expected_Revenue_Fee__c = 0.00;
        
        if ((OptLine.get(0).isNiBreakdownCalculate__c == false)// && NiThisYear > 0) 
        || (OptLine.get(0).isNiBreakdownCalculate__c == true && OptLine.get(0).This_Year_Expected_NI__c != mapOldNI.get(OptLine.get(0).id))){
            if (OptLine.get(0).Type_Of_Reference__c != null){
                calculateNIBreakdown(NiThisYear);
            }
        }
        if ((OptLine.get(0).isFeeBreakdownCalculate__c == false)// && FeeThisYear > 0) 
        || (OptLine.get(0).isFeeBreakdownCalculate__c == true && OptLine.get(0).This_Year_Expected_Fee__c != mapOldFee.get(OptLine.get(0).id))){ 
            if (OptLine.get(0).Type_Of_Reference_Fee__c != null){
                calculateFeeBreakdown(FeeThisYear);
            }
        }
     
               
         boolean IsNotError=true;
         
         if ((OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) || (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null)
            || (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) || (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null))
         {
            string errorText = '';
            //Please Select NI Expected Start Year
             if (OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) errorText += '<br/>'+status_code__c.getValues('8045').status_message__c ;
                //Please Select NI Expected Start Month
                if (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null) errorText += '<br/>'+status_code__c.getValues('8046').status_message__c ;
                //Please Select Fee Expected Start Year
                if (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) errorText += '<br/>'+status_code__c.getValues('8047').status_message__c ;
                //Please Select Fee Expected Start Month
                if (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null) errorText += '<br/>'+status_code__c.getValues('8048').status_message__c ;
                

            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, OptLine.get(0).PricebookEntry.Product2.Name + errorText));
            iscomplete = false;
         } 
         
         if (OptLine.get(0).UnitPrice == null) OptLine.get(0).UnitPrice = 0;
         if (OptLine.get(0).quantity == null) OptLine.get(0).quantity = 0;
         if (OptLine.get(0).Expected_Util_Year_NI__c == null) OptLine.get(0).Expected_Util_Year_NI__c = 0.00;
         if (OptLine.get(0).Expected_Util_Year_Fee__c == null) OptLine.get(0).Expected_Util_Year_Fee__c = 0.00;
         
         if (OptLine.get(0).UnitPrice < 0 || OptLine.get(0).quantity < 0 || OptLine.get(0).Tenor_Years__c < 0 || 
             OptLine.get(0).Notional_Amount__c < 0 || OptLine.get(0).Expected_Util_Year_NI__c < 0 || OptLine.get(0).Expected_Util_Year_Fee__c < 0 ||
             OptLine.get(0).Expected_Util_Year_NI__c > 100 || OptLine.get(0).Expected_Util_Year_Fee__c > 100 ||
             OptLine.get(0).This_Year_Expected_NI__c < 0 || OptLine.get(0).This_Year_Expected_Fee__c < 0)
         {
            
              string fieldNegative = '';
             if (OptLine.get(0).UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
             if (OptLine.get(0).quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
             if (OptLine.get(0).Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
             if (OptLine.get(0).Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-TMB Account No';
             if (OptLine.get(0).Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             if (OptLine.get(0).This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
             if (OptLine.get(0).This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
             string errorTextNegative = '';
             if (fieldNegative != '') 
                 errorTextNegative = status_code__c.getValues('8050').status_message__c 
                                     + fieldNegative;
            
             string fieldExceedValue = '';
             if (OptLine.get(0).Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             string errorTextExceedValue = '';
             if (fieldExceedValue != '') 
                 errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                        + fieldExceedValue;
            
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,OptLine.get(0).PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
             //return null;
             iscomplete = false;
             
         }else {
         
             OptLine.get(0).Expected_Utilization_Vol_NI__c = OptLine.get(0).Unitprice * OptLine.get(0).Quantity * (OptLine.get(0).Expected_Util_Year_NI__c/100);
             OptLine.get(0).Expected_Utilization_Vol_Fee__c = OptLine.get(0).Unitprice * OptLine.get(0).Quantity * (OptLine.get(0).Expected_Util_Year_Fee__c/100);
    
             
             if (OptLine.get(0).OriginalStartMonth__c == null && OptLine.get(0).OriginalStartYear__c == null && OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c != null)
             {
                 OptLine.get(0).OriginalStartMonth__c = OptLine.get(0).RevisedStartMonth__c;
                 OptLine.get(0).OriginalStartYear__c = OptLine.get(0).RevisedStartYear__c;
             }
            
             if (OptLine.get(0).OriginalStartMonthFee__c == null && OptLine.get(0).OriginalStartYearFee__c == null && OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c != null)
             {
                 OptLine.get(0).OriginalStartMonthFee__c = OptLine.get(0).RevisedStartMonthFee__c;
                 OptLine.get(0).OriginalStartYearFee__c = OptLine.get(0).RevisedStartYearFee__c;
             }
             
             
             update OptLine;
             toggleScript = true;
    
         }

 
     

        }catch(Exception e){
            system.debug(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
           if(ErrorsPresent()){
            iscomplete = false;
        }else{
            iscomplete = true;
        }
        system.debug('iscomplete='+iscomplete); 

    }

    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR); 
    }
    
    public pageReference openBreakdown()
    {
        dosave();
        if (isComplete){
            //return new pageReference('/apex/OppProductBreakDown?id='+optyline.id);
            return new pageReference('/apex/OppProductBreakDown?listoppprodid='+OptLine.get(0).id);
        }else{
            return null;
        }
    }


    public void calculateNIBreakdown(decimal NiThisYear)
    {
        OptLine.get(0).Ni_January__c = 0;
        OptLine.get(0).Ni_February__c = 0;
        OptLine.get(0).Ni_March__c = 0;
        OptLine.get(0).Ni_April__c = 0;
        OptLine.get(0).Ni_May__c = 0;
        OptLine.get(0).Ni_June__c = 0;
        OptLine.get(0).Ni_July__c = 0;
        OptLine.get(0).Ni_August__c = 0;
        OptLine.get(0).Ni_September__c = 0;
        OptLine.get(0).Ni_October__c = 0;
        OptLine.get(0).Ni_November__c = 0;
        OptLine.get(0).Ni_December__c = 0;
    
        //if (NiThisYear > 0.00){
            
            OptLine.get(0).isNiBreakdownCalculate__c = true;
            OptLine.get(0).niBreakdownDate__c = system.now();
            
            decimal totalMonth = 12;
            decimal divideVal = 1;
            decimal eachVal = 0;
            decimal diffVal = 0;
            
            if (OptLine.get(0).RevisedStartMonth__c == 'Jan') totalMonth = totalMonth - 1;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Feb') totalMonth = totalMonth - 2;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Mar') totalMonth = totalMonth - 3;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Apr') totalMonth = totalMonth - 4;
            else if (OptLine.get(0).RevisedStartMonth__c == 'May') totalMonth = totalMonth - 5;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Jun') totalMonth = totalMonth - 6;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Jul') totalMonth = totalMonth - 7;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Aug') totalMonth = totalMonth - 8;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Sep') totalMonth = totalMonth - 9;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Oct') totalMonth = totalMonth - 10;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Nov') totalMonth = totalMonth - 11;
            else if (OptLine.get(0).RevisedStartMonth__c == 'Dec') totalMonth = totalMonth - 12;
            
            if (OptLine.get(0).Frequency__c == 'Monthly'){
                divideVal = totalMonth/1;
            }else if (OptLine.get(0).Frequency__c == 'Quarterly'){
                divideVal = totalMonth/3;
            }else if (OptLine.get(0).Frequency__c == 'Half-yearly'){
                divideVal = totalMonth/6;
            }else if (OptLine.get(0).Frequency__c == 'Annually'){
                divideVal = 0;
            }else{
                divideVal = 0;
            }
            
            divideVal = divideVal.round(System.RoundingMode.FLOOR) + 1;
            eachVal = (NiThisYear / divideVal).round(System.RoundingMode.FLOOR);
            diffVal = NiThisYear - (eachVal * divideVal);
            
            if (OptLine.get(0).RevisedStartMonth__c == 'Jan'){
                OptLine.get(0).NI_January__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_February__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_March__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_April__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_May__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_July__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Feb'){
                OptLine.get(0).NI_February__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_March__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_April__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_May__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_August__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Mar'){
                OptLine.get(0).NI_March__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_April__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_May__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_September__c = eachVal + diffVal;
                
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Apr'){
                OptLine.get(0).NI_April__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_May__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_October__c = eachVal + diffVal;
                
            }else if (OptLine.get(0).RevisedStartMonth__c == 'May'){
                OptLine.get(0).NI_May__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_November__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Jun'){
                OptLine.get(0).NI_June__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly' || OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_December__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Jul'){
                OptLine.get(0).NI_July__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_July__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Aug'){
                OptLine.get(0).NI_August__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_August__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Sep'){
                OptLine.get(0).NI_September__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly' || OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_September__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Oct'){
                OptLine.get(0).NI_October__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_October__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_October__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Nov'){
                OptLine.get(0).NI_November__c = eachVal;
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal;
                
                if (OptLine.get(0).Frequency__c == 'Monthly') OptLine.get(0).NI_December__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Quarterly') OptLine.get(0).NI_November__c = eachVal + diffVal;
                else if (OptLine.get(0).Frequency__c == 'Half-yearly') OptLine.get(0).NI_November__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonth__c == 'Dec'){
                OptLine.get(0).NI_December__c = eachVal + diffVal;
            
            }
            
            
        //}
    }
    
    public void calculateFeeBreakdown(decimal FeeThisYear)
    {
        OptLine.get(0).Fee_January__c = 0;
        OptLine.get(0).Fee_February__c = 0;
        OptLine.get(0).Fee_March__c = 0;
        OptLine.get(0).Fee_April__c = 0;
        OptLine.get(0).Fee_May__c = 0;
        OptLine.get(0).Fee_June__c = 0;
        OptLine.get(0).Fee_July__c = 0;
        OptLine.get(0).Fee_August__c = 0;
        OptLine.get(0).Fee_September__c = 0;
        OptLine.get(0).Fee_October__c = 0;
        OptLine.get(0).Fee_November__c = 0;
        OptLine.get(0).Fee_December__c = 0;
    
        //if (FeeThisYear > 0.00){
            
            OptLine.get(0).isFeeBreakdownCalculate__c = true;
            OptLine.get(0).feeBreakdownDate__c = system.now();
            
            decimal totalMonth = 12;
            decimal divideVal = 1;
            decimal eachVal = 0;
            decimal diffVal = 0;
            
            if (OptLine.get(0).RevisedStartMonthFee__c == 'Jan') totalMonth = totalMonth - 1;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Feb') totalMonth = totalMonth - 2;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Mar') totalMonth = totalMonth - 3;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Apr') totalMonth = totalMonth - 4;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'May') totalMonth = totalMonth - 5;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Jun') totalMonth = totalMonth - 6;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Jul') totalMonth = totalMonth - 7;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Aug') totalMonth = totalMonth - 8;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Sep') totalMonth = totalMonth - 9;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Oct') totalMonth = totalMonth - 10;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Nov') totalMonth = totalMonth - 11;
            else if (OptLine.get(0).RevisedStartMonthFee__c == 'Dec') totalMonth = totalMonth - 12;
            
            if (OptLine.get(0).FrequencyFee__c == 'Monthly'){
                divideVal = totalMonth/1;
            }else if (OptLine.get(0).FrequencyFee__c == 'Quarterly'){
                divideVal = totalMonth/3;
            }else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly'){
                divideVal = totalMonth/6;
            }else if (OptLine.get(0).FrequencyFee__c == 'Annually'){
                divideVal = 0;
            }else{
                divideVal = 0;
            }
            
            divideVal = divideVal.round(System.RoundingMode.FLOOR) + 1;
            eachVal = (FeeThisYear / divideVal).round(System.RoundingMode.FLOOR);
            diffVal = FeeThisYear - (eachVal * divideVal);
            
            if (OptLine.get(0).RevisedStartMonthFee__c == 'Jan'){
                OptLine.get(0).Fee_January__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_February__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_March__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_April__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_May__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_July__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Feb'){
                OptLine.get(0).Fee_February__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_March__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_April__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_May__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_August__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Mar'){
                OptLine.get(0).Fee_March__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_April__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_May__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_September__c = eachVal + diffVal;
                
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Apr'){
                OptLine.get(0).Fee_April__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_May__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
                
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'May'){
                OptLine.get(0).Fee_May__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Jun'){
                OptLine.get(0).Fee_June__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly' || OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Jul'){
                OptLine.get(0).Fee_July__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_July__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Aug'){
                OptLine.get(0).Fee_August__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_August__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Sep'){
                OptLine.get(0).Fee_September__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly' || OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_September__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Oct'){
                OptLine.get(0).Fee_October__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_October__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Nov'){
                OptLine.get(0).Fee_November__c = eachVal;
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal;
                
                if (OptLine.get(0).FrequencyFee__c == 'Monthly') OptLine.get(0).Fee_December__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Quarterly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
                else if (OptLine.get(0).FrequencyFee__c == 'Half-yearly') OptLine.get(0).Fee_November__c = eachVal + diffVal;
            
            }else if (OptLine.get(0).RevisedStartMonthFee__c == 'Dec'){
                OptLine.get(0).Fee_December__c = eachVal + diffVal;
            
            }
            
            
        //}
    }

    public void validateYear()
    {
        //if (OptLine.get(0).isNiBreakdownCalculate__c == false || OptLine.get(0).isFeeBreakdownCalculate__c == false){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING, status_code__c.getValues('8060').status_message__c));
        //}
    }
    
   
}