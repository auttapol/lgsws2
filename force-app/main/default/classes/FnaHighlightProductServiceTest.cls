@isTest
public class FnaHighlightProductServiceTest {
    
    @isTest
    private static void Test_getHighLightProduct() {
        
        FNA_Activity__c fna = new FNA_Activity__c();
        insert fna;
        
		Branch_and_Zone__c branch = new Branch_and_Zone__c();
        branch.Branch_Code__c = '252';
        branch.isActive__c = true;
        insert branch;
        
        RTL_product_master__c product = new RTL_product_master__c();
        product.FNA_Active__c 			= 	true;
        product.FNA_Assigned_Pool__c 	= 	'OUTBOUND';
        product.FNA_Product_Name__c 	= 	'TestProductName';
        product.FNA_Product_Group__c 	= 	'For Save';
		product.Product_Code__c    		=  	'P123456';
        insert product;

        FNA_Product_Mapping__c productMapping = new FNA_Product_Mapping__c();
        productMapping.Product__c = product.Id;
        insert productMapping;

        FNA_Product_Offering__c productOffering = new FNA_Product_Offering__c();
        productOffering.Flag_Offset_product_holding__c = false;
        productOffering.FNA_Product_Name__c = productMapping.Id;
        productOffering.FNA_Activity__c = fna.Id;
        productOffering.Flag_Highlight__c = true;
        insert productOffering;
        
        FnaHighlightProductService.getHighLightProductByStation(fna.id,'252','01');
    }
    
    @isTest
    private static void Test_failGetHighLightProduct(){
        FNA_Activity__c fna = new FNA_Activity__c();
        insert fna;
        
        FnaHighlightProductService.getHighLightProductByStation(fna.id,'111','00');
        FnaHighlightProductService.getHighLightProductByStation('','','');
    }

}