public class CustomerAccountResponse {

	public class BancassuranceAccounts {
		public List<BancassuranceAccount> BancassuranceAccount {get;set;} 

		public BancassuranceAccounts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'BancassuranceAccount') {
							BancassuranceAccount = arrayOfBancassuranceAccount(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'BancassuranceAccounts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class GetCustomerAccountResponse {
		public DepositAccounts DepositAccounts {get;set;} 
		public CreditCardAccounts CreditCardAccounts {get;set;} 
		public LoanAccounts LoanAccounts {get;set;} 
		public BancassuranceAccounts BancassuranceAccounts {get;set;} 
		public InvestmentAccounts InvestmentAccounts {get;set;} 

		public GetCustomerAccountResponse(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'DepositAccounts') {
							DepositAccounts = new DepositAccounts(parser);
						} else if (text == 'CreditCardAccounts') {
							CreditCardAccounts = new CreditCardAccounts(parser);
						} else if (text == 'LoanAccounts') {
							LoanAccounts = new LoanAccounts(parser);
						} else if (text == 'BancassuranceAccounts') {
							BancassuranceAccounts = new BancassuranceAccounts(parser);
						} else if (text == 'InvestmentAccounts') {
							InvestmentAccounts = new InvestmentAccounts(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'GetCustomerAccountResponse consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Status {
		public Integer StatusCode {get;set;} 
		public String StatusDesc {get;set;} 

		public Status(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'StatusCode') {
							StatusCode = parser.getIntegerValue();
						} else if (text == 'StatusDesc') {
							StatusDesc = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Status consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public GetCustomerAccountResponse GetCustomerAccountResponse {get;set;} 
	public Status Status {get;set;} 

	public CustomerAccountResponse(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'GetCustomerAccountResponse') {
						GetCustomerAccountResponse = new GetCustomerAccountResponse(parser);
					} else if (text == 'Status') {
						Status = new Status(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'CustomerAccountResponse consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class LoanAccount {
		public String Status {get;set;} 
		public String AccountNumber {get;set;} 
		public String FIIdent {get;set;} 
		public String ProductType {get;set;} 
		public String ProductCode {get;set;} 
		public String OpenedDate {get;set;} 
		public String AccountStatus {get;set;} 
		public String Outstanding {get;set;} 
		public String Limit_Z {get;set;} // in json: Limit
		public String HasCoborrower {get;set;} 

		public LoanAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'AccountNumber') {
							AccountNumber = parser.getText();
						} else if (text == 'FIIdent') {
							FIIdent = parser.getText();
						} else if (text == 'ProductType') {
							ProductType = parser.getText();
						} else if (text == 'ProductCode') {
							ProductCode = parser.getText();
						} else if (text == 'OpenedDate') {
							OpenedDate = parser.getText();
						} else if (text == 'AccountStatus') {
							AccountStatus = parser.getText();
						} else if (text == 'Outstanding') {
							Outstanding = parser.getText();
						} else if (text == 'Limit') {
							Limit_Z = parser.getText();
						} else if (text == 'HasCoborrower') {
							HasCoborrower = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'LoanAccount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CreditCardAccount {
		public String Status {get;set;} 
		public String CardNumber {get;set;} 
		public String CreditCardType {get;set;} 
		public String OpenedDate {get;set;} 
		public String AccountStatus {get;set;} 

		public CreditCardAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'CardNumber') {
							CardNumber = parser.getText();
						} else if (text == 'CreditCardType') {
							CreditCardType = parser.getText();
						} else if (text == 'OpenedDate') {
							OpenedDate = parser.getText();
						} else if (text == 'AccountStatus') {
							AccountStatus = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'CreditCardAccount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class InvestmentAccount {
		public String Status {get;set;} 
		public String UnitHoldNo {get;set;} 
		public String Units {get;set;} 
		public String MarketValue {get;set;} 
		public String UnrealizedGL {get;set;} 
		public String AvgCost {get;set;} 
		public String NoOfUnit {get;set;} 

		public InvestmentAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'UnitHoldNo') {
							UnitHoldNo = parser.getText();
						} else if (text == 'Units') {
							Units = parser.getText();
						} else if (text == 'MarketValue') {
							MarketValue = parser.getText();
						} else if (text == 'UnrealizedGL') {
							UnrealizedGL = parser.getText();
						} else if (text == 'AvgCost') {
							AvgCost = parser.getText();
						} else if (text == 'NoOfUnit') {
							NoOfUnit = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'InvestmentAccount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class LoanAccounts {
		public List<LoanAccount> LoanAccount {get;set;} 

		public LoanAccounts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'LoanAccount') {
							LoanAccount = arrayOfLoanAccount(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'LoanAccounts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DepositAccount {
		public String Status {get;set;} 
		public String AccountNumber {get;set;} 
		public String FIIdent {get;set;} 
		public String ProductType {get;set;} 
		public String ProductCode {get;set;} 
		public String OpenedDate {get;set;} 
		public String AccountStatus {get;set;} 
		public String Outstanding {get;set;} 
		public String AvgOutstanding {get;set;} 
		public String ODLimit {get;set;} 
		public String Ledger {get;set;} 
		public String InterestEarned {get;set;} 
		public String HasJoint {get;set;} 

		public DepositAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'AccountNumber') {
							AccountNumber = parser.getText();
						} else if (text == 'FIIdent') {
							FIIdent = parser.getText();
						} else if (text == 'ProductType') {
							ProductType = parser.getText();
						} else if (text == 'ProductCode') {
							ProductCode = parser.getText();
						} else if (text == 'OpenedDate') {
							OpenedDate = parser.getText();
						} else if (text == 'AccountStatus') {
							AccountStatus = parser.getText();
						} else if (text == 'Outstanding') {
							Outstanding = parser.getText();
						} else if (text == 'AvgOutstanding') {
							AvgOutstanding = parser.getText();
						} else if (text == 'ODLimit') {
							ODLimit = parser.getText();
						} else if (text == 'Ledger') {
							Ledger = parser.getText();
						} else if (text == 'InterestEarned') {
							InterestEarned = parser.getText();
						} else if (text == 'HasJoint') {
							HasJoint = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'DepositAccount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class InvestmentAccounts {
		public List<InvestmentAccount> InvestmentAccount {get;set;} 

		public InvestmentAccounts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'InvestmentAccount') {
							InvestmentAccount = arrayOfInvestmentAccount(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'InvestmentAccounts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class CreditCardAccounts {
		public List<CreditCardAccount> CreditCardAccount {get;set;} 

		public CreditCardAccounts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'CreditCardAccount') {
							CreditCardAccount = arrayOfCreditCardAccount(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'CreditCardAccounts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class BancassuranceAccount {
		public String Status {get;set;} 
		public String SumInsure {get;set;} 
		public String AFVP {get;set;} 

		public BancassuranceAccount(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'Status') {
							Status = parser.getText();
						} else if (text == 'SumInsure') {
							SumInsure = parser.getText();
						} else if (text == 'AFVP') {
							AFVP = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'BancassuranceAccount consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class DepositAccounts {
		public List<DepositAccount> DepositAccount {get;set;} 

		public DepositAccounts(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'DepositAccount') {
							DepositAccount = arrayOfDepositAccount(parser);
						} else {
							System.debug(LoggingLevel.WARN, 'DepositAccounts consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public static CustomerAccountResponse parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new CustomerAccountResponse(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<InvestmentAccount> arrayOfInvestmentAccount(System.JSONParser p) {
        List<InvestmentAccount> res = new List<InvestmentAccount>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new InvestmentAccount(p));
        }
        return res;
    }

    private static List<BancassuranceAccount> arrayOfBancassuranceAccount(System.JSONParser p) {
        List<BancassuranceAccount> res = new List<BancassuranceAccount>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new BancassuranceAccount(p));
        }
        return res;
    }

    private static List<LoanAccount> arrayOfLoanAccount(System.JSONParser p) {
        List<LoanAccount> res = new List<LoanAccount>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new LoanAccount(p));
        }
        return res;
    }

    private static List<DepositAccount> arrayOfDepositAccount(System.JSONParser p) {
        List<DepositAccount> res = new List<DepositAccount>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new DepositAccount(p));
        }
        return res;
    }

    private static List<CreditCardAccount> arrayOfCreditCardAccount(System.JSONParser p) {
        List<CreditCardAccount> res = new List<CreditCardAccount>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new CreditCardAccount(p));
        }
        return res;
    }
}