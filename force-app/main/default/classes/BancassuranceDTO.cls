Global class BancassuranceDTO implements Comparable{
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global string PolicyNo { get; set; }
	global string SubProductGroup { get; set; }
	global string ProductName { get; set; }
	global string InsuranceCompany { get; set; }
	global Date OpenedDate { get; set; }
	global string Status { get; set; }
	global Decimal SumInsure { get; set; }
	global Decimal AFYP { get; set; }
	global Date ExpiryDate { get; set; }
	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	global string Params {
		get {

			string p = PolicyNo;
			return UrlHelper.encryptParams(p);

		}
	}
    
    global String convertedOpenedDate{
        get{
            return NumberHelper.DateFormat(OpenedDate);
        }
    }
    
    global String convertedExpiryDate{
        get{
            return NumberHelper.DateFormat(ExpiryDate);
        }
    }
    
    //Compare BA by Status (Active First) then ExpiryDate ASC
    global Integer compareTo(Object compareTo) {
        BancassuranceDTO compareToBa = (BancassuranceDTO)compareTo;
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if(Status == compareToBa.Status){
            if(ExpiryDate > compareToBa.ExpiryDate){
                return 1;
            }else if(ExpiryDate < compareToBa.ExpiryDate){
                return -1;
            }
        }
        if (Status > compareToBa.Status) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (Status < compareToBa.Status) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
}