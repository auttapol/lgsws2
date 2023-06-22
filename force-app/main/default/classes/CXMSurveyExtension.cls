public class CXMSurveyExtension {

    public Account acct {get;set;}

    //CXM Face for Customer 05/05/2020
    public List<CXM_Survey_Condition__mdt> CXMMeta {get;set;}
    public CXM_Survey__c CXM {get;set;}
    public String CXMFace {get;set;}
    public String tabId {get;set;}

    public CXMSurveyExtension(ApexPages.StandardController std){
        
        acct = (Account)std.getRecord();
        //****** Get account detail and User's Profile detail *****
        //*** These data use for loggin button to Online service log ***
        CXMFace = '';
        if (acct != null){
            CXM = getCXM(acct.Id);
            CXMMeta = getCXMMeta();
            
            if (CXM != null && CXMMeta != null){
                Decimal score = CXM.Survey_Score__c;
                for (CXM_Survey_Condition__mdt mdt : CXMMeta){
                    if (score <= mdt.Highest_Score__c && score >= mdt.Lowest_Score__c){
                        CXMFace = mdt.Emotion_Face__c;
                    }
                }
            }
        }
    }

    //CXM Customer 05/05/2020
    public CXM_Survey__c getCXM(String AccId){
        try {
            Account acct = [SELECT Id,TMB_Customer_ID_PE__c FROM Account WHERE Id =: AccId];
            CXM_Survey__c thisCXM = [SELECT Id,Account__c,Survey_Score__c,Survey_Datetime__c FROM CXM_Survey__c WHERE Customer_ID__c =:acct.TMB_Customer_ID_PE__c AND Survey_Datetime__c  = LAST_N_DAYS:30  ORDER BY Survey_Datetime__c DESC LIMIT 1];
            // CXM_Survey__c thisCXM = [SELECT Id,Account__c,Survey_Score__c,Survey_Datetime__c FROM CXM_Survey__c WHERE Survey_Datetime__c > LAST_N_MONTHS:1 LIMIT 1];
            return thisCXM;
        }catch (Exception e){
            System.Debug(e.getMessage());
            return null;
        }
    }

    public List<CXM_Survey_Condition__mdt> getCXMMeta(){
        try {
            List<CXM_Survey_Condition__mdt> thisCXMMeta = [SELECT Emotion_Face__c,Highest_Score__c,Lowest_Score__c,Possible_Value__c FROM CXM_Survey_Condition__mdt];
            return thisCXMMeta;
        }catch (Exception e){
            System.Debug(e.getMessage());
            return null;
        }
        
    }
    
}