public class ContactTriggerHandler {
    
    static Boolean detectError = false;
    static String errorException = '';
    static String STR_INSERT = 'insert';
    static String STR_UPDATE = 'update';
    static String STR_DELETE = 'delete';
    static final String COREBANK_RECORDTYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Core bank').getRecordTypeId();
    static final String CREATE_REC_ERROR_DUP_NAME = Trigger_Msg__c.getValues('Create contact error duplicate name') == null ? 'Contact is duplicate name with existing record.' : Trigger_Msg__c.getValues('Create contact error duplicate name').Description__c;
    
    static Map<Id, Contact> contForCheckDup {
        get{
            if(contForCheckDup == null){
                contForCheckDup = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, AccountId, Account.TMB_Customer_ID_PE__c FROM Contact WHERE Contact_ID__c = null AND Recordtype.Name = 'Core bank']);
            }
            return contForCheckDup;
        }
        set;
    }
    
    public static void handlerBeforeInsert(List<Contact> contactsNew){
        conditionCreateContact(contactsNew,null,STR_INSERT);
        resizeContactPhoto(contactsNew,STR_INSERT);
    }
    
    public static void handlerBeforeUpdate(List<Contact> contactsNew){
        resizeContactPhoto(contactsNew,STR_UPDATE);
    }
    
    public static void conditionCreateContact(List<Contact> contactsNew,List<Contact> contactsOld,String eventMode){
        System.debug(':::: conditionCreateVisitReport Start ::::');
        
        List<Id> idAccountList = new List<Id>();
        List<Id> idUserList = new List<Id>();
                
        for( Contact eachCont : contactsNew ){
            if( eachCont.AccountId != null ){
                idAccountList.add(eachCont.AccountId);
            }            
            idUserList.add(eachCont.OwnerId);
        }
        
        Map<Id,Account> queryAccount = new Map<Id,Account>([ select Id,OwnerId,Owner.Segment__c
                                                            from Account 
                                                            where Id IN :idAccountList ]);
        
        List<AccountTeamMember> queryAccountTeamMember = [ select accountId,userId
                                                          from AccountTeamMember 
                                                          where accountId IN :idAccountList 
                                                          and userId IN :idUserList];
        
        Map<Id,User> queryUser = new Map<Id,User>([select Id,UserRole.Name,Segment__c from user where Id IN :idUserList]);
        
        for( Contact eachCont : contactsNew ){
            Boolean checkCreate = false;
            if(eachCont.RecordTypeId == COREBANK_RECORDTYPE){
                Id contDupName = isDuplicateName(eachCont);
                System.debug('contDupName : ' + contDupName);
                if(contDupName != null){
                    eachCont.addError(CREATE_REC_ERROR_DUP_NAME, true);
                    continue;
                }else{
                    eachCont.ID_Type_PE__c = eachCont.ID_Number_PE__c == null ? null : eachCont.ID_Number_PE__c.length() == 13 ? 'Citizen ID' : 'Passport ID';
                }
            }
            
            if( queryAccount.containsKey(eachCont.AccountId) ){                
                if( queryAccount.get(eachCont.AccountId).OwnerId == eachCont.OwnerId ){
                    checkCreate = true;
                }
                
                if(!checkCreate){
                    for(AccountTeamMember eachAccTeam : queryAccountTeamMember ){
                        if( eachCont.AccountId == eachAccTeam.AccountId && eachCont.OwnerId ==  eachAccTeam.UserId ){
                            checkCreate = true;
                            break;
                        }
                    }
                }
            }
            
            if(!checkCreate){
                
                List<Account__c> privilegeList = Account__c.getall().values();
                
                for( Account__c eachPrivilege : privilegeList ){
                    if(queryUser.get(eachCont.OwnerId).UserRole.Name == eachPrivilege.Role__c 
                       && queryAccount.get(eachCont.AccountId).Owner.Segment__c == eachPrivilege.Segment__c){
                           checkCreate = true;
                       }                    
                }                            
            }
            
            if(!checkCreate){
                if(eachCont.Completed_Survey__c == true){
                    checkCreate = true;
                }  
            }
            
            if(!checkCreate){
                eachCont.addError( Trigger_Msg__c.getValues('Permission_Create_Opportunity').Description__c  ,false);    
            }
            System.debug('::::: checkCreate : '+checkCreate+' || '+eachCont.Name+' :::::');
        }
        
        System.debug(':::: conditionCreateContact End ::::');
    }
    
    private static Id isDuplicateName(Contact newCont){
        Id result;
        System.debug(newCont);
        for(Contact cont : contForCheckDup.values()){
            if(newCont.FirstName == cont.FirstName && newCont.LastName == cont.LastName && newCont.AccountId == cont.AccountId) return cont.Id;
        }
        
        return result;
    }
    
    /*** To resize contact photo for generate Executive Summary PDF by Jittramas ***/
    public static void resizeContactPhoto(List<Contact> contactsNew,String eventMode){
        System.debug(':::: conditionCreateVisitReport Start ::::');
        String photo = null;
        String photoSrc = null;
        String photoStyle = null;
        String rawPhoto = null;
        for(Contact contactItem : contactsNew){
            Boolean checkCreate = false;
            System.debug('## contact photo original :'+ contactItem.Photo__c);
            if(contactItem.Photo__c != null){
                checkCreate = true;
                rawPhoto = contactItem.Photo__c;
                if(rawPhoto.contains('<img')){
                    List<String> listnoImgStart = rawPhoto.split('<img');
                    String sfront = listnoImgStart[0];
                    photoSrc = listnoImgStart[1].substringBetween('src="', '"');
                    List<String> listnoImgStop = listnoImgStart[1].split('/img>');
                    String sback = '';
                    if(listnoImgStop.size() > 1){
                        sback = listnoImgStop[1];
                    } 

                    String img = '<img src="' + photoSrc + '" alt="User-added image" style="height: auto;width: 200px"></img>';
                    System.debug(photoSrc);
                    System.debug(sfront);
                    System.debug(img);
                    System.debug(sback);
                    photo = sfront + img + sback;
                    System.debug(photo);
                    contactItem.Photo__c = photo;
                }
                
                // photo = contactItem.Photo__c;
                // photoSrc = photo.substringBetween('src="', '"');
                // if(photo.contains('style')){
                //     photoStyle = photo.substringBetween('style=', '>');
                //     photo = photo.replace(photoStyle, '"height: auto;width: 200px"');
                // }
                // else{
                //     photoStyle = '"height: auto;width: 200px"';
                //     photo = '<img alt="User-added image" src="'+photoSrc+'" style='+photoStyle+'></img>';
                // }
                
                // contactItem.Photo__c = photo;
            }else{
                contactItem.Photo__c = null;
                checkCreate = true;
            }
            if(!checkCreate){
                contactItem.addError('',false);
            }
        }
        
        System.debug(':::: conditionCreateVisitReport End ::::');
    }
    
    
}