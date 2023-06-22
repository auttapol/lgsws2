public class RTL_CampaignProductInterestedWrapper {
	public Integer numberOfProduct {get;set;}
	public Integer rowNum {get;set;}
	public String apiProductGroup {get;set;}
	public String apiProductSubGroup {get;set;}
	public String apiProductId {get;set;}
	public String apiProductName {get;set;}
	public Opportunity objOpp {get;set;}
	public Boolean viewSubGroup {get;set;}
	public Boolean viewProductName {get;set;}
	
	public RTL_CampaignProductInterestedWrapper(Integer numberOfProduct, Integer rowNum,String apiProductGroup,String apiProductSubGroup,
		String apiProductId,String apiProductName,Opportunity objOpp,Boolean viewSubGroup,Boolean viewProductName){
		this.numberOfProduct = numberOfProduct;
		this.rowNum = rowNum;
		this.apiProductGroup = apiProductGroup;
		this.apiProductSubGroup = apiProductSubGroup;
		this.apiProductId = apiProductId;
		this.apiProductName = apiProductName;
		this.objOpp = objOpp;
		this.viewSubGroup = viewSubGroup;
		this.viewProductName = viewProductName;
	}
}