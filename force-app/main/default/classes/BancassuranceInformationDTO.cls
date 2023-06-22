global class BancassuranceInformationDTO {
    global String   ProductType                                           { get; set; }
    global String   ProductCode                                           { get; set; }
    global String   ProductGroup                                           { get; set; }
    global String   SubProductGroup                                           { get; set; }
    global String   ProductName                                           { get; set; }
    global Date     EffectiveDate                                           { get; set; }
    global String   PolicyStatus                                           { get; set; }
    global String   PolicyNo                                           { get; set; }
    global Decimal  SumInsured                                           { get; set; }
    global Decimal  AFYP                                           { get; set; }
    global Date     ExpiryDate                                           { get; set; }
    global String   Sales                                           { get; set; }
    //START-BC28122016
    global String   BA_Plan                                        { get; set; }
    //END-BC28122016
    // Error Handler message
    global String SoapStatus { get; set; }
    global String SoapMessage { get; set; }

    global BancassuranceDetailsDTO BancassuranceDetail { get; set; }
    global PaymentInformationDTO PaymentInformation { get; set; }
    global NextCashBackInformationzmationDTO NextCashBackInformationzmation { get; set; }    
    global InsuredPropertyAssetDTO InsuredPropertyAsset { get; set; }
    global InsuredAutomobileAssetDTO InsuredAutomobileAsset { get; set; }
    global List<BeneficiaryInformationDTO> BeneficiaryInformations  { get; set; }
    global List<InsuranceClaimRecordDTO> InsuranceClaimRecords  { get; set; }
    public BancassuranceInformationDTO()
    {
        BancassuranceDetail = new BancassuranceDetailsDTO();
        PaymentInformation = new PaymentInformationDTO();
        NextCashBackInformationzmation = new NextCashBackInformationzmationDTO();
        InsuredPropertyAsset = new InsuredPropertyAssetDTO();
        InsuredAutomobileAsset = new InsuredAutomobileAssetDTO();
        BeneficiaryInformations = new List<BeneficiaryInformationDTO>();
        InsuranceClaimRecords = new List<InsuranceClaimRecordDTO>();
        SumInsured = AFYP = 0; 
    }   
    
    global String convertedEffectiveDate{
        get{
            return NumberHelper.DateFormat(EffectiveDate);
        }
    }
    global String convertedExpiryDate{
        get{
            return NumberHelper.DateFormat(ExpiryDate);
        }
    }




}