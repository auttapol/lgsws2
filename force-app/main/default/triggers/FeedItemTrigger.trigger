trigger FeedItemTrigger on FeedItem (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {
        FileExtensionHandler.getInstance().checkRestrictedFileUpload(Trigger.New);
    }
}