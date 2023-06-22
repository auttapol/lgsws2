trigger Main_Bank_List_View_Trigger on Main_Bank_List_View__c (before insert , before update) {
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true'; 
    
    if(Trigger.isBefore &&  (Trigger.isInsert || Trigger.isUpdate ) ){
        List<Main_Bank_List_View__c> mainBankListViews = Trigger.New ; 
        System.debug('minalistview: '+mainBankListViews.size());
        list<string> lstCusId =  new list<string>();
        for(Main_Bank_List_View__c each : mainBankListViews){
            if(each.customer_ID__c != null){
                lstCusId.add(each.customer_ID__c);
            }    
        }
        System.debug('lstCusOd:'+lstCusId.size());
        System.debug('lstCusId :' + lstCusId);
        if(lstCusId.size()>0){
            list<account> lstAct = [select id ,TMB_Customer_ID_PE__c,RTL_Most_Operating_Branch__c ,RTL_Assigned_BRC__c  from account where TMB_Customer_ID_PE__c  in: lstCusId ];
            map<string,account> mapActId = new map<string,account>();
            for(account act : lstAct){
                mapActId.put(act.TMB_Customer_ID_PE__c , act);
            }
            System.debug('mapActId :' + mapActId);

            for(Main_Bank_List_View__c each : mainBankListViews){
                if(mapActId.containskey(each.customer_ID__c)){
                    account actnow = mapActId.get(each.customer_ID__c);
                    each.Most_Operating_Branch__c = actnow.RTL_Most_Operating_Branch__c;
                    each.Assigned_BRC_User__c = actnow.RTL_Assigned_BRC__c;
                    if(each.customer__c == null){
                        each.customer__c = actnow.Id;
                    }

                    // System.debug('each.Most_Operating_Branch__c :' )
                }
            }
        }
    }

}