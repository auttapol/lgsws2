@isTest
public class TestRetailProductService {
	static {
		Test.loadData(Product2.sObjectType, 'RTLProductMaster');
	}

	@isTest
	private static void codeCoverage() {

		Map<string /*product code*/, RTLProductMasterDTO> datas =
		 RetailProductService.getOnlyRTLProducts();


		//System.assertNotEquals(0 , datas.size());
        
        RetailProductService.setMockservice(new RetailProductServiceMockImpl());
        

	}
    
    public class RetailProductServiceMockImpl implements IRetailProductService {
        
        public Map<string /*product code*/, RTLProductMasterDTO> getOnlyRTLProducts() {
            return new Map<string /*product code*/, RTLProductMasterDTO>();
        }
    }
}