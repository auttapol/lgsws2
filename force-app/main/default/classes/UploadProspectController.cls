public with sharing class UploadProspectController {   
    public String ValidDateTime{get;set;}  
    public UploadProspectController()
    {                  
        ValidDateTime =DateTime.now().addMinutes(60).format('yyyy-MM-dd HH:mm:ss Z');
    }
    
}