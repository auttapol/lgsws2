public class CampaignTriggerHandler {

    public CampaignTriggerHandler() {

    }

    public static void checkDuplicateName(list<campaign> listNewCampaign, list<campaign> listOldCampaign) {
        boolean error = false;

        set<string> listCheckCampaignNameDuplicate = new set<string>();
        for (campaign c : listNewCampaign) { // new list campaign name duplicate
            if (listCheckCampaignNameDuplicate.contains(c.name))
                error = true;
            listCheckCampaignNameDuplicate.add(c.name);
        }

        set<string> listCampaignName = new set<string>();
        map<string, string> mapOldCampaignName = new map<string, string>();
        for (campaign c : listOldCampaign) {
            mapOldCampaignName.put(c.id, c.name);
        }
        for (campaign c : listNewCampaign) {
            if (c.name != mapOldCampaignName.get(c.id))
                listCampaignName.add(c.name);
        }

        integer found = [select count() from campaign where name in : listCampaignName];
        if (found > 0) error = true;

        if (error)
            listNewCampaign.get(0).name.addError(status_code__c.getValues('8002').status_message__c);
    }

    /*
    public static void InactiveLead(list<campaign> listNewCampaign, list<campaign> listOldCampaign) {
        list<lead> listUpdateLead = new list<lead>();
        list<string> listChangeCampaignID = new list<string>();
        map<id, campaign> mapOld = new map<id, campaign>();
        if (listOldCampaign != null && listOldCampaign.size() > 0) {
            mapOld.putAll(listOldCampaign);
        }

        for (campaign c : listNewCampaign) {
            if (c.status == 'Cancelled' && c.status != mapOld.get(c.id).status) {
                listChangeCampaignID.add(c.id);
            }
        }

        for (lead l : [select id, status from lead where Primary_Campaign__c in: listChangeCampaignID
                       and status = 'Open'
                                    and Keep_Lead_in_Campaign__c = false]) {
            l.status = 'Inactive';
            listUpdateLead.add(l);
        }

        try {
            if (listUpdateLead.size() > 0) {
                update listUpdateLead;
            }
        } catch (exception ex) {
            system.debug('error :' + ex.getMessage());
        }
    }
    */

    public static void calculateParentCampaign(list<Campaign> listNewCampaign, list<Campaign> listOldCampaign) {

        system.debug('campaign trigger : calculateParentCampaign start');

        Map<Id, Campaign> mapOld = new Map<Id, Campaign>();
        mapOld.putAll(listOldCampaign);
        List<String> listChangeCampaignID = new List<String>();
        Map<Id, Decimal> mapFull = new Map<Id, Decimal>();
        Map<Id, Decimal> mapThis = new Map<Id, Decimal>();
        Map<Id, Decimal> mapFullWon = new Map<Id, Decimal>();
        Map<Id, Decimal> mapThisWon = new Map<Id, Decimal>();
        Set<String> setParentCampaignID = new Set<String>();
        List<Campaign> listUpdateCampaign = new List<Campaign>();

        for (Campaign c : listNewCampaign) {
            if (c.HierarchyFullDealExpectedRevenueOpty__c != mapOld.get(c.Id).HierarchyFullDealExpectedRevenueOpty__c
                    || c.HierarchyThisYearExpectedRevenueOpty__c != mapOld.get(c.Id).HierarchyThisYearExpectedRevenueOpty__c
                    || c.HierarchyFullDealExpectedRevenueWONOpty__c != mapOld.get(c.Id).HierarchyFullDealExpectedRevenueWONOpty__c
                    || c.HierarchyThisYearExpectedRevenueWONOpty__c != mapOld.get(c.Id).HierarchyThisYearExpectedRevenueWONOpty__c) {
                listChangeCampaignID.add(c.Id);
                Decimal fullyear = ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00) - ((mapOld.get(c.Id).HierarchyFullDealExpectedRevenueOpty__c != null) ? mapOld.get(c.Id).HierarchyFullDealExpectedRevenueOpty__c : 0.00);
                Decimal thisyear = ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00) - ((mapOld.get(c.Id).HierarchyThisYearExpectedRevenueOpty__c != null) ? mapOld.get(c.Id).HierarchyThisYearExpectedRevenueOpty__c  : 0.00);
                Decimal fullyearWon = ((c.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? c.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) - ((mapOld.get(c.Id).HierarchyFullDealExpectedRevenueWONOpty__c != null) ? mapOld.get(c.Id).HierarchyFullDealExpectedRevenueWONOpty__c : 0.00);
                Decimal thisyearWon = ((c.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? c.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) - ((mapOld.get(c.Id).HierarchyThisYearExpectedRevenueWONOpty__c != null) ? mapOld.get(c.Id).HierarchyThisYearExpectedRevenueWONOpty__c : 0.00);

                mapFull.put(c.Id, fullyear);
                mapThis.put(c.Id, thisyear);
                mapFullWon.put(c.Id, fullyearWon);
                mapThisWon.put(c.Id, thisyearWon);
            }
        }

        if (listChangeCampaignID.size() > 0) {

            Map<Id, Campaign> mapParentCampaign = new Map<Id, Campaign>();
            List<Campaign> ListParentCampaign = [Select Id, ParentId
                                                 , Parent.HierarchyFullDealExpectedRevenueOpty__c
                                                 , Parent.HierarchyThisYearExpectedRevenueOpty__c
                                                 , Parent.HierarchyFullDealExpectedRevenueWONOpty__c
                                                 , Parent.HierarchyThisYearExpectedRevenueWONOpty__c
                                                 from Campaign
                                                 where ID in: listChangeCampaignID and ParentId != ''];
            for (Campaign c : ListParentCampaign) {
                setParentCampaignID.add(c.ParentID);
                if (mapParentCampaign.get(c.ParentID) == null) {
                    Campaign ca = new Campaign(ID = c.ParentID);
                    ca.HierarchyFullDealExpectedRevenueOpty__c = ((c.Parent.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.Parent.HierarchyFullDealExpectedRevenueOpty__c : 0.00) + ((mapFull.get(c.ID) != null) ? mapFull.get(c.ID) : 0.00);
                    ca.HierarchyThisYearExpectedRevenueOpty__c = ((c.Parent.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.Parent.HierarchyThisYearExpectedRevenueOpty__c : 0.00) + ((mapThis.get(c.ID) != null) ? mapThis.get(c.ID) : 0.00);
                    ca.HierarchyFullDealExpectedRevenueWONOpty__c = ((c.Parent.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? c.Parent.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00) + ((mapFullWon.get(c.ID) != null) ? mapFullWon.get(c.ID) : 0.00);
                    ca.HierarchyThisYearExpectedRevenueWONOpty__c = ((c.Parent.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? c.Parent.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00) + ((mapThisWon.get(c.ID) != null) ? mapThisWon.get(c.ID) : 0.00);
                    mapParentCampaign.put(c.ParentID, ca);
                } else {
                    Campaign ca = mapParentCampaign.get(c.ParentID);
                    ca.HierarchyFullDealExpectedRevenueOpty__c = ca.HierarchyFullDealExpectedRevenueOpty__c + ((mapFull.get(c.ID) != null) ? mapFull.get(c.ID) : 0.00);
                    ca.HierarchyThisYearExpectedRevenueOpty__c = ca.HierarchyThisYearExpectedRevenueOpty__c + ((mapThis.get(c.ID) != null) ? mapThis.get(c.ID) : 0.00);
                    ca.HierarchyFullDealExpectedRevenueWONOpty__c = ca.HierarchyFullDealExpectedRevenueWONOpty__c + ((mapFullWon.get(c.ID) != null) ? mapFullWon.get(c.ID) : 0.00);
                    ca.HierarchyThisYearExpectedRevenueWONOpty__c = ca.HierarchyThisYearExpectedRevenueWONOpty__c + ((mapThisWon.get(c.ID) != null) ? mapThisWon.get(c.ID) : 0.00);
                    mapParentCampaign.put(c.ParentID, ca);
                }
            }

            for (String cid : setParentCampaignID) {
                if (mapParentCampaign.get(cid) != null) {
                    listUpdateCampaign.add(mapParentCampaign.get(cid));
                }
            }

            try {
                if (listUpdateCampaign.size() > 0)
                    update listUpdateCampaign;
            } catch (exception ex) {
                system.debug('campaign trigger calculateParentCampaign Error Line ' + ex.getLineNumber() + ' : ' + ex.getMessage());
            }

        }

        system.debug('campaign trigger : calculateParentCampaign end');

    }

    public static void checkParentCampaign(list<Campaign> listNewCampaign, list<Campaign> listOldCampaign) {

        system.debug('campaign trigger : checkParentCampaign start');

        String actionType = '';
        List<String> listNewParentCampaignID = new List<String>();
        List<String> listOldParentCampaignID = new List<String>();
        List<Campaign> listUpdateCampaign = new List<Campaign>();

        Map<String,Decimal> mapFull = new Map<String,Decimal>();
        Map<String,Decimal> mapThis = new Map<String,Decimal>();
        Map<String,Decimal> mapFullWon = new Map<String,Decimal>();
        Map<String,Decimal> mapThisWon = new Map<String,Decimal>();

        Map<Id, Campaign> mapOld = new Map<Id, Campaign>();

        mapOld.putAll(listOldCampaign);
        for (Campaign c : listNewCampaign) {
            //system.debug(c.ParentID);
            string NewID = c.ParentID;
            string OldID = mapold.get(c.ID).ParentID;
            
            if (NewID != '' || OldID != '') {
                if (NewID != null && OldID == '') {
                    actionType = 'add';
                } else if (NewID == '' && OldID != '') {
                    actionType = 'remove';
                } else if (NewID != OldID) {
                    actionType = 'change';
                }

                if (NewID != '') {
                    listNewParentCampaignID.add(NewID);
                    mapFull.put(NewID, ((mapFull.get(NewID) != null) ? mapFull.get(NewID) : 0.00) + ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00));
                    mapThis.put(NewID, ((mapThis.get(NewID) != null) ? mapThis.get(NewID) : 0.00) + ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00));
                    mapFullWon.put(NewID, ((mapFullWon.get(NewID) != null) ? mapFullWon.get(NewID) : 0.00) + ((c.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? c.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00));
                    mapThisWon.put(NewID, ((mapThisWon.get(NewID) != null) ? mapThisWon.get(NewID) : 0.00) + ((c.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? c.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00));
                }

                if (OldID != '') {
                    listOldParentCampaignID.add(OldID);
                    mapFull.put(OldID, ((mapFull.get(OldID) != null) ? mapFull.get(OldID) : 0.00) + ((c.HierarchyFullDealExpectedRevenueOpty__c != null) ? c.HierarchyFullDealExpectedRevenueOpty__c : 0.00));
                    mapThis.put(OldID, ((mapThis.get(OldID) != null) ? mapThis.get(OldID) : 0.00) + ((c.HierarchyThisYearExpectedRevenueOpty__c != null) ? c.HierarchyThisYearExpectedRevenueOpty__c : 0.00));
                    mapFullWon.put(OldID, ((mapFullWon.get(OldID) != null) ? mapFullWon.get(OldID) : 0.00) + ((c.HierarchyFullDealExpectedRevenueWONOpty__c != null) ? c.HierarchyFullDealExpectedRevenueWONOpty__c : 0.00));
                    mapThisWon.put(OldID, ((mapThisWon.get(OldID) != null) ? mapThisWon.get(OldID) : 0.00) + ((c.HierarchyThisYearExpectedRevenueWONOpty__c != null) ? c.HierarchyThisYearExpectedRevenueWONOpty__c : 0.00));
                }
            }
        }

        if (actionType == 'change' || actionType == 'add') {
            for (Campaign c : [Select ID
                               , HierarchyFullDealExpectedRevenueOpty__c
                               , HierarchyThisYearExpectedRevenueOpty__c
                               , HierarchyFullDealExpectedRevenueWONOpty__c
                               , HierarchyThisYearExpectedRevenueWONOpty__c
                               From Campaign Where Id in: listNewParentCampaignID]) {

                c.HierarchyFullDealExpectedRevenueOpty__c = c.HierarchyFullDealExpectedRevenueOpty__c + ((mapFull.get(c.ID) != null) ? mapFull.get(c.ID) : 0.00);
                c.HierarchyThisYearExpectedRevenueOpty__c = c.HierarchyThisYearExpectedRevenueOpty__c + ((mapThis.get(c.ID) != null) ? mapThis.get(c.ID) : 0.00);
                c.HierarchyFullDealExpectedRevenueWONOpty__c = c.HierarchyFullDealExpectedRevenueWONOpty__c + ((mapFullWon.get(c.ID) != null) ? mapFullWon.get(c.ID) : 0.00);
                c.HierarchyThisYearExpectedRevenueWONOpty__c = c.HierarchyThisYearExpectedRevenueWONOpty__c + ((mapThisWon.get(c.ID) != null) ? mapThisWon.get(c.ID) : 0.00);
                listUpdateCampaign.add(c);
            }
        }

        if (actionType == 'change' || actionType == 'remove') {
            for (Campaign c : [Select ID
                               , HierarchyFullDealExpectedRevenueOpty__c
                               , HierarchyThisYearExpectedRevenueOpty__c
                               , HierarchyFullDealExpectedRevenueWONOpty__c
                               , HierarchyThisYearExpectedRevenueWONOpty__c
                               From Campaign Where Id in: listOldParentCampaignID]) {
                c.HierarchyFullDealExpectedRevenueOpty__c = c.HierarchyFullDealExpectedRevenueOpty__c - ((mapFull.get(c.ID) != null) ? mapFull.get(c.ID) : 0.00);
                c.HierarchyThisYearExpectedRevenueOpty__c = c.HierarchyThisYearExpectedRevenueOpty__c - ((mapThis.get(c.ID) != null) ? mapThis.get(c.ID) : 0.00);
                c.HierarchyFullDealExpectedRevenueWONOpty__c = c.HierarchyFullDealExpectedRevenueWONOpty__c - ((mapFullWon.get(c.ID) != null) ? mapFullWon.get(c.ID) : 0.00);
                c.HierarchyThisYearExpectedRevenueWONOpty__c = c.HierarchyThisYearExpectedRevenueWONOpty__c - ((mapThisWon.get(c.ID) != null) ? mapThisWon.get(c.ID) : 0.00);
                listUpdateCampaign.add(c);
            }
        }

        try {
            update listUpdateCampaign;
        } catch (exception ex) {
            system.debug(' campaign trigger checkParentCampaign Error Line ' + ex.getLineNumber() + ' - ' + ex.getMessage());
        }

        system.debug('campaign trigger : checkParentCampaign end');

    }


}