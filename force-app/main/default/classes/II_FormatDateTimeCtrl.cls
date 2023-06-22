public class II_FormatDateTimeCtrl {
 	public DateTime dateTimeValue { get; set; }
	public String getTimeZoneValue() {
	    if( dateTimeValue != null ) {
	        String localeFormatDT = dateTimeValue.format();
	        return localeFormatDT;
	    }
	    return null;
	}
}