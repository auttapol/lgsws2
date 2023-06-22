public class RetailProductServiceImpl implements IRetailProductService {
	// Lazy Load
	private static Map<string /*product code*/, RTLProductMasterDTO> onlyRTLProductWithProductCode;

	
	public Map<string /*product code*/, RTLProductMasterDTO> getOnlyRTLProducts() {
		
		if (onlyRTLProductWithProductCode == null) {
			System.Debug('TMB: -> RetailProductServiceImpl Invoked');
			onlyRTLProductWithProductCode = new Map<string /*product code*/, RTLProductMasterDTO> ();

			//  Check if contain procuct code use product code as a key  other why user credit type
			List<Product2> productMasters = RetailProductSelector.getAllRetailProduct2();
			// Create Map
			for (Product2 product : productMasters)
			{
				RTLProductMasterDTO prd = new RTLProductMasterDTO(product);
				if (prd.Product_Code != null && prd.Product_Code != '')
				{
					if (!onlyRTLProductWithProductCode.containsKey(prd.Product_Code))
					{
						onlyRTLProductWithProductCode.put(prd.Product_Code, prd);
					}
				}
				
			}
			System.Debug('TMB: -> RetailProductServiceImpl Get Product2 contrain ' + onlyRTLProductWithProductCode.size() + ' Items');
		}
		return onlyRTLProductWithProductCode;
	}


}