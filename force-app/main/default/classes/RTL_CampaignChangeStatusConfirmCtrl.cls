public class RTL_CampaignChangeStatusConfirmCtrl {
    public string activity {get; set;}
    public string messageShowPage {get; set;}
    public string messageSubtitleShowPage {get; set;}
    public string successShowPage {get; set;}
    public Id campaignid {get; set;}
    public Campaign campaign {get; set;}
    public List<RTL_Campaign_Status__mdt> listCancelStatus {get; set;}
    //public List<Campaign_Status__mdt> listHoldStatus {get; set;}
    public Map<Id, Recordtype> campaignRecordType {get; set;}
    public Map<String, Recordtype> campaignRecordTypeName {get; set;}
    public boolean isCancelStatus {get; set;}
    public boolean isChildCampaign {get; set;}
    public boolean displayCannotHold {get; set;}
    public boolean displayPopup {get; set;}

    public RTL_CampaignChangeStatusConfirmCtrl(ApexPages.StandardController stdController) {
        activity = apexpages.currentpage().getparameters().get('activity');
        campaignid = apexpages.currentpage().getparameters().get('id');

        isCancelStatus = false;
        isChildCampaign = false;

        //Setup Message,Record Type,Status can hold/unhold/cencel
        setupMessageShowPage(activity);
        getRecordTypeName();
        listCancelStatus = [select label from RTL_Campaign_Status__mdt where type__c = 'Cancel'];

        //Get Campaign will change
        campaign = [SELECT Id,
                    Name,
                    RecordTypeId,
                    IsActive,
                    Status,
                    RTL_Campaign_Stage__c,
                    RTL_Remark__c
                    FROM Campaign
                    Where Id = :campaignid limit 1];

        system.debug('Campaign is changing status: ' + campaign);




        if (campaign != null) {
            //check record type
            if (!campaignRecordType.get(campaign.RecordTypeId).Name.containsIgnoreCase('Master')) {
                isChildCampaign = true;
            }

            //check campaign status planned,submitted,1-approved,rejected in custom meta
            for (RTL_Campaign_Status__mdt l : listCancelStatus) {
                if (campaign.Status == l.label) {
                    isCancelStatus = true;
                    break;
                }

            }


            //Check hold status
            if(isChildCampaign && activity == 'Hold'){
                if(campaign.RTL_Campaign_Stage__c == 'Executed' && (campaign.status == 'Open' || campaign.status == 'In Progress')){
                    displayCannotHold = false;
                    displayPopup = false;

                }else{
                    displayCannotHold = true;
                    displayPopup = true;
                }
            }

            campaign.RTL_Remark__c = null;

        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR001));
        }

    }

    public Pagereference save() {

        if (isChildCampaign) {
            if(campaign.RTL_Remark__c != null){
                campaign.RTL_Remark__c = campaign.RTL_Remark__c ;
            }

            if (activity == 'hold') {
                campaign.Status = 'On Hold';
                campaign.RTL_Campaign_Stage__c = 'Executed';
                campaign.IsActive = false;

            }

            if (activity == 'unhold') {
                campaign.Status = 'In Progress';
                campaign.RTL_Campaign_Stage__c = 'Executed';
                campaign.IsActive = true;
                //campaign.RTL_Remark__c = null;

            }

            if (activity == 'cancel') {
                if(campaign.RTL_Campaign_Stage__c == 'New'){
                    if(isCancelStatus){
                        campaign.Status = 'Cancelled';
                        campaign.IsActive = false;

                        system.debug('campaign.RecordTypeId'+campaign.RecordTypeId);

                        if (campaignRecordType.get(campaign.RecordTypeId).DeveloperName.equalsIgnoreCase('Exclusive_Campaign')) {
                            campaign.RecordTypeId = campaignRecordTypeName.get('Exclusive_Campaign_Expired').Id;
                        } else if (campaignRecordType.get(campaign.RecordTypeId).DeveloperName.equalsIgnoreCase('Local_Exclusive_Campaign')) {
                            campaign.RecordTypeId = campaignRecordTypeName.get('Local_Exclusive_Campaign_Expired').Id;
                        } else if (campaignRecordType.get(campaign.RecordTypeId).DeveloperName.equalsIgnoreCase('Mass_Campaign')) {
                            campaign.RecordTypeId = campaignRecordTypeName.get('Mass_Campaign_Expired').Id;
                        } else if (campaignRecordType.get(campaign.RecordTypeId).DeveloperName.equalsIgnoreCase('Research_Campaign')) {
                            campaign.RecordTypeId = campaignRecordTypeName.get('Research_Campaign_Expired').Id;
                        } else {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR002));
                            return null;
                        }
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR003));
                        return null;
                    }

                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR004));
                    return null;
                }

            }
        }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR005));
                    return null;
                }

        try {
            system.debug(campaign);
            update campaign;

        } catch (Exception e) {
            system.debug(e);
            ApexPages.addmessages(e);
            return null;
        }

        displayPopup = true;

        if (activity == 'hold') {
            successShowPage = System.Label.RTL_Campaign_Status_end_hold;
        } else if (activity == 'unhold') {
            successShowPage = System.Label.RTL_Campaign_Status_end_unhold;
        } else if (activity == 'cancel') {
            successShowPage = System.Label.RTL_Campaign_Status_end_cancel;
        } else {
            messageShowPage = 'This not support on action in parameter.';
        }

        return null;


    }

    public Pagereference cancel(){
        PageReference detailpage;
        detailpage = new PageReference('/'+campaign.Id+'?isdtp=vw'); 
        detailpage.setRedirect(true);
        return detailpage;

    }


    public void setupMessageShowPage (string activity) {
        if (activity == 'hold') {
            messageSubtitleShowPage = System.Label.RTL_Campaign_Status_title_hold;
            messageShowPage = System.Label.RTL_Campaign_Status_cf_hold;
        } else if (activity == 'unhold') {
            messageSubtitleShowPage = System.Label.RTL_Campaign_Status_title_unhold;
            messageShowPage = System.Label.RTL_Campaign_Status_cf_unhold;
        } else if (activity == 'cancel') {
            messageSubtitleShowPage = System.Label.RTL_Campaign_Status_title_cancel;
            messageShowPage = System.Label.RTL_Campaign_Status_cf_cancel;
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.RTL_Campaign_Status_ERR006));
        }
    }

    public void getRecordTypeName() {
        campaignRecordType = new Map<Id, RecordType>([SELECT ID, Name, DeveloperName
                FROM Recordtype
                WHERE sObjectType = 'Campaign'
                                    AND (NOT DeveloperName LIKE '%Commercial%')]);

        campaignRecordTypeName = new Map<String, RecordType>();

        for (Recordtype r : [SELECT DeveloperName, Id, name
                             FROM Recordtype
                             WHERE sObjectType = 'Campaign'
                                     AND (NOT DeveloperName LIKE '%Commercial%')]) {

            campaignRecordTypeName.put(r.DeveloperName, r);
        }

        system.debug('campaignRecordTypeName' + campaignRecordTypeName);
        system.debug('campaignRecordType' + campaignRecordType.size());

    }

}