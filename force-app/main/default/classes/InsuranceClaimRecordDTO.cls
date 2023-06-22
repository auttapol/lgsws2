global class InsuranceClaimRecordDTO { 
    global Date Date_x { get; set; }
	global String Type_x { get; set; }
	global String Description { get; set; }
	global Decimal RequestAmount { get; set; }
	global Decimal ApprovedAmount { get; set; }

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }
    
    global String convertedDate_x{
        get{
            return NumberHelper.DateFormat(Date_x);
        }
    }
}