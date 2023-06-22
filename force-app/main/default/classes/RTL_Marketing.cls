public class RTL_Marketing{
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
    
    public String getMarketingStatus(){
        if(isNull(primaryAddr)&&isNull(primaryZipCode)&&isNull(registeredAddr)&&
           isNull(registeredZipCode)&&isNull(officeAddr)&&isNull(officeZipCode)&&
           isNull(citizenID)&&isNull(mobile)&&isNull(email)&&isNull(DOB)&&
           isNull(occupation)){
            return 'Pass';
        }
        return 'Fail';
        
        /*if(isNull(primaryAddr) &&isNull(registeredAddr)&&isNull(officeAddr)&&isNull(citizenID)&&isNull(mobile)&&isNull(email)&&isNull(DOB)&&isNull(occupation)){
            return 'Pass';
        }
        return 'Fail';*/
    }
    
    public Boolean isNull(String input){
        if(input == null || input == '')
            return true;
        return false;
    }
    
    public void validateMarketing(RTL_Customer_Data_Validation__c dataValidation){
    	primaryAddr = dataValidation.RTL_Primary_Address_Mkt__c;
    	primaryZipCode = dataValidation.RTL_Primary_Address_Zip_Mkt__c;
    	registeredAddr = dataValidation.RTL_Registered_Address_Mkt__c;
    	registeredZipCode = dataValidation.RTL_Registered_Address_Zip_Mkt__c;
    	officeAddr = dataValidation.RTL_Office_Address_Mkt__c;
    	officeZipCode = dataValidation.RTL_Office_Address_Zip_Mkt__c;
    	citizenID = dataValidation.RTL_Citizen_ID_Mkt__c;
    	mobile = dataValidation.RTL_Mobile_Mkt__c;
    	email = dataValidation.RTL_Email_Mkt__c;
    	DOB = dataValidation.RTL_DOB_Mkt__c;
    	occupation = dataValidation.RTL_Occupation_Mkt__c;
        
	}
}