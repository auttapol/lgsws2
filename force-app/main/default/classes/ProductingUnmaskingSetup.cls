public class ProductingUnmaskingSetup {
    public static string getProductUnmaskSetting() {
        
        String jsonUnmasked = '';        
        Id userProfileId = userinfo.getProfileId();
        List<Profile> myProfile = [Select Name from Profile Where Id = :userProfileId];
        String profileName = !Test.isRunningTest()?myProfile[0].Name:'System Administrator';

        List<Product_Holding_Unmasked__mdt> unmasked = [SELECT ALHpAmount__c,ALInstallmentAmount__c,ALOutstandingAmount__c,ALOverdueAmount__c,AL_CarDownAmt__c,AL_CarpriceAmt__c,AL_FinancialAmount__c,AL_HpAmount__c,AL_InstallmentAmount__c,AL_OutstandingAmount__c,AL_OverdueAmount__c,AL_PenaltyAmount__c,CreditCreditLine__c,CreditLimit__c,CreditOutStanding__c,Credit_CreditLine__c,Credit_Limit__c,Credit_OutStanding__c,DepositAvgOutstanding__c,DepositLedgerBalance__c,DepositOutStanding__c,Deposit_AvgOutstanding__c,Deposit_LedgerBalance__c,Deposit_OutStanding__c,DeveloperName,Id,Label,Language,LoanLimit__c,LoanOutStadning__c,Loan_Limit__c,Loan_OutStadning__c,MasterLabel,NamespacePrefix,Profile_Name__c,QualifiedApiName,SummaryLimit__c,SummaryOutStanding__c FROM Product_Holding_Unmasked__mdt WHERE Profile_Name__c = :profileName];
		System.debug( unmasked );
        System.debug( unmasked.size() );
        // Start Writing json for Unmasked balance
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        try{
        if( unmasked.size() >= 0){
                    gen.writeFieldName('Summary_Section');
                            gen.writeStartObject();
                                gen.writeBooleanField('SummaryString',unmasked[0].SummaryOutStanding__c);
                                gen.writeBooleanField('SummaryODLimit',unmasked[0].SummaryLimit__c);
                            gen.writeEndObject();
                    gen.writeFieldName('Deposit_Section');
                        gen.writeStartObject();
                            gen.writeBooleanField('MarkedLedgerBalance', unmasked[0].DepositLedgerBalance__c);
                            gen.writeBooleanField('MarkedAvgOutStanding',unmasked[0].DepositAvgOutstanding__c);
                            gen.writeBooleanField('MarkedOutStanding',unmasked[0].DepositOutStanding__c);
                        gen.writeEndObject();
                    gen.writeFieldName('Deposit_Detail');
                        gen.writeStartObject();
                            gen.writeBooleanField('MarkedLedgerBalance', unmasked[0].Deposit_LedgerBalance__c);
                            gen.writeBooleanField('MarkedAvgOutStanding',unmasked[0].Deposit_OutStanding__c);
                            gen.writeBooleanField('MarkedOutStanding',unmasked[0].Deposit_AvgOutstanding__c);
                        gen.writeEndObject();
                    gen.writeFieldName('Loan_Section');
                        gen.writeStartObject();
                            gen.writeBooleanField('MarkedOutstanding',unmasked[0].LoanOutStadning__c);
                            gen.writeBooleanField('MarkedVLimit',unmasked[0].LoanLimit__c);
                        gen.writeEndObject();
                    gen.writeFieldName('Loan_Detail');
                        gen.writeStartObject();
                            gen.writeBooleanField('MarkedOutstanding',unmasked[0].Loan_OutStadning__c);
                            gen.writeBooleanField('MarkedVLimit',unmasked[0].Loan_Limit__c);
                        gen.writeEndObject();
                    gen.writeFieldName('CreditCard_Section');
                        gen.writeStartObject();
                            gen.writeBooleanField('MarkedOutstanding',unmasked[0].Credit_OutStanding__c);
                            gen.writeBooleanField('MarkedVLimit',unmasked[0].CreditLimit__c);
                            gen.writeBooleanField('MaskedCreditLine',unmasked[0].CreditCreditLine__c);
                        gen.writeEndObject();
                    gen.writeFieldName('CreditCard_Detail');
                        gen.writeStartArray();
                            // loop 1
                            gen.writeStartObject();
                                gen.writeStringField('from', 'MarkedCurrentBalance');
                                gen.writeStringField('to', unmasked[0].Credit_OutStanding__c == true?'CurrentBalance':'MarkedCurrentBalance');
                            gen.writeEndObject();
                            // loop 2
                            gen.writeStartObject();
                                gen.writeStringField('from', 'MarkedCreditLimit');
                                gen.writeStringField('to', unmasked[0].Credit_Limit__c == true?'CreditLimit':'MarkedCreditLimit');
                            gen.writeEndObject();
                        gen.writeEndArray();
                    gen.writeFieldName('AutoLoan_Section');
                        gen.writeStartObject();
                            gen.writeBooleanField('HP_Amount',unmasked[0].ALHpAmount__c);
                            gen.writeBooleanField('Outstanding_Amount',unmasked[0].ALOutstandingAmount__c);
                            gen.writeBooleanField('Installment_Amount',unmasked[0].ALInstallmentAmount__c);
                            gen.writeBooleanField('MarkedOverdue_Amount',unmasked[0].ALOverdueAmount__c);
                        gen.writeEndObject();
                    gen.writeFieldName('AutoLoan_Detail');
                        gen.writeStartArray();
                        // loop 1
                        gen.writeStartObject();
                            gen.writeStringField('field', 'CarpriceAmt');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_CarpriceAmt__c);
                        gen.writeEndObject();
                        // loop 2
                        gen.writeStartObject();
                            gen.writeStringField('field', 'CarDownAmt');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_CarDownAmt__c);
                        gen.writeEndObject();
                        // loop 3
                        gen.writeStartObject();
                            gen.writeStringField('field', 'FinancialAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_FinancialAmount__c);
                        gen.writeEndObject();
                        // loop 4
                        gen.writeStartObject();
                            gen.writeStringField('field', 'InstallmentAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_InstallmentAmount__c);
                        gen.writeEndObject();
                        // loop 5
                        gen.writeStartObject();
                            gen.writeStringField('field', 'OutstandingAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_OutstandingAmount__c);
                        gen.writeEndObject();
                        // loop 6
                        gen.writeStartObject();
                            gen.writeStringField('field', 'HPTotalAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_HpAmount__c);
                        gen.writeEndObject();
                        // loop 7
                        gen.writeStartObject();
                            gen.writeStringField('field', 'OverdueAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_OverdueAmount__c);
                        gen.writeEndObject();
                        // loop 8
                        gen.writeStartObject();
                            gen.writeStringField('field', 'PenaltyAmount');
                            gen.writeBooleanField('unmasked', unmasked[0].AL_PenaltyAmount__c);
                        gen.writeEndObject();
                        // end loop
                    gen.writeEndArray();
           }
        }catch(Exception e){
        	// exception
        	System.debug(' no record fond on unmasked');
        }    
            gen.writeEndObject();
            // End Writint json for unmasked balance
            System.debug( gen.getAsString());
        jsonUnmasked = gen.getAsString();    
        return jsonUnmasked;
    }
}