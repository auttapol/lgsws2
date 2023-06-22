global class CreditCardInformationDTO {
	// Input fields
	global string CardNumber { get; set; }
	global string CreditCardType { get; set; } /** SubProductGroup It is used to derive the Product Name and Product Type (Sub Group) from Product Hierarchy.*/
	global decimal CreditLimit { get; set; }
	global string ProductName { get; set; }
    global string ProductType {get;set;}
	//information 
	global decimal TemporaryLine { get; set; }
	global decimal CycleCut { get; set; }
	global string UsageStatus { get; set; }
	global string BlockCode { get; set; }
	global Date NextExpiredPointOn { get; set; }
	global string CashChillChill { get; set; }
	global string CashWithdrawalAccountNumber { get; set; }
	global Date OpenedDate { get; set; }
	global Decimal CurrentBalance { get; set; } // Used to Outstanding
	global Decimal TemporaryLinePeriod { get; set; }
	global Date PaymentDue { get; set; }
	global string PaymentBehavior { get; set; }
	global Decimal RewardPoints { get; set; }
	global Decimal NextExpiredPoints { get; set; }
	global string CashChillChillStatus { get; set; }
	global string DirectDebitAccountNumber { get; set; }
	global string AccountAgreementStatus { get; set; }
	global string CardAccountStatus { get; set; }
	global Date AcknowledgementDate { get; set; }
	global string CardStop { get; set; }
	global string CardStopReason { get; set; }
	global Date PreviousExpiryDate { get; set; }

	global string UsageBehavior { get; set; }
	global Date LastPaymentDate { get; set; }
    
    // Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }
    
	//Method
	global CreditCardInformationDTO() {
		SoGoodPayPlan = new SoGoodPayPlanDTO();
		SupplementaryInformations = new List<SupplementaryInformationDTO> ();
		NextExpiredPoints=TemporaryLinePeriod=CurrentBalance=CreditLimit=TemporaryLine=CycleCut=CreditLimit =0;
	}
	global string MarkedCardNumber {
		get {
			return NumberHelper.MarkCardNo(NumberHelper.TrimCardNo(CardNumber));

		}
	}

	global string MarkedCreditLimit {
		get {
			return NumberHelper.MarkDecimal(CreditLimit);

		}
	}
	global string MarkedCurrentBalance {
		get {
			return NumberHelper.MarkDecimal(CurrentBalance);

		}
	}
    global string MarkedCashWithdrawalAccountNumber {
		get {
			return NumberHelper.MarkAccountNo(NumberHelper.TrimDirectDebit(CashWithdrawalAccountNumber));

		}
	}
    global string MarkedDirectDebitAccountNumber {
		get {
			if(null == DirectDebitAccountNumber || '' == DirectDebitAccountNumber)
				return '-';
			
			// DirectDebitAccountNumber length != 10 and 14 will show number without mask
			if(DirectDebitAccountNumber.length() < 10) {
				return DirectDebitAccountNumber;
			} 
			if (DirectDebitAccountNumber.length() >= 11 && DirectDebitAccountNumber.length() <= 13) {
				return DirectDebitAccountNumber;
			}
			if(DirectDebitAccountNumber.length() > 14) {
				return DirectDebitAccountNumber;
			} 
			return NumberHelper.MarkAccountNo(NumberHelper.TrimDirectDebit(DirectDebitAccountNumber));

		}
	}
    global String convertedOpenedDate{
        get{
            return NumberHelper.DateFormat(OpenedDate);
        }
    }
    
    global String convertedPaymentDue{
        get{
            return NumberHelper.DateFormat(PaymentDue);
        }
    }
    
    global String convertedLastPaymentDate{
        get{
            return NumberHelper.DateFormat(LastPaymentDate);
        }
    }
    
    global String convertedNextExpiredPointOn{
        get{
            return NumberHelper.DateFormat(NextExpiredPointOn);
        }
    }
    
    global String translatedBlockCode{
        get{
            if(null == BlockCode || '' == BlockCode)
                return ' - BLANK';
            
			// RTL_Card_Block_Code__c BlckCode = RTL_Card_Block_Code__c.getValues(BlockCode);
			SCS_Block_Code_Status__c BlckCode = SCS_Block_Code_Status__c.getValues(BlockCode);
			String notFound = System.Label.Cannot_Lookup.replace('{code}', BlockCode);
			return (BlckCode == null) ? notFound : BlockCode + ' - ' + BlckCode.Value__c;
        }
    }
    
    global String translatedStatusCode{
        get{
            if(null == UsageStatus)
                return '';
            
            RTL_Card_Status_Code__c StatusCode = RTL_Card_Status_Code__c.getValues(UsageStatus);
            return (StatusCode == null) ? UsageStatus : StatusCode.Value__c;
        }
	}
	
	global String translatedAccountAgreementStatus{
        get{
            if(null == AccountAgreementStatus || '' == AccountAgreementStatus)
                return '';
            
			AccountAgreementStatus = SCSMessageAPIUtil.leftPadZero(AccountAgreementStatus, SCSMessageAPIUtil.ACCOUNT_AGREE_STATUS_TYPE);
			SCS_Account_Agreement_Status__c AgreementStatus = SCS_Account_Agreement_Status__c.getValues(AccountAgreementStatus+BlockCode);
			String notFound = System.Label.Cannot_Lookup.replace('{code}', AccountAgreementStatus+BlockCode);
            return (AgreementStatus == null) ? notFound : AccountAgreementStatus + ' - ' + AgreementStatus.Value__c;
        }
	}
	
	global String translatedCardStop{
        get{
            if(null == CardStop || '' == CardStop)
			return '';
            
			SCS_Card_Stop_Status__c StopCode = SCS_Card_Stop_Status__c.getValues(CardStop);
			String notFound = System.Label.Cannot_Lookup.replace('{code}', CardStop);
            return (StopCode == null) ? notFound : CardStop + ' - ' + StopCode.Value__c;
        }
	}
	
	global String translatedCardAccountStatus{
        get{
            if(null == CardAccountStatus || '' == CardAccountStatus)
                return '';
            
			CardAccountStatus = SCSMessageAPIUtil.leftPadZero(CardAccountStatus, SCSMessageAPIUtil.ACCOUNT_STATUS_TYPE);
			// SCS_Account_Agreement_Status__c AgreementStatus = SCS_Account_Agreement_Status__c.getValues(AccountAgreementStatus+BlockCode);
			// return (AgreementStatus == null) ? AccountAgreementStatus : AccountAgreementStatus + ' - ' + AgreementStatus.Value__c;
			return CardAccountStatus;
        }
	}
	
	global String translatedCardStopReason{
        get{
            if(null == CardStopReason || '' == CardStopReason)
			return '';
            
            return CardStopReason;
        }
	}

	// Nested Class
	public SoGoodPayPlanDTO SoGoodPayPlan { get; set; }

	public List<SupplementaryInformationDTO> SupplementaryInformations { get; set; }
}