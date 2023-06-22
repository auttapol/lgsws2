public class RTL_ValidateData {
    private Account cust;
    
    public RTL_DataSummary resultDataSummary{get;set;}
    
    private RTL_Customer_Data_Validation__c validation;
    private RTL_Data_Summary__c summary;
    private Map<String,RTL_Data_Age__mdt> dataAgeMdtMap;
    private static final String DATA_NULL_ERROR_MSG = System.Label.RTL_ERR001;
    private static final String DATA_LENGTH_ERROR_MSG = System.Label.RTL_ERR002;
    private static final String ZIP_CODE_LENGTH_ERROR_MSG = System.Label.RTL_ERR011;
    private static final String CITIZEN_ID_TYPE = 'Citizen Id';
    
    public RTL_ValidateData(Account inCust,RTL_Customer_Data_Validation__c dataValidation,RTL_Data_Summary__c dataSummary){
        cust = inCust;
        resultDataSummary = new RTL_DataSummary();
        validation = dataValidation;
        summary = dataSummary;
    }
    public RTL_DataSummary execute(){
        resultDataSummary.Quality.validateDataQuality(cust);
        resultDataSummary.Age.validateDataAge(cust);
        resultDataSummary.Marketing.validateMarketing(validation);
        return resultDataSummary;
    }
        
    

}