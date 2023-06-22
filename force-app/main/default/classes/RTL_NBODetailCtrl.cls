public class RTL_NBODetailCtrl {
  
    public ViewState ViewState { get; set; }
    public string nboId {get;set;}
    public Id accId {get;set;}
    public string pageMsg {get;set;}
    public boolean pageMsgFlag {get;set;}
    
    public RTL_NBODetailCtrl() {
        try{
  			viewstate = new ViewState();
  			nboId = ApexPages.currentPage().getParameters().get('p');
  			ViewState.NBOHistory = getNBOHistory();
  			ViewState.NBOProductList = ViewState.NBOHistory.NBO_History_Products__r;
  			ViewState.validNBOProductList = getValidNBOProduct(ViewState.NBOProductList);
        }catch(Exception e){
            System.debug('Error on NBO Detail View : '+e.getMessage());
            pageMsg = e.getMessage();
            pageMsgFlag = true; 
        }
	}
    
    public RTL_NBO_History__c getNBOHistory(){
        RTL_NBO_History__c nboHistory = [SELECT Id,RTL_Campaign_Name__c,RTL_Campaign_Code__c,RTL_Valid_From__c,
                                                   RTL_Valid_To__c,RTL_Status__c,RTL_Customer_Name__r.Name,
                                                   RTL_NBO_Group__c,
                                                   RTL_NBO_SubGroup__c,
                                                   RTL_Expired__c,
                                                   RTL_Smart_Info__c,
                                         		   RTL_Channel__c, RTL_Result_Business__c,RTL_Campaign__c,RTL_Campaign_Status__c,
                                                   (SELECT Id,Name,RTL_NBO_ID__c,RTL_Product_Group__c,RTL_Product_SubGroup__c,RTL_Product__c,
                                                           RTL_Opportunity__c,RTL_Opportunity__r.Name,RTL_Related_NBO__c,RTL_Invalid_Product_Reason__c,
                                                           RTL_Status__c,RTL_Reject_Reason__c,RTL_Offering_Channel__c,RTL_Product_Smart_Info__c 
                                                    FROM NBO_History_Products__r where RTL_Status__c != 'Invalid') 
                                         FROM RTL_NBO_History__c WHERE RTL_NBO_ID__c =: nboId];
        accId = nboHistory.RTL_Customer_Name__c;
        return nboHistory;
    }
    
    public List<RTL_NBO_History_Product__c> getValidNBOProduct(List<RTL_NBO_History_Product__c> inProductList){
        List<RTL_NBO_History_Product__c> returnProduct = new List<RTL_NBO_History_Product__c>();
        for(RTL_NBO_History_Product__c product : inProductList){
            if(product.RTL_Invalid_Product_Reason__c == null){
                returnProduct.add(product);
            }
        }
        return returnProduct;
    }
    
    public class ViewState {
    	public RTL_NBO_History__c NBOHistory { get; set; }
        public List<RTL_NBO_History_Product__c > NBOProductList {get;set;}
        public List<RTL_NBO_History_Product__c> validNBOProductList {get;set;}
        
        public ViewState(){
            NBOHistory = new RTL_NBO_History__c();
            NBOProductList = new List<RTL_NBO_History_Product__c >();
            validNBOProductList = new List<RTL_NBO_History_Product__c >();
        }
	}
    
    
}