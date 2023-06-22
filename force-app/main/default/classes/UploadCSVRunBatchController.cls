public with sharing class UploadCSVRunBatchController {
    
    @AuraEnabled
    public static void uploadFile (String CSV, String objectName){
        System.debug('object: '+ objectName);
        // System.debug('Csv: '+ CSV);
        list<String> switchCallIDList = new List<String>();
        list<String> row = new List<String>();
        integer selectColumn;
        row = csv.split('\r\n');
        for (integer i = 0; i < row.Size(); i++) {
            //get Header
            if(i==0){
                List<String> header = new List<String>();
                header = row[i].split(',');
                for(Integer j = 0; j< header.size(); j++){
                    if(header[j] == 'Switch Call Id'){
                        selectColumn = j;
                    }
                }

            }
            else{
                List<String> listText = new List<String>();
                listText = row[i].split(',');
                switchCallIDList.add(listText[selectColumn]);
            }
        }
        System.debug('switchCallIDList: '+ switchCallIDList);
        
        List<String> listErrorDasQuery = new List<String>();
        List<String> listErrorImport = new List<String>();
        //Query Voice_Tagging__c
        List<Voice_Tagging__c> listVoice = [SELECT Id, Name, Audio_Channel_Num__c, Audio_End_Time__c, Audio_Module_Num__c, Audio_Start_Time__c, Call_Log_ID__c,
        Channel__c, Error_Message__c, Import_Datetime__c, Import_Result__c, Import_Type__c, Private_Data__c, Transaction_Group_Id__c, Unique_Id__c, Verint_Call_ID__c
        FROM Voice_Tagging__c 
        WHERE Call_Log_ID__c in :switchCallIDList];
        System.debug('listVoice: '+ listVoice);
        for(Voice_Tagging__c v : listVoice){
            if(v.Private_Data__c == null){
                listErrorDasQuery.add(v.Call_Log_ID__c);
            }
            else if(v.Private_Data__c != null && v.Import_Result__c == false){
                listErrorImport.add(v.Call_Log_ID__c);
            }
        }
        List<Voice_Tagging__c> deletevoice = [SELECT Id FROM Voice_Tagging__c WHERE Call_Log_ID__c in :listErrorDasQuery];
        delete deletevoice;
        System.debug('listErrorDasQuery: '+ listErrorDasQuery);
        System.debug('listErrorImport: '+ listErrorImport);
        if(listErrorDasQuery.size() > 0){
            if(objectName == 'Case'){
                List<Case> listCase = [SELECT Id, Call_Log_ID__c, Owner_Employee_ID__c, CaseNumber, Category__c,
                Sub_Category__c, Product_Category__c, Issue__c, LastModifiedDate, Created_Email__c, Created_ID__c 
                FROM Case 
                WHERE Call_Log_ID__c IN :listErrorDasQuery
                ORDER BY CreatedDate ASC];

                System.debug('listCaseSize: '+ listCase.size() +' listCase: '+ listCase);
                //RunBatch
                TagCaseBatch tcb = new TagCaseBatch(listCase);
                Database.executeBatch(tcb);
            }
            // if(objectName == 'Campaign Member'){
            //     List<String> listCampaignID = new List<String>();
            //     List<Task> listTask = [SELECT Id, Call_Log_ID__c, Related_Object__c, LastModifiedDate FROM Task WHERE Call_Log_ID__c in :listErrorDasQuery];
            //     for(Task t : listTask){
            //         listCampaignID.add(t.Related_Object__c);
            //     }

            //     System.debug('listTask: '+ listTask);
            //     System.debug('listCampaignID: '+ listCampaignID);
            //     List<CampaignMember> campaignList = [SELECT Id, RTL_Web_Unique_ID__c, RTL_Marketing_Code__c,
            //     RTL_Campaign_Product_1__r.Name, RTL_OfferResult_Product_1__c, RTL_Reason_1__c,
            //     RTL_Campaign_Product_2__r.Name, RTL_OfferResult_Product_2__c, RTL_Reason_2__c,
            //     RTL_Campaign_Product_3__r.Name, RTL_OfferResult_Product_3__c, RTL_Reason_3__c,
            //     RTL_Campaign_Product_4__r.Name, RTL_OfferResult_Product_4__c, RTL_Reason_4__c
            //     FROM CampaignMember
            //     WHERE Id IN :listCampaignID 
            //     ORDER BY CreatedDate ASC];

            //     System.debug('campaignList: '+ campaignList);
            //     TagBODBatch tbb = new TagBODBatch(campaignList);
            //     Database.executeBatch(tbb);
            // }
            // if(objectName == 'Lead'){
            //     List<String> listLeadID = new List<String>();
            //     List<Task> listTask = [SELECT Id, Call_Log_ID__c, Related_Object__c, LastModifiedDate FROM Task WHERE Call_Log_ID__c in :listErrorDasQuery];
            //     for(Task t : listTask){
            //         listLeadID.add(t.Related_Object__c);
            //     }

            //     System.debug('listTask: '+ listTask);
            //     System.debug('listLeadID: '+ listLeadID);

            //     List<Lead> listLead = [SELECT Id, Status,
            //     (SELECT Id, Name, COM_Offer_Result__c, COM_Unqualified_Reason__c FROM Product_Interest__r)
            //     FROM Lead 
            //     WHERE Id IN  :listLeadID 
            //     AND Recordtype.Name = 'Commercial Lead' 
            //     ORDER BY CreatedDate ASC];
            //     System.debug('listLead: '+ listLead);

            //     TagLeadBatch tlb = new TagLeadBatch(listLead);
            //     Database.executeBatch(tlb);
            // }
        }

        if(listErrorImport.size() > 0){
            System.debug('in if listErrorImport: '+ listErrorImport);
            TagAudioDataBatch tag = new TagAudioDataBatch(listErrorImport);
            Database.executeBatch(tag);
        }
    }
}