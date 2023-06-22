public class PDPAViewHistPageController {
    public List<PDPAStructure.PDPAconsents> consentDisplay {get; set;}
    public List<PDPAStructure.PDPAconsents> consents;
    public Account currAccount;
    public Id accountId;
    
    public String state{get; set;} //0 = Displayable, 1 = Error call service, 2 = No record 
    public boolean isGetAccount;
    public boolean isEmpty;
    public boolean isError;
    public boolean isHaveTMB_ID;
    public Boolean isSuccess;
    private List<PDPAMapping__c> pdpaMaps;
    
    //pagination
    public integer page{get; set;}
    public integer pageMax{get; set;}
    public String pageString{get; set;}
    
    //Service
    public String responseBody;
    public String TMB_Id;	

    public static Integer pdpaRetry {
        get{
            if(pdpaRetry == null) {
                //get from custom label
                pdpaRetry = Label.Number_Of_Retry_Times != null ? Integer.valueOf(Label.Number_Of_Retry_Times) : 3;
            }
            return pdpaRetry;
        }set;
    }

    public static Integer pdpaHisRetryDelay {
        get{
            if(pdpaHisRetryDelay == null) {
                //get from custom label
                pdpaHisRetryDelay = Label.Retry_SetTimeOut != null ? Integer.valueOf(Label.Retry_SetTimeOut) : 20000;
            }
            return pdpaHisRetryDelay;
        }set;
    }

    public Integer pdpaHisRetryRemain {get;set;}
    public Boolean isPDPAHisInvalidToken {get;set;}
    public String webServiceErrMsg {get;set;}
    public Boolean isViewPDPAHisRetryTimeout {get;set;}
    
    public PDPAViewHistPageController(ApexPages.StandardController stdController){
        isEmpty = false;
        isGetAccount = false;
        isHaveTMB_ID = true;
        isError = false;
        isSuccess = false;
        pdpaHisRetryRemain = pdpaRetry; // set retry default
        isViewPDPAHisRetryTimeout = false;
        accountId = stdController.getRecord().Id;
        pdpaMaps = new List<PDPAMapping__c>();    
        
        try{
            currAccount = [SELECT ID, Name, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c FROM Account WHERE id =: accountId ];
            if(currAccount != null){
                isGetAccount = true;
            }
            TMB_Id = currAccount.TMB_Customer_ID_PE__c;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        if(TMB_Id == null && currAccount != null){
            System.debug('TMB_Customer_ID is null');
            isHaveTMB_ID = false;
        }
        consentDisplay = new  List<PDPAStructure.PDPAconsents>();
        consents = new List<PDPAStructure.PDPAconsents>();
    }

    public void setPDPAHisRetryState() {
        System.debug('Before Set retry state'+pdpaHisRetryRemain);
        if(pdpaHisRetryRemain != null) {
            pdpaHisRetryRemain -= 1;
            System.debug('Call set pdpa retry state'+pdpaHisRetryRemain);
            webServiceErrMsg = 'Error getting data, retrying... ('+String.valueOf(pdpaRetry-pdpaHisRetryRemain)+')';
        }
        System.debug('After Set retry state'+pdpaHisRetryRemain);
    }
    
    public void calloutConsentHist(){
        PDPAStructure pdpaData = New PDPAStructure();
        if(isHaveTMB_ID){
            try{
                responseBody = pdpaCalloutUtil.callHistService(currAccount, TMB_Id);
                System.debug('ResponseBody: ' + responseBody);
            }catch(Exception e){
                isError = true;
                System.debug('Fail to call service:' + e.getMessage());
            }
         }
         isPDPAHisInvalidToken = responseBody != null ? responseBody.contains('invalid_token') : false;
        if(isPDPAHisInvalidToken && pdpaHisRetryRemain <= 0) {
            isViewPDPAHisRetryTimeout = true;
        }

        isSuccess = pdpaCalloutUtil.isGetHistSuccess;
        List<PDPAStructure.PDPAconsents> consentList = new List<PDPAStructure.PDPAconsents>();
        if(isSuccess){
            try{
                pdpaData = PDPAStructure.parseJsontoObj(responseBody);
                consentList = pdpaData.data.consents;
                pdpaMaps = getPDPAMapping(pdpaMaps);
            }catch(Exception e){
                System.debug(e.getMessage());
                isError = true;
            }
        }

        for(PDPAStructure.PDPAconsents pdpaConsent : consentList){ //get displayable consent
            if(pdpaConsent.flag == 'Y'){
                pdpaConsent.flag = Label.PDPA_Accept_YES;
            }else if(pdpaConsent.flag == 'N'){
                pdpaConsent.flag = Label.PDPA_Accept_NO;
            }
            if(pdpaConsent.type == 'PDPA-DEPOSIT' || pdpaConsent.type == 'MARKET'){//Show criteria "PDPA-DEPOSIT" and "MARKET" only.
                for(PDPAMapping__c pdpaMap:pdpaMaps){
                    if(pdpaConsent.type == pdpaMap.Name){               
                        pdpaConsent.type = pdpaMap.Display_Type__c;
                        consents.add(pdpaConsent);   
                        break;
                    }
                }
            }   
        }
        if(consents.size() > 0){
            isEmpty = false;
        }else{
            isEmpty = true;
        }
        sortByLastUpdate(consents);
        page = 0;
        pagination();
        
        System.debug('isGetAccount: ' + isGetAccount);
        System.debug('isHaveTMB_ID: ' + isHaveTMB_ID);
        System.debug('isSuccess: ' + isSuccess);
        System.debug('isEmpty: ' + isEmpty);
        System.debug('isError: ' + isError +'\n');
        if(isGetAccount){
            if(isHaveTMB_ID){
                if(isSuccess){
                    if(!isEmpty){
                        if(isError){
                            System.debug('Error');
                            state = '1';
                        }else{
                            System.debug('Success');
                            state = '0';
                        }
                    }else{
                        System.debug('No displayable record');
                        state = '2';
                    }
                }else{
                    System.debug('Call service unsuccess');
                    state = '1';
                }
            }else{
            	System.debug('Account don\'t have TMB_ID');
                state = '2';
            }
        }else{
            System.debug('Don\'t get account');
            state = '2';
        }
        System.debug('state: ' + state);
    }
    
    public List<PDPAMapping__c> getPDPAMapping(List<PDPAMapping__c> pdpaMaps){
        return [SELECT Name, Display_Type__c FROM PDPAMapping__c ];
    }
    
    public void sortByLastUpdate(List<PDPAStructure.PDPAconsents> consentList){
        for(integer i = 1; i < consentList.size(); i++){
            for(integer j = i-1; j >= 0; j--){
                if(consentList[j].consentDateTime<consentList[j+1].consentDateTime){
                    swapConsentInList(consentList,j,j+1);
                }else {
                    break;
                }
            }
        }
    }
    
    public void swapConsentInList(List<PDPAStructure.PDPAconsents> consentList,integer index1,integer index2){
        PDPAStructure.PDPAconsents tmp1 = consentList[index1];
        PDPAStructure.PDPAconsents tmp2 = consentList[index2];
        consentList.remove(index2);
        if(index2 == consentList.size()){
            consentList.add(tmp1);
        }else{
            consentList.add(index2, tmp1);
        }
        consentList.remove(index1);
        consentList.add(index1, tmp2);
    }
    
    public void paginationPrevious(){
        page -= 1;
        pagination();
    }
    
    public void paginationNext(){
        page += 1;
        pagination();
    }
    
    public void pagination(){
        pageMax = consents.size()/5;
        consentDisplay = new List<PDPAStructure.PDPAconsents>();
        if(math.mod(consents.size(), 5) == 0){
            pageMax -= 1;
        }
        if(page != pageMax){
            pageString = '(' + ((page*5)+1) + '-' + ((page*5)+5) + ' of ' + consents.size() + ')';
        }else{
            pageString = '(' + ((page*5)+1) + '-' + consents.size() + ' of ' + consents.size() + ')';
        }
        if(consents.size() < 5){
            pageString = '(1-' + consents.size() + ' of ' + consents.size() + ')';
        }
        for(integer i = 0; i < 5 ; i++){
            if(page*5+i >= consents.size()){
                break;
            }
            consentDisplay.add(consents.get(page*5+i));
        }
    }
    
}