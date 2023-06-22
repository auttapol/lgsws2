public class RTLProductMasterDTO {
	public string Product_Code { get; set; }
	public string Asset_Class { get; set; }
	public string Name { get; set; }
	public string Product_Group { get; set; }
	public string Product_Sub_group { get; set; }
	public string Issuer_Fund_House { get; set; }
	public string SEQ_GRP {get;set;}
	public string SFProductKey {get;set;}
	public RTLProductMasterDTO(Product2 prd)
	{
		// Create PK 
		if (prd.RTL_Product_Code__c != null && prd.RTL_Product_Code__c != '') {
            //will use in the future if mulesoft can get projectcode & datasource
			//Product_Code = prd.RTL_Product_Code__c+checkNull(prd.RTL_TMB_PROJECT_CD__c)+checkNull(prd.RTL_DATA_SOURCE__c);
			Product_Code = prd.RTL_Product_Code__c;
		}
		else if (prd.RTL_TMB_Product_Type__c != null && prd.RTL_TMB_Product_Type__c != '') {
			Product_Code = prd.RTL_TMB_Product_Type__c+'CRE';
		}

		Name = prd.Name;
		Asset_Class = prd.RTL_Asset_Class__c;
		Product_Group = prd.Family;
		Product_Sub_group = prd.Sub_Family__c;
		Issuer_Fund_House = prd.RTL_Issuer_Fund_House__c;
		SEQ_GRP = prd.SEQ_GRP__c;
		SFProductKey = prd.SF_Product_Key__c;
	}
    
    /*private String checkNull(String input){
        if(input == null)
            return '';
        return input;
    }*/
}