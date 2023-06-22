public with sharing class PDPAReportController {
   
    @AuraEnabled
    public static  Map<String, Object> getPDPAReport(){
        Map<String, Object> response = new Map<String, Object>();
          try {
            List<Account> AccountList = [SELECT Id, Name, tolabel(RMC_Has_PDPA__c)
                                          FROM Account 
                                          WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND (RMC_Has_PDPA__c = 'N/A')
                                          AND RMC_Is_current_RM_BM__c = true
                                          LIMIT 5
                                          ];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Has_MarketPDPA_2OX'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList);                            
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }           
       
        return response;
    }
    
     @AuraEnabled
    public static  Map<String, Object> getMarketConductReport(){
        Map<String, Object> response = new Map<String, Object>();
          try {
            List<Account> AccountList = [SELECT Id, Name, tolabel(RMC_Has_Market_Conduct__c)
                                          FROM Account 
                                          WHERE RTL_Wealth_RM__c = :UserInfo.getUserId() AND  (RMC_Has_Market_Conduct__c = 'N/A')
                                          AND RMC_Is_current_RM_BM__c = true
                                          LIMIT 5
                                          ];

            List<Report> reportList = [SELECT Id, Name FROM Report WHERE DeveloperName = 'Has_Market_Conduct_7wg'];

            if(reportList!=null && reportList.size() > 0){
                response.put('reportId', reportList[0].Id);      
            }
            response.put('Success', true);                            
            response.put('data', AccountList);                            
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());
        }           
       
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> getPDPAList(String accId){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = [SELECT Id, TMB_Customer_ID_PE__c, Email_Address_PE__c
                                    FROM Account WHERE Id = :accId LIMIT 1];
            if(accList != null && accList.size() > 0){
                Account acc = accList[0];
                PDPAWebserviceCtl pdpa = new PDPAWebserviceCtl();
                pdpa.tmbCustId = acc.TMB_Customer_ID_PE__c;
                pdpa.pdpatype = null;
                pdpa.PDPAWebserviceCtl2(accId, acc, acc.TMB_Customer_ID_PE__c, null);
                pdpa.viewPDPA();
                List<PDPAStructure.PDPAconsents> pdpaData = pdpa.pdpaForDisplay;
                
                Boolean isError = pdpa.getisErrorResponse();

                System.debug('getPDPAList: '+pdpaData);

                if(isError){
                    response.put('Success', false);  
                    response.put('Message', pdpa.geterrorMessageRespone()); 
                    return response;    
                }else{
                    response.put('Success', true); 
                    response.put('data', pdpaData);        
                }
                

                 
                // response.put('Message', 'Account not found. Please recheck your account Id.');                        
                 
                response.put('account', acc);

                Id profileId = userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

                Set<String> allowedProfileList = new Set<String>();
                Map<String, PDPA_Activity_profile_button__mdt> profileMdt = PDPA_Activity_profile_button__mdt.getAll();
                for(PDPA_Activity_profile_button__mdt profile : profileMdt.values()) {
                    allowedProfileList.add(profile.Profile_Name__c);
                }

                Boolean isPrintable = false;
                if(allowedProfileList.contains(profileName)){
                    isPrintable = true;
                }
                response.put('isPrintable', isPrintable);

                if(isPrintable && acc.Email_Address_PE__c != null){
                    response.put('isEmailable', true);
                }else{
                    response.put('isEmailable', false);
                }

                // pdpa.profileMapChanel;
                response.put('isEditable',  pdpa.isEdit);    

            }else{
                response.put('Success', false); 
                response.put('Message', 'Account not found. Please recheck your account Id.');           
            }
           
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage()+' '+e.getLineNumber());
            response.put('Success', false);
            response.put('Message', e.getMessage());           
        }
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> printPDPA(String accId, Integer index){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = [SELECT Id, TMB_Customer_ID_PE__c  FROM Account WHERE Id = :accId LIMIT 1];
            if(accList != null && accList.size() > 0){
                Account acc = accList[0];

                PDPAWebserviceCtl pdpa = new PDPAWebserviceCtl();
                pdpa.selectedConsentIdx = index;
                pdpa.accountObj         = acc;
                pdpa.tmbCustId          = acc.TMB_Customer_ID_PE__c;
                pdpa.pdpatype           = null;
                pdpa.PDPAWebserviceCtl2(accId, acc, acc.TMB_Customer_ID_PE__c, null);
                pdpa.viewPDPA();

                PageReference pageRef = pdpa.printConsentPDF();
                response.put('Success', true);
                // response.put('Message', e.getMessage());      
                response.put('PageReference', pageRef.getUrl());
            }else{
                response.put('Success', false); 
                response.put('Message', 'Account not found. Please recheck your account Id.');    
            }  
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());        
        }
        System.debug('response: '+response);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> sendEmailController(String accId, Integer index){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = [SELECT Id, TMB_Customer_ID_PE__c, Email_Address_PE__c FROM Account WHERE Id = :accId LIMIT 1];
            if(accList != null && accList.size() > 0){
                Account acc = accList[0];

                PDPAWebserviceCtl pdpa  = new PDPAWebserviceCtl();
                pdpa.accountObj         = acc;
                pdpa.selectedConsentIdx = index;
                pdpa.tmbCustId          = acc.TMB_Customer_ID_PE__c;
                pdpa.PDPAWebserviceCtl2(accId, acc, acc.TMB_Customer_ID_PE__c, null);
                pdpa.viewPDPA();
                pdpa.sendMail();
                response.put('Success', true);
            }
        }catch(Exception e){
            response.put('Success', false);
            response.put('Message', e.getMessage());        
        }
        System.debug('response: '+response);
        return response;
    }

    @AuraEnabled
    public static Map<String, Object> editPDPAController(Integer index, String accId, String type){
        Map<String, Object> response = new Map<String, Object>();
        try {
            List<Account> accList = [SELECT Id, TMB_Customer_ID_PE__c, Email_Address_PE__c FROM  Account WHERE Id = :accId LIMIT 1];
            if(accList != null && accList.size() > 0){
                Account acc = accList[0];

                PDPAWebserviceCtl pdpa  = new PDPAWebserviceCtl();
                pdpa.accountObj         = acc;
                pdpa.selectedConsentIdx = index;
                pdpa.tmbCustId          = acc.TMB_Customer_ID_PE__c;
                pdpa.PDPAWebserviceCtl2(accId, acc, acc.TMB_Customer_ID_PE__c, null);
                pdpa.viewPDPA();
                // pdpa.sendMail();
                String url = pdpa.urlToUpdatePdpa+'?id='+acc.Id+'&retURL='+acc.Id+'&pdpatype='+type+'&tmbid='+acc.TMB_Customer_ID_PE__c;
                //openSubTab('{!urlToUpdatePdpa}?id={!accountObj.Id}&retURL={!accountObj.Id}&pdpatype={!pdpaDetail.type}&tmbid={!accountObj.TMB_Customer_ID_PE__c}','PDPA and Market Consent','PDPA and Market Consent',true);return false;
                response.put('Success', true);
                response.put('url', url);
            }
        } catch (Exception e) {
            response.put('Success', false);
            response.put('Message', e.getMessage());  
        }
        return response;
    }
}