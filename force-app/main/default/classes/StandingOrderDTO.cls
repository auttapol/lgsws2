global class StandingOrderDTO {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Data Transfer Objects
	  Inputs:        None
	  Base Class:    -
	  Test Class:    -
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  ----------------------------------------------------------------------------------*/
	global Date RequestDate { get; set; }
	global decimal Frequency { get; set; }
	global Date SettlementDate { get; set; }
	global string Type { get; set; }
	global decimal LastAmount { get; set; }
	global Date LastTrxDate { get; set; }
    
    global String convertedRequestDate{
        get{
            return NumberHelper.DateFormat(RequestDate);
        }
    }
    
    global String convertedSettleDate{
        get{
            return NumberHelper.DateFormat(SettlementDate);
        }
    }
    
    global String convertedLastTrxDate{
        get{
            return NumberHelper.DateFormat(LastTrxDate);
        }
    }
}