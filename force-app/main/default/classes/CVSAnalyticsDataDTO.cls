global class CVSAnalyticsDataDTO
{
        global String Status { get; set; }
        global String Message { get; set; }
        global String MIBStatus { get; set; }
        global String UsagePercentage { get; set; }
        global String LastLoginSuccessDate { get; set; }
        global String suitability { get; set; }
        global String privilege { get; set; }
        global String privilege2Url { get; set; }
        global String currentPrivilege2Desc { get; set; }
        global String entitledPrivilege2Desc { get; set; }
        global String afPrivilegeFlag { get; set; }
    
        global String touchStatus {get;set;}
        global String ibStatus {get;set;}
        global String csProfFreqBr {get;set;}
        global decimal csProfAvgaum12m {get;set;}
        global Date csProfAvgaum12mDt {get;set;}
        global String csProfSubsegment {get;set;}
        global String csProfWealthExpDt {get;set;}
    
     	global String SoapStatus { get; set; }
    	global String SoapMessage { get; set; }
    
    public CVSAnalyticsDataDTO()
    {
        
    }
}