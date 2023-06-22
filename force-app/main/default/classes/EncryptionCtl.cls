public with sharing class EncryptionCtl {

    //get key from custom setting
    //key must be 32 bytes
    Blob cryptoKey = Blob.valueOf(AppConfig__c.getValues('encrypt_CardKey').Value__c);
    
    public EncryptionCtl() {       
      
    }    

    public String encryptedDataToHex(String inputData){

        //Add '|' to the start text, because after DWH decrypted, it will cut off text after '|' 
        String convertString = inputData;      
        convertString = convertString.replace('|', ' ');
        convertString = '|'+convertString;    

        //character set  'UTF-8'
        //Generate the data to be encrypted. 
        Blob data = Blob.valueOf(convertString);

        //Encrytp data and convert to hexadecimal
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256',cryptoKey, data);
        String convertToHex = EncodingUtil.convertToHex(encryptedData);
            
        return convertToHex;
    }

}