global class RESTOpportunityProductUtil {

    global class Response {
        public String status;
        public String message;
    }

	public static User sfextapi{
        get{
            if(sfextapi == null){
                AppConfig__c temp = AppConfig__c.getValues('sfextapi');
                String name;
                if(temp == null){
                    name = 'sfextapi';
                }else{
                    name = temp.Value__c;
                }

                sfextapi = [SELECT Id, Employee_ID__c, IsActive FROM User WHERE Name =: name LIMIT 1];
            }
            return sfextapi;
        }
        set;
    }

	public static Response updateNewOppLineItem(RESTOpportunityProductWrapperClass req){
		List<RESTOpportunityProductWrapperClass.prodWrap> prdWrap = new List<RESTOpportunityProductWrapperClass.prodWrap>();
		List<OpportunityLineItem> oldOLI = new List<OpportunityLineItem>();
		List<OpportunityLineItem> newOLI = new List<OpportunityLineItem>();
		List<String> prdCodelst = new List<String>();
		Map<Id, String> prdIdCodeMap = new Map<Id, String>();
		Map<String, Id> priceBookprdIdMap = new Map<String, Id>();
		Boolean successfag = true;
		String errorPrd = ''; 

		Response res = new Response();
		
		String optyId;
		Opportunity ThisOpty;

		prdWrap = req.Products;
		optyId = req.OpportunityId;

		try {
			ThisOpty = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :optyId LIMIT 1];
		} catch (Exception e) {
			System.debug(e.getMessage());
			res.status = 'ERROR';
			res.message = 'Get Opportunity ERROR:' + e.getMessage();
			
			return res;
		}

		oldOLI = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :optyId];

		for (RESTOpportunityProductWrapperClass.prodWrap prd: prdWrap) {
			prdCodelst.add(prd.ProductCode);
		}
		
		for (PriceBookEntry pbEnty : [SELECT Id, Name, Pricebook2Id, Pricebook2.Name, Product2Id, Product2.RTL_PRODUCT_CODE__c, Product2.ProductCode FROM PricebookEntry WHERE Pricebook2Id = :ThisOpty.Pricebook2Id AND  Product2.RTL_PRODUCT_CODE__c IN :prdCodelst]) {
		   priceBookprdIdMap.put(pbEnty.Product2.RTL_PRODUCT_CODE__c, pbEnty.Id);
		}
		
		for (RESTOpportunityProductWrapperClass.prodWrap prd: prdWrap) {
			if (priceBookprdIdMap.get(prd.ProductCode) == null) {
			   	successfag = false;
			   	if(prd.ProductCode != null){
					if(errorPrd != ''){
						errorPrd += ', ';
					}
					errorPrd += prd.ProductCode;
			   	}
			}
			else{
				OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=ThisOpty.Id, PricebookEntryId=priceBookprdIdMap.get(prd.ProductCode), TMB_Account_ID__c = prd.AccountNumber, Quantity = 1, TotalPrice = 0);
				newOLI.add(oli);
			}

		}

		if(successfag && newOLI.size() > 0){
			try {
				insert newOLI;
				delete oldOLI;

				res.status = 'SUCCESS';
				res.message = '';
			} catch (Exception e) {
				System.debug(e.getMessage());
				res.status = 'ERROR';
				res.message = e.getMessage();
			}
		}else if(errorPrd != ''){
			res.status = 'ERROR';
			res.message = 'ProductCode (' + errorPrd + ') not found.';
		}else{
			res.status = 'ERROR';
			res.message = 'Products is null.';
		}

		return res;
	}

}