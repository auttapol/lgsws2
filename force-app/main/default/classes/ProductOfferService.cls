public class ProductOfferService {
    public static Map<String,ProductWrapper> productWrapperMap;
    public static MuleInfo muleInfo;
	public static void parseJson(String jsonInput){
        productWrapperMap = new Map<String,ProductWrapper>();
        muleInfo = new MuleInfo();
        Map<String, Object> output = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);

        if(output.containsKey('data')){
            Map<String,Object> dataMap = (Map<String,Object>)output.get('data');
		    productTraverse(dataMap,null);
            System.debug('Final result ::: '+productWrapperMap);
        }
        if(output.containsKey('mule_info')){
            Map<String,Object> MuleInfoMap  = (Map<String,Object>)output.get('mule_info');
            List<Object> messageObjList = (List<Object>)MuleInfoMap.get('message');
            
            for(Object obj : messageObjList){
                muleInfo.message.add((String)obj);
            }
            muleInfo.log_id = (String)MuleInfoMap.get('log_id');           
            muleInfo.status = (String)MuleInfoMap.get('status');
        }
        

        
    }

	public static void productTraverse (Map<String,Object> inputMap,String root) {
        System.debug('root :: '+root);
        String traversedNode;
		for(String key : inputMap.keySet()){
            traversedNode = root==null?key:root+';'+key;
			Object obj = inputMap.get(key);
			System.debug('key ::: '+key);
			System.debug('value ::: '+obj);
			//check if value in map is still an Object that can be extracted or it is already the String value (inner most value)
			if((obj instanceof String) == false){
				//if the map value can still be extracted, convert map value into Map
				productTraverse((Map<String,Object>)obj,traversedNode);
			}else{
				key = key.replace('_',' ');
				//productMap.put(key,(String)obj);
                List<String> productStr;
                ProductWrapper product = new ProductWrapper();
                if(traversedNode != null){
                   productStr  = traversedNode.split(';'); 
                }
                Integer i = 0;
                for(String s : productStr){
                    if(i == 0){
                        product.productGroup = s;
                    }
                    else if(i == 1){
                        product.productSubGroup = s;
                    }
                    else if(i == 2){
                        product.productName = s;
                    }
                    i++;

                }
                

                String value = (String)obj;
				product.valueList = new List<String>{value};
                System.debug('product result :::: '+product);
                String keyMap;
                if(product.productName != null ){
                    keyMap = product.ProductName.replace('_',' ');
                }else if(product.productSubGroup != null ){
                    keyMap = product.productSubGroup.replace('_',' ');
                }else if(product.productGroup != null){
                    keyMap = product.productGroup.replace('_',' ');
                }
				
                if(productWrapperMap.containsKey(keyMap)){
					ProductWrapper tmpProduct = productWrapperMap.get(keyMap);
					tmpProduct.valueList.add(value);
				}
				else{
					productWrapperMap.put(keyMap,product);
				}
                
			}
		}
	}

    public class ProductWrapper{
        public String productGroup {get;set;}
        public String productSubGroup {get;set;}
        public String productName {get;set;}
		public List<String> valueList {get;set;}
    }

    public class MuleInfo{
        public String log_id {get;set;}
        public List<String> message {get;set;}
        public String status {get;set;}

        public MuleInfo(){
            message = new List<String>();
        }
    }

    
}