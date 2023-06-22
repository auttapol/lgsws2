@isTest
private class FileExtensionHandlerTest {

    @isTest
    private static void TestContentVersion(){

        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
                
        ContentVersion contentVersion_1 = new ContentVersion (
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion_1;
    }

    @isTest
    private static void TestFeedItem(){

        FeedItem item = new FeedItem(
            parentId = UserInfo.getUserId(), 
            createdById = UserInfo.getUserId(), 
            body = '<p><b>FeedItem</b> supports <i>rich text</i> but not @ mentions:</p> @[0F9j00000008TNc] @0F9j00000008TNc {0F9j00000008TNc} @{0F9j00000008TNc}',
            isRichText = true
        );

        insert item;
    }

    @isTest
    private static void TestAttachment(){
        Lead lead = new Lead();
        lead.RTL_Mobile_Number__c = '0987654321';
        lead.RTL_ID_Type__c = 'Other ID'; 
        lead.RTL_Citizen_Id__c = '123456789';
        lead.LastName = 'TT01';
        lead.Company = 'T Company';
        lead.RecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
        insert lead;


        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
        Attachment attachment = new Attachment();
        attachment.Body = bodyBlob;
        attachment.Name = String.valueOf('test.txt');
        attachment.ParentId = lead.id;
        insert attachment;
    }
}