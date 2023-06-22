public without sharing class DisqualifiedProcessBuilder {

    
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
    
    public static List<List<SObject>> searchList {get{
        if(searchList ==null){
            searchList = new List<List<SObject>> ();
        }
        return searchList;
    }set;}
    
    public static List<Account> AccountResultList {get;set;}
    public static List<Lead> LeadResultList {get;set;}
    
    public class ProspectWrapperSOAP {
        public account prospect {get;set;}
        public boolean isfoundDuplicate {get{
            if(isfoundduplicate==null){
                isfoundduplicate = false;
            }
            return isfoundduplicate;
        }set;}
        public String ErrorMessage {get;set;} 
        public Integer index {get;set;}
    }
    
    public class LeadWrapperSOAP{
        public Lead leadRec {get;set;}
        public boolean isfoundDuplicate {get{
            if(isfoundDuplicate==null){
                isfoundDuplicate = false;
            }
            return isfoundDuplicate;
        }set;}
        public String ErrorMessage {get;set;} 
        public Integer index {get;set;}
    } 
    
    public static Map<ID,Account> MapwithOrginialOwner {get;set;}
    public static Map<String,Lead> LeadSAOPIndexWithOrginialAcct {get{
        if(LeadSAOPIndexWithOrginialAcct==null){
        LeadSAOPIndexWithOrginialAcct = new Map<String,Lead>();
    }
    
        return LeadSAOPIndexWithOrginialAcct;
    }
                                                                      set;}
    //Account action
    public static boolean CheckDisqualifiedAction(List<Account> triggerNew,List<Account>triggerOld,String action) {
     			boolean isDuplicated = false;
         		List<Account> AccountWithID = new List<account>();
         		List<Account> AccountOnlyName = new List<Account>();
         		MapwithOrginialOwner = new Map<ID,Account>();
            	Map<Id,Account> oldMap = new Map<Id,Account>();
        		AccountResultList = new List<Account>();
        		LeadResultList = new List<Lead>();
         
         	STR_ACTION = action;
         	//Insert Flow
         if(action ==STR_INSERT){
             
             for(Account acct : triggerNew){
                  if(acct.ID_Type_PE__c !=null 
                     && acct.ID_Number_PE__c != null
                     ){
                      AccountWithID.add(acct);
                     }else{
                      AccountOnlyName.add(acct);
                     }
              }
             
             if(AccountWithID.size()>0){
                 for(Account acct : (List<Account>)HasID(AccountWithID).get(0)){
                 
                 isDuplicated = true;
             	}
             }
             
             if(AccountOnlyName.size()>0){
                 for(Account acct : (List<Account>)HasOnlyName(AccountOnlyName).get(0)){
                 //acct.addError(Status_Code__c.GetValues('6002').Status_Message__c);
                 isDuplicated = true;
                 //
             	}
             }
             
             
             
             //Update Flow
         }else if(action ==STR_UPDATE){
             
              
              for(Account acct : triggerOld){
                  oldmap.put(acct.id,acct);
              }
              
              for(Account acct : triggerNew){
                  Account oldacct = oldmap.get(acct.id);
                  String IDPE = oldacct.ID_Number_PE__c==null?'':oldacct.ID_Number_PE__c;
                  System.debug('oldacct.ID_Number_PE__c : '+oldacct.ID_Number_PE__c);
                  System.debug('acct.ID_Type_PE__c : '+acct.ID_Type_PE__c);
                  System.debug('acct.ID_Number_PE__c : '+acct.ID_Number_PE__c);
                  
                  if(acct.ID_Type_PE__c !=null 
                    
                     && !IDPE.containsIgnoreCase('Duplicated')
                     ){
                      AccountWithID.add(acct);
                     }else if(acct.Name != oldacct.Name){
                       AccountOnlyName.add(acct);
                     }
                  
              }
             
             
             
             
             
              if(AccountWithID.size()>0){
                  List<account> DisqualifiedList = new List<account>();
                 for(Account acct : (List<Account>)HasID(AccountWithID).get(0)){
                     account existingAcct = MapwithOrginialOwner.get(acct.id);
                           String ErrorMessage =' Prospect is duplicated with Prospect/Customer owned by "'+existingAcct.Owner.Name+'",';
                            if(existingAcct.owner.MobilePhone!=null){
                                ErrorMessage +=' Please contact "'+existingAcct.owner.MobilePhone+'"';
                            }
              
                      acct.Disqualified_Reason__c  = ErrorMessage;
                      
                      acct.RecordTypeId = DisqualifiedRecord.id;
                      acct.IsDisqualified__c = true;
                      //acct.ID_Number_PE__c = acct.ID_Number_PE__c+'Duplicated';
                     DisqualifiedList.add(acct);
                     isDuplicated =true;
             	}
                  
                 
             }
             
             if(AccountOnlyName.size()>0){
                 for(Account acct : (List<Account>)HasOnlyName(AccountOnlyName).get(0)){
                 //acct.addError(Status_Code__c.GetValues('6002').Status_Message__c);
                     
                     isduplicated =true;
             	}
             }
             
             
             
             
             
         }
              
              
      
      return isDuplicated;
  
         
    }
    
    //Lead action
    public static boolean CheckDisqualifiedAction(List<lead> triggerNew,List<lead>triggerOld,String action){
        boolean isDuplicated = false;
         		List<Account> AccountWithID = new List<account>();
         		List<Account> AccountOnlyName = new List<Account>();
         		MapwithOrginialOwner = new Map<ID,Account>();
            	Map<Id,Account> oldMap = new Map<Id,Account>();
         		AccountResultList = new List<Account>();
        		LeadResultList = new List<Lead>();
         	STR_ACTION = action;
        
        if(action == STR_INSERT){
            isDuplicated = CheckDisqualifiedAction(LeadtoAccount(triggerNew),LeadtoAccount(triggerOld),'insert');
        }else if(action == STR_UPDATE){
            isDuplicated = CheckDisqualifiedAction(LeadtoAccount(triggerNew),LeadtoAccount(triggerOld),'update');
        }
       
        
       return isDuplicated;
    }
    
    //Lead to Acct
    private static List<Account> LeadtoAccount (List<Lead> leadlist){
        List<Account> convertedAccount = new List<Account>();
        for(Lead leadrec : leadlist){
            Account acct = new Account();
                 acct.Name = LeadRec.Company;
                 acct.Mobile_Number_PE__c = LeadRec.MobilePhone;
                 acct.Phone = LeadRec.Phone;
                 acct.Customer_Type__c = LeadRec.Customer_Type__c;
                 acct.OwnerID = LeadRec.OwnerID;
            	 acct.ID_Type_PE__c = leadrec.ID_Type__c; 
                 acct.ID_Number_PE__c = leadrec.ID_Number__c; 
            convertedAccount.add(acct);
        }
        
        
        return convertedAccount;
        
    }
    
    
    //Lead to Acct SOAP ver
     private static Account LeadtoAccountSOAP (String WrapperIndex,Lead Leadrec){
        
            	 Account acct = new Account();
         	     //temp
         		 acct.CRM_ID__c = WrapperIndex;
         		 //temp
                 acct.Name = LeadRec.Company;
                 acct.Mobile_Number_PE__c = LeadRec.MobilePhone;
                 acct.Phone = LeadRec.Phone;
                 acct.Customer_Type__c = LeadRec.Customer_Type__c;
                 acct.OwnerID = LeadRec.OwnerID;
            	 acct.ID_Type_PE__c = leadrec.ID_Type__c; 
                 acct.ID_Number_PE__c = leadrec.ID_Number__c; 
          
        
        return acct;
        
    }
    
    
    //Upload Prospect
    public static List<ProspectWrapperSOAP> CheckDisqualifiedSOAP (List<ProspectWrapperSOAP> soapList) {
        		Map<Integer,ProspectWrapperSOAP> rowIndexProspectMap = new Map<integer,ProspectWrapperSOAP>();
        		List<Account> prospectwithID = new List<Account>();
         		List<Account> prospectonlyName = new List<Account>();
     			MapwithOrginialOwner = new Map<ID,Account>();
            	Map<Id,Account> oldMap = new Map<Id,Account>();
				AccountResultList = new List<Account>();
        		LeadResultList = new List<Lead>();
         	//Insert Flow
             for(ProspectWrapperSOAP wrapper : soapList){
                
                  if(wrapper.prospect.ID_Type_PE__c !=null && wrapper.prospect.ID_Type_PE__c !=''
                     && wrapper.prospect.ID_Number_PE__c != null && wrapper.prospect.ID_Type_PE__c !=''
                     ){
                      prospectwithID.add(wrapper.prospect);
                     }else{
                      prospectonlyName.add(wrapper.prospect);
                     }
                 
                 rowIndexProspectMap.put(wrapper.index,wrapper);
              }

             if(prospectwithID.size()>0){
                 for(Account acct : (List<Account>)HasID(prospectwithID).get(0)){
                  //acct.addError(Status_Code__c.GetValues('6001').Status_Message__c);
                   Integer rowIndexTemp = Integer.valueof(acct.CRM_ID__c);
                     if(rowIndexProspectMap.containsKey(rowIndexTemp)){                        
                         rowIndexProspectMap.get(rowIndexTemp).isfoundDuplicate = true;
                         rowIndexProspectMap.get(rowIndexTemp).ErrorMessage = Status_Code__c.GetValues('6001').Status_Message__c;
                     }
             	}
             }
             
             if(prospectonlyName.size()>0){
                 for(Account acct : (List<Account>)HasOnlyName(prospectonlyName).get(0)){
                 //acct.addError(Status_Code__c.GetValues('6002').Status_Message__c);
                 Integer rowIndexTemp = Integer.valueof(acct.CRM_ID__c);
                 if(rowIndexProspectMap.containsKey(rowIndexTemp)){
                         rowIndexProspectMap.get(rowIndexTemp).isfoundDuplicate = true;
                         rowIndexProspectMap.get(rowIndexTemp).ErrorMessage = Status_Code__c.GetValues('6002').Status_Message__c;
                     }
                 
             	}
             }
             return rowIndexProspectMap.values();
         
       
    }
    
    //Upload Lead
    public static List<LeadWrapperSOAP> CheckDisqualifiedLeadSOAP (List<LeadWrapperSOAP> LeadsoapList){
        Map<Integer,LeadWrapperSOAP> rowIndexLeadMap = new Map<integer,LeadWrapperSOAP>();
        Map<Integer,Account> rowIndexTempAcctMap = new Map<integer,Account>();
        MapwithOrginialOwner = new Map<ID,Account>();
        List<LeaD> LeadLinkToAcct = new List<Lead>();
        List<Lead> leadwithID = new List<Lead>();
		List<Lead> leadwithOnlyName = new List<Lead>();
        AccountResultList = new List<Account>();
		LeadResultList = new List<Lead>();
        
        for(LeadWrapperSOAP leadwrapper : LeadsoapList){
            Lead leadRec = leadwrapper.LeadRec;
            if(leadRec.Account__c !=null ){
            
            }else if(leadRec.ID_Type__c !=null && leadRec.ID_Type__c !=''
                    && leadRec.ID_Number__c !=null && leadRec.ID_Number__c !=''){
                leadwithID.add(leadRec);
                 rowIndexTempAcctMap.put(leadwrapper.index,LeadtoAccountSOAP(String.ValueOf(leadwrapper.index),leadRec));
           }else{
                  leadwithOnlyName.add(leadRec);      
           }
           system.debug('leadwrapper.index : '+leadwrapper.index);
           system.debug('leadwrapper : '+leadwrapper);
           rowIndexLeadMap.put(leadwrapper.index,leadwrapper); 
        }

       
        if(leadwithID.size()>0){
			List<List<Sobject>> searchresults = HasID(rowIndexTempAcctMap.values());
            for(Account acct : (List<Account>)searchresults.get(0)){
                Integer rowIndexTemp = Integer.valueof(acct.CRM_ID__c);
                System.debug('AcctDupIndex : '+rowIndexTemp);
                if(rowIndexLeadMap.containsKey(rowIndexTemp)){                        
                         rowIndexLeadMap.get(rowIndexTemp).isfoundDuplicate = true;
                         rowIndexLeadMap.get(rowIndexTemp).ErrorMessage = status_code__c.getValues('5043').status_message__c;
                }
            }
            for(Account acct : (List<Account>)searchresults.get(1)){
                Integer rowIndexTemp = Integer.valueof(acct.CRM_ID__c);
                System.debug('LeadDupIndex : '+rowIndexTemp);
                if(rowIndexLeadMap.containsKey(rowIndexTemp)){                        
                         rowIndexLeadMap.get(rowIndexTemp).isfoundDuplicate = true;
                         rowIndexLeadMap.get(rowIndexTemp).ErrorMessage = status_code__c.getValues('5043').status_message__c;
                }
            }
            
            
           
            
            
        }
        
             
       
        return rowIndexLeadMap.values();
    }
    
    
    
    //Find Duplicate
    public static List<List<Sobject>> HasID(List<Account> newList){
      Set<ID> AcctID = new Set<ID>();
      Set<String> IDNumberset = new Set<String>();
      List<String> IDNumberList = new List<String>();
      set<String> IDTypeSet =new Set<String>();
      for(Account acct : newList){
          IDNumberset.add(acct.ID_Number_PE__c);
          IDTypeSet.add(acct.ID_Type_PE__c);
      }
        IDNumberList.addAll(IDNumberset);
      String Expression = '';
      for(integer i=0;i<IDNumberList.size();i++){
          Expression += IDNumberList.get(i);
          if(i != (IDNumberList.size()-1)){
              Expression +=' OR ';
          }
      }
        
        
        
        return SearchResults(expression,newList,STR_BYID);
        
    }
    
    public static List<List<Sobject>> HasOnlyName(List<account> newList){
      
     Set<String> AcctNameSet = new Set<String>();
      for(Account acct : newList){
          AcctNameSet.add(acct.Name);
      }
      String Expression = '';
        
        Integer index =1;
        for(String acctName : AcctNameSet){
            Expression += acctName;
          if(index != (AcctNameSet.size())){
              Expression +=' OR ';
          }
            index++;
        }
        
        System.debug(Expression);
        
        return SearchResults(expression,newList,STR_BYNAME);
        
    }
    
    public static List<List<sObject>> SearchResults(String Expression,List<Account> newList,String searchTerm){
        
        
        Set<ID> ExistingID = new Set<ID>();
        Set<ID> ExistingLeadID = new Set<ID>();
        //Exclude 
        if(STR_ACTION == STR_UPDATE){
            for(account acct : newList){
                ExistingID.add(acct.id);
            }
        }
        
        Set<Account> acctlist = new Set<Account>();
        Set<Lead> leadlist = new Set<Lead>();
        boolean nextround = true;
        //Up to 8 rounds
        for(integer i=0;i<40;i++){
            if(nextround){
                 List<account> AcctResults = new List<Account>();
                 List<Lead> Leadresults = new List<Lead>();
                if(searchTerm==STR_BYNAME){
                    System.debug('>>>> Search by Name <<<<<');
                    AcctResults.addAll(SearchSOSLByName(Expression,ExistingID));
                }else if(searchTerm==STR_BYID){
                    System.debug('>>>> Search by ID <<<<<');
                    List<List<Sobject>> searchResults = SearchSOSLbyID(Expression,ExistingID,ExistingLeadID);
                    AcctResults.addAll((List<Account>)searchResults[0]);
                    Leadresults.addAll((List<Lead>)searchResults[1]);
                }
                
                System.debug('acctResults : '+acctResults.size());
                System.debug('Leadresults : '+Leadresults.size());
                if(acctResults.size()>=250){
                    nextround =true;
                }else{
                    nextround = false;
                }
                acctlist.addAll(AcctResults);
                
                for(Account acct : acctlist){
                    ExistingID.add(acct.id);
                }
                
                //LeadResults
                //
                if(Leadresults.size()>250){
                    nextround = true;
                }else{
                    nextround = false;
                }
                
                leadlist.addall(Leadresults);
                    
                for(Lead leadRec : Leadresults){
                    ExistingLeadID.add(LeadRec.id);
                }
                
                
                //
                //
                
            }
        }
        
        List<Account> DisqualifiedList = new List<Account>();
        List<Account> DisqualifiedLeadList = new List<Account>();
        
        //finding match in Name
        if(searchTerm==STR_BYNAME){     
       	Map<String,Map<ID,Account>> NameWOwnerAcctMap = new Map<String,Map<ID,Account>>();
            // AccountName -----> OwnerID------> Account object
          for(Account acct : acctlist){
              if(!NameWOwnerAcctMap.containsKey(acct.Name)){
                  Map<ID,Account> Ownerwithacct = new Map<ID,Account>();
                  Ownerwithacct.put(acct.OwnerID,acct);
                  NameWOwnerAcctMap.put(acct.Name,Ownerwithacct);
                  
              }else{
                  Map<ID,Account> Ownerwithacct = NameWOwnerAcctMap.get(acct.Name);
                  if(!Ownerwithacct.containsKey(acct.OwnerID)){
                      Ownerwithacct.put(acct.OwnerID,acct);
                  	  NameWOwnerAcctMap.put(acct.Name,Ownerwithacct);
                  }
              }
          }        
            
            
      		for(Account acct : newList){
                 if(NameWOwnerAcctMap.containsKey(acct.Name)){
                     Map<ID,Account> ExistingwithAcct  = NameWOwnerAcctMap.get(acct.Name);
                     Set<ID> allExistingOwnerSet = ExistingwithAcct.keySet();
                    for(ID existingOwnerID : allExistingOwnerSet){
                         Account OriginalAcct = ExistingwithAcct.get(existingOwnerID); 
                        
                        	System.debug(acct.Name+'<>'+originalAcct.Name);
                            System.debug(acct.Name==originalAcct.Name);
                            System.debug(acct.OwnerID+'<>'+originalAcct.OwnerID);
                            System.debug(acct.OwnerID==originalAcct.OwnerID);
                        	System.debug(acct.Owner.Name+'<>'+originalAcct.Owner.Name);
                        if(OriginalAcct.OwnerId ==acct.OwnerId){
                            
                             System.debug('DISQUALIFIED BY NAME');
                            	DisqualifiedList.add(acct);
                              	MapwithOrginialOwner.put(acct.id,originalAcct);
                            
                        }
                    }
                    
                    
                }
      		}
            //finding match in ID
        }else if(searchTerm==STR_BYID){
      		Map<String,Map<String,Account>> IDandAcctMap = new Map<String,Map<String,Account>>();
            //ID Type ----> ID number ----> Existing Account
          for(Account acct : acctlist){
              if(!IDandAcctMap.containsKey(acct.ID_Type_PE__C)){
                  Map<String,Account> IDNumberWAcct = new Map<String,Account>();
                  IDNumberWAcct.put(acct.ID_Number_PE__c,acct);
                  IDandAcctMap.put(acct.ID_Type_PE__C,IDNumberWAcct);
              }else{
                  Map<String,Account> IDNumberWAcct = IDandAcctMap.get(acct.ID_Type_PE__C);
                   IDNumberWAcct.put(acct.ID_Number_PE__c,acct);
                  IDandAcctMap.put(acct.ID_Type_PE__C,IDNumberWAcct);
              }

          } 
            //Lead result Mapping
            //
            Map<String,Map<String,Lead>> IDandLeadMap = new Map<String,Map<String,Lead>>();
            
            for(Lead LeadRec : leadlist){
              if(!IDandLeadMap.containsKey(LeadRec.ID_Type__C)){
                  Map<String,Lead> IDNumberWLead = new Map<String,Lead>();
                  IDNumberWLead.put(LeadRec.ID_Number__c,LeadRec);
                  IDandLeadMap.put(LeadRec.ID_Type__C,IDNumberWLead);
              }else{
                  Map<String,Lead> IDNumberWLead = IDandLeadMap.get(LeadRec.ID_Type__C);
                   IDNumberWLead.put(LeadRec.ID_Number__c,LeadRec);
                  IDandLeadMap.put(LeadRec.ID_Type__C,IDNumberWLead);
              }

          }
            
            
            //
            
      		for(Account acct : newList){
                if(IDandAcctMap.containsKey(acct.ID_Type_PE__C)){
                     Map<String,Account> IDNumberWAcct = IDandAcctMap.get(acct.ID_Type_PE__C);
                    	if(IDNumberWAcct.containsKey(acct.ID_Number_PE__c)){
                          Account OriginalAcct = IDNumberWAcct.get(acct.ID_Number_PE__c);
                            System.debug(acct.ID_Type_PE__c+'<>'+originalAcct.ID_Type_PE__c);
                            System.debug(acct.ID_Number_PE__c+'<>'+originalAcct.ID_Number_PE__c);
                    		if(acct.ID_Type_PE__c == originalAcct.ID_Type_PE__c){
                                 if(acct.ID_Number_PE__c == originalAcct.ID_Number_PE__c){
                                     System.debug('DISQUALIFIED BY ID');
                                    DisqualifiedList.add(acct);
                                    MapwithOrginialOwner.put(acct.id,originalAcct);
                                    AccountResultList.add(originalAcct);
                                }
                            }
                         
                     	}
                         
                            
                }
                
                //Lead Check Duplicate
                //
                 if(IDandLeadMap.containsKey(acct.ID_Type_PE__C)){
                             Map<String,Lead> IDNumberWLead = IDandLeadMap.get(acct.ID_Type_PE__C);
                                if(IDNumberWLead.containsKey(acct.ID_Number_PE__c)){
                                Lead OriginalLead = IDNumberWLead.get(acct.ID_Number_PE__c);
                                    System.debug(acct.ID_Type_PE__c+'<>'+OriginalLead.ID_Type__c);
                                    System.debug(acct.ID_Number_PE__c+'<>'+OriginalLead.ID_Number__c);
                                
                                if(acct.ID_Type_PE__c == OriginalLead.ID_Type__c){
                                         if(acct.ID_Number_PE__c == OriginalLead.ID_Number__c){
                                             System.debug('DISQUALIFIED BY COMMERCIAL LEAD ID');
                                            LeadresultList.add(OriginalLead);
                                             DisqualifiedLeadList.add(acct);
                                             LeadSAOPIndexWithOrginialAcct.put(acct.CRM_ID__c,OriginalLead);
                                        }
                                    }
                                
                                
                            }
                        }
                //

      		}
            
        }
        
        List<List<Sobject>> searchresults = new List<List<Sobject>>();
        searchresults.add(DisqualifiedList);
        searchresults.add(DisqualifiedLeadList);
        return searchresults;
    }
    
    public static List<Account> SearchSOSLByName(String Expression,Set<ID> notINLISt){
        
         searchList = [FIND : Expression IN NAME FIELDS
                                                  RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,Owner.Employee_ID__c,
                                                                     Owner.MobilePhone, Name, Customer_Type__c ,
                                                                     ID_Type_PE__c, ID_Number_PE__c
                                                                     WHERE RecordTypeID != :DisqualifiedRecord.id
                                                                     AND ID NOT IN :notINLISt
                                                                     )];
        
        
           List<Account>  accounts = ((List<Account>)searchList[0]);
        
           
           return accounts;
        
    }
    
    public static List<List<Sobject>> SearchSOSLbyID(String Expression,Set<ID> notINLISt,Set<ID> notInListLead){
        
        searchList = [FIND : Expression
                                                  IN ALL FIELDS
                                                  RETURNING Account (id, Owner.Name, OwnerID, RecordTypeID,Owner.Employee_ID__c,
                                                                     Owner.MobilePhone, Name, Customer_Type__c ,
                                                                     ID_Type_PE__c, ID_Number_PE__c
                                                                     WHERE RecordTypeID != :DisqualifiedRecord.id
                                                                     AND ID NOT IN :notINLISt ),
                      							Lead (id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,
                                                  Name, Customer_Type__c ,Owner_Segment__c ,Status,
                                                 ID_Type__c, ID_Number__c, Customer_Name_EN__c
                                                 WHERE ID NOT IN: notInListLead
                                                 AND RecordTypeID =:CommercialLeadRecordType.id
                                                 AND Status IN: LeadStatusFilters
                                                )
                     ];
        
         //List<Account>  accounts = ((List<Account>)searchList[0]);
        
        
        return searchList;
    }
    
  /*  public static List<Lead> SearchLeadSOSLbyID(String Expression,Set<ID> notINLISt){
        
        searchList = [FIND : Expression
                                                  IN ALL FIELDS
                                                  RETURNING Lead (id, Owner.Name,Owner.phone, OwnerID, RecordTypeID,
                                                  Name, Customer_Type__c ,Owner_Segment__c ,Status,
                                                 ID_Type__c, ID_Number__c, Customer_Name_EN__c
                                                 WHERE ID NOT IN: notINLISt
                                                 AND RecordTypeID =:CommercialLeadRecordType.id
                                                 AND Status IN: LeadStatusFilters
                                                )
                     ];
        
         List<Lead>  Leads = ((List<Lead>)searchList[0]);
        
        
        return Leads;
    }
    */
    
  
}