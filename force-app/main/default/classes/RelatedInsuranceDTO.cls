global class RelatedInsuranceDTO {
	global string Insurance { get; set; }
	global string PolicyNumber { get; set; }
	global string Insurer { get; set; }
	global decimal SumInsured { get; set; }
	global Date StartDate { get; set; }
    global Date EndDate { get; set; }
    
    global String convertedStartDate{
        get{
            return NumberHelper.DateFormat(StartDate);
        }
    }
    
    global String convertedEndDate{
        get{
            return NumberHelper.DateFormat(EndDate);
        }
    }
}