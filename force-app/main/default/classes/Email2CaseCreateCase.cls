public class Email2CaseCreateCase {
    
    public Email2CaseCreateCase(List<EmailMessage> newList){
        
        System.debug('Email2CaseCreateCase Start');
        try{                
            createCase(newList);
        }catch(Exception e){
            System.debug('error : '+e.getMessage());
        }
        System.debug('Email2CaseCreateCase End');
    }
    
    public void createCase(List<EmailMessage> newList){
        
        Id rbgRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Retail Service').getRecordTypeId();
        Id wbgRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('WBG Service').getRecordTypeId();

 
        List<EmailMessage> emailLogList = [ select id,ParentId, ActivityId, CreatedById, TextBody, HtmlBody, Headers, Subject, FromName, 
                                           FromAddress, ToAddress, CcAddress, BccAddress, Incoming,
                                           HasAttachment, Status, MessageDate, IsExternallyVisible,                    
                                            Parent.Status,Parent.OwnerId,Parent.Subject,Parent.PTA_Segment__c,Parent.Category__c,Parent.Sub_Category__c,Parent.Product_Category__c,
                                           Parent.Service_Type_Matrix_Code__c,Parent.Problem_Type__c,Parent.Journey__c,Parent.Email_Topic__c,Parent.Origin, Parent.RecordType.Name
                                           from emailMessage where id IN :newList ];   
                
        List<Skill_Master__c> smList = [SELECT Id, Name, Topic__c, Skill__c  , Source__c, Segment__c, Service_Level1__c, Service_Level2__c, Service_Level3__c
                           ,Validate_Code__c,Problem_Type__c,Journey__c,Assign_to_Queue__c 
                           FROM Skill_Master__c];
        
        Map<String,Skill_Master__c> skillMasterMap = new Map<String,Skill_Master__c>();
        List<String> queueList = new List<String>();      
        List<String> subjectKeyword = new List<String>();
        System.debug('Skill Master list size : '+smList.size());
        if(smList.size() > 0)
        {
            for(Skill_Master__c skill : smList)
            {
                skillMasterMap.put(skill.Topic__c+skill.Source__c,skill);
                queueList.add(skill.Assign_to_Queue__c);
                subjectKeyword.add(skill.Topic__c);
            }
        }             
        System.debug('Subject Keyword : '+subjectKeyword);
        List<Group> queryGroup =  [ select Id,Name from Group where Type = 'Queue' AND Name IN: queueList];
        Map<String,Group> mapGroup = new Map<String,Group>();
        for( Group each : queryGroup ){
            mapGroup.put(each.Name,each);
        }

        List<Case> insertCaseList = new List<Case>();
        List<EmailMessage> insertEmailList = new List<EmailMessage>();       
        Map<String,Case> newCaseMap = new Map<String,Case>();
        String caseSubject = '';
        String caseOrigin = '';
        // Get Case Subject and Origin 
        for( EmailMessage each : emailLogList ){
          
            if( each.Parent.Status == 'Completed'){

                for(String s : subjectKeyword)
                {
                    System.debug('s:'+s);
                    if((each.Parent.Subject).containsIgnoreCase(s))
                    {
                        caseSubject = s;
                        caseOrigin = each.Parent.Origin;
                        break;
                    }
                }
            }
        }

        if(skillMasterMap.containsKey(caseSubject+caseOrigin))
        {
            for( EmailMessage each : emailLogList ){
                if( each.Parent.Status == 'Completed' && each.Incoming){
                    Case objCase = new Case();
                    objCase.Status = 'New';
                    objCase.Origin = each.Parent.Origin;
                    objCase.SuppliedEmail = each.FromAddress;
                    objCase.Description = each.TextBody;
                    objCase.Subject = skillMasterMap.get(caseSubject+caseOrigin).Topic__c; //each.Parent.Subject;
                    objCase.ParentId = each.ParentId;
                    objCase.Email_Status__c = 'New';
                    objCase.PTA_Segment__c = each.Parent.PTA_Segment__c;
                    objCase.Category__c = each.Parent.Category__c;
                    objCase.Sub_Category__c = each.Parent.Sub_Category__c;
                    objCase.Product_Category__c = each.Parent.Product_Category__c;
                    objCase.Service_Type_Matrix_Code__c = each.Parent.Service_Type_Matrix_Code__c;
                    objCase.Problem_Type__c = each.Parent.Problem_Type__c;
                    objCase.Journey__c = each.Parent.Journey__c;
                    objCase.Email_Topic__c = each.Parent.Email_Topic__c;
                    objCase.Is_Cloned__c = true;
                    if(each.Parent.RecordType.Name.contains('Retail Service')){
                        objCase.RecordTypeId = rbgRecordTypeId;
                    }else if(each.Parent.RecordType.Name.contains('WBG Service')){
                        objCase.RecordTypeId = wbgRecordTypeId;
                    }
                    

                    if( mapGroup.containsKey(skillMasterMap.get(caseSubject+caseOrigin).Assign_to_Queue__c) )
                    {
                        objCase.OwnerId = mapGroup.get(skillMasterMap.get(caseSubject+caseOrigin).Assign_to_Queue__c).Id;
                    }
                    insertCaseList.add(objCase);
                    
                    newCaseMap.put(objCase.ParentId,objCase);
                    
                    emailMessage mailObj;
                    mailObj = each.clone(false,true);
                    //mailObj.ParentId = objCase.Id;
                    mailObj.Status = '0'; 
                    insertEmailList.add(mailObj);              

                }
            }
        }
        else 
        {
            for( EmailMessage each : emailLogList ){
                if( each.Parent.Status == 'Completed' && each.Incoming){
                    Case objCase = new Case();
                    objCase.Status = 'New';
                    objCase.Origin = each.Parent.Origin;
                    objCase.SuppliedEmail = each.FromAddress;
                    objCase.Description = each.TextBody;
                    objCase.Subject = each.Parent.Subject;
                    objCase.ParentId = each.ParentId;
                    objCase.Email_Status__c = 'New';
                    objCase.PTA_Segment__c = each.Parent.PTA_Segment__c;
                    objCase.Category__c = each.Parent.Category__c;
                    objCase.Sub_Category__c = each.Parent.Sub_Category__c;
                    objCase.Product_Category__c = each.Parent.Product_Category__c;
                    objCase.Service_Type_Matrix_Code__c = each.Parent.Service_Type_Matrix_Code__c;
                    objCase.Problem_Type__c = each.Parent.Problem_Type__c;
                    objCase.Journey__c = each.Parent.Journey__c;
                    objCase.Email_Topic__c = each.Parent.Email_Topic__c;
                    objCase.Is_Cloned__c = true;
                    if(each.Parent.RecordType.Name.contains('Retail Service')){
                        objCase.RecordTypeId = rbgRecordTypeId;
                    }else if(each.Parent.RecordType.Name.contains('WBG Service')){
                        objCase.RecordTypeId = wbgRecordTypeId;
                    }
                    
                    objCase.OwnerId = mapGroup.get('Email - TMB').Id;

                    insertCaseList.add(objCase);
                    
                    newCaseMap.put(objCase.ParentId,objCase);
                    
                    emailMessage mailObj;
                    mailObj = each.clone(false,true);
                    //mailObj.ParentId = objCase.Id;
                    mailObj.Status = '0'; 
                    insertEmailList.add(mailObj);              

                }
            }
        }

        if(insertCaseList.size() > 0)
        {
            insert insertCaseList;

        }
        
        if(insertEmailList.size() > 0)
        {   
            if(insertCaseList.size() > 0)
            {
                for(Case caseObj : insertCaseList)
                {
                    for(EmailMessage em : insertEmailList)
                    {
                        if(newCaseMap.get(caseObj.ParentId).ParentId == caseObj.ParentId )
                        {
                            em.ParentId = caseObj.Id;
                        }                   
                    }
                }
            }
            insert insertEmailList;
            
        }
        
    }

}