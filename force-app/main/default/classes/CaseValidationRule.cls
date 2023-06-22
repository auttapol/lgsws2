public class CaseValidationRule {
    public static User currentUser = [SELECT Id,Name,Profile.Name FROM User Where Id =: UserInfo.getUserId()];

    public static App_Config__mdt appMeta_CaseOrigin{
        get{
            if(appMeta_CaseOrigin==null){
                appMeta_CaseOrigin = [SELECT Id, Label, Value__c FROM App_Config__mdt WHERE Label = 'Case Origin']; 
            }
            return appMeta_CaseOrigin;
        }
        set;
    }
    public static void checkValidate(List<Case> caseList){
        //CR Non-Voice ---------
        Map<String,String> caseOriginMap = new Map<String,String>();
        List<String> caseOriginList = appMeta_CaseOrigin.Value__c.split(',');

        for(String caseOrigin : caseOriginList)
        {
            caseOriginMap.put(caseOrigin,caseOrigin);

        }
        //-----------------------
        for(Case newCase : caseList){     
            //CR Non-Voice ------
            if(currentUser.Profile.Name == 'System Administrator' && caseOriginMap.containsKey(newCase.Origin))
            {
                newCase.Is_Bypassed__c = true;
                newCase.Contact_Person_Email__c = newCase.SuppliedEmail;
            }     
            if(!newCase.Is_Bypassed__c) //-------
            {
                //Check Description to not allow input credit card number
                if(newCase.Description != null){
                    String commentText = newCase.Description .replace(' ', '');   
                    commentText = commentText.replace('-', '');
                    commentText = commentText.replace('\r\n', ' ');
                    commentText = commentText.replace('\n', ' ');
                    commentText = commentText.replace('\r', ' ');
                    if(Pattern.matches('(.*[0-9]{16}.*)*', commentText)){
                        //Cannot input credit card number, please input to specified field Card No
                        newCase.Description.addError(Label.Case_ERR016);
                    }else                
                    //Validate_Description length
                    if(newCase.Description.length() > 3500 ){
                        //Description cannot more than 3500 character
                        newCase.Description.addError(Label.Case_ERR017);
                    }
                }else             
                //validate_contact_info
                if(newCase.Quick_Case__c == false && newCase.AccountId == null && newCase.Contact_Person_Name__c == null){
                    //Please input contact information.
                    newCase.Contact_Person_Name__c.addError(Label.Case_ERR018);
                }
                
                //Check_CS_Status_before_Closed_Case
                if((newCase.CS_Status__c == '01. Onhand CS1' || newCase.CS_Status__c == '02. Onhand AAD' || newCase.CS_Status__c == '03. Onhand ZM' ||
                    newCase.CS_Status__c == '04. Onhand UW' || newCase.CS_Status__c == '05. Onhand CS2') && 
                    (newCase.Status == 'Completed' || newCase.Status == 'Cancel')){
                        //ไม่สามารถปิดเคสได้ กรุณาเลือก CS Status ให้ถูกต้อง
                        newCase.CS_Status__c.addError(Label.Case_ERR021);   
                }else
                //Validate_Service_Request_CS
                if( newCase.CS_Flow__c != null && newCase.Category__c.contains('Service Request') &&
                    newCase.CS_Flow__c != '03. BU'){
                    //ถ้า Category = Service Request_CS สามารถเลือก  CS Flow ได้เฉพาะ 03. BU เท่านั้น
                    newCase.CS_Flow__c.addError(Label.Case_ERR022);
                }else    
                //Check_AAD_pending_Reason
                if(newCase.AAD_Action__c  == 'Pending' && NewCase.AAD_Pending_Reason__c == ''){
                    //กรุณาใส่ AAD Pending Reason
                    newCase.AAD_Pending_Reason__c.addError(Label.Case_ERR023); 
                }else             
                //Validate_UW_Authorize
                if(newCase.UW_Action__c == 'Approved' && (newCase.Authorize_1__c == null || newCase.Authorize_2__c == null)){
                    //Please input  Authorize 1 and Authorize 2
                    newCase.Authorize_1__c.addError(Label.Case_ERR024); 
                }    
            } 
            newCase.Is_Bypassed__c = false; 
        }
     }
}