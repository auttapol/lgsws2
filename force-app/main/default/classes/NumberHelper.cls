public class NumberHelper {
	/*----------------------------------------------------------------------------------
	  Author:        Keattisak Chinburarat
	  Company:       I&I Consulting 
	  Description:   Used to mark any format
	  Inputs:        None
	  Test Class:    TestNumberHelper.cls
	  History
	  <Date>      <Authors Name>     <Brief Description of Change>
	  2016-04-18   Keattisak.C        First Draft
	  ----------------------------------------------------------------------------------*/


	/*----------------------------------------------------------------------------------
	 * @description :
	 *			Masking Rule:
	 *			Last 2 digit before decimal  to be masked with �XX� and after decimal digits not be shown. 
	 *			e.g. 1,200.50 >>
	 *			1,2XX
	 *
	 * @param val 
	 * @return marked decimal string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkDecimal(Decimal val) {

        if (val == null || val == 0)
		{
			return '-';
		}

		string strNo = val.longValue().format();
		if (strNo.length() >= 3)
		{
			strNo = strNo.left(strNo.length() - 2) + 'xx';
		}
		else if (strNo.length() == 2) {
			strNo = 'xx';
		}
		else {
			strNo = 'x';
		}
		return strNo;
	}

	/*----------------------------------------------------------------------------------
	 * @description :
	 *			Masking Rule:
	 *			Mask first 3 digit and last digit with “X” 
	 *          e.g. 1234567890 > XXX-4-56789-X
	 *			e.g. 12345678901234 > XXXX-XXX
	 *
	 * @param val 
	 * @return marked  string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkAccountNo(string val) {
		if (val == null || val == '')
		{
			return '';
		}

		if (val.length() == 4) val = 'xxxx';
		else if (val.length() == 10) {
			val = 'xxx' + val.right(val.length() - 3);
			val = val.left(val.length() - 1) + 'x';
			list<string> mark = new list<string> ();
			mark.add(val.substring(0, 3));
			mark.add(val.substring(3, 4));
			mark.add(val.substring(4, 9));
			mark.add(val.substring(9, 10));
			val = String.join(mark, '-');
		}
		else
		{
            String prefix = 'xxx';
            for(Integer i = 0;i<val.length()-10;i++)
            	prefix += 'x';
            
			val = prefix + val.right(7);
			val = val.left(val.length() - 1) + 'x';

            string tmpVal = val.reverse();
			list<string> mark = new list<string> ();
            mark.add(tmpVal.substring(0,1));
            mark.add(tmpVal.substring(1,6));
            mark.add(tmpVal.substring(6,7));
            mark.add(tmpVal.substring(7,10));
            mark.add(tmpVal.substring(10,val.length()));
			/*mark.add(val.substring(0, 4));
			mark.add(val.substring(4, 7));
			mark.add(val.substring(7, 8));
			mark.add(val.substring(8, 13));
			mark.add(val.substring(13, 14));*/
			val = String.join(mark, '-');
            val = val.reverse();
		}

		return val;
	}
    
    /*----------------------------------------------------------------------------------
	 * @description :
	 * 	
	 *  RM store account in 14 digit format for deposit. To chop account number to 10 or 13 digit please use below logic.
	 *  If first four digit of account number is 0 then use 10 digit (for saving) 
	 *  else if first three digit of account number is 0 then use 13 digit (for TD) 
	 *  else if account number has 10 digit then use 10 digit (for current) 
	 *	
	 * @param val 
	 * @return marked  string 
	 * 
	  ----------------------------------------------------------------------------------*/
	public static string TrimDepositAccountNo(string val) {
		if (val == null || val == '')
		{
			return '';
		}
        
        if(val.length() == 10)
            return val;
		
        if(val.startsWith('0000')){
            val = val.substring(4);
            System.debug('start with 0000' + val);
        }
          
        else{
            val = val.substring(1);
            System.debug('start with 000' + val);
        }
           

		return val;
	}
    
    /*----------------------------------------------------------------------------------
	 * @description :
	 * 	
	 *  Trim Leftmost digit out and show only 13 digits
	 *	
	 * @param val 
	 * @return marked  string 
	 * 
	  ----------------------------------------------------------------------------------*/
	public static string TrimLoanAccountNo(string val) {
		if (val == null || val == '')
		{
			return '';
		}
        if(val.length() == 10){
            return val;
        }     
        else if(val.length() == 14){
            return val.substring(1,11);
        }
        
		return val;
	}
    
    /*----------------------------------------------------------------------------------
	 * @description :
	 * 	
	 * Trim 2 digits in the middle out to get actual credit card no
	 *	
	 * @param val 
	 * @return marked  string 
	 * 
	  ----------------------------------------------------------------------------------*/
	public static string TrimCardNo(string val) {
		if (val == null || val == '')
		{
			return '';
		}
        
        if(val.length() == 18)
            return val.left(8)+val.right(8);

		return val;
	}
    
    public static string TrimDirectDebit(string val) {
		if (val == null || val == '')
		{
			return '';
		}
        
        if(val.length() == 10)
            return val;       
        else
            return val.right(10);
        

		return val;
	}

	//sub last 3 digit from account number
    public static string trimSuffixAccountNo(string accountNo){
        string result ='';
		if(accountNo!=null){
			if(accountNo.length() > 10 && !accountNo.startsWith('0000')){
				result = accountNo.right(3);
			}
		}  
        return result;
    }
    //trim 10 digit from 14 digit 
    public static string TrimDepositAccountNo10Digit(string val) {
		if (val == null || val == '')
		{
			return '';
		}
        
        if(val.length() == 10)
            return val;
		
        if(val.startsWith('0000')){
            val = val.substring(4);
            System.debug('start with 0000' + val);

        }else if(val.length() == 14){
        	//Account Time Deposit
           	val = val.substring(1,11);
        }    

		return val;
	}

	public static string MaskPromptPay(string val){
		if (val == null || val == '')
		{
			return '';
		}
		if(val.length()>3){
			string mask = '';
			Integer lengthX = val.length()-3;
			for(Integer i = 0;i<lengthX ;i++){
				mask+= 'x';
			}
			mask += val.right(3);
			val = mask;
		}

		return val;
	}


	/*----------------------------------------------------------------------------------
	 * @description :
	 *		Masking rule:
	 *			Masking 7th – 12th digit with “X”
	 *			e.g. 1234 5678 9012 3456 > 1234-56XX-XXXX-3456
	 * @param val 
	 * @return marked  string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkCardNo(string val) {

		if (val == null || val == '')
		{
			return '';
			//return 'xxxx-xxxx-xxxx-xxxx';
		}
		System.debug('TMB: => Before MarkCardNo = ' + val);
		// remove -
		if (val.contains('-'))
		{
			val = val.replace('-', '');
		}
		if (val.contains(' '))
		{
			val = val.replace(' ', '');
		}

		if (val.length() == 0)
		{
			return '';
		}
		else if (val.length() == 16)
		{
			list<string> mark = new list<string> ();
			mark.add(val.substring(0, 4));
			mark.add(val.substring(4, 8).left(2) + 'xx');
			//mark.add(val.substring(8, 12));
			mark.add('xxxx');
			mark.add(val.substring(12, 16));
			val = String.join(mark, '-');
		}

		System.debug('TMB: => After MarkCardNo = ' + val);
		return val;
	}

	/*----------------------------------------------------------------------------------
	 * @description :
	 *		Masking Rule:
	 *		Mask first 3 digit and last digit with “X” 
	 *		e.g. 1234567890 > XXX-4-56789-X
	 *
	 *
	 * @param val 16 digit
	 * @return marked  string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkDirectDebit(string val) {

		if (null == val || val == '')
		{
			return '';
		}
		if (val.length() == 4) {
			//val = 'xxxx';
			val = '';
		}
		else {
			val = 'xxx' + val.right(val.length() - 3);
			val = val.left(val.length() - 1) + 'x';
			list<string> mark = new list<string> ();
			mark.add(val.substring(0, 3));
			mark.add(val.substring(3, 4));
			mark.add(val.substring(4, 9));
			mark.add(val.substring(9, 10));
			val = String.join(mark, '-');
		}
		return val;

	}
	/*----------------------------------------------------------------------------------
	 * @description :
	 *			Masking Rule:
	 *		Mask first 3 digit and last digit with “X” 
	 *		e.g. 1234567890 > XXX-4-56789-X
	 * @param val 16 digit
	 * @return marked  string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkCashWithdrwal(string val) {

		if (null == val || val == '')
		{
			return '';
		}
		if (val.length() == 4) {
			val = '';
			//val = 'xxxx';
		}
		else {
			val = 'xxx' + val.right(val.length() - 3);
			val = val.left(val.length() - 1) + 'x';
			list<string> mark = new list<string> ();
			mark.add(val.substring(0, 3));
			mark.add(val.substring(3, 4));
			mark.add(val.substring(4, 9));
			mark.add(val.substring(9, 10));
			val = String.join(mark, '-');
		}
		return val;

	}
	/*----------------------------------------------------------------------------------
	 * @description :
	 *   Masking rule:
	 *      Masking 7th – 12th digit with “X”
	 *      e.g. 1234 5678 9012 3456 > 1234-56XX-XXXX-3456
	 * @param val 16 digit
	 * @return marked  string 
	  ----------------------------------------------------------------------------------*/
	public static string MarkSuppCardNumber(string val) {
		if (val == null || val == '')
		{
			return '';
			//return 'xxxx-xxxx-xxxx-xxxx';
		}
		System.debug('TMB: => Before MarkCardNo = ' + val);
		// remove -
		if (val.contains('-'))
		{
			val = val.replace('-', '');
		}
		if (val.contains(' '))
		{
			val = val.replace(' ', '');
		}
		if (val.length() == 16)
		{
			list<string> mark = new list<string> ();
			mark.add(val.substring(0, 4));
			mark.add(val.substring(4, 8).left(2) + 'xx');
			//mark.add(val.substring(8, 12));
			mark.add('xxxx');
			mark.add(val.substring(12, 16));
			val = String.join(mark, '-');
		}
		System.debug('TMB: => After MarkCardNo = ' + val);
		return val;
	}
	public static string ConvertDecimalToFormatString(Decimal val) {
		List<String> args = new String[] { '0', 'number', '#,##0.0000' };
		String ds = String.format(val.format(), args);

		return ds;

	}


	public static string ConvertDecimalToMarkedFormatString(Decimal val) {
		val = val == null ? 0 : val;
		string finalValue = '';
		List<String> args = new String[] { '0', 'number', '#,###.00' };
		String ds = String.format(val.format(), args);
		system.debug('::::::>  ' + ds);
		integer IDX = ds.indexOf('.');
		if (IDX > 0) {
			// มีจุด
			system.debug(':IDX > 0  ');
			string[] values = ds.split('\\.');
			system.debug(':values  =   ' + values);
			integer le = values[0].length();
			if (le > 2) {
				finalValue = values[0].left(le - 2) + 'xx.' + values[1];
			}
			else {
				finalValue = 'xx.' + values[1];
			}

		}
		else {
			integer le = ds.length();
			if (le > 2) {
				finalValue = ds.left(le - 2) + 'xx';
			}
			else {
				finalValue = 'xx';
			}

		}
		return finalValue;

	}
    
    public static String dateFormat(Date input){
        if(null == input){
            return '';
        }
		Date dateCheckbeyear = input.addYears(543);
		if(dateCheckbeyear.year() > 3000){
			input = UserInfo.getLocale().equalsIgnoreCase('th') || UserInfo.getLocale().equalsIgnoreCase('th_TH') ? input : input.addYears(-543);
		}else{
			input = UserInfo.getLocale().equalsIgnoreCase('th') || UserInfo.getLocale().equalsIgnoreCase('th_TH') ? input.addYears(543) : input;
		}

        DateTime newDate = DateTime.newInstance(input.year(),input.month(),input.day());
        return newDate.format('dd/MM/yyyy');
    }
    
    //generate request u-id number
    public static string generateUID (){
    	string uid = '';
    	Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		uid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
		system.debug(uid);
		return uid;
    }

}