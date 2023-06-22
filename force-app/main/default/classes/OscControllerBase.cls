public virtual class OscControllerBase {
	public static String serviceType = '';
	static {
		AppConfig__c cf = AppConfig__c.getValues('SVR_MODE');
		serviceType = (cf == null ? 'soap' : cf.Value__c);
	}
	protected Map<String, String> params;
	//public String instanceUrl { get; set; }
	//public String returnedContinuationId { get; set; }
	//protected final Integer TIMEOUT_INT_SECS = 60;
	
    //2017Sep: Fixed support incident 00006150 - INC0031417 : Salesforce CRM In Product Holding Page, there is timeout hardcode to get product   
    private Integer getTIMEOUT_INT_SECS(){ 
       Integer DEFAULT_TIMEOUT = 60;
        try{
            List<App_Config__mdt> productHoldingTimeOut = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'ProductHolding_TIMEOUT_INT_SECS'];
            if (productHoldingTimeOut != null && productHoldingTimeOut.size() > 0) {
                 return Integer.valueOf(productHoldingTimeOut.get(0).Value__c);
            }           
            return DEFAULT_TIMEOUT;
          }catch( Exception e ){
           return DEFAULT_TIMEOUT;
        }
    }
    protected final Integer TIMEOUT_INT_SECS = getTIMEOUT_INT_SECS();
    
	@testVisible
	protected String SVR_MODE = OscControllerBase.serviceType;
	public String PageMessage { get; set; }

	//Re-Used Code
	public Continuation startRequest() {
		PageMessage = '';
		Continuation cont = new Continuation(TIMEOUT_INT_SECS);
		if (SVR_MODE == 'soap')
		{
			CallSOAP(cont);
		}
		return cont;
	}

	public virtual void CallSOAP(Continuation cont){


	} 

}