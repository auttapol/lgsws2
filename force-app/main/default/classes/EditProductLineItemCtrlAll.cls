public class EditProductLineItemCtrlAll {

    public Opportunity opty {get;set;}
    public OpportunityLineItem optyline {get;set;}

    public List<OpportunityLineItem> OptLine {get;set;}
    public boolean launchNavigate {get;set;}
    
    public boolean isNoProduct {get;set;}
    
    public EditProductLineItemCtrlAll (ApexPages.StandardController stdController){

        opportunity optyTemp = (Opportunity)stdController.getRecord();
        //[Fah] opty = [select id,stagename,probability,Total_Vol__c,Supply_Chain_Flag__c,Application_status__c,recordtypeid,recordtype.name from Opportunity where id =: optyTemp.id];
        opty = [select id,stagename,probability,Supply_Chain_Flag__c,Application_status__c,recordtypeid,recordtype.name from Opportunity where id =: optyTemp.id];
       
        OptLine = getChildren();
        launchNavigate = false;
        if (OptLine.size() < 1)
        {
            isNoProduct = true; 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,status_code__c.getValues('8016').status_message__c));
            
        } else isNoProduct = false;
        
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
                 from OpportunityLineItem where opportunityid =: opty.id];
    }
    
    public PageReference back(){
    
        PageReference Page = new ApexPages.StandardController(opty).view();
        Page.setRedirect(true);
        return Page;   
    
    }

    public PageReference dosave(){
     try{
               
         boolean IsNotError=true;
         
         for (opportunityLineItem o : optLine)
         {
         
             if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
             {
                string errorText = '';
                if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
                return null;
             }
         
             if (o.UnitPrice == null) o.UnitPrice = 0;
             if (o.quantity == null) o.quantity = 0;
             if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
             if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
             
             if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                 o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                 o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100)
             {
            
                 string fieldNegative = '';
                 if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                 if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                 if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                 if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                 if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                 if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
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
                
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                 return null;
                 
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
         
         
         update OptLine;

         
         PageReference Page = new ApexPages.StandardController(opty).view();
         Page.setRedirect(true);
         return Page;  

 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        } 
        
    }
    
    public void dosaveMobile(){
     try{
           
         boolean IsNotError=true;  
         boolean isPass = true;
         
         for (opportunityLineItem o : optLine)
         {  
         
             if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
             {
                string errorText = '';
                if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
                isPass = false;
             }
         
             if (o.UnitPrice == null) o.UnitPrice = 0;
             if (o.quantity == null) o.quantity = 0;
             if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
             if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
             
             if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                 o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                 o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100)
             {
            
                 string fieldNegative = '';
                 if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                 if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                 if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                 if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                 if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                 if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
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
                
                 ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                 isPass = false;
 
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
         
         if (isPass)
         {
             update OptLine;       
             launchNavigate = true;
         }


        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));

        } 
        
    }
    
    public pageReference saveCloseWon()
    {
        try {
        
            for (opportunityLineItem o : optLine)
            {
            
                if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                    || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
                {
                    string errorText = '';
                    if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                    if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                    if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                    if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
                    return null;
                }
            
                if (o.UnitPrice == null) o.UnitPrice = 0;
                if (o.quantity == null) o.quantity = 0;
                if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
                if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
                
                if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                    o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                    o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100)
                {
            
                    string fieldNegative = '';
                    if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                       if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                    if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                    if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                    if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
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
                
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                    return null;
                
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
                return null;
            }else{
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
                    
                //opty.Application_status__c = '';
                update opty;
                PageReference Page = new ApexPages.StandardController(opty).view();
                Page.setRedirect(true);
                return Page; 
            }
            
        }catch(exception ex){
            system.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }

    }
    public void saveCloseWonMobile()
    {
        try {
        
            boolean isPass = true;
             
            for (opportunityLineItem o : optLine)
            {  
                
                if ((o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) || (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null)
                    || (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) || (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null))
                {
                    string errorText = '';
                    if (o.RevisedStartMonth__c != null && o.RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
                    if (o.RevisedStartMonth__c == null && o.RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
                    if (o.RevisedStartMonthFee__c != null && o.RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
                    if (o.RevisedStartMonthFee__c == null && o.RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, o.PricebookEntry.Product2.Name + errorText));
                    isPass = false;
                }
                
                if (o.UnitPrice == null) o.UnitPrice = 0;
                if (o.quantity == null) o.quantity = 0;
                if (o.Expected_Util_Year_NI__c == null) o.Expected_Util_Year_NI__c = 0.00;
                if (o.Expected_Util_Year_Fee__c == null) o.Expected_Util_Year_Fee__c = 0.00;
                
                if (o.UnitPrice < 0 || o.quantity < 0 || o.Tenor_Years__c < 0 || 
                    o.Notional_Amount__c < 0 || o.Expected_Util_Year_NI__c < 0 || o.Expected_Util_Year_Fee__c < 0 ||
                    o.Expected_Util_Year_NI__c > 100 || o.Expected_Util_Year_Fee__c > 100)
                {
            
                    string fieldNegative = '';
                    if (o.UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
                       if (o.quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
                    if (o.Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
                    if (o.Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
                    if (o.Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
                    if (o.Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
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
                
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,o.PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
                    isPass = false;
             
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
        
            if (isPass)
            {
                string errmsg = CloseWon();
                
                if (errmsg != 'success')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errmsg));
                }else{
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
                    
                    //opty.Application_status__c = '';
                    update opty;
                    launchNavigate = true;
                }
            }
            
        }catch(exception ex){
            system.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
    }
    
    public string CloseWon()
    {
        string errmsg = 'success';
        if (opty.Supply_Chain_Flag__c == false && opty.probability < 95)
        {

            errmsg = status_code__c.getvalues('8009').status_message__c;

        }else{
            
            decimal totalAmount = 0.00;
            for (opportunityLineItem o : optLine)
            {  
                if (o.unitprice != null && o.quantity != null)
                    totalAmount += (o.unitprice * o.quantity);
                    
            } 
            
            if (totalAmount <= 0)
                errmsg = status_code__c.getvalues('8010').status_message__c;
        }
        
        return errmsg;

    }
    
    public void forCloseWonMsg()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Please confirm Product Vol. and Expected Revenue before changing to Close Won'));
    }


}