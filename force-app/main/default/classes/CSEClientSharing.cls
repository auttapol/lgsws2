public without sharing class CSEClientSharing {
    public CSEClientSharing() {
        
    }
    public static boolean manualShareRead(List<Id> recordId, Id userOrGroupId){
        
        List<E_Client_Suitability__Share> eclientShrList  = new List<E_Client_Suitability__Share> ();
        for(Id recId : recordId)
        {
            // deleteSharingEclient(recId);
            // Create new sharing object for the custom object Job.
            E_Client_Suitability__Share eclientShr  = new E_Client_Suitability__Share ();
            
            // Set the ID of record being shared.
            eclientShr.ParentId = recId;
            
            // Set the ID of user or group being granted access.x
            eclientShr.UserOrGroupId = userOrGroupId;
            
            // Set the access level.
            eclientShr.AccessLevel = 'Read';
            
            // Set rowCause to 'manual' for manual sharing.
            // This line can be omitted as 'manual' is the default value for sharing objects.
            eclientShr.RowCause = Schema.E_Client_Suitability__Share.RowCause.RM_Privilege__c;
            
            system.System.debug('eclientShr: ' + eclientShr);	
            
            eclientShrList.add(eclientShr);
        }
        
        // Insert the sharing record and capture the save result. 
        // The false parameter allows for partial processing if multiple records passed 
        // into the operation.
        if(eclientShrList.size() > 0)
        {
            Database.SaveResult[] sr = Database.insert(eclientShrList,false);
            // Process the save results.
            for (Integer i = 0; i < sr.size(); i++) 
            {	
                if(sr[i].isSuccess())
                {
                    // Indicates success
                    system.System.debug('save result success');
                    return true;
                }
                else 
                {
                    // Get first save result error.
                    Database.Error err = sr[i].getErrors()[0];
                    
                    System.debug('error: '+err.getMessage());
                    // Check if the error is related to trival access level.
                    // Access level must be more permissive than the object's default.
                    // These sharing records are not required and thus an insert exception is acceptable. 
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                       err.getMessage().contains('AccessLevel')){
                           // Indicates success.
                           return true;
                       }
                    else{
                        // Indicates failure.
                        return false;
                    }
                }
            }
        }
        return true;
    }
    
    public static void deleteSharingEclient(List<Id> recordId)
    {  
        try 
        {
            // Locate all existing sharing records for the Job records in the batch.
            // Only records using an Apex sharing reason for this app should be returned. 
            List<E_Client_Suitability__Share> oldEc = [SELECT Id FROM E_Client_Suitability__Share 
                                                       WHERE ParentId IN:recordId AND RowCause =: Schema.E_Client_Suitability__Share.RowCause.RM_Privilege__c
                                                      ]; 
            Database.DeleteResult[] dr = Database.delete(oldEc, false);
            // Iterate through each returned result
            for (Integer i = 0; i < dr.size(); i++) 
            {	
                if(dr[i].isSuccess())
                {
                    // Indicates success
                    System.debug('Delete result success');
                }
                else 
                {
                    // Get first save result error.
                    Database.Error err = dr[i].getErrors()[0];
                    
                    // Check if the error is related to trival access level.
                    // Access level must be more permissive than the object's default.
                    // These sharing records are not required and thus an insert exception is acceptable. 
                    if(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  
                       err.getMessage().contains('AccessLevel')){
                           // Indicates success.
                           System.debug('success');
                       }
                    else{
                        // Indicates failure.
                        System.debug('fail');
                    }
                }
            }
        } 
        catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } 
        
    }
}