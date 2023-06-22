global class LoanProductDetailDTO {

	global string LoanAccountNumber { get; set; }
	global string LoanProductCode { get; set; }
	global string ProductName { get; set; }
	global string SubProductGroup { get; set; }

	global Decimal TenorMonth { get; set; }
	global string AccountStatus { get; set; }
	global Decimal CreditLimit { get; set; }
	global Decimal Outstanding { get; set; }
	global Date OpenDate { get; set; }
	global Date ContractEndDate { get; set; }
	global Date PaymentDueDate { get; set; }
	global string OtherConditions { get; set; }
	global string CampaignName { get; set; }
	global Date LastPaymentDate { get; set; }
	global Date RetentionDate { get; set; }
	global Decimal CurrentTenor { get; set; }
	global String HasCoBorrowe { get; set; }

	// Error Handler message
	global String SoapStatus { get; set; }
	global String SoapMessage { get; set; }

	public LoanProductDetailDTO()
	{
		CreditLimit = Outstanding = CurrentTenor = 0;
		LoanPayment = new LoanPaymentDTO();
		RelatedInsurance = new RelatedInsuranceDTO();
		CoBorroweres = new List<CoBorrowerDTO> ();
		InterestPlans = new List<InterestPlanDTO> ();
	}


	global LoanPaymentDTO LoanPayment { get; set; }
	global RelatedInsuranceDTO RelatedInsurance { get; set; }
	global List<CoBorrowerDTO> CoBorroweres { get; set; }
	//Relate List
	global List<InterestPlanDTO> InterestPlans { get; set; }


	global string MakeLoanAccountNumber { get {

			return NumberHelper.MarkAccountNo(NumberHelper.TrimLoanAccountNo(LoanAccountNumber));
		}
	}
	global string MarkOutstanding { get {

			return NumberHelper.MarkDecimal(Outstanding);
		}
	}
	global string MarkCreditLimit { get {

			return NumberHelper.MarkDecimal(CreditLimit);
		}
	}
    
    global String convertedOpenedDate{
        get{
            return NumberHelper.dateFormat(OpenDate);
        }
    }
    
    global String convertedContractEndDate{
        get{
            return NumberHelper.dateFormat(ContractEndDate);
        }
    }
    
    global String convertedPaymentDueDate{
        get{
            return NumberHelper.dateFormat(PaymentDueDate);
        }
    }
    
    global String convertedLastPaymentDate{
        get{
            return NumberHelper.dateFormat(LastPaymentDate);
        }
    }
    
    global String convertedRetentionDate{
        get{
            return NumberHelper.dateFormat(RetentionDate);
        }
    }

}