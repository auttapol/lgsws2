global class LoanPaymentDTO {

    global string PaymentMethod { get; set; }
    global string SavingAccount { get; set; }
    global decimal InstallmentBalance { get; set; }
    global decimal PayrollDeductionUnit { get; set; }

    global string MarkedSavingAccount { get {

            return NumberHelper.MarkAccountNo(NumberHelper.TrimDepositAccountNo(SavingAccount));
        }
    }
    
    global String translatedPaymentMethod{
        get{
            if(null == PaymentMethod)
                return '';
            
            RTL_Payment_Method__c t_PaymentMethod = RTL_Payment_Method__c.getValues(PaymentMethod);
            return (t_PaymentMethod == null) ? PaymentMethod : t_PaymentMethod.Value__c;
        }
    }


}