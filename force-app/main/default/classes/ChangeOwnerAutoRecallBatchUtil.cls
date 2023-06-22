public class ChangeOwnerAutoRecallBatchUtil {
    public static Map<String, Sales_Management__mdt> segmentEmpIdSet {
        get{
            if(segmentEmpIdSet == null){
                segmentEmpIdSet = new Map<String, Sales_Management__mdt>();
                for (Sales_Management__mdt salesmdt : [SELECT Id, Label, EmployeeId__c, Segment__c FROM Sales_Management__mdt]) {
                    System.debug('salesmdt : ' + salesmdt);
                    segmentEmpIdSet.put(salesmdt.Segment__c, salesmdt);
                }
            }
            return segmentEmpIdSet;
        }
        set;
    }

    public static Map<String, User> mapSMSegmentUser {
        get{
            if(mapSMSegmentUser == null){
                mapSMSegmentUser = new Map<String, User>();
                Set<String> empIdset = new Set<String>();
                for (Sales_Management__mdt mdt : segmentEmpIdSet.values()) {
                    empIdset.add(mdt.EmployeeId__c);
                }

                Map<String, User> MapuserEmpId = new Map<String, User>();

                for(User u : [SELECT Id, Name, Employee_ID__c, isActive, Zone__c FROM User WHERE Employee_ID__c IN :empIdset]){
                    MapuserEmpId.put(u.Employee_ID__c, u);
                }

                for(Sales_Management__mdt mdt : segmentEmpIdSet.values()){
                    System.debug('mdt : ' + mdt);
                    mapSMSegmentUser.put(mdt.Segment__c, MapuserEmpId.get(mdt.EmployeeId__c));
                }
            }
            System.debug('mapSMSegmentUser : ' + mapSMSegmentUser);
            return mapSMSegmentUser;
        }
        set;
    }

    public static Map<String, Approver_Profile_Escalation__mdt> mapProfileEscalateMatrix{
        get{
            if(mapProfileEscalateMatrix == null){
                mapProfileEscalateMatrix = new Map<String, Approver_Profile_Escalation__mdt> ();

                for (Approver_Profile_Escalation__mdt mdt : [SELECT Escalate_to__c, Profile_Name__c, Segment__c FROM Approver_Profile_Escalation__mdt]){
                    mapProfileEscalateMatrix.put(mdt.Profile_Name__c, mdt);
                }
            }
            return mapProfileEscalateMatrix;
        }
        set;
    }

    public static Map<Id, User> mapUser{
        get{
            if(mapUser == null){
                mapUser = new Map<Id, User> ([SELECT Id, Name, ManagerId, ProfileId, Profile.Name, Employee_ID__c, Segment__c, IsActive, Zone__c FROM User WHERE Profile.Name IN :mapProfileEscalateMatrix.keySet()]);
            }
            return mapUser;
        }
        set;
    }

    public static List<String> specialProfileToIgnore{
        get{
            if(specialProfileToIgnore == null){
                specialProfileToIgnore = new List<String>();

                specialProfileToIgnore.add('TMB BB Sales Management Profile');
                specialProfileToIgnore.add('TMB CB/MB Sales Management Profile');
                specialProfileToIgnore.add('TMB Commercial Report Specialist Profile');
                specialProfileToIgnore.add('TMB SE Regional Manager Profile');
                specialProfileToIgnore.add('TMB SE Sales Management Profile');
            }
            return specialProfileToIgnore;
        }
        set;
    }

    public static Map<Id, String> reassignApprover(Map<Id, Change_Owner_Approval_History__c> mapChangeOwnerEscalate){
        Map<Id, String> result = new Map<Id, String>();
        Map<Id, String> piwiResult = new Map<Id, String>();

        Datetime batchDate = datetime.now();

        Set<Id> userIdset = new Set<Id> ();
        
        Map<Id, ProcessInstanceWorkitem> mapChangeOwnerHisWorkitem = new Map<Id, ProcessInstanceWorkitem>();

        Map<Id, User> mapUserId = new Map<Id, User>();
        Map<Id, User> mapUserpiwi = new Map<Id, User>();
        List<ProcessInstanceWorkitem> piwiAdditionProcess = new List<ProcessInstanceWorkitem>();

        Map<Id, Change_Owner_Approval_History__c> mapUpdateChangeOwnHis = new Map<Id, Change_Owner_Approval_History__c> ();
        List<ProcessInstanceWorkitem> updatePiwlst = new List<ProcessInstanceWorkitem> ();

        for (ProcessInstanceWorkitem piwi : [SELECT Id, ActorId, Actor.Name, Actor.Profile.Name, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :mapChangeOwnerEscalate.keySet()]) {
            mapChangeOwnerHisWorkitem.put(piwi.ProcessInstance.TargetObjectId, piwi);
        }

        for (ProcessInstanceWorkitem piwi : mapChangeOwnerHisWorkitem.values()) {
            if(mapProfileEscalateMatrix.containsKey(piwi.Actor.Profile.Name)){

                System.debug(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name));
                System.debug(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c);
                System.debug(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Escalate_to__c);

                //Custbase P2 Change flow not longer reassign to salesmanagement.
                // if(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Escalate_to__c == 'Sales Management'){
                //     System.debug('SALES MANAGEMENT');
                //     if(piwi.Actor.Profile.Name == 'TMB Team Head Profile'){
                //         System.debug(mapSMSegmentUser.containsKey(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c));
                //         userIdset.add(piwi.ActorId);
                //         piwiAdditionProcess.add(piwi);
                //     }else{
                //         System.debug(mapSMSegmentUser.containsKey(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c));

                //         if(mapSMSegmentUser.containsKey(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c)){
                //             if(mapSMSegmentUser.get(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c).isActive){
                //                 mapUserpiwi.put(piwi.Id, mapSMSegmentUser.get(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c));
                //             }else{
                //                 String message = 'SalesManagement inactive';
                //                 piwiResult.put(piwi.Id, message);
                //             }
                //         }else{
                //             String message = 'FAIL : ' + System.label.ChangeOwnerMessage2;
                //             piwiResult.put(piwi.Id, message);
                //         }
                //     }
                // }else{
                    System.debug('MANAGER');
                    userIdset.add(piwi.ActorId);
                    piwiAdditionProcess.add(piwi);
                // }
            }else if(!specialProfileToIgnore.contains(piwi.Actor.Profile.Name)){
                String message = 'FAIL : '  + System.label.ChangeOwnerMessage3;
                message += '(' + piwi.Actor.Profile.Name + ')';
                piwiResult.put(piwi.Id, message);
            }
        }

        for (User u : mapSMSegmentUser.values()) {
            userIdset.add(u.Id);
        }

        System.debug('userIdset : ' + userIdset);

        mapUserId = userIdset.size() == 0 ? mapUserId : new Map<Id, User> ([SELECT Id, Name, ManagerId, ProfileId, Profile.Name, Employee_ID__c, Segment__c, IsActive, Zone__c FROM User WHERE Id IN :userIdset]);

        System.debug('mapUserpiwi : ' + mapUserpiwi);
        
        userIdset = new Set<Id>(); 
        
        for (ProcessInstanceWorkitem piwi : piwiAdditionProcess) {
            if(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Escalate_to__c == 'Manager' && mapUserId.size() > 0){
                User nextApprover = getNextApprover(mapUserId.get(piwi.ActorId));
                
                if(nextApprover != null){
                    mapUserpiwi.put(piwi.Id, nextApprover);
                }
                //Custbase P2 Change flow not longer reassign to salesmanagement.
                // else{
                //     String message = 'SalesManagement inactive';
                //     piwiResult.put(piwi.Id, message);
                // }

            }
            //Custbase P2 Change flow not longer reassign to salesmanagement.
            // else if(piwi.Actor.Profile.Name == 'TMB Team Head Profile'){
                
            //     if(mapSMSegmentUser.containsKey(mapUserId.get(piwi.ActorId).Segment__c)){
            //         if(mapSMSegmentUser.get(mapUserId.get(piwi.ActorId).Segment__c).isActive){
            //             mapUserpiwi.put(piwi.Id, mapSMSegmentUser.get(mapUserId.get(piwi.ActorId).Segment__c));
            //         }
            //         else{
            //             String message = 'SalesManagement inactive';
            //             piwiResult.put(piwi.Id, message);
            //         }
                    
            //         // userIdset.add(mapSMSegmentUser.get(mapProfileEscalateMatrix.get(piwi.Actor.Profile.Name).Segment__c).Id);
            //     }else{
            //         String message = 'FAIL : ' + System.label.ChangeOwnerMessage2;
            //         piwiResult.put(piwi.Id, message);
            //     }

            // }
        }

        System.debug('::: REASSIGN STEP :::');
        System.debug('mapUserpiwi : ' + mapUserpiwi);

        for (ProcessInstanceWorkitem piwi : mapChangeOwnerHisWorkitem.values()) {
            if(mapUserpiwi.containsKey(piwi.Id)){
                piwi.ActorId  = mapUserpiwi.get(piwi.id).Id;

                Change_Owner_Approval_History__c changeOwnHis = mapChangeOwnerEscalate.get(piwi.ProcessInstance.TargetObjectId);
                changeOwnHis.Current_Approver_Name__c = mapUserpiwi.get(piwi.Id).Name;
                changeOwnHis.Current_Approver_Emp_Id__c = mapUserpiwi.get(piwi.Id).Employee_ID__c;
                changeOwnHis.Approval_Step_Start_Wait_Time__c = batchDate;
                changeOwnHis.Pending_Approver_Team__c = mapUserpiwi.get(piwi.Id).Zone__c;
                changeOwnHis.Escalated_Flag__c = true;

                mapUpdateChangeOwnHis.put(changeOwnHis.Id, changeOwnHis);
                updatePiwlst.add(piwi);
            }else if(piwiResult.containsKey(piwi.Id)){
                result.put(piwi.ProcessInstance.TargetObjectId, piwiResult.get(piwi.Id));
            }
            // else{
            //     String message = 'FAIL : -------.';
            //     result.put(piwi.ProcessInstance.TargetObjectId, message);
            // }
        }

        if(updatePiwlst != null && updatePiwlst.size() > 0){
            List<Database.SaveResult> srList = Database.update(updatePiwlst, false);

            for (Integer i = 0 ; i < srList.size() ; i++){
                Database.SaveResult sr = srList.get(i);
                
                if (!sr.isSuccess()) {
                    String message = '';

                    for(Database.Error err : sr.getErrors()) {
                        message += ' | ' + err.getStatusCode() + ':' + err.getMessage();
                    }

                    if(mapUpdateChangeOwnHis.containsKey(updatePiwlst.get(i).ProcessInstance.TargetObjectId)){
                        mapUpdateChangeOwnHis.remove(updatePiwlst.get(i).ProcessInstance.TargetObjectId);
                    }

                    result.put(updatePiwlst.get(i).ProcessInstance.TargetObjectId, message);
                }
            }
        }

        try {
            update mapUpdateChangeOwnHis.values();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        return result;
    }

    public static User getNextApprover(User u){
        User result;
        //Custbase P2 Change flow not longer reassign to salesmanagement.
        // if(mapProfileEscalateMatrix.containsKey(u.Profile.Name) && mapProfileEscalateMatrix.get(u.Profile.Name).Escalate_to__c == 'Sales Management' && mapSMSegmentUser.containsKey(u.Segment__c) && mapSMSegmentUser.get(u.Segment__c).isActive){
        //     return mapSMSegmentUser.get(u.Segment__c);
        // }
        // else 
        if(mapUser.containsKey(u.ManagerId)){
            if(mapUser.get(u.ManagerId).isActive){
                return mapUser.get(u.ManagerId);
            }else{
                return getNextApprover(mapUser.get(u.ManagerId));
            }
        }
        //Custbase P2 Change flow not longer reassign to salesmanagement.
        // else if(mapSMSegmentUser.get(u.Segment__c).isActive){
        //     return mapSMSegmentUser.get(u.Segment__c);
        // }

        return result;
    }
}