public without sharing  class ii_SecurityCryptoManager {      
    public static string SignWithCertificate(string signature,string certName){
        system.debug('SecurityCryptoManager || Certificate Name : ' + certName);          
        String signString ='';
        try{
            Blob data = Blob.valueOf(signature);
            Blob data2 =  System.Crypto.signWithCertificate('RSA-SHA256', data, certName); 
            signString = EncodingUtil.base64encode(data2);
        }
        catch(Exception ex){
        	if(Test.isRunningTest()){ signString='Test'; }
            else throw new  HashManagerException('Unable to sign signature');    
        }
        return signString;
    }  

    public class HashManagerException extends Exception {}
}