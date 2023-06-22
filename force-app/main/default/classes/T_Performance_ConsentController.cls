public class T_Performance_ConsentController {
  
    public static String getPDF() {
        List<ContentVersion> cv = getListContentVersion('T-Performance');
        /* System.debug('cv'+cv); */
        if (cv.size()>0){
            String dataPDF = EncodingUtil.base64Encode(cv[0].VersionData);
            return  'data:application/pdf;base64,'+dataPDF;
        }
        else{
           return null;
        }
        /* System.debug('dataPdf'+dataPDF); */
        
    }
    public static List<ContentVersion> getListContentVersion(String libraryName ){
        List<ContentVersion> contentList = new List<ContentVersion>();
        List<ContentFolderItem> folderList =	[SELECT Id, IsDeleted, IsFolder, ParentContentFolderId 
                                                 FROM ContentFolderItem WHERE 
                                                 ParentContentFolderId in (SELECT RootContentFolderId FROM ContentWorkspace WHERE Name = :libraryName) 
                                                 ORDER BY LastModifiedDate DESC LIMIT 1];
        if(folderList.size()>0){

            Id folderId = folderList.get(0).ParentContentFolderId;
            
            Set<Id> contentIdInFolderList = new Set<Id>();
            map<id,ContentFolderItem> contentInFolderMap = new map<id,ContentFolderItem>([SELECT Id 
                                                            FROM ContentFolderItem 
                                                            WHERE ParentContentFolderId =:folderId
                                                            ORDER BY LastModifiedDate DESC LIMIT 1]);
            
            contentIdInFolderList.addAll(contentInFolderMap.KeySet());

            contentList = [SELECT Id, Title, VersionData, ContentDocumentId, ContentSize 
                                            FROM ContentVersion 
                                            WHERE IsLatest = TRUE 
                                            AND ContentDocumentId in :contentIdInFolderList]; 

        }
        System.debug('contenList'+contentList);
        return contentList;
	}
   
    
    
}