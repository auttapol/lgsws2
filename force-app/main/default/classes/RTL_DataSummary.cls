public class RTL_DataSummary {
    public RTL_DataAge Age{get;set;}
    public RTL_Quality Quality{get;set;}
    public RTL_Marketing Marketing{get;set;}
    
    public RTL_DataSummary(){
        Age = new RTL_DataAge();
        Quality = new RTL_Quality();
        Marketing = new RTL_Marketing();     
    }
    
    public String getDataAgeStatus(){
        return Age.status;
    }
    public String getQualityStatus(){
        return Quality.getQualityStatus();
    }
    public String getMarketingStatus(){
        return Marketing.getMarketingStatus();
    }
}