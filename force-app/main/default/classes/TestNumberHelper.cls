@isTest
private class TestNumberHelper {

	@isTest
	static void TestMarkDecimal() {
		//init
		decimal d1 = 1200.00;
		string ret = NumberHelper.MarkDecimal(d1);
		System.assertEquals('1,2xx', ret);


		decimal d2 = 100.00;
		string ret2 = NumberHelper.MarkDecimal(d2);
		System.assertEquals('1xx', ret2);


		decimal d3 = 10.00;
		ret2 = NumberHelper.MarkDecimal(d3);
		System.assertEquals('xx', ret2);


		d3 = 1.00;
		ret2 = NumberHelper.MarkDecimal(d3);
		System.assertEquals('x', ret2);

		ret2 = NumberHelper.MarkDecimal(null);
		System.assertEquals('-', ret2);

	}
	@isTest
	static void TestMarkAccountNo() {
		string acctno = '1234567890';
		string marked = NumberHelper.MarkAccountNo(acctno);

		System.assertEquals('xxx-4-56789-x', marked);

		acctno = '12345678901234';
		marked = NumberHelper.MarkAccountNo(acctno);
		System.assertEquals('xxxx-xxx-8-90123-x', marked);
		acctno = '';
		marked = NumberHelper.MarkAccountNo(acctno);

		System.assertEquals('', marked);

	}
    
    @isTest
	static void TestTrimDepositAccountNo() {
		string acctno = '1234567890';
		string marked = NumberHelper.TrimDepositAccountNo(acctno);

		System.assertEquals('1234567890', marked);

		acctno = '00005678901234';
		marked = NumberHelper.TrimDepositAccountNo(acctno);
		System.assertEquals('5678901234', marked);
		acctno = '00056789012344';
		marked = NumberHelper.TrimDepositAccountNo(acctno);

		System.assertEquals('0056789012344', marked);
        
        acctno = '';
		marked = NumberHelper.TrimDepositAccountNo(acctno);

		System.assertEquals('', marked);

	}
    
    @isTest
	static void TestTrimCardNo() {
		string acctno = '040512345678909001';
		string marked = NumberHelper.TrimCardNo(acctno);
		System.assertEquals('0405123478909001', marked);

		acctno = '';
		marked = NumberHelper.TrimCardNo(acctno);
		System.assertEquals('', marked);

	}
    
    @isTest
	static void TestTrimLoanAccountNo() {
		string acctno = '12345678901234';
		string marked = NumberHelper.TrimLoanAccountNo(acctno);

		System.assertEquals('2345678901', marked);

		acctno = '';
		marked = NumberHelper.TrimLoanAccountNo(acctno);
		System.assertEquals('', marked);

	}
	@isTest
	static void TestMarkCardNo() {
		String acctno = '1234 5678 9012 3456';
		string marked = NumberHelper.MarkCardNo(acctno);

		System.assertEquals('1234-56xx-xxxx-3456', marked);


		String acctno2 = '1234-5678-9012-3456';
		string marked2 = NumberHelper.MarkCardNo(acctno2);

		System.assertEquals('1234-56xx-xxxx-3456', marked2);

		String acctno3;
		string marked3 = NumberHelper.MarkCardNo(acctno3);

		System.assertEquals('', marked3);

		String acctno4 = '';
		string marked4 = NumberHelper.MarkCardNo(acctno4);

		System.assertEquals('', marked4);
		 acctno4 = '  ';
		 marked4 = NumberHelper.MarkCardNo(acctno4);

		System.assertEquals('', marked4);
	}

	@isTest
	static void TestMarkDebitNo() {
		String debit = '1234567890';
		string marked = NumberHelper.MarkDirectDebit(debit);
		System.assertEquals('xxx-4-56789-x', marked);


		String debit1 = '2222';
		string marked1 = NumberHelper.MarkDirectDebit(debit1);
		System.assertEquals('', marked1);

		debit1 = '';
		marked1 = NumberHelper.MarkDirectDebit(debit1);
		System.assertEquals('', marked1);
	}

