public class RTL_Quality {
    public string primaryAddr {get;set;}
    public string primaryZipCode {get;set;}
    public string registeredAddr {get;set;}
    public string registeredZipCode {get;set;}
    public string officeAddr {get;set;}
    public string officeZipCode {get;set;}
    public string citizenID {get;set;}
    public string mobile {get;set;}
    public string email {get;set;}
    public string DOB {get;set;}
    public string occupation {get;set;} 
    
    private static final String DATA_NULL_ERROR_MSG = System.Label.RTL_ERR001;
    private static final String DATA_LENGTH_ERROR_MSG = System.Label.RTL_ERR002;
    private static final String ZIP_CODE_LENGTH_ERROR_MSG = System.Label.RTL_ERR011;
    private static final String CITIZEN_ID_TYPE = 'Citizen Id';
        
    public String getQualityStatus(){
        if(isNull(primaryAddr)&&isNull(primaryZipCode)&&isNull(registeredAddr)&&
           isNull(registeredZipCode)&&isNull(officeAddr)&&isNull(officeZipCode)&&
           isNull(citizenID)&&isNull(mobile)&&isNull(email)&&isNull(DOB)&&
           isNull(occupation)){
            return 'Pass';
        }
        return 'Fail';
    }
    
    public Boolean isNull(String input){
        if(input == null || input == '')
            return true;
        return false;
    }
    
    public void validateDataQuality(Account cust){
       RTL_Address_Field_Length__c primaryLen = RTL_Address_Field_Length__c.getValues('Primary Address Length');
       RTL_Address_Field_Length__c officeLen = RTL_Address_Field_Length__c.getValues('Office Address Length');
       RTL_Address_Field_Length__c regisLen = RTL_Address_Field_Length__c.getValues('Registered Address Length');
        //Validate Primary Address
        if(isNull(cust.Primary_Address_Line_1_PE__c)){
            primaryAddr = DATA_NULL_ERROR_MSG;
        }else if(isValidLength(cust.Primary_Address_Line_1_PE__c,primaryLen.RTL_Min_Field_Length__c.intValue()) == false ){
            primaryAddr = System.Label.RTL_ERR002+' '+primaryLen.RTL_Min_Field_Length__c.intValue();
        }
        //Validate Primary Zip Code
        if(isNull(cust.Zip_Code_Primary_PE__c)){
            primaryZipCode = DATA_NULL_ERROR_MSG;
        }else if(cust.Zip_Code_Primary_PE__c.length() != 5){
            primaryZipCode = System.Label.RTL_ERR011;
        }
        
        //Validate Registered Address
        if(isNull(cust.Registered_Address_Line_1_PE__c)){
            registeredAddr = DATA_NULL_ERROR_MSG;
        }else if(isValidLength(cust.Registered_Address_Line_1_PE__c,regisLen.RTL_Min_Field_Length__c.intValue()) == false ){
            registeredAddr = System.Label.RTL_ERR002+' '+regisLen.RTL_Min_Field_Length__c.intValue();
        }
        //Validate Registered Zip Code
        if(isNull(cust.Zip_Code_Registered_PE__c)){
            registeredZipCode = DATA_NULL_ERROR_MSG;
        }else if(cust.Zip_Code_Registered_PE__c.length() != 5){
            registeredZipCode = System.Label.RTL_ERR011;
        }
        
        //Validate Office Address
        if(isNull(cust.Office_Address_Line_1_PE__c)){
            officeAddr = DATA_NULL_ERROR_MSG;
        }else if(isValidLength(cust.Office_Address_Line_1_PE__c,officeLen.RTL_Min_Field_Length__c.intValue()) == false){
            officeAddr = System.Label.RTL_ERR002+' '+officeLen.RTL_Min_Field_Length__c.intValue();
        }
        //Validate Office Zip Code
        if(isNull(cust.Zip_Code_Office_PE__c)){
            officeZipCode = DATA_NULL_ERROR_MSG;
        }else if(cust.Zip_Code_Office_PE__c.length() != 5){
            officeZipCode = System.Label.RTL_ERR011;
        }

        //Validate Citizen ID
        if(isNull(cust.ID_Number_PE__c)){
            citizenID = DATA_NULL_ERROR_MSG;
        }
        else{
            if(cust.ID_Type_PE__c == CITIZEN_ID_TYPE){
                if(cust.ID_Number_PE__c.length() != 13 || isValidCitizenId(cust.ID_Number_PE__c) == false){
                    citizenID = System.Label.RTL_ERR003;
                }
            }
        }
        
        //Validate Mobile Number
        if(isNull(cust.Mobile_Number_PE__c)){
            mobile = DATA_NULL_ERROR_MSG;
        }else if(cust.Mobile_Number_PE__c.length() != 10){
            mobile = System.Label.RTL_ERR004;
        }else if(cust.Mobile_Number_PE__c == '0000000000'){
            mobile = System.Label.RTL_ERR006;
        }
        
        //Validate Email Address
        if(isNull(cust.Email_Address_PE__c)){
            email = DATA_NULL_ERROR_MSG;
        }else if(!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})',cust.Email_Address_PE__c)){
            email = System.Label.RTL_ERR007;
        }
        
        //Validate DOB
        Date compareDate = date.newInstance(1900, 1, 1); // locale en_US
        if(UserInfo.getLocale() == 'th_TH'){
            compareDate = date.newInstance(2443, 1, 1);
        }
        String dobString = String.valueOf(cust.RTL_Date_Of_Birth__c);
        if(isNull(dobString)){
            dob = DATA_NULL_ERROR_MSG;
        }else if(cust.RTL_Date_Of_Birth__c <= comparedate ){
            dob = System.Label.RTL_ERR005;
        }
        
        //Validate Occupation
        if(cust.RTL_Occupation_Details__c == null){
            occupation = DATA_NULL_ERROR_MSG;
        }
    }
    
    public Boolean isValidLength(String inputString,Integer minLength){
        if(inputString.length() > 0 && inputString.length() < minLength){
            return false;
        }
        return true;
    }
    
    public Boolean isValidCitizenId(String inputString){
        return Integer.valueOf(inputString.mid(12,1)) == math.mod(11- math.mod((Integer.valueOf(inputString.mid(0,1))*13 +
                                                                         Integer.valueOf(inputString.mid(1,1))*12 +
                                                                         Integer.valueOf(inputString.mid(2,1))*11 +
                                                                         Integer.valueOf(inputString.mid(3,1))*10 +
                                                                         Integer.valueOf(inputString.mid(4,1))*9 +
                                                                         Integer.valueOf(inputString.mid(5,1))*8 +
                                                                         Integer.valueOf(inputString.mid(6,1))*7 +
                                                                         Integer.valueOf(inputString.mid(7,1))*6 +
                                                                         Integer.valueOf(inputString.mid(8,1))*5 +
                                                                         Integer.valueOf(inputString.mid(9,1))*4 +
                                                                         Integer.valueOf(inputString.mid(10,1))*3 +
                                                                         Integer.valueOf(inputString.mid(11,1))*2),11),10);
    }
   
}