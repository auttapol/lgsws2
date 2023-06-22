public without sharing class RevenueContributionEditatble extends EditableList {
    public String groupid {get;set;}
    public String companyid {get;set;}

    public RevenueContributionEditatble(ApexPages.StandardController stdController) {
    super(stdController);

    // If necessary, explicitly query for additional metadata on parent record
    // if you are looking to display things that don't come back with the 
    // StandardController. In that case, you will need to replace the "Account.X"
    // references in the Visualforce Page with references to an Account variable
    // that you will need to declare in this class (myAccount.X). I have commented out
    // an example.

    // this.myAccount = [SELECT Id,
    //                            Name,
    //                            Custom_Relationship__r.Name
    //                        FROM Account
    //                        WHERE Id =: stdController.getRecord().Id];
    groupid = ApexPages.currentPage().getParameters().get('groupid');
    //groupid = 'a0WO0000004rnXA';
    companyid = ApexPages.currentPage().getParameters().get('companyid');
        System.debug('companyid : '+companyid);
           if((groupid !=null && groupid !='') || (companyid !=null && companyid !='')){
               if(groupID !=null && groupid !=''){
                    this.childList = [SELECT ID,Name,
                            Account_Plan_Company_Profile__c,
                            AccountPlanGroupProfile__c,
                            BusinessUnit__c ,
                            EBITDAContributionPercent__c ,
                            Regional__c,
                            RevenueContributionPercent__c,
                            RevenueContributionType__c 
                           FROM AcctPlanContribution__c 
                           WHERE AccountPlanGroupProfile__c =:groupid AND Account_Plan_Company_Profile__c =null
                           ORDER BY RevenueContributionType__c ASC,RevenueContributionPercent__c DESC];
               }else if(companyid !=null && companyid !=''){
                this.childList = [SELECT ID,Name,
                            Account_Plan_Company_Profile__c,
                            AccountPlanGroupProfile__c,
                            BusinessUnit__c ,
                            EBITDAContributionPercent__c ,
                            Regional__c,
                            RevenueContributionPercent__c,
                            RevenueContributionType__c 
                           FROM AcctPlanContribution__c  
                           WHERE Account_Plan_Company_Profile__c =: companyid
                           ORDER BY RevenueContributionType__c ASC,RevenueContributionPercent__c DESC];
               }
               
           }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please return to save the current Account Plan from the main screen before adding new record in this screen.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1007').Status_Message__c));
        
       
    }
  }
  
  
    /*
   * This method is necessary for reference on the Visualforce page, 
   * in order to reference non-standard fields.
   */
  public List<AcctPlanContribution__c> getChildren()
  {
    return (List<AcctPlanContribution__c>)childList;
  }

  public override sObject initChildRecord()
  {
    AcctPlanContribution__c child = new AcctPlanContribution__c();
   if((groupid !=null && groupid !='') || (companyid !=null && companyid !='')){
      if(groupid !=null && groupid !=''){
           child.AccountPlanGroupProfile__c = groupid;
      }
      if(companyid !=null && companyid !=''){
           child.Account_Plan_Company_Profile__c = companyid;
      }
    }else{
        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Please return to save the current Account Plan from the main screen before adding new record in this screen.'));
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1007').Status_Message__c));
        
        return null;
    }
    
    return child;
  }
    
    
    public void insertRecord(){
        try{
          
            boolean ebitdaoverstack = false;
            boolean revenueoverstack = false;
            
            Map<String,Double> editdaMap = new Map<String,Double>();
            Map<String,Double> revenuemap = new Map<String,Double>();
            Set<String> revenuetypesSet = new Set<String>();
            for(AcctPlanContribution__c contri :getChildren() ){
                
                if(contri.EBITDAContributionPercent__c >100){
                      ebitdaoverstack = true;
                }else if(contri.RevenueContributionPercent__c > 100){
                      revenueoverstack = true;
                }else{
                    //EBITDA TOTAL FOR EACH
                    if(editdaMap.containsKey(contri.RevenueContributionType__c)){
                        Double total = editdaMap.get(contri.RevenueContributionType__c) ;
                        if(contri.EBITDAContributionPercent__c !=null && contri.EBITDAContributionPercent__c >0){
                          total += contri.EBITDAContributionPercent__c;  
                        }
                        editdaMap.put(contri.RevenueContributionType__c,total);
                    }else{
                         revenuetypesSet.add(contri.RevenueContributionType__c);
                        Double total = 0.00;
                        if(contri.EBITDAContributionPercent__c !=null && contri.EBITDAContributionPercent__c >0){
                          total += contri.EBITDAContributionPercent__c;  
                        }
                        editdaMap.put(contri.RevenueContributionType__c,total);
                    }
                    //REVENUE TOTAL FOR EACH
                    if(revenuemap.containsKey(contri.RevenueContributionType__c)){
                        Double total = revenuemap.get(contri.RevenueContributionType__c) ;
                        total +=contri.RevenueContributionPercent__c;
                        revenuemap.put(contri.RevenueContributionType__c,total);
                    }else{
                        revenuetypesSet.add(contri.RevenueContributionType__c);
                        Double total = 0.00;
                        total += contri.RevenueContributionPercent__c;
                        revenuemap.put(contri.RevenueContributionType__c,total);
                    }
                    
                } 
            }
            
            boolean isTotalRevenueoverstack = false;
            boolean isTotalEBITDAoverstack = false;
            String Revenueoverstackname;
             String EBITDAoverstackname;
            System.debug('revenuemap : '+revenuemap);
            System.debug('editdaMap : '+editdaMap);
            for(String revenuetype : revenuetypesSet){
                Double rtotal = revenuemap.get(revenuetype);
                if(rtotal >100){
                    isTotalRevenueoverstack = true;
                    Revenueoverstackname = revenuetype;
                }
                Double etotal = editdaMap.get(revenuetype);
                if(etotal >100){
                    isTotalEBITDAoverstack = true;
                    EBITDAoverstackname = revenuetype;
                }
            }
            
            
            
            
            
            if(isTotalRevenueoverstack){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total Revenue Contribution in '+Revenueoverstackname+' must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1008').Status_Message__c));
        
            }else if(isTotalEBITDAoverstack){
               //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Total EBITDA Contribution in '+EBITDAoverstackname+' must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1009').Status_Message__c));
        
            }else if(ebitdaoverstack){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'EBITDA Contribution must not be more than 100%')); 
                  ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1010').Status_Message__c));
            }else if( revenueoverstack ){
               //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Revenue Contribution must not be more than 100%')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1011').Status_Message__c));
        
            }else{
                super.save(); 
               //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,'Save Successful'));
               ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM ,Account_Plan_Status_Code__c.GetValues('9001').Status_Message__c));
        
            }
        }catch(DMLException e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,'Save error : '+e.getMessage()));
        }
    }
}