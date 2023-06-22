public class EditProductLineItemCtrlSingle {

    public Opportunity opty {get;set;}
    public OpportunityLineItem optyline {get;set;}

    public List<OpportunityLineItem> OptLine {get;set;}
    public boolean launchNavigate {get;set;}
    
    public EditProductLineItemCtrlSingle (ApexPages.StandardController stdController){

        optyline = (OpportunityLineItem)stdController.getRecord();
        opportunityLineitem tempOptyLine = [select opportunityid from opportunityLineitem where id =: optyline.id];
        //[Fah] opty = [select id,stagename,probability,Total_Vol__c from Opportunity where id =: tempOptyLine.opportunityId];
        opty = [select id,stagename,probability from Opportunity where id =: tempOptyLine.opportunityId];
        OptLine = getChildren();
        launchNavigate = false;
        
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
                 ,Expected_Revenue__c
                 ,RevisedStartMonth__c,RevisedStartYear__c,Type_Of_Reference_Fee__c,Recurring_Type_Fee__c,Expected_Fee__c
                 ,Expected_Revenue_Fee__c
                 ,RevisedStartMonthFee__c,RevisedStartYearFee__c 
                 , Quantity, Notional_Amount__c
                 , Expected_NIM__c, Deal_Probability__c, Expected_Fee_Rate__c
                 , PricebookEntry.Product2.Name
                 , Description, Expected_Util_Year_NI__c, Expected_Utilization_Vol_NI__c, This_Year_Expected_NI__c 
                 , Expected_Util_Year_Fee__c, This_Year_Expected_Fee__c , Expected_Utilization_Vol_Fee__c 
                 , OriginalStartMonth__c, OriginalStartYear__c, OriginalStartMonthFee__c, OriginalStartYearFee__c
                 from OpportunityLineItem where id =: optyline.id];
    }
    
    public PageReference back(){
    
        PageReference Page = new ApexPages.StandardController(opty).view();
        Page.setRedirect(true);
        return Page;   
    
    }

    public PageReference dosave(){
     try{
               
         boolean IsNotError=true;
         
         if ((OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) || (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null)
            || (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) || (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null))
         {
            string errorText = '';
            if (OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
            if (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
            if (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
            if (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
            
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, OptLine.get(0).PricebookEntry.Product2.Name + errorText));
            return null;
         }
         
         if (OptLine.get(0).UnitPrice == null) OptLine.get(0).UnitPrice = 0;
         if (OptLine.get(0).quantity == null) OptLine.get(0).quantity = 0;
         if (OptLine.get(0).Expected_Util_Year_NI__c == null) OptLine.get(0).Expected_Util_Year_NI__c = 0.00;
         if (OptLine.get(0).Expected_Util_Year_Fee__c == null) OptLine.get(0).Expected_Util_Year_Fee__c = 0.00;
         
         if (OptLine.get(0).UnitPrice < 0 || OptLine.get(0).quantity < 0 || OptLine.get(0).Tenor_Years__c < 0 || 
             OptLine.get(0).Notional_Amount__c < 0 || OptLine.get(0).Expected_Util_Year_NI__c < 0 || OptLine.get(0).Expected_Util_Year_Fee__c < 0 ||
             OptLine.get(0).Expected_Util_Year_NI__c > 100 || OptLine.get(0).Expected_Util_Year_Fee__c > 100)
         {
            
             string fieldNegative = '';
             if (OptLine.get(0).UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
             if (OptLine.get(0).quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
             if (OptLine.get(0).Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
             if (OptLine.get(0).Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
             if (OptLine.get(0).Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             string errorTextNegative = '';
             if (fieldNegative != '') 
                 errorTextNegative = status_code__c.getValues('8008').status_message__c 
                                     + fieldNegative;
            
             string fieldExceedValue = '';
             if (OptLine.get(0).Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             string errorTextExceedValue = '';
             if (fieldExceedValue != '') 
                 errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                        + fieldExceedValue;
            
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,OptLine.get(0).PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
             return null;
             
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
    
             PageReference Page = new ApexPages.StandardController(opty).view();
             Page.setRedirect(true);
             return Page;  
         
         }

 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        } 
        
    }
    
    public void dosaveMobile(){
     try{
           
         boolean IsNotError=true;  
         
         if ((OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) || (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null)
            || (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) || (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null))
         {
            string errorText = '';
            if (OptLine.get(0).RevisedStartMonth__c != null && OptLine.get(0).RevisedStartYear__c == null) errorText += '<br/>Please Select NI Expected Start Year';
            if (OptLine.get(0).RevisedStartMonth__c == null && OptLine.get(0).RevisedStartYear__c != null) errorText += '<br/>Please Select NI Expected Start Month';
            if (OptLine.get(0).RevisedStartMonthFee__c != null && OptLine.get(0).RevisedStartYearFee__c == null) errorText += '<br/>Please Select Fee Expected Start Year';
            if (OptLine.get(0).RevisedStartMonthFee__c == null && OptLine.get(0).RevisedStartYearFee__c != null) errorText += '<br/>Please Select Fee Expected Start Month';
            
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, OptLine.get(0).PricebookEntry.Product2.Name + errorText));
         }
         
         if (OptLine.get(0).UnitPrice == null) OptLine.get(0).UnitPrice = 0;
         if (OptLine.get(0).quantity == null) OptLine.get(0).quantity = 0;
         if (OptLine.get(0).Expected_Util_Year_NI__c == null) OptLine.get(0).Expected_Util_Year_NI__c = 0.00;
         if (OptLine.get(0).Expected_Util_Year_Fee__c == null) OptLine.get(0).Expected_Util_Year_Fee__c = 0.00;
         
         if (OptLine.get(0).UnitPrice < 0 || OptLine.get(0).quantity < 0 || OptLine.get(0).Tenor_Years__c < 0 || 
             OptLine.get(0).Notional_Amount__c < 0 || OptLine.get(0).Expected_Util_Year_NI__c < 0 || OptLine.get(0).Expected_Util_Year_Fee__c < 0 ||
             OptLine.get(0).Expected_Util_Year_NI__c > 100 || OptLine.get(0).Expected_Util_Year_Fee__c > 100)
         {
            
             string fieldNegative = '';
             if (OptLine.get(0).UnitPrice < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Vol. / Limit (THB)';
             if (OptLine.get(0).quantity < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Units of Acct. / Limits';
             if (OptLine.get(0).Tenor_Years__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Tenor (Years)';
             if (OptLine.get(0).Notional_Amount__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-All Bank Vol. (Limit) for only Syndicate loan';
             if (OptLine.get(0).Expected_Util_Year_NI__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c < 0) fieldNegative += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             string errorTextNegative = '';
             if (fieldNegative != '') 
                 errorTextNegative = status_code__c.getValues('8008').status_message__c 
                                     + fieldNegative;
            
             string fieldExceedValue = '';
             if (OptLine.get(0).Expected_Util_Year_NI__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-NI % Expected Utz. / Year';
             if (OptLine.get(0).Expected_Util_Year_Fee__c > 100) fieldExceedValue += '<br/>&nbsp;&nbsp;-Fee % Expected Utz. / Year';
             string errorTextExceedValue = '';
             if (fieldExceedValue != '') 
                 errorTextExceedValue = status_code__c.getValues('8015').status_message__c
                                        + fieldExceedValue;
            
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,OptLine.get(0).PricebookEntry.Product2.Name + '<br/>' + errorTextNegative + '<br/>' + errorTextExceedValue));
    
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
    
             
             launchNavigate = true;
         }

        }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } 
        
    }


}