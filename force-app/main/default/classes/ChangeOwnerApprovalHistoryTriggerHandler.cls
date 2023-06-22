public class ChangeOwnerApprovalHistoryTriggerHandler {
    public static void handleAfterUpdate(List<Change_Owner_Approval_History__c> listNew, List<Change_Owner_Approval_History__c> listOld){
        System.debug('handleAfterUpdate ::::');
        Map<String, Recordtype> mapRecordtypeName = new Map<String, Recordtype> ();

        for (Recordtype rt : [SELECT id, DeveloperName FROM recordType WHERE SobjectType = 'Change_Owner_Approval_History__c']) {
            mapRecordtypeName.put(rt.DeveloperName, rt);
        }

        Map<Id, Change_Owner_Approval_History__c> mapOld = new Map<Id, Change_Owner_Approval_History__c>(listOld);
        Map<Id, Change_Owner_Approval_History__c> mapNew = new Map<Id, Change_Owner_Approval_History__c>(listNew);

        Map<Id, Change_Owner_Approval_History__c> mapAcctChangeOwnerHis = new Map<Id, Change_Owner_Approval_History__c>();

        List<Change_Owner_Approval_History__c> approvalHisAddAccTeamlst = new List<Change_Owner_Approval_History__c> ();

        Map<Id, Change_Owner_Approval_History__c> mapAcctChangeSegment = new Map<Id, Change_Owner_Approval_History__c>();
        Map<Id, String> updateApprovalHistoryResult = new Map<Id, String>();
        
        for(Change_Owner_Approval_History__c changeOwnerAppHis : listNew){
            if(changeOwnerAppHis.Change_Owner_Approval_Status__c == 'Final Approved' && changeOwnerAppHis.Change_Owner_Approval_Status__c != mapOld.get(changeOwnerAppHis.Id).Change_Owner_Approval_Status__c){
                if(changeOwnerAppHis.RecordTypeId == mapRecordtypeName.get('Change_Owner_Existing_Customer').id){
                    System.debug('Change_Owner_Existing_Customer :::');

                    if(changeOwnerAppHis.Change_Owner_Cross_Segment_flag__c == false && changeOwnerAppHis.Change_to_owner__c != null){
                        mapAcctChangeOwnerHis.put(changeOwnerAppHis.Account__c, changeOwnerAppHis);
                    }

                }else if(changeOwnerAppHis.RecordTypeId == mapRecordtypeName.get('Change_Owner_Qualified_Prospect').id){
                    System.debug('Change_Owner_Qualified_Prospect :::');

                    if(changeOwnerAppHis.Change_to_owner__c != null){
                        mapAcctChangeOwnerHis.put(changeOwnerAppHis.Account__c, changeOwnerAppHis);
                    }
                    
                }else if(changeOwnerAppHis.RecordTypeId == mapRecordtypeName.get('Add_Account_Team').id){
                    System.debug('Add_Account_Team :::');

                    Boolean criteria1 = changeOwnerAppHis.Account__c != null;
                    Boolean criteria2 = changeOwnerAppHis.Change_to_owner__c != null;
                    Boolean criteria3 = changeOwnerAppHis.Team_Role__c != null;
                    Boolean criteria4 = changeOwnerAppHis.Account_Access__c != null;
                    Boolean criteria5 = changeOwnerAppHis.Opportunity_Access__c != null;
                    Boolean criteria6 = changeOwnerAppHis.Case_Access__c != null;

                    if(criteria1 && criteria2 && criteria3 && criteria4 && criteria5 && criteria6){
                        System.debug('add Add_Account_Team :::');
                        approvalHisAddAccTeamlst.add(changeOwnerAppHis);
                    }
                }else if(changeOwnerAppHis.RecordTypeId == mapRecordtypeName.get('Change_Segment').id){
                    System.debug('Change_Segment :::');
                    mapAcctChangeSegment.put(changeOwnerAppHis.Account__c, changeOwnerAppHis);
                }
            }
        }

        if(mapAcctChangeOwnerHis.size() > 0){
            System.debug('mapAcctChangeOwnerHis.size() > 0');
            updateApprovalHistoryResult.putAll(updateAccountOwner(mapAcctChangeOwnerHis));
            
        }

        if(approvalHisAddAccTeamlst.size() > 0){
            System.debug('approvalHisAddAccTeamlst.size() > 0');
            updateApprovalHistoryResult.putAll(insertAccountTeamMember(approvalHisAddAccTeamlst));
        }

        if(mapAcctChangeSegment.size() > 0){
            System.debug('mapAcctChangeSegment.size() > 0');
            updateApprovalHistoryResult.putAll(updateAccountSegment(mapAcctChangeSegment));
        }


        if(updateApprovalHistoryResult != null && updateApprovalHistoryResult.size() > 0){
            List<Change_Owner_Approval_History__c> changeOwnerHislst = [SELECT Id, Change_Owner_Remark__c FROM Change_Owner_Approval_History__c WHERE Id IN :updateApprovalHistoryResult.keySet()];
            
            for(Change_Owner_Approval_History__c changeOwnerAppHis : changeOwnerHislst){
                changeOwnerAppHis.Change_Owner_Remark__c = updateApprovalHistoryResult.get(changeOwnerAppHis.id);
            }

            if(changeOwnerHislst != null && changeOwnerHislst.size() > 0){
                update changeOwnerHislst;
            }
        }
    }

    public static Map<Id, String> insertAccountTeamMember(List<Change_Owner_Approval_History__c> approvalHisAddAccTeamlst){
        System.debug('insertAccountTeamMember :::');
        List<AccountTeamMember> insertAcctTeamlst = new List<AccountTeamMember>();
        Map<Id, String> updateOwnerResult = new Map<Id, String>();
        Map<String, Change_Owner_Approval_History__c> mapAcctTeamKeyApprovalHist = new Map <String, Change_Owner_Approval_History__c>();

        for(Change_Owner_Approval_History__c changeOwnerHistory : approvalHisAddAccTeamlst){
            AccountTeamMember newAccountTeam = new AccountTeamMember(
                AccountId = changeOwnerHistory.Account__c,
                UserId = changeOwnerHistory.Change_to_owner__c,
                TeamMemberRole = changeOwnerHistory.Team_Role__c ,

                AccountAccessLevel = changeOwnerHistory.Account_Access__c,
                OpportunityAccessLevel = changeOwnerHistory.Opportunity_Access__c,
                CaseAccessLevel = changeOwnerHistory.Case_Access__c
            );

            insertAcctTeamlst.add(newAccountTeam);
            
            String key = changeOwnerHistory.Account__c + '' + changeOwnerHistory.Change_to_owner__c;
            mapAcctTeamKeyApprovalHist.put(key, changeOwnerHistory);
        }
        

        if(insertAcctTeamlst.size() > 0){
            List<Database.SaveResult> srList = Database.insert(insertAcctTeamlst, false);

            for (Integer i = 0 ; i < srList.size() ; i++){
                Database.SaveResult sr = srList.get(i);
                
                if (!sr.isSuccess()) {
                    // String message = 'Mr.Tay error message : Can not add accountTeamMember | ';
                    String message = 'Can not add Account Team due to requester is inactive.';

                    for(Database.Error err : sr.getErrors()) {
                        // message += err.getStatusCode() + ':' + err.getMessage();
                    }
                    String key = insertAcctTeamlst.get(i).AccountId + '' + insertAcctTeamlst.get(i).UserId;
                    updateOwnerResult.put(mapAcctTeamKeyApprovalHist.get(key).Id, message);
                }
            }
        }

        return updateOwnerResult;
    }

    public static Map<Id, String> updateAccountOwner(Map<Id, Change_Owner_Approval_History__c> mapAcctChangeOwnerHis){
        System.debug('updateAccountOwner::::');
        Set<id> acctIdSet = mapAcctChangeOwnerHis.keySet();
        Map<Id, String> updateOwnerResult = new Map<Id, String>();
        List<Account> acctLst = [SELECT Id, OwnerId FROM Account WHERE Id IN :acctIdSet];

        if(acctLst.size() > 0){
            for(Account acct : acctLst){
                acct.OwnerId = mapAcctChangeOwnerHis.get(acct.Id).Change_to_owner__c;
                acct.Change_Owner_Reason__c = mapAcctChangeOwnerHis.get(acct.Id).Change_Owner_Remark__c;
            }

            if(acctLst != null && acctLst.size() > 0){
                List<Database.SaveResult> srList = Database.update(acctLst, false);

                for (Integer i = 0 ; i < srList.size() ; i++){
                    Database.SaveResult sr = srList.get(i);
                    
                    if (!sr.isSuccess()) {
                        String message = 'Can not Change Owner due to Requester is inactive.';

                        for(Database.Error err : sr.getErrors()) {
                            // message += err.getStatusCode() + ':' + err.getMessage();
                        }

                        // message += ' | ';

                        updateOwnerResult.put(mapAcctChangeOwnerHis.get(acctLst.get(i).Id).Id, message);
                    }
                }
            }
        }
        return updateOwnerResult;
    }

    public static Map<Id, String> updateAccountSegment(Map<Id, Change_Owner_Approval_History__c> mapAcctChangeSegmentHis){
        System.debug('updateAccountSegment::::');
        Set<id> acctIdSet = mapAcctChangeSegmentHis.keySet();
        Map<Id, String> updateSegmentResult = new Map<Id, String>();
        List<Account> acctLst = [SELECT Id, Core_Banking_Suggested_Segment__c FROM Account WHERE Id IN :acctIdSet];
        if(acctLst.size() > 0){
            for(Account acct : acctLst){
                acct.Change_to_be_segment__c = mapAcctChangeSegmentHis.get(acct.Id).To_Be_New_Segment__c;
                acct.Change_Segment_Reason__c = mapAcctChangeSegmentHis.get(acct.Id).Change_Owner_Remark__c;
            }

            if(acctLst != null && acctLst.size() > 0){
                List<Database.SaveResult> srList = Database.update(acctLst, false);

                for (Integer i = 0 ; i < srList.size() ; i++){
                    Database.SaveResult sr = srList.get(i);
                    
                    if (!sr.isSuccess()) {
                        String message = 'Can not Change Segment due to Requester is inactive.';

                        for(Database.Error err : sr.getErrors()) {
                            // message += err.getStatusCode() + ':' + err.getMessage();
                        }

                        // message += ' | ';

                        updateSegmentResult.put(mapAcctChangeSegmentHis.get(acctLst.get(i).Id).Id, message);
                    }
                }
            }
        }
        return updateSegmentResult;
    }
}