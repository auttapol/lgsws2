trigger RTL_DoNotContactTrigger on RTL_Do_not_Contact_Info__c (after insert,after update, after delete) {
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true';

    if((RunTrigger || Test.isRunningTest()) && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<RTL_Do_not_Contact_Info__c> newDoNotConatact = Trigger.New ;
        System.debug('Do not Contact List Size: '+ newDoNotConatact.size());
        list<string> lstCusId =  new list<string>();
        for(RTL_Do_not_Contact_Info__c each : newDoNotConatact){
            if(each.Customer__c != null){
                lstCusId.add(each.Customer__c);
            }
        }
        System.debug('lstCusOd:'+lstCusId.size());
        System.debug('lstCusId :' + lstCusId);
        if(lstCusId.size()>0){
            list<RTL_Do_not_Contact_Info__c> lstDnc = [Select Customer__c ,End_Date__c From RTL_Do_not_Contact_Info__c where Customer__c in: lstCusId];
            list<Account> accUpdateList = [Select Id, DNC_Expired_Date__c From Account where Id in: lstCusId];
            Map<Id,Account> mapAccount = new Map<Id,Account>();
            if (lstDnc.size() > 0){
                // Update with longest expired date.
                for(RTL_Do_not_Contact_Info__c dnc : lstDnc){
                    Account acc = new Account();
                    acc.Id = dnc.Customer__c;
                    if (mapAccount.containsKey(acc.Id)){
                        if (mapAccount.get(acc.Id).DNC_Expired_Date__c < dnc.End_Date__c){
                            mapAccount.get(acc.Id).DNC_Expired_Date__c = dnc.End_Date__c;
                        }
                    }
                    else{
                        acc.DNC_Expired_Date__c = dnc.End_Date__c;
                        mapAccount.put(acc.Id, acc);
                    }
                }

                // Assign all DNC expired Date to all update list customer.
                for(integer i=0;i<accUpdateList.size();i+=1){
                    for(Id eachCust : mapAccount.keySet()){
                        if (eachCust == accUpdateList[i].Id){
                            accUpdateList[i].DNC_Expired_Date__c = mapAccount.get(eachCust).DNC_Expired_Date__c;
                            break;
                        }
                    }
                }

                try{
                    // update accUpdateList;
                    Database.Update(accUpdateList, false);
                }catch (DmlException e){
                    System.debug('error : '+e.getMessage());
                }
            }
        }
    }

    if((RunTrigger || Test.isRunningTest()) && Trigger.isAfter && Trigger.isDelete){
        List<RTL_Do_not_Contact_Info__c> delDoNotConatact = Trigger.Old ;
        System.debug('Do not Contact List Size: '+delDoNotConatact.size());
        list<string> lstCusId =  new list<string>();
        for(RTL_Do_not_Contact_Info__c each : delDoNotConatact){
            if(each.Customer__c != null){
                lstCusId.add(each.Customer__c);
            }
        }
        System.debug('lstCusOd:'+lstCusId.size());
        System.debug('lstCusId :' + lstCusId);
        if(lstCusId.size()>0){
            list<RTL_Do_not_Contact_Info__c> lstDnc = [Select Customer__c ,End_Date__c From RTL_Do_not_Contact_Info__c where Customer__c in: lstCusId];
            list<Account> accUpdateList = [Select Id, DNC_Expired_Date__c From Account where Id in: lstCusId];
            Map<Id,Account> mapAccount = new Map<Id,Account>();
            // Set The Expired Date from the exist DNC record
            if (lstDnc.size() > 0){
                for(RTL_Do_not_Contact_Info__c dnc : lstDnc){
                    Account acc = new Account();
                    acc.Id = dnc.Customer__c;
                    if (mapAccount.containsKey(acc.Id)){
                        if (mapAccount.get(acc.Id).DNC_Expired_Date__c < dnc.End_Date__c){
                            mapAccount.get(acc.Id).DNC_Expired_Date__c = dnc.End_Date__c;
                        }
                    }
                    else{
                        acc.DNC_Expired_Date__c = dnc.End_Date__c;
                        mapAccount.put(acc.Id, acc);
                    }
                }
            }

            // Assign all DNC expired Date to all update list customer.
            for(integer i=0;i<accUpdateList.size();i+=1){
                Boolean found = false;
                for(Id eachCust : mapAccount.keySet()){
                    if (eachCust == accUpdateList[i].Id){
                        accUpdateList[i].DNC_Expired_Date__c = mapAccount.get(eachCust).DNC_Expired_Date__c;
                        found = true;
                        break;
                    }
                }
                // No DNC record on this customer.
                if (found == false){
                    accUpdateList[i].DNC_Expired_Date__c = null;
                }
            }

            try{
                // update accUpdateList;
                Database.Update(accUpdateList, false);
            }catch (DmlException e){
                System.debug('error : '+e.getMessage());
            }
        }
    }
}