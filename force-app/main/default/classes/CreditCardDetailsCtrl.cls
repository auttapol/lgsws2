public class CreditCardDetailsCtrl extends OscControllerBase {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Controller of CreditCardDetailsView.page
	  Inputs:        
	  1. Card Number
	  2. Credit Card Type
	  Base Class:    -
	  Test Class:    TestCreditCardDetailsCtrl.cls
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-18   Keattisak.C        First Draft
	  ----------------------------------------------------------------------------------*/

	private final String cdno; /*  Card Number  */
	private final String cdtype; /*  Card Number  */
    public Boolean isEmployee {get;set;}/*is Employee*/
	public ViewState ViewState { get; set; }
	AsyncRTL_CreditCardDetailsService.getCreditCardDetailsResponse_elementFuture asyncRet;
	public CreditCardDetailsCtrl() {
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
			cdno = arrParams[0];
			cdtype = arrParams[1];
            isEmployee = Boolean.valueOf(arrParams[2]);
		}
		System.debug('TMB: -> cdno is :' + cdno);
		System.debug('TMB: -> cdtype is :' + cdtype);
		ViewState = new ViewState();
		// Get Retail Product Master
		//ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
		ViewState.CreditCardInformation.CardNumber = cdno;
	}
	public override void CallSOAP(Continuation cont) {
		cont.continuationMethod = 'processResponseSOAP';
		AsyncRTL_CreditCardDetailsService.AsyncCreditCardDetailsSOAP asynSvr = new AsyncRTL_CreditCardDetailsService.AsyncCreditCardDetailsSOAP();
		asyncRet = asynSvr.beginGetCreditCardDetails(cont, /*cardNumber'4560432101111150'*/ cdno, /*creditCardType'1'*/ cdtype);
	}
	public Object processResponseSOAP() {
		try
		{
			RTL_CreditCardDetailsService.CreditCardDetails soapCreditCardDetails = asyncRet.getValue();
			CreditcardInformationDTO item = ((CreditcardInformationDTO) TypeMapper.MappingSoapToDTO(soapCreditCardDetails));
			
            if(item.SoapStatus == 'ERROR'){
            	pageMessage = item.SoapMessage;
                return null;
            }
            ViewState.OnlyProductWithProductCode = RetailProductService.getOnlyRTLProducts();
            ViewState.CreditCardInformation = item;
			ViewState.TransformDataCreditCard(cdno,cdtype);
			return null;

		}
		catch(Exception e)
		{

			PageMessage = 'Web services callout error with inner exception : ' + e.getMessage();
		}
		return null;
	}	
	// Inner class
	public class ViewState {
		public CreditCardInformationDTO CreditCardInformation { get; set; }
		public Map<string /*product code*/, RTLProductMasterDTO> OnlyProductWithProductCode { get; set; }

		public ViewState() {
			CreditCardInformation = new CreditCardInformationDTO();
		}

		/* Private Method */
		public void TransformDataCreditCard(String cdno,String cdtype) {
            // use cardNumber from service1 instead
            CreditCardInformation.CardNumber = cdno;
            CreditCardInformation.CreditCardType = cdtype.remove('CRE');
            System.debug('credit card type ::: '+cdtype);
			// Transform Deposit
			if (OnlyProductWithProductCode.containsKey(cdtype))
			{

				CreditCardInformation.ProductName = OnlyProductWithProductCode.get(cdtype).Name;
                CreditCardInformation.ProductType = OnlyProductWithProductCode.get(cdtype).Product_Group;

			}
			else {
				CreditCardInformation.CreditCardType = '#N/A';
				CreditCardInformation.ProductName = '#N/A';
                CreditCardInformation.ProductType = '#N/A';

			}
		}


	}
}