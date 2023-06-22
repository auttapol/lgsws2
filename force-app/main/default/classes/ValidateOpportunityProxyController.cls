public with sharing class ValidateOpportunityProxyController {
    public Id recID {
        get{
            if(recID == null){
                recID = ApexPages.currentPage().getParameters().get('id');
            }
            System.debug('recID ' + recID);
            return recID;
        } 
        set;
    }

    public Boolean ValidateOptyFag {
        get{
            ValidateOptyFag = true;
            if(ProfileMap.get(currentUserProfile.name) != null){
                System.debug('Validate profile : PASS : ' + currentUserProfile.name);
                if(leadlst.size() > 0 || referallst.size() > 0 || opptylst.size() > 0){
                    System.debug('Validate Other : PASS');
                    ValidateOptyFag = false;
                }
            }
            System.debug('Validate Opty fag : ' + ValidateOptyFag);
            return ValidateOptyFag; 
        } 
        set;
    }

    public Integer leadSize{
        get{
            return leadlst.size();
        }
    }

    public Integer referSize{
        get{
            return referallst.size();
        }
    }

    public Integer optySize{
        get{
            return opptylst.size();
        }
    }

    public Profile currentUserProfile {
        get{
            if(currentUserProfile == null){
                currentUserProfile = [SELECT id,name FROM profile WHERE id =: userinfo.getprofileID()];
            }
            return currentUserProfile;
        }set;
    }

    public static Map<String,Validate_Opportunity_Profile__mdt> ProfileMap {
        get{
            Map<String,Validate_Opportunity_Profile__mdt> ProfileMap = new Map<String,Validate_Opportunity_Profile__mdt>();        
                for(Validate_Opportunity_Profile__mdt listProfile : [SELECT id, Label, DeveloperName FROM Validate_Opportunity_Profile__mdt] ){
                    ProfileMap.put(listProfile.Label, listProfile);
                }        
            return new Map<String,Validate_Opportunity_Profile__mdt>(ProfileMap);
        }
        set;
    }

    public List<Lead> leadlst {
        get{
            if(leadlst == null){
                leadlst = [SELECT Id, Name, Customer_Name_EN__c, Status, OwnerId, Owner.Name, Primary_Campaign__c, Primary_Campaign__r.Name, Pri_Campaign_Active__c, CreatedDate, LastModifiedDate 
                            FROM Lead
                            WHERE OwnerId =: userOwnerId 
                            AND Account__c =: recID
                            AND Status IN ('New', 'Open', 'Passed Prescreening', 'Contacted', 'Qualified') 
                            AND Pri_Campaign_Active__c = true 
                            AND Primary_Campaign__c != null
                            ];
                System.debug('GET LEAD ' + leadlst.size());
            }
            return leadlst;
        } 
        set;
    }

    public List<RTL_Referral__c> referallst {
        get{
            if(referallst == null){
                referallst = [SELECT Id, OwnerId, Owner.Name, Name, RTL_FirstName__c, RTL_LastName__c, RTL_Campaign__c, RTL_Stage__c, RTL_Referred_Date_time__c 
                                FROM RTL_Referral__c 
                                WHERE OwnerId =: userOwnerId AND RTL_Stage__c IN ('New', 'In progress_Contacted')
                                AND RTL_Account_Name__c =: recID
                                ];
                System.debug('GET REFERAL ' + referallst.size());
            }
            return referallst;
        } 
        set;
    }

    public List<Opportunity> opptylst { 
        get{
            if(opptylst == null){
                List<String> stagename1 = new List<String> {'Analysis', 'Develop & Propose Solution', 'Follow up', 'Submit to Credit Process', 'CA-Prep', 'Approval Process', 'Post Approval', 'Set up', 'Document Preparation'};
                List<String> stagename2 = new List<String> {'Analysis', 'Develop & Propose Solution', 'Follow up', 'Receive Doc', 'On Process', 'Issued by centralize', 'Issued by Insurance', 'Issued by Branch'};

                List<String> recordtype1 = new List<String> {'SE Credit Product', 'SE Credit Product2', 'SE Credit Product3', 'WBG Credit Product', 'WBG Credit Product2', 'WBG Credit Product3'};
                List<String> recordtype2 = new List<String> {'Non-credit Product', 'Non-credit Product2', 'Non-credit Product3'};

                opptylst = [SELECT Id, Name, AccountId, Account.RTL_Customer_Name_TH__c, Type, StageName, RTL_Status__c, CreatedDate, OwnerId, Owner.Name, No_of_Product__c, RecordTypeId, CloseDate, Expected_submit_date__c 
                            FROM Opportunity
                            WHERE OwnerId =: userOwnerId 
                            AND AccountId =: recID
                            AND ((StageName IN :stagename1 AND RecordType.Name IN :recordtype1) OR (StageName IN :stagename2 AND RecordType.Name IN :recordtype2))
                            ];
                System.debug('GET OPPORTUNITY ' + opptylst.size());
            }
            return opptylst;
        } 
        set;
    }

    public static Id userOwnerId { 
        get{
            if(userOwnerId == null){
                userOwnerId = UserInfo.getUserId();
                // userOwnerId = '0050w000000ICzSAAW';
                System.debug('Owner Id ' + userOwnerId);
            }
            return userOwnerId;
        } 
        set; 
    }

    public ValidateOpportunityProxyController(ApexPages.StandardSetController controller) {
        
    }

    public PageReference ValidateOpty(){
        return new PageReference('/' + recID).setRedirect(true);
    }
}