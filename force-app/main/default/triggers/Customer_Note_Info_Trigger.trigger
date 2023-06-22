trigger Customer_Note_Info_Trigger on Customer_Note_Info__c (after insert, after update, before delete) {
    System.debug('::: Customer_Note_Info_Trigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true';
    Boolean RunCustomerNoteTrigger = AppConfig__c.getValues('runCustomerNoteTrigger').Value__c == 'true';
    Set<Id> setAcc = new Set<Id>();
    Map<Id, Set<Id>> accTeamMap = new Map<Id, Set<Id>>();

    if (RunTrigger && RunCustomerNoteTrigger){
        // For after Insert or Update.
        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            Map<Id,Id> noteAccTeamMap = new Map<Id,Id>();
            // Set map for note Id and custoemr Id.
            for (Customer_Note_Info__c note : Trigger.new){
                setAcc.add(note.Customer__c);
                noteAccTeamMap.put(note.Id, note.Customer__c);
            }

            // For update case need to delete all the sharing first.
            if (Trigger.isUpdate){
                Set<Id> setNoteId = noteAccTeamMap.keySet();
                string rowCause = Schema.Customer_Note_Info__Share.RowCause.Owner;
                if (setNoteId.size() > 0){
                    list<Customer_Note_Info__Share> listNoteShrToDel = [SELECT Id From Customer_Note_Info__Share Where ParentId IN: setNoteId And RowCause !=: rowCause];
                    // Delete all the current sharing
                    delete listNoteShrToDel;
                }
            }

            // Get list of account team member.
            list<AccountTeamMember> listAccMember = [SELECT AccountId, UserId From AccountTeamMember Where AccountId IN: setAcc];
            for (AccountTeamMember accM : listAccMember){
                if (accTeamMap.containsKey(accM.AccountId)){
                    // list<Id> userlist = accTeamMap.get(accM.AccountId);
                    // userlist.add(accM.UserId);
                    accTeamMap.get(accM.AccountId).add(accM.UserId);
                }
                else{
                    Set<Id> setUserId = new Set<Id>();
                    setUserId.add(accM.UserId);
                    accTeamMap.put(accM.AccountId, setUserId);
                }
            }
            // Add for Owner Id as well.
            list<Account> listAcc = [SELECT Id, OwnerId From Account Where Id IN: setAcc];
            for (Account acc : listAcc){
                if (accTeamMap.containsKey(acc.Id)){
                    // list<Id> userlist = accTeamMap.get(accM.AccountId);
                    // userlist.add(accM.UserId);
                    accTeamMap.get(acc.Id).add(acc.OwnerId);
                }
                else{
                    Set<Id> setUserId = new Set<Id>();
                    setUserId.add(acc.OwnerId);
                    accTeamMap.put(acc.Id, setUserId);
                }
            }

            // Assign Job Share for every account team member as Read permission.
            list<Customer_Note_Info__Share> listNoteShare = new list<Customer_Note_Info__Share>();
            if (noteAccTeamMap.size() != 0){
                for (Id noteId : noteAccTeamMap.keySet()){
                    if (accTeamMap.size() != 0){
                        Id aId = noteAccTeamMap.get(noteId);
                        if (accTeamMap.containsKey(aId)){
                            for (Id uId : accTeamMap.get(aId)){
                                Customer_Note_Info__Share noteShr  = new Customer_Note_Info__Share();
                                noteShr.ParentId = noteId;
                                noteShr.UserOrGroupId = uId;
                                noteShr.AccessLevel = 'Read';
                                noteShr.RowCause = Schema.Customer_Note_Info__Share.RowCause.Manual;
                                listNoteShare.add(noteShr);
                            }
                        }
                    }
                }
            }

            insert listNoteShare;
        }

        // For before delete.
        if (Trigger.isBefore && Trigger.isDelete){
            Map<Id,Id> noteAccTeamMap = new Map<Id,Id>();
            // Set map for note Id and custoemr Id.
            for (Customer_Note_Info__c note : Trigger.old){
                setAcc.add(note.Customer__c);
                noteAccTeamMap.put(note.Id, note.Customer__c);
            }

            Set<Id> setNoteId = noteAccTeamMap.keySet();
            if (setNoteId.size() > 0){
                string rowCause = Schema.Customer_Note_Info__Share.RowCause.Owner;
                list<Customer_Note_Info__Share> listNoteShrToDel = [SELECT Id From Customer_Note_Info__Share Where ParentId IN: setNoteId And RowCause !=: rowCause];
                // Delete all the current sharing
                delete listNoteShrToDel;
            }
        }
    }

    System.debug('::: Customer_Note_Info_Trigger End ::::');
}