trigger AttachmentTrigger on Attachment (before insert) {
    if(Trigger.isBefore && Trigger.isInsert) {
        FileExtensionHandler.getInstance().checkRestrictedFileUpload(Trigger.New);
    }
}