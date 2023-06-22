trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, before delete) {
    System.debug('::: AccountTeamMemberTrigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true';
    Boolean RunCustomerNoteTrigger = AppConfig__c.getValues('runCustomerNoteTrigger').Value__c == 'true';

    if (RunTrigger && RunCustomerNoteTrigger){
        // For after Insert.
        if (Trigger.isAfter && Trigger.isInsert){
            Set<Id> setAcc = new Set<Id>();
            Map<Id, Set<Id>> noteMap = new Map<Id, Set<Id>>();
            Map<Id,Id> custAccTeamMap = new Map<Id,Id>();
            // Set map for account team Id and custoemr Id.
            for (AccountTeamMember accteam : Trigger.new){
                setAcc.add(accteam.AccountId);
                custAccTeamMap.put(accteam.UserId, accteam.AccountId);
            }

            // Get list of note.
            list<Customer_Note_Info__c> listCustNote = [SELECT Id, Customer__c From Customer_Note_Info__c Where Customer__c IN: setAcc];
            for (Customer_Note_Info__c note : listCustNote){
                if (noteMap.containsKey(note.Customer__c)){
                    noteMap.get(note.Customer__c).add(note.Id);
                }
                else{
                    Set<Id> setNoteId = new Set<Id>();
                    setNoteId.add(note.Id);
                    noteMap.put(note.Customer__c, setNoteId);
                }
            }

            // Assign Job Share for every account team member as Read permission.
            list<Customer_Note_Info__Share> listNoteShare = new list<Customer_Note_Info__Share>();
            if (custAccTeamMap.size() != 0){
                for (Id accTeamId : custAccTeamMap.keySet()){
                    if (noteMap.size() != 0){
                        Id aId = custAccTeamMap.get(accTeamId);
                        if (noteMap.containsKey(aId)){
                            for (Id noteId : noteMap.get(aId)){
                                Customer_Note_Info__Share noteShr  = new Customer_Note_Info__Share();
                                noteShr.ParentId = noteId;
                                noteShr.UserOrGroupId = accTeamId;
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

        // For Before Delete.
        if (Trigger.isBefore && Trigger.isDelete){
            Map<Id,Id> custAccTeamMap = new Map<Id,Id>();
            Set<Id> setAcc = new Set<Id>();
            Map<Id, Set<Id>> noteMap = new Map<Id, Set<Id>>();
            list<Customer_Note_Info__Share> noteShrToDelete = new list<Customer_Note_Info__Share>();
            // Set map for account team Id and custoemr Id.
            for (AccountTeamMember accteam : Trigger.old){
                setAcc.add(accteam.AccountId);
                custAccTeamMap.put(accteam.UserId, accteam.AccountId);
            }

            // Get list of note.
            list<Customer_Note_Info__c> listCustNote = [SELECT Id, Customer__c From Customer_Note_Info__c Where Customer__c IN: setAcc];
            for (Customer_Note_Info__c note : listCustNote){
                if (noteMap.containsKey(note.Customer__c)){
                    noteMap.get(note.Customer__c).add(note.Id);
                }
                else{
                    Set<Id> setNoteId = new Set<Id>();
                    setNoteId.add(note.Id);
                    noteMap.put(note.Customer__c, setNoteId);
                }
            }

            // Get list of note sharing to delete.
            list<Customer_Note_Info__Share> listCustNoteShr = [SELECT Id, ParentId, UserOrGroupId From Customer_Note_Info__Share Where ParentId IN: listCustNote];
            for (Customer_Note_Info__Share noteShr : listCustNoteShr){
                if (custAccTeamMap.containsKey(noteShr.UserOrGroupId)
                    && noteMap.containsKey(custAccTeamMap.get(noteShr.UserOrGroupId))
                ){
                    noteShrToDelete.add(noteShr);
                }
            }

            delete noteShrToDelete;
        }
    }

    System.debug('::: AccountTeamMemberTrigger End ::::');
}