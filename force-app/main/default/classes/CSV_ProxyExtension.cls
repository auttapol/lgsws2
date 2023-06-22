public class CSV_ProxyExtension {
    
	public static Account currentObject;
    
    public CSV_ProxyExtension( ApexPages.StandardController stdController ){
        currentObject =  (Account)stdController.getRecord();
    }
    
    public PageReference redirectPage(){
        PageReference ref;
        String cdata =  Apexpages.currentPage().getUrl();
        if( getCSVProxy_CC() ){     
            String verifyId =  Apexpages.currentPage().getParameters().get('verf_hist_id'); 
            System.debug('cdata!!:'+cdata);
            if(verifyId != null)
            {        
                ref = new PageReference('/apex/CallCenter_CSV?id='+currentObject.Id +'&verf_hist_id='+verifyId);
            }
            else {
                ref = new PageReference('/apex/CallCenter_CSV?id='+currentObject.Id);
            }
            ref.setRedirect(true);
            return ref;
        }else{
            ref = new PageReference('/'+currentObject.Id+'?nooverride=1');
            ref.setRedirect(true);
            return ref;
        }
    }
    
    public String getProfileName(){
        try{
            return [ select Name from Profile where Id = :UserInfo.getProfileId() ].Name;
        }catch( Exception e ){
            return '';
        }
    }
    
    public Boolean getCSVProxy_CC(){
        try{
            return [ select Call_Center__c from CSV_Proxy__mdt where Call_Center__c = true and Profile_Name__c = :getProfileName() ].Call_Center__c;
        }catch( Exception e ){
            return false;
        }
    }
    
}