public class BancassuranceProductCtrl extends OscControllerBase {
    /*----------------------------------------------------------------------------------
      Author:        Keattisak Chinburarat
      Company:       I&I Consulting 
      Description:   Controller of BancassuranceProductView.page  OSC05
      Inputs:        
      1. Policy No.
      Base Class:    -
      Test Class:    TestBancassuranceProductCtrl.cls
      History
      <Date>      <Authors Name>     <Brief Description of Change>
      2016-05-10   Keattisak.C        First Draft
      2017-01-17   Bhumipat C.        Add BA Plan
      ----------------------------------------------------------------------------------*/
    private final String policyno; /*  Policy No.  */
    public ViewState ViewState { get; set; }
    private AsyncRTL_BancPrdDetailsService.getBancassuranceProductDetailsResponse_elementFuture asyncRet;
    public BancassuranceProductCtrl() {
        // Input
        params = ApexPages.currentPage().getParameters();
        string p = params.get('p');
        System.debug('TMB: -> p is :' + p);
        p = p.replace(' ', '+');
        string dc = UrlHelper.decryptParams(p);
        System.debug('TMB: -> dc is :' + dc);
        List<String> arrParams = dc.split('&');
        if (null != arrParams && arrParams.size() >= 1)
        {
            policyno = arrParams[0];
        }
        System.debug('TMB: -> policyno is :' + policyno);
        ViewState = new ViewState();
        //ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
    }   
    public override void CallSOAP(Continuation cont) {
        cont.continuationMethod = 'processResponseSOAP';
        AsyncRTL_BancPrdDetailsService.AsyncBancassuranceProductDetailsSOAP asynSvr = new AsyncRTL_BancPrdDetailsService.AsyncBancassuranceProductDetailsSOAP();
        asyncRet = asynSvr.beginGetBancassuranceProductDetails(cont, policyno /*PolicyNo*/); // fix'T02836285'
    }

    public Object processResponseSOAP() {
        try
        {
            RTL_BancPrdDetailsService.BancassuranceProductDetails soapObj = asyncRet.getValue();
            BancassuranceInformationDTO item = ((BancassuranceInformationDTO) TypeMapper.MappingSoapToDTO(soapObj));
            if (item != null)
            {
                if(item.SoapStatus == 'ERROR'){
                    pageMessage = item.SoapMessage;
                    return null;
                }
                item.PolicyNo = policyno;
                ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
                ViewState.BancassuranceInformation = item;
                ViewState.TransformDataBancassurance();
                ViewState.InvokeFindInsuranceCompany();
            }

        }
        catch(Exception e)
        {
            PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
        }
        return null;
    }
    // Inner class
    public class ViewState {
        public BancassuranceInformationDTO BancassuranceInformation { get; set; }
        public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }

        public ViewState() {
            BancassuranceInformation = new BancassuranceInformationDTO();
        }
        /* Private Method */
        public void TransformDataBancassurance() {
            // Transform Bancassurance
        if (OnlyProductWithProductCode.containsKey(BancassuranceInformation.ProductCode))
        {
            // Found Product code in RTL Product Master
            //BancassuranceInformation.ProductName = OnlyProductWithProductCode.get(BancassuranceInformation.ProductCode).Name;
            BancassuranceInformation.SubProductGroup = OnlyProductWithProductCode.get(BancassuranceInformation.ProductCode).Product_Sub_group;
            //BancassuranceInformation.ProductGroup = OnlyProductWithProductCode.get(BancassuranceInformation.ProductCode).Product_Group;
            //STAT-BC28122016
            BancassuranceInformation.BA_Plan = OnlyProductWithProductCode.get(BancassuranceInformation.ProductCode).Asset_Class;            
            //END-BC28122016
            }
        else {
            BancassuranceInformation.ProductCode = 'error';
            //BancassuranceInformation.ProductGroup = '#N/A';
            //BancassuranceInformation.ProductName = '#N/A';
            BancassuranceInformation.SubProductGroup = '#N/A';
        }
        }
        public void InvokeFindInsuranceCompany() {
            /*---------------------------------------------------------------------------------------------------------
              Because the source system does not have the insurance company�s details, a Custom object will be
              created in SFDC to store the details. The Insurance Company details will be maintained by TMB manually. 
              Definition: Object Name � BA_Insurance_Company__c
              --------------------------------------------------------------------------------------------------------*/
            if (BancassuranceInformation.BancassuranceDetail.InsuranceCompany != null && BancassuranceInformation.BancassuranceDetail.InsuranceCompany != '')
            {
                Map<string /*company name*/, BA_Insurance_Company__c> companyNames = BAInsuranceCompanyService.getAllBAInsuranceCompanies();
                if (companyNames.size() > 0)
                {
                    if (companyNames.containsKey(BancassuranceInformation.BancassuranceDetail.InsuranceCompany))
                    {
                        BA_Insurance_Company__c company = companyNames.get(BancassuranceInformation.BancassuranceDetail.InsuranceCompany);
                        BancassuranceInformation.BancassuranceDetail.Address = company.Address__c;
                        BancassuranceInformation.BancassuranceDetail.ContactNumber1 = company.ContactNo1__c;
                        BancassuranceInformation.BancassuranceDetail.ContactNumber2 = company.ContactNo2__c;
                    }
                }
            }
        }
    }
}