public class overSLAReferralEmailNotificationBatch implements Database.Batchable<sObject>, Database.Stateful {

    private Map<Id /*OwnerId */, List<RTL_Referral__c>> mapReferralLst;
    private OrgWideEmailAddress orgWideEmail;
    private Integer emailSuccessful = 0;
    private Integer emailFailed = 0;
    private String query;
    
    private Datetime batchDate = datetime.now();
    private Datetime batchStartTime;
    private Datetime batchExecuteTime;
    
    private Map<Id,String> mapUserIdwithManagerEmail = new Map<Id,String>();

    public overSLAReferralEmailNotificationBatch(String q) {
        this.mapReferralLst = new Map<Id, List<RTL_Referral__c>>();
        // sendMailList = new List<Messaging.SingleEmailMessage>();
        this.orgWideEmail = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' LIMIT 1];
        System.debug('QUERY : '  + q);
        query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug(':::::::::::::::start:::::::::::::::');
        batchStartTime = datetime.now();
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<RTL_Referral__c> scope) {
        System.debug(':::::::::::::::execute:::::::::::::::');
        Set<Id> setuserID = new Set<Id>();

        if(batchExecuteTime == null){
            batchExecuteTime = datetime.now();
        }
        for (RTL_Referral__c a : scope) {
            if(String.valueof(a.OwnerId).startsWith('005')){
                setuserID.add(a.OwnerId);
            }
            if(mapReferralLst.containsKey(a.OwnerId)) {
                mapReferralLst.get(a.Id).add(a);
            }
            else {
                mapReferralLst.put(a.Id, new List<RTL_Referral__c>{ a });
            }
        }
        List<User> ownerlst = [SELECT Id,ManagerId,Manager_Email__c FROM User WHERE Id IN: setuserID];
        for(User each : ownerlst){
            System.debug('Test ' + each.Manager_Email__c);
            mapUserIdwithManagerEmail.put(each.Id,each.Manager_Email__c);
        }
        System.debug('mapUserIdwithManagerEmail Size ' + mapUserIdwithManagerEmail.size());
    }

    public void finish(Database.BatchableContext BC) {
        System.debug(':::::::::::::::finish:::::::::::::::');
        System.debug('batchDate : ' + batchDate);
        System.debug('batchStartTime : ' + batchStartTime);
        System.debug('batchExcuteTime : ' + batchExecuteTime);
        System.debug('batchFinishTime : ' + datetime.now());

        List<Messaging.SingleEmailMessage> sendMailList = new List<Messaging.SingleEmailMessage>();

        for (Id Id : mapReferralLst.keySet()) { 
            if(mapReferralLst.get(Id).get(0).Owner.Email != null){
            String textHeader = mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__c != Null ? 'เรียน คุณ ' : 'เรียน ';
            List<String> ccAddress = new List<String>();
            String Creator = mapReferralLst.get(Id).get(0).CreatedBy.Email;
            String recordType = mapReferralLst.get(Id).get(0).RecordType.Name;
            String productName = recordType == 'Retail Cross Channel Referral' ? mapReferralLst.get(Id).get(0).RTL_Product_Name__r.Name : mapReferralLst.get(Id).get(0).RTL_Interested_Product__c;
            String productGroup = recordType == 'Retail Cross Channel Referral' ? '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;กลุ่มผลิตภัณฑ์: ' + mapReferralLst.get(Id).get(0).RTL_Product_Group__c + '<br/>': '' ;
            String customerName = mapReferralLst.get(Id).get(0).RTL_Account_Name__c == null ?  '' : mapReferralLst.get(Id).get(0).RTL_Account_Name__r.Name;
            
            ccAddress.add(Creator);
            System.debug(Id + ' | ' + mapReferralLst.get(Id).size());
            String Link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapReferralLst.get(Id).get(0).Id;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ mapReferralLst.get(Id).get(0).Owner.Email });
            mail.setSubject('[Reminder before Over SLA] CRM Referral_[' + mapReferralLst.get(Id).get(0).Name + ']' );
            mail.setHtmlBody(
                textHeader + mapReferralLst.get(Id).get(0).Owner.Name 
                + '<br/><br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;แจ้งเตือนเพื่อเร่งดำเนินการติดต่อลูกค้า และอัพเดตสถานะ ' + mapReferralLst.get(Id).get(0).RTL_Stage__c + ' Referral ตาม URL Link ด้านล่าง ภายใน 1 วัน จะครบกำหนด SLA '
                + '<br/><br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;Link: ' + Link
                + '<br/><br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;Referal Number: ' + mapReferralLst.get(Id).get(0).Name 
                + '<br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ขั้นตอน: ' + mapReferralLst.get(Id).get(0).RTL_Stage__c 
                + '<br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;Customer Name: ' + customerName
                + '<br/>'
                + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ประเภทการ Refer: ' + mapReferralLst.get(Id).get(0).RTL_Type__c 
                + '<br/>'
                + productGroup
                + '&nbsp;&nbsp;&nbsp;&nbsp;&#x2022;&nbsp;ชื่อผลิตภัณฑ์: ' + productName
                + '<br/>' 
            );
            mail.setCharset('UTF-8');
            if(mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__c != null ){
                String teamLeadOwner = mapReferralLst.get(Id).get(0).RTL_Preferred_Staff__r.Manager_Email__c;
                System.debug('Preferred Staff Owner ' + teamLeadOwner);

                if(teamLeadOwner != null){
                    ccAddress.add(teamLeadOwner);
                    System.debug(teamLeadOwner);
                }
            }else if(String.ValueOF(mapReferralLst.get(Id).get(0).OwnerId).startsWith('005')){
                String teamLeadOwner = mapUserIdwithManagerEmail.get(mapReferralLst.get(Id).get(0).OwnerId);
                System.debug('Mananger Email ' + teamLeadOwner);
                if(teamLeadOwner != null){
                    ccAddress.add(teamLeadOwner);
                }
            }
            
            mail.setCcAddresses(ccAddress);
            mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            sendMailList.add(mail);
            }
        }
        if(sendMailList.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sendMailList);
            for (Messaging.SendEmailResult result : results) {
                if(result.isSuccess()){
                    emailSuccessful++;
                }
                else {
                    System.debug(logginglevel.ERROR, 'There is error on overSLAReferralEmailNotificationBatch. Error Message is: ' + result.getErrors());
                    emailFailed++;
                }
            }
        }
    }
}