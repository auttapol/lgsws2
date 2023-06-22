public virtual with sharing class FileExtensionHandler {
    @TestVisible
    private static FileExtensionHandler instance = null;
    private static String FILE_EXTENSION_WHITELIST_STRING
    {
		get {
			return (Test.isRunningTest()) ? 'csv,bmp,mp3,vi,gpg,css,doc,gif,ogg,mov,zip,rar,htm,docx,jpeg,wav,mpeg,html,dot,jpg,mpg,js,ics,png,swf,xml,tif,xsl,mdb,tiff,xslt,pdf,vsd,pps,ppsx,ppt,pptx,rtf,sxc,sxi,sxw,txt,xls,xlsx,snote' : AppConfig__c.getValues('File_Extension_Whitelist').Value__c;
		}
    }
    private static List<String> FILE_EXTENSION_WHITELIST = FILE_EXTENSION_WHITELIST_STRING.split(',');
    private static String MESSEGE_ERROR = 'This file extension is not allowed to upload.';
    
    protected FileExtensionHandler() {
    }

    public static FileExtensionHandler getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null) instance = new FileExtensionHandler();
        return instance;
    }

    public List<FeedItem> checkRestrictedFileUpload(List<FeedItem> newList) {
        System.debug('newList = ' + newList);
        Map<Id, FeedItem> contentversionIdToFeedItemMap = new Map<Id, FeedItem>();
        for(FeedItem fi : newList){
            System.debug('FeedItem Type = ' + fi.type + ' ' + fi.RelatedRecordId);
            if(fi.type == 'ContentPost') {
                contentversionIdToFeedItemMap.put(fi.RelatedRecordId, fi);
            }
        }

        for(ContentVersion cv : [SELECT Id, PathOnClient, FileExtension,FileType FROM ContentVersion where Id IN :contentversionIdToFeedItemMap.keySet()]) {
            String fileName =  cv.PathOnClient;
            System.debug('Attachment Name = ' + fileName);
            if(fileName.indexOf('.') > -1) {
                List<String> fileNameWithExtension = fileName.split('\\.');
                String fileExtension = fileNameWithExtension[fileNameWithExtension.size() - 1];
                System.debug('fileExtension = ' + fileExtension);

                if(!FILE_EXTENSION_WHITELIST.contains(fileExtension.toLowerCase())){
                    contentversionIdToFeedItemMap.get(cv.Id).addError(MESSEGE_ERROR);
                }
            }
        }

        return newList;
    }

    public List<Attachment> checkRestrictedFileUpload(List<Attachment> newList) {
        System.debug('newList = ' + newList + ' is test :' + Test.isRunningTest());
        for(Attachment at: newList){
            String fileName =  at.Name;
            
            System.debug('Attachment Name = ' + at.Name);
            if(fileName.indexOf('.') > -1) {
                List<String> fileNameWithExtension = fileName.split('\\.');
                
                String fileExtension = fileNameWithExtension[fileNameWithExtension.size() - 1];
                System.debug('fileExtension = ' + fileExtension);
                
                
                if(!FILE_EXTENSION_WHITELIST.contains(fileExtension.toLowerCase())){
                    at.addError(MESSEGE_ERROR);
                }
                
            }
        }

        return newList;
    }

    public List<ContentVersion> checkRestrictedFileUpload(List<ContentVersion> newList) {

        for(ContentVersion c: newList) {
            String fileName =  c.PathOnClient;
            System.debug('Attachment Name = ' + fileName);
            if(fileName.indexOf('.') > -1) {
                List<String> fileNameWithExtension = fileName.split('\\.');
                String fileExtension = fileNameWithExtension[fileNameWithExtension.size() - 1];
                System.debug('fileExtension = ' + fileExtension);

                if(!FILE_EXTENSION_WHITELIST.contains(fileExtension.toLowerCase())){
                    c.addError(MESSEGE_ERROR);
                }
            }
        }

        return newList;
    }
    
}