	@isTest
	static void TestMarkCashWithdrwal() {
		String card1 = '1234567890';
		string marked = NumberHelper.MarkCashWithdrwal(card1);
		System.assertEquals('xxx-4-56789-x', marked);

		String card2 = '2222';
		marked = NumberHelper.MarkCashWithdrwal(card2);
		System.assertEquals('', marked);

		String card3 = '';
		marked = NumberHelper.MarkCashWithdrwal(card3);
		System.assertEquals('', marked);
	}

	@isTest
	static void TestMarkSuppCardNumber() {
		String suppCard = '1234 5678 9012 3456';
		string marked = NumberHelper.MarkSuppCardNumber(suppCard);
		System.assertEquals('1234-56xx-xxxx-3456', marked);

		String suppCard1 = '1234-5678-9012-3456';
		string marked1 = NumberHelper.MarkSuppCardNumber(suppCard1);
		System.assertEquals('1234-56xx-xxxx-3456', marked1);

		suppCard1 = '';
		marked1 = NumberHelper.MarkSuppCardNumber(suppCard1);
		System.assertEquals('', marked1);

		String suppCard2;
		string marked2 = NumberHelper.MarkSuppCardNumber(suppCard2);
		System.assertEquals('', marked2);


	}
	@isTest
	static void TestConvertDecimalToFormatString() {
		Decimal v1 = 120000.00;
		string v2 = NumberHelper.ConvertDecimalToFormatString(v1);

		System.assertEquals('120,000', v2);
		v1 = 120000.01;
		v2 = NumberHelper.ConvertDecimalToFormatString(v1);

		System.assertEquals('120,000.01', v2);
	}
    
    @isTest
    static void TestConvertDecimalToMarkedFormatString(){
        Decimal v1 = 1245323.234;
        string v2 = NumberHelper.ConvertDecimalToMarkedFormatString(v1);
        System.assertEquals('1,245,3xx.234', v2);
        
        v1 = 23.23;
        v2 = NumberHelper.ConvertDecimalToMarkedFormatString(v1);
        System.assertEquals('xx.23', v2);
        
        v1 = 1123;
        v2 = NumberHelper.ConvertDecimalToMarkedFormatString(v1);
        System.assertEquals('1,1xx', v2);
        
        v1 = 23;
        v2 = NumberHelper.ConvertDecimalToMarkedFormatString(v1);
        System.assertEquals('xx', v2);
    }

	@isTest
	static void testTrimDepositAccountNo10Digit() {
		String card1 = '23432345654567';
		string marked = NumberHelper.TrimDepositAccountNo10Digit(card1);

		String card2 = '0000223345';
		marked = NumberHelper.TrimDepositAccountNo10Digit(card2);

		String card3 = '';
		marked = NumberHelper.TrimDepositAccountNo10Digit(card3);
	}


	@isTest
	static void testMaskPromptPay() {
		String card1 = '23432345654567';
		string marked = NumberHelper.MaskPromptPay(card1);

		String card2 = '0000223345';
		marked = NumberHelper.MaskPromptPay(card2);

		String card3 = '';
		marked = NumberHelper.MaskPromptPay(card3);
	}

	@isTest
	static void testGenerateUID() {
		string marked = NumberHelper.generateUID();
	}

	@isTest
	static void testDateFormat() {
		String bd1 = '26/07/2555';
		Date bdd = date.parse(bd1);
		string marked = NumberHelper.dateFormat(bdd);

		String bd2 = '26/07/1999';
		Date bdd2 = date.parse(bd2);
		marked = NumberHelper.dateFormat(bdd2);
	}

	@isTest
	static void testTrimSuffixAccountNo() {
		String card1 = '23432345654567';
		string marked = NumberHelper.trimSuffixAccountNo(card1);

		String card2 = '0000223345';
		marked = NumberHelper.trimSuffixAccountNo(card2);

		marked = NumberHelper.trimSuffixAccountNo('');
	}

	@isTest
	static void testTrimDirectDebit() {
		String card1 = '23432345654567';
		string marked = NumberHelper.TrimDirectDebit(card1);

		String card2 = '4354567689';
		marked = NumberHelper.TrimDirectDebit(card2);

		marked = NumberHelper.TrimDirectDebit('');
	}

}