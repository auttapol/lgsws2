public with sharing class PHIRecommendedAtionExtensions {
	public Account acct { get; set;}
	public Product_Information_Detail__c ProdHold { get; set;}

	// Smart BDM Phase II
	public Boolean isDepositAccount { get { if(isDepositAccount == null) isDepositAccount = false; return isDepositAccount;} set; }
	public Boolean isS1B { get { if(isS1B == null) isS1B = false; return isS1B;} set; }
	public Boolean isBIZTOUCH { get { if(isBIZTOUCH == null) isBIZTOUCH = false; return isBIZTOUCH;} set; }
	// public Boolean isBIZWOW { get { if(isBIZWOW == null) isBIZWOW = false; return isBIZWOW;} set; }
	// public Boolean isEDC { get { if(isEDC == null) isEDC = false; return isEDC;} set; }
	// public String BDMLatestMTHTXN { get; set; }
	public String BDMLatestSIXMTHTXN { get; set; }
	public String ActionRecommand { get; set; }
	
	public PHIRecommendedAtionExtensions(ApexPages.StandardController std) {
		ProdHold = (Product_Information_Detail__c)std.getRecord();

	}

	public void CheckingProductHoldingInfo()
	{
		
		if(ProdHold.Deposit_Account__c == MiniCSV_Controller.ISHAVING){
			isDepositAccount = true;
		}

		if(ProdHold.S1B__c == MiniCSV_Controller.ISHAVING){
			isS1B = true;
		}

		if(acct.BIZ_Touch__c == MiniCSV_Controller.ISHAVING){
			isBIZTOUCH = true;
		}

		BDMLatestSIXMTHTXN = ProdHold.BDM_Latest_SIXMTH_TXN__c;
	}

	public void CallRecommendedAction(){
		try {

			ProdHold = [SELECT Id, Deposit_Account__c, S1B__c, BDM_Latest_SIXMTH_TXN__c, Customer__c
				FROM Product_Information_Detail__c 
				WHERE Id =: ProdHold.Id AND Product_Domain__c = 'Deposit & Investment'
				LIMIT 1];

			acct = [SELECT Id, BIZ_Touch__c, BIZ_Wow__c
				FROM Account
				WHERE Id =: ProdHold.Customer__c 
				LIMIT 1];

			CheckingProductHoldingInfo();
			System.debug('isDepositAccount: ' + isDepositAccount + '| isS1B: ' + isS1B + '| isBIZTOUCH: ' + isBIZTOUCH + '| BDMLatestSIXMTHTXN: ' + BDMLatestSIXMTHTXN);
			
		   	ActionRecommand = AccountUtility.CalculateRecommendedAction(isDepositAccount, isS1B, isBIZTOUCH, BDMLatestSIXMTHTXN);
			System.debug('ActionRecommand ::: ' + ActionRecommand);
		} catch (Exception e) {
			ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
			System.debug('System debug ::: ' + e.getMessage());
		}
		
		
	}

	/* check if the VF page is display by SF1 */
    public Boolean isSF1 {
        get {                   
            if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
                String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
                ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
                (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
            ) {
                return true;
            }else{
                return false;
            }
        }
    }
}