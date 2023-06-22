public class EditProductLineItemCtrlAll2 {

    public Opportunity opty {get;set;}
    public OpportunityLineItem optyline {get;set;}

    public List<OpportunityLineItem> OptLine {get;set;}
    public boolean launchNavigate {get;set;}
    
    public boolean isNoProduct {get;set;}
    public boolean toggleScript {get;set;}
    public boolean isNotSF1{get;set;}
    public  boolean isSERecordType {get;set;}
    public boolean iscomplete {get;set;}
    
    public string thisYear {get;set;}
    public integer optLineSize {get;set;}
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
    
    
    public EditProductLineItemCtrlAll2 (ApexPages.StandardController stdController){

        mapOldNI = new map<string,decimal>();
        mapOldFee = new map<string,decimal>();
        isNotSF1=true;
        toggleScript =false;
        opportunity optyTemp = (Opportunity)stdController.getRecord();
        //[Fah] opty = [select id,stagename,probability,Total_Vol__c,Supply_Chain_Flag__c,Application_status__c,recordtypeid,recordtype.name from Opportunity where id =: optyTemp.id];
        opty = [select id,name,stagename,probability,Supply_Chain_Flag__c,Application_status__c,recordtypeid,recordtype.name,closeDate from Opportunity where id =: optyTemp.id];

        system.debug('Debug 1 : '+Userinfo.getLocale());
        if (Userinfo.getLocale() == 'th_TH'){
            thisYear = string.valueof(system.now().year() - 543);
        }else{
            thisYear = string.valueof(system.now().year());
        }
        optLineSize = 0;
              
        OptLine = getChildren();
        optLineSize = OptLine.size();
        
        String theme=Userinfo.getUItheme();
        if(theme=='Theme4t'){
            isNotSF1 = false;
        }
        for (opportunitylineitem ol : OptLine)
        {
            mapOldNI.put(ol.id,(ol.This_Year_Expected_NI__c != null) ? ol.This_Year_Expected_NI__c : 0);
            mapOldFee.put(ol.id,(ol.This_Year_Expected_Fee__c != null) ? ol.This_Year_Expected_Fee__c : 0);
        }
        
        launchNavigate = false;
        if (OptLine.size() < 1)
        {
            isNoProduct = true; 
            //You must have at least one product before close won. (ต้องเลือก 1 Product เป็นอย่างน้อยก่อนที่จะ Close won)
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,status_code__c.getValues('8016').status_message__c));
            
        } else isNoProduct = false;

        List<RecordType> recTypes = [select Id, Name, sobjectType, DeveloperName from RecordType where Id = :opty.RecordTypeId];
        
            if (recTypes[0].DeveloperName == 'SE_Credit_Product' || recTypes[0].DeveloperName == 'SE_Credit_Product2' || recTypes[0].DeveloperName == 'SE_Credit_Product3') {
                isSERecordType = true;
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
                 , isNiBreakdownCalculate__c, isFeeBreakdownCalculate__c
                 , niBreakdownDate__c , feeBreakdownDate__c 
                 from OpportunityLineItem where opportunityid =: opty.id];
    }
    

    public void dosave(){
        iscomplete = true;

        
     try{
               
         boolean IsNotError=true;
         string monthString = mapMonth.get(opty.CloseDate.month());
         string yearString = '';
         
        system.debug('Debug 2 : '+Userinfo.getLocale());
         if (Userinfo.getLocale() == 'th_TH'){
             yearString = string.valueof(opty.CloseDate.year() - 543);
         }else{
             yearString = string.valueof(opty.CloseDate.year());
         }
         
         system.debug('Debug yearString : '+yearString);
         
         for (opportunityLineItem o : optLine)
         {
         
            system.debug('Debug RevisedStartYearFee__c : '+o.RevisedStartYearFee__c);
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
  
             if ((o.isNiBreakdownCalculate__c == false)// && NiThisYear > 0)
             || (o.isNiBreakdownCalculate__c == true && o.This_Year_Expected_NI__c != mapOldNI.get(o.id))){
                 if (o.Type_Of_Reference__c != null){
                     calculateNIBreakdown(NiThisYear,o);
                 }
             }
             if ((o.isFeeBreakdownCalculate__c == false)// && FeeThisYear > 0)
             || (o.isFeeBreakdownCalculate__c == true && o.This_Year_Expected_Fee__c != mapOldFee.get(o.id))){
                 if (o.Type_Of_Reference_Fee__c != null){
                     calculateFeeBreakdown(FeeThisYear,o);
                 }
             }
 
          
             if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
             {
                string errorText = '';
               //Please Select NI Expected Start Year
                if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>'+status_code__c.getValues('8045').status_message__c ;
                //Please Select NI Expected Start Month
                if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>'+status_code__c.getValues('8046').status_message__c ;
                //Please Select Fee Expected Start Year
                if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>'+status_code__c.getValues('8047').status_message__c ;
                //Please Select Fee Expected Start Month
                if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>'+status_code__c.getValues('8048').status_message__c ;
                
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
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
                 if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-TMB Account No';
                 if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                 if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                 if (o.This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
                 if (o.This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
                 string errorTextNegative = '';
                 if (fieldNegative != '') 
                     errorTextNegative = status_code__c.getValues('8050').status_message__c 
                                         + fieldNegative;
                
                 string fieldExceedValue = '';
                 if (o.Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                 if (o.Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                 string errorTextExceedValue = '';
                 if (fieldExceedValue != '') 
                     errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                            + fieldExceedValue;
                
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
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
             update OptLine;
             toggleScript = true;
         }


        }catch(Exception e){
            system.debug(e);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           
        } 

        if(ErrorsPresent()){
            iscomplete = false;
        }else{
            iscomplete = true;
        }
        system.debug('iscomplete='+iscomplete); 


        
    }

    public pageReference redirectDeskTop(){
        pageReference p = new ApexPages.StandardController(opty).view();
            p.setRedirect(true);
            return p;
    }

    public Boolean ErrorsPresent(){
        return ApexPages.hasMessages(ApexPages.Severity.ERROR); 
    }

    
    
    public void saveCloseWon()
    {
        iscomplete = true;
        try {
        
            string monthString = mapMonth.get(opty.CloseDate.month());
            string yearString = '';
            
        system.debug('Debug 3 : '+Userinfo.getLocale());
            if (Userinfo.getLocale() == 'th_TH'){
                yearString = string.valueof(opty.CloseDate.year() - 543);
            }else{
                yearString = string.valueof(opty.CloseDate.year());
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
      
                if ((o.isNiBreakdownCalculate__c == false)// && NiThisYear > 0)
                || (o.isNiBreakdownCalculate__c == true && o.This_Year_Expected_NI__c != mapOldNI.get(o.id))){
                    if (o.Type_Of_Reference__c != null){
                        calculateNIBreakdown(NiThisYear,o);
                    }
                }
                if ((o.isFeeBreakdownCalculate__c == false)// && FeeThisYear > 0)
                || (o.isFeeBreakdownCalculate__c == true && o.This_Year_Expected_Fee__c != mapOldFee.get(o.id))){
                    if (o.Type_Of_Reference_Fee__c != null){
                        calculateFeeBreakdown(FeeThisYear,o);
                    }
                }
           
                       
                if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                    || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
                {
                    string errorText = '';
                //Please Select NI Expected Start Year
                if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>'+status_code__c.getValues('8045').status_message__c ;
                //Please Select NI Expected Start Month
                if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>'+status_code__c.getValues('8046').status_message__c ;
                //Please Select Fee Expected Start Year
                if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>'+status_code__c.getValues('8047').status_message__c ;
                //Please Select Fee Expected Start Month
                if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>'+status_code__c.getValues('8048').status_message__c ;
                
                
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
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
                    if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-TMB Account No';
                    if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    if (o.This_Year_Expected_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - NI';
                    if (o.This_Year_Expected_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-This Year Expected Revenue - Fee';
                    string errorTextNegative = '';
                    if (fieldNegative != '') 
                        errorTextNegative = status_code__c.getValues('8050').status_message__c 
                                            + fieldNegative;
                
                    string fieldExceedValue = '';
                    if (o.Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
                    string errorTextExceedValue = '';
                    if (fieldExceedValue != '') 
                        errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                               + fieldExceedValue;
                
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                    //return null;
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
        
            string errmsg = CloseWon();
            
            if (errmsg != 'success')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errmsg));
                //return null;
                iscomplete = false;
            }else if (iscomplete){
                update optLine;
                opty.StageName= 'Close Won';
                opty.Probability = 100;
                
                map<string,string> mapRecordtype = new map<string,string>();
                
                for (recordtype r : [select id, name from recordtype where sobjecttype = 'Opportunity' and name in ('Non-credit Product3','SE Credit Product3','WBG Credit Product3')])
                {
                    mapRecordtype.put(r.name,r.id);
                }
                if (opty.recordtype.name == 'SE Credit Product' || opty.recordtype.name == 'WBG Credit Product' || opty.recordtype.name == 'Non-credit Product') 
                    opty.recordtypeid = mapRecordtype.get(opty.recordtype.name+'3');
                    
                update opty;
                
            }
            

            
        }catch(exception ex){
            system.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           
        }

        if(ErrorsPresent()){
                iscomplete = false;
            }else{
                iscomplete = true;
            }
            system.debug('iscomplete='+iscomplete);

    } 
    
    public string CloseWon()
    {
        string errmsg = 'success';
        if (opty.Supply_Chain_Flag__c == false && opty.probability < 95)
        {

            //Opportunity cannot be closed won if the product has not beed been set up or issued(โปรดตรวจสอบว่า Product ได้รับการ Setup หรือ Issued หรือยัง)
            errmsg = status_code__c.getvalues('8009').status_message__c;

        }else{
            
            decimal totalAmount = 0.00;
            for (opportunityLineItem o : optLine)
            {  
                if (o.unitprice != null && o.quantity != null)
                    totalAmount += (o.unitprice * o.quantity);
                    
            } 
            
            if (totalAmount <= 0)
                //Opportunity cannot be closed won. Requested Vol. must be more than 0. (โปรดตรวจสอบว่า Request Volume ไม่ควรเป็น 0)
                errmsg = status_code__c.getvalues('8010').status_message__c;
        }
        
        return errmsg;

    }
    
    public void forCloseWonMsg()
    {
        //Please confirm Product Vol. and Expected Revenue before changing to Close Won
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, status_code__c.getvalues('8049').status_message__c));
    }
    
    public pageReference openBreakdown()
    {
        dosave();
        if (isComplete){
            string strOppProdId = '';
            for (opportunitylineitem o: OptLine)
            {
                strOppProdId += ','+o.id;
            }
            return new pageReference('/apex/OppProductBreakDown?prevPage=all&listoppprodid='+strOppProdId.substring(1));
        }else{
            return null;
        }
    }
    public pageReference openBreakdownCloseWon()
    {
        dosave();
        if (isComplete){
            string strOppProdId = '';
            for (opportunitylineitem o: OptLine)
            {
                strOppProdId += ','+o.id;
            }
            return new pageReference('/apex/OppProductBreakDown?prevPage=closewon&oppId='+opty.id+'&listoppprodid='+strOppProdId.substring(1));
        }else{
            return null;
        }
    }
    
    public void calculateNIBreakdown(decimal NiThisYear, opportunityLineItem oppProd)
    {
        oppProd.Ni_January__c = 0;
        oppProd.Ni_February__c = 0;
        oppProd.Ni_March__c = 0;
        oppProd.Ni_April__c = 0;
        oppProd.Ni_May__c = 0;
        oppProd.Ni_June__c = 0;
        oppProd.Ni_July__c = 0;
        oppProd.Ni_August__c = 0;
        oppProd.Ni_September__c = 0;
        oppProd.Ni_October__c = 0;
        oppProd.Ni_November__c = 0;
        oppProd.Ni_December__c = 0;
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
        oppProd.Fee_January__c = 0;
        oppProd.Fee_February__c = 0;
        oppProd.Fee_March__c = 0;
        oppProd.Fee_April__c = 0;
        oppProd.Fee_May__c = 0;
        oppProd.Fee_June__c = 0;
        oppProd.Fee_July__c = 0;
        oppProd.Fee_August__c = 0;
        oppProd.Fee_September__c = 0;
        oppProd.Fee_October__c = 0;
        oppProd.Fee_November__c = 0;
        oppProd.Fee_December__c = 0;
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