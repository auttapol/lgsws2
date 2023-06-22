public class ValidateOpportunityController {
    public List<Lead> leadshowlst {
        get{
            if(leadshowlst == null){
                leadshowlst = new List<Lead>();
            }
            return leadshowlst;
        } 
        set;
    }

    public List<Lead> leadlst {
        get{
            if(leadlst == null){
                leadlst = [SELECT Id, Name, Company, Customer_Name_EN__c, Status, OwnerId, Owner.Name, Primary_Campaign__c, Primary_Campaign__r.Name, Pri_Campaign_Active__c, CreatedDate, LastModifiedDate 
                            FROM Lead
                            WHERE OwnerId =: userOwnerId AND Account__c =: AccountId
                            AND Status IN ('New', 'Open', 'Passed Prescreening', 'Contacted', 'Qualified') 
                            AND ((Primary_Campaign__c != null AND Pri_Campaign_Active__c = true ) OR Primary_Campaign__c = null)
                            ORDER BY LastModifiedDate DESC];
            }
            return leadlst;
        } 
        set;
    }
    
    public List<RTL_Referral__c> referalshowlst {
        get{
            if(referalshowlst == null){
                referalshowlst = new List<RTL_Referral__c>();
            }
            return referalshowlst;
        } 
        set;
    }

    public List<RTL_Referral__c> referallst {
        get{
            if(referallst == null){
                referallst = [SELECT Id, OwnerId, Owner.Name, Name, RTL_FirstName__c, RTL_LastName__c, RTL_Account_Name__c, RTL_Account_Name__r.Name, RTL_Stage__c, RTL_Referred_Date_time__c 
                                FROM RTL_Referral__c 
                                WHERE OwnerId =: userOwnerId AND RTL_Account_Name__c =: AccountId
                                AND RTL_Stage__c IN ('New', 'In progress_Contacted')
                                ORDER BY LastModifiedDate DESC];
            }
            return referallst;
        } 
        set;
    }

    public List<Opportunity> opptyshowlst {
        get{
            if(opptyshowlst == null){
                opptyshowlst = new List<Opportunity>();
            }
            return opptyshowlst;
        } 
        set;
    }

    public List<Opportunity> opptylst { 
        get{
            if(opptylst == null){
                List<String> stagename1 = new List<String> {'Analysis', 'Develop & Propose Solution', 'Follow up', 'Submit to Credit Process', 'CA-Prep', 'Approval Process', 'Post Approval', 'Set up', 'Document Preparation'};
                List<String> stagename2 = new List<String> {'Analysis', 'Develop & Propose Solution', 'Follow up', 'Preparing Doc', 'On Process', 'Issued by centralize', 'Issued', 'Issued by Branch'};

                List<String> recordtype1 = new List<String> {'SE Credit Product', 'SE Credit Product2', 'SE Credit Product3', 'WBG Credit Product', 'WBG Credit Product2', 'WBG Credit Product3'};
                List<String> recordtype2 = new List<String> {'Non-credit Product', 'Non-credit Product2', 'Non-credit Product3'};

                opptylst = [SELECT Id, Name, AccountId, Account.Name, Type, StageName, Application_Status__c, RTL_Status__c, Opportunity_Type_Formula__c, CreatedDate, OwnerId, Owner.Name, No_of_Product__c, RecordTypeId, CloseDate, Expected_submit_date__c 
                            FROM Opportunity
                            WHERE OwnerId =: userOwnerId 
                            AND AccountId =: AccountId
                            AND ((StageName IN :stagename1 AND RecordType.Name IN :recordtype1) OR (StageName IN :stagename2 AND RecordType.Name IN :recordtype2))
                            ORDER BY LastModifiedDate DESC];
            }
            return opptylst;
        } 
        set;
    }

    // LIIMIT
    public Integer VO_LIMIT {
        get{
            return 5;
        }
    }

    // OFFSET
    public integer LeadOffset {
        get { 
            if(LeadOffset == null){
                LeadOffset = 0;
            }
            return LeadOffset;
        } 
        set;
    }
    public integer ReferralOffset {
        get { 
            if(ReferralOffset == null){
                ReferralOffset = 0;
            }
            return ReferralOffset;
        } 
        set;
    }
    public integer OpptyOffset {
        get { 
            if(OpptyOffset == null){
                OpptyOffset = 0;
            }
            return OpptyOffset;
        } 
        set;
    }
    
    public Id userOwnerId { 
        get{
            if(userOwnerId == null){
                userOwnerId = UserInfo.getUserId();
                // userOwnerId = '0050w000000ICzSAAW';
            }
            System.debug('userOwnerId ::: ' + UserInfo.getUserId());
            System.debug('userOwnerId ::: '+ userOwnerId);
            return userOwnerId;
        } 
        set; 
    }
    public Id AccountId { get; set; }
    public ValidateOpportunityController(){
        AccountId = ApexPages.currentPage().getParameters().get('AccountId');
        // AccountId = '0010w000001oljZAAQ';
        System.debug('Account Id :::: '+ AccountId);
        callInitial();
    }

    public void callInitial(){
        for (Integer i = 0 ; i  < leadlst.size() && i < VO_LIMIT ; i++) {
            LeadOffset++;
            leadshowlst.add(leadlst.get(i));
        }

        for (Integer i = 0 ; i  < referallst.size() && i < VO_LIMIT ; i++) {
            ReferralOffset++;
            referalshowlst.add(referallst.get(i));
        }
        
        for (Integer i = 0 ; i  < opptylst.size() && i < VO_LIMIT ; i++) {
            OpptyOffset++;
            opptyshowlst.add(opptylst.get(i));
        }
    }

    public void callShowMore(){
        string CallType = ApexPages.currentPage().getParameters().get('CallType');
        System.debug('CallType ::: '+ CallType);
        
        if(CallType == 'Lead'){
            Integer tmpLength = LeadOffset + VO_LIMIT;
            for (Integer i = LeadOffset; i < leadlst.size() && i < tmpLength; i++) {
                LeadOffset++;
                leadshowlst.add(leadlst.get(i));
            }
        }

        else if (CallType == 'Referral') {
            Integer tmpLength = ReferralOffset + VO_LIMIT;
            for (Integer i = ReferralOffset; i < referallst.size() && i < tmpLength; i++) {
                ReferralOffset++;
                referalshowlst.add(referallst.get(i));
            }
        }

        else if (CallType == 'Oppty') {
            Integer tmpLength = OpptyOffset + VO_LIMIT;
            for (Integer i = OpptyOffset; i < opptylst.size() && i < tmpLength; i++) {
                OpptyOffset++;
                opptyshowlst.add(opptylst.get(i));
            }
        }
    }

    /* check if the VF page is display by SF1 */
    // public Boolean isSF1 {
    //     get {                   
    //         if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
    //             String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
    //             ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
    //             (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
    //         ) {
    //             return true;
    //         }else{
    //             return false;
    //         }
    //     }
    // }
}