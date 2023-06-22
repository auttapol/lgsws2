public without sharing class CommercialDuplicateCheck {
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    static String STR_BYNAME = 'ByName';
    static String STR_BYID   = 'ByID';
    static String STR_ACTION;
    
    public static RecordType DisqualifiedRecord {get{
        if(DisqualifiedRecord ==null){
           DisqualifiedRecord = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Disqualified prospect' 
                                 AND sObjectType='Account' LIMIT 1];
        }
        return DisqualifiedRecord;
    }set;}
    
    public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}
    
    public static List<String> LeadStatusFilters {get{
        if(LeadStatusFilters==null){
            LeadStatusFilters = new List<String>();
            LeadStatusFilters.add('Open');
            LeadStatusFilters.add('Passed Prescreening');
            LeadStatusFilters.add('Contacted');
        }
        return LeadStatusFilters;
    }set;}
    
    public static List<Account> AccountResultList {get;set;}
    public static List<Lead> LeadResultList {get;set;}
    public static Map<Integer,LeadWrapper> LeadWrapperMap {get;set;}

    public class LeadWrapper{
        public Lead leadRec {get;set;}
        public boolean isfoundDuplicate {get{
            if(isfoundDuplicate==null){
                isfoundDuplicate = false;
            }
            return isfoundDuplicate;
        }set;}
        public sObject Originalrecord {get;set;}
        public String OrgininalrecordType {get{
            if(Originalrecord !=null){
                OrgininalrecordType = Originalrecord.getSobjectType().getDescribe().getName();
            }else{
                OrgininalrecordType ='';
            }
            return OrgininalrecordType;
        }set;}
        
        public String ErrorMessage {get;set;} 
        public Integer index {get;set;}
        public Boolean isExcludedSelf {get{
            if(isExcludedSelf==null){
                isExcludedSelf = false;
            }
            return isExcludedSelf;
        }set;}
        public Boolean isAccountCheckDup {get{
            if(isAccountCheckDup==null){
                isAccountCheckDup = false;
            }
            return isAccountCheckDup;
        }set;}
        public Account AccountCheck {get;set;}
    } 

    //BAU Issues fix - Enhance Check dup FEB 2017 - Tinnakrit


    //Account To Lead for Temporary
     private static Lead AccountToLeadTemp (Account acctRec){
        
                 Lead leadTemp = new Lead();
                 
                 leadTemp.Company  = acctRec.Name;
                 leadTemp.MobilePhone =  acctRec.Mobile_Number_PE__c;
                 leadTemp.Phone = acctRec.Phone;
                 leadTemp.Customer_Type__c = acctRec.Customer_Type__c;
                 leadTemp.OwnerID = acctRec.OwnerID;
                 leadTemp.ID_Type__c = acctRec.ID_Type_PE__c; 
                 leadTemp.ID_Number__c = acctRec.ID_Number_PE__c; 
          
        
        return leadTemp;
        
    }


    public Static boolean DuplicateCheckAccountSingleRecord(Account acctRec,Account oldAcct){

         boolean isExcludedSelf = false;
         boolean isDuplicateOnAccount = false;
        if(acctRec.ID_Type_PE__c == oldAcct.ID_Type_PE__c 
                  && acctRec.ID_Number_PE__c == oldAcct.ID_Number_PE__c){
            isExcludedSelf= true;
        }
        
            LeadWrapperMap = new Map<Integer,LeadWrapper>();
            LeadWrapper LeadWrap = new LeadWrapper();
            LeadWrap.leadRec = AccountToLeadTemp(acctRec);
            LeadWrap.index = 0;
            LeadWrap.isExcludedSelf = isExcludedSelf;
            LeadWrap.isAccountCheckDup = true;
            LeadWrap.AccountCheck = acctRec;
            LeadWrapperMap.put(0,LeadWrap);
      
        
            SearchResults(LeadWrapperMap);
            LeadWrapper LeadWrapperresult = leadwrapperMap.get(0);
            System.debug('results : '+LeadWrapperresult);
            System.debug('results : '+LeadWrapperresult.isfoundDuplicate);
            System.debug('results : '+LeadWrapperResult.OrgininalrecordType);
            System.debug('results : '+LeadWrapperResult.Originalrecord);
            if(LeadWrapperresult.isfoundDuplicate && LeadWrapperResult.OrgininalrecordType=='Account'){
                System.debug(isExcludedSelf);
                System.debug(acctRec.id);
                System.debug(LeadWrapperResult.Originalrecord.get('ID'));
                if(isExcludedSelf ){
                    if(acctRec.id != LeadWrapperResult.Originalrecord.get('ID')){
                        isDuplicateOnAccount = true;
                    }
                    System.debug('Excluded');
                }else{
                    isDuplicateOnAccount = true;
                    System.debug('Update');

                }
            }


        
            return isDuplicateOnAccount;
    }
    
    public static Map<Integer,LeadWrapper> DuplicateCheckLeadSingleRecord(Lead leadRec,Lead oldLead){
        boolean isExcludedSelf = false;
        if(leadRec.ID_Type__c == oldLead.ID_Type__c 
                  && leadRec.ID_Number__c == oldLead.ID_Number__c){
            isExcludedSelf= true;
        }
        
            LeadWrapperMap = new Map<Integer,LeadWrapper>();
            LeadWrapper LeadWrap = new LeadWrapper();
            LeadWrap.leadRec = leadRec;
            LeadWrap.index = 0;
            LeadWrap.isExcludedSelf = isExcludedSelf;
            LeadWrapperMap.put(0,LeadWrap);
      
        
            SearchResults(LeadWrapperMap);
        
            return LeadWrapperMap;
    }
    
    public static Map<Integer,LeadWrapper> CheckDisqualifiedLeadSOAP (Map<Integer,LeadWrapper> LeadWrapperMapSOAP){
        
        SearchResults(LeadWrapperMapSOAP);
        for(Integer index : LeadWrapperMapSOAP.keySet()){
            if(LeadWrapperMapSOAP.get(index).isfoundDuplicate){
                LeadWrapperMapSOAP.get(index).ErrorMessage = status_code__c.getValues('5043').status_message__c; 
            }
        }
        
        
        return LeadWrapperMapSOAP;
    }
    
    public static void SearchResults(Map<Integer,LeadWrapper> LeadWrapMap){
        Set<String> allIDType = new Set<String>();
        //Set<String> allthreedigits = new Set<String>();
        Set<String> allfivedigits = new Set<String>();
        Set<ID> notInList = new Set<ID>();
        Set<ID> totalAccountIDset = new Set<ID>();
        for(Integer leadIndex : LeadWrapMap.keySet()){
            allIDType.add(LeadWrapMap.get(leadIndex).LeadRec.ID_Type__c);
            //String IDNumber =  LeadWrapMap.get(leadIndex).LeadRec.ID_Number__c;
            //allthreedigits.add(IDnumber.substring(IDNumber.length()-3, IDNumber.length()));
            //
            
            //Enhance Account CheckDup

            if(LeadWrapMap.get(leadIndex).isAccountCheckDup 
                && LeadWrapMap.get(leadIndex).isExcludedSelf
                && LeadWrapMap.get(leadIndex).AccountCheck !=null ){
                //Excluded Account itself

                totalAccountIDset.add(LeadWrapMap.get(leadIndex).AccountCheck.id);
            }

            //
            
            //Enhance 1+4
            //
           String IDNumber =  LeadWrapMap.get(leadIndex).LeadRec.ID_Number__c;
           
            if(IDNumber !=null && IDNumber !=''){
                
                if(IDNumber.length() <=5){
                allfivedigits.add(IDNumber);
            }else{
                String firstdigit = IDNumber.left(1);
                String last4digits = IDNumber.right(4);
                allfivedigits.add(firstdigit+last4digits);
            }
                
            }
            //
            //
        }
        
      
        
       
        boolean isInterval = true;
        Integer accountInterval = 1;
        Set<Account> totalAccountResultSet = new Set<Account>();
       
        
        
        
        // ACCOUNT DUPLICATE CHECK
        // 
        while(isInterval){
            
           List<Account> accountList = SearchAccountbyID(allIDType,allfivedigits,totalAccountIDset);
           accountInterval++;
            if(accountList.size()<50000 || accountInterval>=40){
                isInterval= false;
            }else{
                for(Account acct : accountList){
                    totalAccountIDset.add(acct.id);
                }
            }
            totalAccountResultSet.addAll(accountList);
                        
        }
        
        //Gathering Account result
        //
        //Map ID Type --> ID Number --> Account record
         Map<String,Map<String,Account>> AccountIDMap = new Map<String,Map<String,Account>>();
        for(Account acct : totalAccountResultSet){
            String IDTypetoLower = acct.ID_Type_PE__c.toLowerCase();
            if(AccountIDMap.containsKey(IDTypetoLower)){
                AccountIDMap.get(IDTypetoLower).put(acct.ID_Number_PE__c,acct);
            }else{
                Map<String,Account> AccountNumberMap = new Map<String,Account>();
                AccountNumberMap.put(acct.ID_Number_PE__c,acct);
                AccountIDMap.put(IDTypetoLower,AccountNumberMap);
            }
        }
        
        //Duplicate check with Account results
        
        for(Integer leadIndex : LeadWrapMap.keySet()){
            LeadWrapper leadWrap = LeadWrapMap.get(leadIndex);
            String LeadIDTypetoLower = LeadWrap.Leadrec.ID_Type__c.toLowerCase();
            if(AccountIDMap.containsKey(LeadIDTypetoLower)){
                if(AccountIDMap.get(LeadIDTypetoLower).containsKey(LeadWrap.Leadrec.ID_Number__c)){
                    Lead leadRec = LeadWrap.leadRec;
                    Account OriginalAcct = AccountIDMap.get(LeadIDTypetoLower).get(LeadWrap.Leadrec.ID_Number__c);
                    System.debug(leadRec.ID_Type__c+'<A>'+originalAcct.ID_Type_PE__c);
                    System.debug(leadRec.ID_Number__c+'<A>'+originalAcct.ID_Number_PE__c);
                    //double check
                    if(leadRec.ID_Type__c==originalAcct.ID_Type_PE__c &&
                       leadRec.ID_Number__c==originalAcct.ID_Number_PE__c){
                           //Duplicated with Existing Account in the system.
                        leadWrap.isfoundDuplicate = true;
                        leadWrap.Originalrecord = originalAcct;
                        leadWrap.ErrorMessage = Status_Code__c.GetValues('6003').Status_Message__c;

                    }
                    
                }
            }
        }
        
        
        
        // LEAD DUPLICATE CHECK
        
        allIDType = new Set<String>();
       // allthreedigits = new Set<String>();
       allfivedigits = new Set<String>();
        notInList = new Set<ID>();
        Set<ID> totalLeadIDset = new Set<ID>();
        for(Integer leadIndex : LeadWrapMap.keySet()){
            System.debug('LeadWrapMap.get(leadIndex) : '+LeadWrapMap.get(leadIndex));
            if(!LeadWrapMap.get(leadIndex).isfoundDuplicate){
                allIDType.add(LeadWrapMap.get(leadIndex).LeadRec.ID_Type__c);
                String IDNumber =  LeadWrapMap.get(leadIndex).LeadRec.ID_Number__c;
                //allthreedigits.add(IDnumber.substring(IDNumber.length()-3, IDNumber.length()));
                //
                       if(IDNumber.length() <=5){
                            allfivedigits.add(IDNumber);
                        }else{
                            String firstdigit = IDNumber.left(1);
                            String last4digits = IDNumber.right(4);
                            allfivedigits.add(firstdigit+last4digits);
                        }
                if(LeadWrapMap.get(leadIndex).isExcludedSelf){
                    notInList.add(LeadWrapMap.get(leadIndex).LeadRec.id);
                    totalLeadIDset.add(LeadWrapMap.get(leadIndex).LeadRec.id);
                }
                
            }
        }
        
        
        //if has remaining results.
        if(allfivedigits.size()>0){
            
            boolean leadIsInterval = true;
            Integer leadInterval = 1;
            Set<Lead> totalLeadResultSet = new Set<Lead>();
            // LEAD DUPLICATE CHECK
            // 
            while(leadIsInterval){
               List<Lead> leadList = SearchLeadbyID(allIDType,allfivedigits,totalLeadIDset);
               leadInterval++;
                if(leadList.size()<50000 || leadInterval>=20){
                    leadIsInterval= false;
                }else{
                    for(Lead leadRec : leadList){
                        totalLeadIDset.add(leadRec.id);
                    }
                }
                totalLeadResultSet.addAll(leadList);
                            
            }
            
            
            //Gathering Account result
        //
        //Map ID Type --> ID Number --> Account record
         Map<String,Map<String,Lead>> LeadIDMap = new Map<String,Map<String,Lead>>();
        for(Lead leadRec : totalLeadResultSet){
            String LeadIDTypetoLowerCase = leadRec.ID_Type__c.toLowerCase();
            if(LeadIDMap.containsKey(LeadIDTypetoLowerCase)){
                LeadIDMap.get(LeadIDTypetoLowerCase).put(leadRec.ID_Number__c,leadRec);
            }else{
                Map<String,Lead> LeadNumberMap = new Map<String,Lead>();
                LeadNumberMap.put(leadRec.ID_Number__c,leadrec);
                LeadIDMap.put(LeadIDTypetoLowerCase,LeadNumberMap);
            }
        }
            
            
         //Duplicate check with Account results
        
        for(Integer leadIndex : LeadWrapMap.keySet()){
            LeadWrapper leadWrap = LeadWrapMap.get(leadIndex);
            String LeadIdTypeTolowerCase = LeadWrap.Leadrec.ID_Type__c.tolowerCase();
            System.debug('LeadIdTypeTolowerCase : '+LeadIdTypeTolowerCase);
            System.debug('LeadIDMap: '+LeadIDMap);
            if(LeadIDMap.containsKey(LeadIdTypeTolowerCase)){
                if(LeadIDMap.get(LeadIdTypeTolowerCase).containsKey(LeadWrap.Leadrec.ID_Number__c)){
                    Lead leadRec = LeadWrap.leadRec;
                    Lead OriginalLead = LeadIDMap.get(LeadIdTypeTolowerCase).get(LeadWrap.Leadrec.ID_Number__c);
                    System.debug(leadRec.ID_Type__c+'<L>'+OriginalLead.ID_Type__c);
                    System.debug(leadRec.ID_Number__c+'<L>'+OriginalLead.ID_Number__c);
                    //double check
                    if(leadRec.ID_Type__c==OriginalLead.ID_Type__c &&
                       leadRec.ID_Number__c==OriginalLead.ID_Number__c){
                           //Duplicated with Existing Account in the system.
                        leadWrap.isfoundDuplicate = true;
                        leadWrap.Originalrecord = OriginalLead;
                        leadWrap.ErrorMessage = Status_Code__c.GetValues('6003').Status_Message__c;
                    }
                    
                }
            }
        }
            
        }
        
        
        
    }
    
    
   
    public static List<Account> SearchAccountbyID(Set<String> IDType,Set<String> lastthreedigits,Set<ID> notINLISt){
        AccountResultList = [SELECT Id,Owner.Name, OwnerID, RecordTypeID,Owner.Employee_ID__c,
                                                                     Owner.MobilePhone, Name, Customer_Type__c ,
                                                                     ID_Type_PE__c, ID_Number_PE__c, RTL_NID__c 
                             
                                                                     FROM Account
                                                                     WHERE RecordTypeID != :DisqualifiedRecord.id
                                                                     AND ID_type_PE__c IN: IDtype
                                                                     AND RTL_NID__c IN: lastthreedigits
                                                                     AND ID NOT IN :notINLISt
                             										 ORDER BY TMB_Customer_ID_PE__c desc
                                                                     LIMIT 50000];
        
         return AccountResultList;
    }
    
    public static List<Lead> SearchLeadbyID(Set<String> IDType,Set<String> Lastthreedigits,Set<ID> notINLISt){
        System.debug('IDType: '+IDType);
        System.debug('Lastthreedigits:  '+Lastthreedigits);
        LeadResultList = [SELECT id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,
                                                  Name, Customer_Type__c ,Owner_Segment__c ,Status,
                                                 ID_Type__c, ID_Number__c, Customer_Name_EN__c, ID_REGEX__c , isbyPassDuplicatecheck__c
                                                 FROM Lead
                                                 WHERE ID NOT IN: notINLISt
                                                 AND ID_Type__c IN:IDType
                                                 AND RecordTypeID =:CommercialLeadRecordType.id
                                                 AND Status IN: LeadStatusFilters
                                                 AND isbyPassDuplicatecheck__c = false
                                                 AND ID_REGEX__C IN:Lastthreedigits
                                                 LIMIT 50000];

        System.debug('LeadResultList : '+LeadResultList);
        return LeadResultList;       
    }
        
  
}