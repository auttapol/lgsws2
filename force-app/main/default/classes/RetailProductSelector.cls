public class RetailProductSelector {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Selector for RTL_product_master__c
	  Inputs:        None
	  Test Class:    TestRetailProductSelector
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/

	/*----------------------------------------------------------------------------------
	  Retial Product Hollding change to use Product2 intead of RTL_Product_master
	  History
	  <Date>      <Authors Name>		 <Brief Description of Change>
	  2016-05-26  Keattisak Chinburarat  Product2 intead of RTL_Product_master
	  ----------------------------------------------------------------------------------*/
	private static string selectRTLProduct2All() {
		return 
		' select Name,SF_Product_Key__c,ProductCode,Family,Sub_Family__c,RTL_Asset_Class__c,RTL_TMB_Product_Type__c '+
		' ,RTL_Issuer_Fund_House__c,RTL_Product_Name_ENG__c,RTL_Product_Short_Name_ENG__c                           '+
		' ,RTL_Product_Name_TH__c,RTL_Product_Short_Name_TH__c,SEQ_GRP__c                                           '+
		' ,FUND_TYPE__c,RTL_PRODUCT_CODE__c,RTL_TMB_PROJECT_CD__c                                                   '+
		' ,RTL_DATA_SOURCE__c                                                                                       '+
		' from product2 where SEQ_GRP__c != null                                                                    ';
	}

	public static List<Product2> getAllRetailProduct2() {
		List<Product2> ret;
		string sql = selectRTLProduct2All();
		System.Debug('TMB: -> SOQL : ' + sql);
		try
		{
			ret = (List<Product2>) Database.query(sql);
		}
		catch(Exception ex)
		{
			throw new RetailProductSelectorException('There is some error when query Product2', ex);
		}
		return ret;
	}

	public class RetailProductSelectorException extends Exception {
	}
}