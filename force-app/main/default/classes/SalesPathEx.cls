public class SalesPathEx {

    public string COMPLETE_COLOR
    {get{
        return '#0076DE';
    }set;}
    public string INCOMPLETE_COLOR
    {get{
        return '#E0E5EE';
    }set;
     }
    
    public string WARNING_COLOR
    {get{
        return '#ffb75d';
    }set;
     }
    
    public string ERROR_COLOR
        {get{
            return '#ED6F67';
            }set;
     }
    
    public boolean isLeadobj {get;set;}
    public boolean isCompleted {get;set;}
    public Integer Progress {get;set;}
    public lead leadObj {get;set;}
    public opportunity oppobj {get;set;}
    public List<OpportunityHistory> oppobjHistory {get;set;}
    //LeadProgress
    public boolean isPrescreen {get;set;}
    public boolean isContactLead {get;set;}
    public boolean isConvertLead {get;set;}
    public boolean isUnqualified {get;set;}
    public boolean isBypassDuplicateCheck {get;set;}
    public String BypassDuplicateCheckMsg {get;set;}
    
    //OppProgress
    public boolean isAnalysis {get;set;}
    public boolean isProcess {get;set;}
    public boolean isSetUp {get;set;}
    
    
     public static RecordType CompletedRecordType {get{
        if(CompletedRecordType ==null){
           CompletedRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Completed' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CompletedRecordType;
    }set;}
    
    
    
    public SalesPathEx (ApexPages.StandardController sc){
        SObjectType sObjectType = sc.getRecord().getSObjectType();
         Progress = 25;
      if(sObjectType == Opportunity.sObjectType)
     {
         isLeadobj = false;
         isAnalysis = false;
         isProcess = false;
         isSetUp = false;
         isCompleted = false;
         Opportunity opp = (Opportunity) sc.getRecord();
         oppobj = [select Probability, StageName from opportunity where id =: opp.id];
        
         /*if(oppobj.Probability >0 && oppobj.Probability <40){
             Progress =25; 
             //isAnalysis =true;                       
         }
         if((oppobj.Probability >=40 && oppobj.Probability <=70) && oppobj.StageName != 'CA Prep'){
             Progress =50; 
             isAnalysis =true;                       
         }
         if((oppobj.Probability >75 && oppobj.Probability < 95) || oppobj.StageName == 'CA Prep'){
             Progress =75;
             isAnalysis =true;
             isProcess =true;             
         }
         if(oppobj.Probability >=95 &&oppobj.Probability <100){
             Progress =100;
             isAnalysis =true;
             isProcess =true;
             isSetUp =true;
         }
         if(oppobj.Probability == 100 || oppobj.StageName == 'Close Lost'
            || oppobj.StageName == 'Rejected' || oppobj.StageName == 'Cancelled'){
             Progress =100;
             isAnalysis =true;
             isProcess =true;
             isSetUp =true;
             isCompleted =true;
         }*/
         oppobjHistory = [select id, StageName ,Probability, OpportunityId
                          , opportunity.host_system__c
                          , opportunity.Probability
                          , opportunity.StageName
                          from OpportunityHistory where OpportunityId= :opp.id
                          order by createddate];
         if(oppobjHistory.size()>0){
         
             //boolean isReAppeal = true;
             
             for(OpportunityHistory itemOppHistory : oppobjHistory){
                 /*system.debug('------');
                 system.debug('itemOppHistory.StageName='+itemOppHistory.StageName);
                 system.debug('itemOppHistory.Probability='+itemOppHistory.Probability);*/
                 
                 if (string.isNotBlank(itemOppHistory.opportunity.host_system__c)
                     && itemOppHistory.opportunity.host_system__c.toLowerCase() == 'sls'){
                     
                     /*
                     if (isReAppeal){
                         isAnalysis = false;
                         isProcess = false;
                         isSetUp = false;
                         isCompleted = false;
                         isReAppeal = false;
                     }
                     */
                     
                     if((itemOppHistory.Probability >=40 && itemOppHistory.Probability <=70) && itemOppHistory.StageName != 'CA-Prep'){
                         isAnalysis =true;                       
                     }
                     if((itemOppHistory.Probability >75 && itemOppHistory.Probability < 95) || itemOppHistory.StageName == 'CA-Prep'){
                         isProcess =true;             
                     }
                     if(itemOppHistory.Probability >=95 &&itemOppHistory.Probability <100){
                         isSetUp =true;
                     }
                     if(itemOppHistory.Probability == 100 || itemOppHistory.StageName == 'Closed Lost'
                        || itemOppHistory.StageName == 'Rejected' || itemOppHistory.StageName == 'Cancelled'
                        || itemOppHistory.StageName =='Rejected waiting Appeal'){
                            isCompleted =true;
                            //isReAppeal = true;
                     }
                     
                     if (itemOppHistory.Probability > 0){
                         if (itemOppHistory.Probability < 100) isCompleted = false;
                         if (itemOppHistory.Probability < 95) isSetUp = false;
                         if (itemOppHistory.Probability < 75 && itemOppHistory.StageName != 'CA-Prep') isProcess = false;
                         if (itemOppHistory.Probability < 40) isAnalysis = false;
                     }
                     
                     /*
                     if (itemOppHistory.opportunity.Probability >= 40){ //&& itemOppHistory.opportunity.Probability <= 70){
                         isAnalysis =true;
                     }
                     if (itemOppHistory.opportunity.Probability > 75){ //&& itemOppHistory.opportunity.Probability <95){
                         isProcess =true; 
                     }
                     if (itemOppHistory.opportunity.Probability >= 95){ //&& itemOppHistory.opportunity.Probability <= 100){
                         isSetUp =true;
                     }
                     if (itemOppHistory.opportunity.Probability == 100){
                         isCompleted =true;
                     }
                     if (itemOppHistory.opportunity.StageName == 'CA-Prep'){
                         isAnalysis = true;
                         isProcess = true;
                     }
                     */
                     
                     /*
                     if (itemOppHistory.opportunity.StageName == 'Closed Lost'
                         || itemOppHistory.opportunity.StageName == 'Rejected'
                         || itemOppHistory.opportunity.StageName == 'Cancelled'
                         || itemOppHistory.opportunity.StageName == 'Rejected waiting Appeal'){
                         isAnalysis = true;
                         isProcess = true;
                         isSetUp =true;
                         isCompleted =true;
                     }
                     */
                     
                 } else {
                 
                     if((itemOppHistory.Probability >=40 && itemOppHistory.Probability <=70) && itemOppHistory.StageName != 'CA-Prep'){
                         isAnalysis =true;                       
                     }
                     if((itemOppHistory.Probability >75 && itemOppHistory.Probability < 95) || itemOppHistory.StageName == 'CA-Prep'){
                         isProcess =true;             
                     }
                     if(itemOppHistory.Probability >=95 &&itemOppHistory.Probability <100){
                         isSetUp =true;
                     }
                     if(itemOppHistory.Probability == 100 || itemOppHistory.StageName == 'Closed Lost'
                        || itemOppHistory.StageName == 'Rejected' || itemOppHistory.StageName == 'Cancelled'
                        || itemOppHistory.StageName =='Rejected waiting Appeal'){
                            isCompleted =true;
                     }
                 
                 }
                 
             }
         }
         if(isAnalysis){
             Progress =50;                     
         }
         if(isProcess){
             Progress =75;            
         }
         if(isSetUp){
             Progress =100;
         }
         if(isCompleted){
             Progress =100;
         }
         
     }
        //Lead Path
        else if(sObjectType == Lead.sObjectType){
         isLeadobj =true;
         isUnqualified = false;
         lead tempLead = (lead)sc.getRecord();
        
         leadObj = [select Converted_Flag__c,Status ,Contacted_Flag__c, Pre_screen_passed__c, 
                       isBypassDuplicateCheck__c ,RecordTypeID
                       from lead where id =: tempLead.id];
         isBypassDuplicateCheck = leadObj.isBypassDuplicateCheck__c;
         //isBypassDuplicateCheck = false;
         BypassDuplicateCheckMsg = Status_Code__c.GetValues('6111').Status_Message__c;
            
          /*Integer countProductInterests = [SELECT count() from Product_Interest__c  WHERE Lead__c =: leadobj.id];
        
            if(countProductInterests >0){
                isContactLead =true;
            }else{
                isContactLead =false;
            }*/
        
            if(leadobj.Status =='Unqualified'){
               isUnqualified = true; 
            }
        
        isPrescreen = leadobj.Pre_screen_passed__c;
        if(isPrescreen){Progress=50;}
        
        isContactLead = leadobj.Contacted_Flag__c;
        if(isContactLead){Progress=75;}
        
        isConvertLead = leadobj.Converted_Flag__c;
        if(isConvertLead){Progress=100;
                         isCompleted =true;
                         }
        
            
            if(leadObj.RecordTypeId == CompletedRecordType.id){
                Progress=100;
                isCompleted =true;
            }
         System.debug(isPrescreen);
         System.debug(isContactLead);
         System.debug(isConvertLead);
         System.debug(Progress);
         
     }
        
         
    }
}