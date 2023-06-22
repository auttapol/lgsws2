public class InvestmentProductDetailCtrl extends OscControllerBase {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Controller of InvestmentProductDetailView.page  OSC06
	  Inputs:        
	  1. Unit Holder No.
	  2. Fund Code
	  Base Class:    -
	  Test Class:    TestInvestmentProductDetailCtrl.cls
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-05-10   Keattisak.C        First Draft
	  ----------------------------------------------------------------------------------*/

	public String unitHolderNo { get; set; }
	public String fundCode { get; set; }
	public ViewState ViewState { get; set; }
    public String devideByZeroText{
        get{
            if( devideByZeroText == null )
            {
                try
                {
                    Investment_Product_Configuration__mdt conf = [SELECT ID,Devide_By_Zero_Result_Text__c
                                                            FROM Investment_Product_Configuration__mdt WHERE Label='Configuration' ];
                    devideByZeroText = conf.Devide_By_Zero_Result_Text__c;
                }
                catch (exception e)
                {
                    devideByZeroText = '0.000';
                    system.debug('Cannot find custom meta data for display devide by zero text.' );
                }

            }
            return devideByZeroText;
        }
        set;
    }
    
	AsyncRTL_InvestmentPrdDetailsService.getInvestmentProductDetailsResponse_elementFuture asyncRet;
	public InvestmentProductDetailCtrl()
	{
		// Input
		params = ApexPages.currentPage().getParameters();
		string p = params.get('p');
		System.debug('TMB: -> p is :' + p);
		p = p.replace(' ', '+');
		string dc = UrlHelper.decryptParams(p);
		System.debug('TMB: -> dc is :' + dc);

		List<String> arrParams = dc.split('&');


		if (null != arrParams && arrParams.size() >= 2)
		{
			unitHolderNo = arrParams[0];
			fundCode = arrParams[1];
		}
		System.debug('TMB: -> unitHolderNo is :' + unitHolderNo);
		System.debug('TMB: -> fundCode is :' + fundCode);

		ViewState = new ViewState();
		//ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();

	}




	public override void CallSOAP(Continuation cont) {
		cont.continuationMethod = 'processResponseSOAP';
		AsyncRTL_InvestmentPrdDetailsService.AsyncInvestmentProductDetailsSOAP asynSvr
		= new AsyncRTL_InvestmentPrdDetailsService.AsyncInvestmentProductDetailsSOAP();
		asyncRet = asynSvr.beginGetInvestmentProductDetails(cont, /* UnitHolderNo '111643000068' */ unitHolderNo, /*FundCode 'ABIG' */ fundCode); // UnitHolderNo,String FundCode)
	}
	public Object processResponseSOAP() {
		try
		{
			RTL_InvestmentPrdDetailsService.InvestmentProductDetails soapInvestmentProductDetails = asyncRet.getValue();
			InvestmentProductDetailsDTO item = ((InvestmentProductDetailsDTO) TypeMapper.MappingSoapToDTO(soapInvestmentProductDetails));
			
            if(item.SoapStatus == 'ERROR'){
            	pageMessage = item.SoapMessage;
                return null;
            }
            item.InvestmentInformation.FundCode = fundCode;
            ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
			ViewState.InvestmentProductDetails = item;
			ViewState.TransformDataInvestment();


			return null;

		}
		catch(Exception e)
		{

			PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
		}
		return null;
	}




	public class ViewState {
		public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }
		public InvestmentProductDetailsDTO InvestmentProductDetails { get; set; }
		public ViewState()
		{
			InvestmentProductDetails = new InvestmentProductDetailsDTO();
		}
		/* Private Method */
		public void TransformDataInvestment() {
			// Transform Deposit
			if (OnlyProductWithProductCode.containsKey(InvestmentProductDetails.InvestmentInformation.FundCode))
			{
				// Found Product code in RTL Product Master
				InvestmentProductDetails.InvestmentInformation.ProductName = OnlyProductWithProductCode.get(InvestmentProductDetails.InvestmentInformation.FundCode).Name;
				InvestmentProductDetails.InvestmentInformation.ProductType = OnlyProductWithProductCode.get(InvestmentProductDetails.InvestmentInformation.FundCode).Product_Sub_group;
				InvestmentProductDetails.InvestmentInformation.AssetType = OnlyProductWithProductCode.get(InvestmentProductDetails.InvestmentInformation.FundCode).Asset_Class;
				InvestmentProductDetails.InvestmentInformation.IssuerFundHouse = OnlyProductWithProductCode.get(InvestmentProductDetails.InvestmentInformation.FundCode).Issuer_Fund_House;
				InvestmentProductDetails.InvestmentInformation.FundType = '';
			}
			else {

				InvestmentProductDetails.InvestmentInformation.ProductName = '#N/A';
				InvestmentProductDetails.InvestmentInformation.ProductType = '#N/A';
			}
		}
	}

}