public class TypeMapper {
    /*----------------------------------------------------------------------------------
      Author:        Keattisak Chinburarat
      Company:       I&I Consulting 
      Description:   Auto mapper from SOAP Model to DTO
      Inputs:        -   
      Base Class:    -
      Test Class:    -
      History
      <Date>      <Authors Name>     <Brief Description of Change>
      2016-05-09   Keattisak.C        First Draft
      ----------------------------------------------------------------------------------*/
    
    //modified on 30 May 2019 for BA CR
    public static Object MappingSoapToDTO(Object request) {
        return MappingSoapToDTO(request,'');
    }
    //modified on 30 May 2019 for BA CR

    public static Object MappingSoapToDTO(Object request,String rmid) {
        Object ret;
        /*--------------------------------------------------------------------------------
        OSC01
        ----------------------------------------------------------------------------------*/
        if (request instanceOf RTL_CustomerProductHoldingsService.CustomerProductHoldings) {
            RTL_CustomerProductHoldingsService.CustomerProductHoldings item = ((RTL_CustomerProductHoldingsService.CustomerProductHoldings) request);
            ProductHoldingDTO mapping = new ProductHoldingDTO();
            // Error Handler message
            mapping.SoapStatus = item.MuleInfo.Status == null ? '' : item.MuleInfo.Status; // Posible value :   SUCCESS , ERROR 
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.MuleInfo.Message));
            mapping.reqId = item.MuleInfo.LogId;
            //STPE 1 ) RTL_CustomerProductHoldingsService.DepositAccount[]

            if (null != item.DepositAccounts) {
                mapping.depSoapStatus = item.DepositAccounts.MuleInfo.Status == null ? '' : item.DepositAccounts.MuleInfo.Status;
                mapping.depSoapMessage = item.DepositAccounts.MuleInfo.Message;
                if (item.DepositAccounts.DepositAccount != null) {
                    for (RTL_CustomerProductHoldingsService.DepositAccount dep: item.DepositAccounts.DepositAccount) {
                        DepositeProductDTO depObj = new DepositeProductDTO();
                        //========================= Status =============================//
                        depObj.SoapStatus = dep.Status;
                        depObj.SoapMessage = dep.Message;
                        depObj.DepositAccountNumber = dep.AccountNumber;
                        //========================= Mapping =============================//
                        //if(depObj.SoapStatus == 'SUCCESS'){
                        depObj.ProductType = dep.ProductType;
                        depObj.DepositProductCode = dep.ProductCode;
                        depObj.Fiident = dep.Fiident;
                        depObj.ProjectCode = TypeMapper.DefaultValue(dep.ProjectCode);
                        depObj.DataSource = TypeMapper.DefaultValue(dep.DataSource);
                        depObj.OpenedDate = dep.OpenedDate;
                        depObj.Status = dep.AccountStatus;
                        depObj.OutStanding = dep.Outstanding;
                        depObj.AvgOutStanding = dep.AvgOutstanding;
                        depObj.IntEarning = dep.InterestEarned;
                        depObj.Other = dep.Other;
                        depObj.HasJoint = dep.HasJoint;
                        depObj.ODLimit = dep.ODLimit;
                        depObj.LedgerBalance = dep.Ledger;
                        //}

                        mapping.DepositeProducts.add(depObj);
                        System.debug('Outstanding :: ' + depObj.OutStanding);
                        System.debug('AvgOutstanding :: ' + depObj.AvgOutStanding);
                        System.debug('Fiident :: ' + depObj.Fiident);
                        System.debug('Status :: ' + depObj.SoapStatus);
                        System.debug('Message :: ' + depObj.SoapMessage);
                    }
                }
            }
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.CreditCardAccount Status = ' + (item.CreditCardAccounts.Status == null ? 'null : Error' : item.CreditCardAccounts.Status));
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.CreditCardAccount Size = ' + (item.CreditCardAccounts.CreditCardAccount != null ? item.CreditCardAccounts.CreditCardAccount.size() + ' Items' : 'SOAP Object null'));
            if (null != item.CreditCardAccounts) {
                mapping.cardSoapStatus = item.CreditCardAccounts.MuleInfo.Status == null ? '' : item.CreditCardAccounts.MuleInfo.Status;
                mapping.cardSoapMessage = item.CreditCardAccounts.MuleInfo.Message;
                if (item.CreditCardAccounts.CreditCardAccount != null) {
                    //STPE 2) RTL_CustomerProductHoldingsService.CreditCardAccount[]
                    for (RTL_CustomerProductHoldingsService.CreditCardAccount credit: item.CreditCardAccounts.CreditCardAccount) {
                        CreditCardRDCProductDTO creditObj = new CreditCardRDCProductDTO();
                        //========================= Status =============================//
                        creditObj.SoapStatus = credit.Status;
                        creditObj.SoapMessage = credit.Message;
                        creditObj.CardNumber = credit.CardNumber;
                        //if(creditObj.SoapStatus == 'SUCCESS'){
                        //========================= Mapping =============================//
                        creditObj.CreditCardType = credit.CreditCardType;
                        creditObj.SubProductGroup = '';
                        creditObj.ProductName = '';
                        creditObj.OpenedDate = credit.OpenedDate;
                        creditObj.Status = credit.AccountStatus;
                        creditObj.Outstanding = credit.Outstanding == null ? 0 : credit.Outstanding;
                        creditObj.VLimit = credit.Limit_x == null ? 0 : credit.Limit_x;
                        //}

                        mapping.CreditCardRDCProducts.add(creditObj);
                    }
                }
            }
            //System.debug('MULESOFT (OSC01): =>  RTL_CustomerProductHoldingsService.LoanAccount Status = ' + (item.LoanAccounts.Status == null ? 'null : Error' : item.LoanAccounts.Status));
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.LoanAccount Size = ' + (item.LoanAccounts.LoanAccount != null ? item.LoanAccounts.LoanAccount.size() + ' Items' : 'SOAP Object null'));

            if (null != item.LoanAccounts) {
                mapping.loanSoapStatus = item.LoanAccounts.MuleInfo.Status == null ? '' : item.LoanAccounts.MuleInfo.Status;
                mapping.loanSoapMessage = item.LoanAccounts.MuleInfo.Message;
                if (item.LoanAccounts.LoanAccount != null) {
                    //STPE 3) RTL_CustomerProductHoldingsService.CreditCardAccount[] 
                    for (RTL_CustomerProductHoldingsService.LoanAccount loan: item.LoanAccounts.LoanAccount) {
                        LoanProductDTO loanObj = new LoanProductDTO();
                        //========================= Status =============================//
                        loanObj.SoapStatus = loan.Status;
                        loanObj.SoapMessage = loan.Message;
                        loanObj.LoanAccountNumber = loan.AccountNumber;
                        //if(loanObj.SoapStatus == 'SUCCESS'){
                        //========================= Mapping =============================//
                        loanObj.LoanProductCode = loan.ProductCode;
                        loanObj.ProjectCode = TypeMapper.DefaultValue(loan.ProjectCode);
                        loanObj.DataSource = TypeMapper.DefaultValue(loan.DataSource);
                        loanObj.ProductType = loan.ProductType;
                        loanObj.Fiident = loan.Fiident;
                        loanObj.OpenedDate = loan.OpenedDate;
                        loanObj.Status = loan.AccountStatus;
                        loanObj.Outstanding = loan.Outstanding == null ? 0 : loan.Outstanding;
                        loanObj.VLimit = loan.Limit_x == null ? 0 : loan.Limit_x;
                        loanObj.MuturityDate = loan.MaturityDate;
                        loanObj.HasCoBorrower = loan.HasCoborrower;
                        //}
                        mapping.LoanProducts.add(loanObj);
                    }
                }
            }
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.BancassuranceAccount Status = ' + (item.BancassuranceAccounts.Status == null ? 'null : Error' : item.BancassuranceAccounts.Status));
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.BancassuranceAccount Size = ' + (item.BancassuranceAccounts.BancassuranceAccount != null ? item.BancassuranceAccounts.BancassuranceAccount.size() + ' Items' : 'SOAP Object null'));
            if (null != item.BancassuranceAccounts) {
                mapping.BASoapStatus = item.BancassuranceAccounts.MuleInfo.Status == null ? '' : item.BancassuranceAccounts.MuleInfo.Status;
                mapping.BASoapMessage = item.BancassuranceAccounts.MuleInfo.Message;
                if (item.BancassuranceAccounts.BancassuranceAccount != null) {
                    //STEP 4) RTL_CustomerProductHoldingsService.BancassuaranceAccount[] 
                    for (RTL_CustomerProductHoldingsService.BancassuranceAccount ban: item.BancassuranceAccounts.BancassuranceAccount) {
                        BancassuranceDTO banObj = new BancassuranceDTO();
                        //========================= Status =============================//
                        banObj.SoapStatus = ban.Status;
                        banObj.SoapMessage = ban.Message;
                        banObj.PolicyNo = ban.PolicyNumber;
                        //if(banObj.SoapStatus == 'SUCCESS'){
                        //========================= Mapping =============================//
                        banObj.SubProductGroup = ban.SubProductGroup;
                        banObj.ProductName = ban.ProductName;
                        banObj.InsuranceCompany = ban.InsuranceCompany;
                        banObj.OpenedDate = ban.OpenedDate;
                        banObj.Status = ban.PolicyStatus;
                        banObj.SumInsure = ban.SumInsure == null ? 0 : ban.SumInsure;
                        banObj.AFYP = ban.AFVP == null ? 0 : ban.AFVP;
                        banObj.ExpiryDate = ban.ExpiryDate;
                        //}

                        mapping.Bancassurances.add(banObj);
                    }

                }
                mapping.Bancassurances.sort();
            }

            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.InvestmentAccount Status = ' + (item.InvestmentAccounts.Status == null ? 'null : Error' : item.InvestmentAccounts.Status));
            //System.debug('MULESOFT (OSC01): => RTL_CustomerProductHoldingsService.InvestmentAccount Size = ' + (item.InvestmentAccounts.InvestmentAccount != null ? item.InvestmentAccounts.InvestmentAccount.size() + ' Items' : 'SOAP Object null'));

            if (null != item.InvestmentAccounts) {
                mapping.investmentSoapStatus = item.InvestmentAccounts.MuleInfo.Status == null ? '' : item.InvestmentAccounts.MuleInfo.Status;
                mapping.investmentSoapMessage = item.InvestmentAccounts.MuleInfo.Message;
                if (item.InvestmentAccounts.InvestmentAccount != null) {
                    //STEP 5) RTL_CustomerProductHoldingsService.InvestmentAccount[] 
                    for (RTL_CustomerProductHoldingsService.InvestmentAccount inv: item.InvestmentAccounts.InvestmentAccount) {
                        InvestmentProductDTO invObj = new InvestmentProductDTO();
                        //========================= Status =============================//
                        invObj.SoapStatus = inv.Status;
                        invObj.SoapMessage = inv.Message;
                        invObj.UnitHolderNo = inv.UnitHoldNo;
                        //if(invObj.SoapStatus == 'SUCCESS'){
                        //========================= Mapping =============================//
                        invObj.SubProductGroup = '' /*cannot mapping*/ ;
                        invObj.ProductName = '' /*cannot mapping*/ ;
                        invObj.AssetClass = '' /*cannot mapping*/ ;
                        invObj.FundCode = inv.FundCode;
                        invObj.IssuerFundHouse = inv.Issuer;
                        invObj.OpenedDate = inv.OpenedDate;
                        invObj.Units = inv.Units;
                        invObj.InitialValue = inv.InitialValue;
                        invObj.MarketValue = inv.MarketValue;
                        invObj.UnrealizedGL = inv.UnrealizedGL;
                        invObj.CostOfInvestment = inv.AvgCost;
                        invObj.NumberOfUnit = inv.NoOfUnit;
                        // SCR No. 2017-1-1804 for Average field Add on 18/10/2017
                        invObj.NavUnit = inv.NavUnit;
                        // End SCR No. 2017-1-1804 for Average field Add on 18/10/2017
                        //}
                        mapping.InvestmentProducts.add(invObj);
                    }
                }
            }
            ret = mapping;
        }

        /*--------------------------------------------------------------------------------
          OSC02
          ----------------------------------------------------------------------------------*/
        if (request instanceOf RTL_DepositProductDetailsService.DepositProductDetails) {
            RTL_DepositProductDetailsService.DepositProductDetails item = ((RTL_DepositProductDetailsService.DepositProductDetails) request);


            //System.debug('MULESOFT (OSC02): => RTL_DepositProductDetailsService.DepositProductDetails Status = '
            //             + (item.Status == null ? 'null : Error' : item.Status));

            DepositeProductDetailDTO mapping = new DepositeProductDetailDTO();
            // Error Handler message
            mapping.SoapStatus = item.Status == null ? '' : item.Status;
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));

            /*====================================================/
             *DepositAccountInfo
             *====================================================*/


            if (null != item.DepositAccount) {
                string productcode = TypeMapper.DefaultValue(item.DepositAccount.ProductCode);
                productcode = productcode.length() > 2 ? productcode.substring(2) : productcode;

                mapping.DepositAccountNumber = TypeMapper.DefaultValue(item.DepositAccount.AccountNumber);
                mapping.DepositProductCode = productcode;
                mapping.SubProductGroup = '';
                mapping.ProductName = '';
                mapping.OpenedDate = item.DepositAccount.OpenedDate;
                mapping.Status = TypeMapper.DefaultValue(item.DepositAccount.AccountStatus);
                mapping.OutStanding = item.DepositAccount.Outstanding;
                //mapping.AvgOutStanding             =  item.;
                mapping.InterestEarned = TypeMapper.DefaultValue(item.DepositAccount.InterestEarned);
                //mapping.Other = item.DepositAccount.;
                mapping.HasJoint = TypeMapper.DefaultValue(item.DepositAccount.HasJoint);
                mapping.AccountName = TypeMapper.DefaultValue(item.DepositAccount.AccountName);
                mapping.InterestRate = TypeMapper.DefaultValue(item.DepositAccount.InterestRate);
                mapping.MaturityDate = item.DepositAccount.MaturityDate;
                mapping.SMSAlertService = TypeMapper.DefaultValue(item.DepositAccount.SMSAlertService);
                mapping.MEAccountBundledBank = TypeMapper.DefaultValue(item.DepositAccount.MEAccountBundledBank);
                mapping.NoActiveDebitCardBundling = TypeMapper.DefaultValue(item.DepositAccount.NumberOfActiveDebitCardBundling);
                mapping.AvgBalanceMTD = item.DepositAccount.AvgBalanceMTD;
                mapping.ODLimit = item.DepositAccount.ODLimit;
                mapping.LedgerBalance = item.DepositAccount.Ledger;
                System.debug('Outstanding :: ' + item.DepositAccount.Outstanding);
                System.debug('AvgOutstanding :: ' + item.DepositAccount.AvgBalanceMTD);
            }
            /*====================================================/
             *JointAccountInfo
             *    NOTE:
             *         WDSL Return Lists
             *====================================================*/

            if (null != item.JointAccount && null != item.JointAccount.JointAccount) {
                /*JoinAccountInformationDTO joinObj = new JoinAccountInformationDTO();
                mapping.JoinAccountInformations.add(joinObj);
                joinObj.JointAccountOwnerNumber = TypeMapper.DefaultValue(item.JointAccount.JointAccount.OwnerNumber);
                joinObj.Relationship = TypeMapper.DefaultValue(item.JointAccount.JointAccount.Relationship);
                */
                /*drop 2 will use below code*/
                for (RTL_DepositProductDetailsService.JointAccountInfo jointAcct: item.JointAccount.JointAccount) {
                    JoinAccountInformationDTO joinObj = new JoinAccountInformationDTO();
                    mapping.JoinAccountInformations.add(joinObj);
                    joinObj.JointAccountOwnerNumber = TypeMapper.DefaultValue(jointAcct.OwnerNumber);
                    joinObj.Relationship = TypeMapper.DefaultValue(jointAcct.Relationship);
                }
            } else {
                JoinAccountInformationDTO joinObj = new JoinAccountInformationDTO();
                mapping.JoinAccountInformations.add(joinObj);
            }

            /*====================================================/
             *Last Month Transaction Summary 
             *====================================================*/
            if (null != item.LastMonthTransactionSummary) {
                LastMonthTransactionSummaryDTO lastmonth = new LastMonthTransactionSummaryDTO();
                mapping.LastMonthTransactionSummary = lastmonth;
                lastmonth.OfDeposit = TypeMapper.DefaultValue(item.LastMonthTransactionSummary.MonthlyAvgDepositTransactions);
                lastmonth.OfWithdraw = TypeMapper.DefaultValue(item.LastMonthTransactionSummary.MonthlyAvgWithdrawTransactions);
                lastmonth.OfTransferOutTMB = TypeMapper.DefaultValue(item.LastMonthTransactionSummary.MonthlyAvgTransfersWithinTMB);
                lastmonth.OfTransferOutOther = TypeMapper.DefaultValue(item.LastMonthTransactionSummary.MonthlyAvgTransfersToOtherBanks);
                lastmonth.OfBillPayment = TypeMapper.DefaultValue(item.LastMonthTransactionSummary.MonthlyAvgBillPaymentTransactions);
            }

            /*====================================================/
             *BeneficiaryInfo
             *    NOTE:
             *         WDSL Return Lists
             *====================================================*/
            if (null != item.Beneficiary && null != item.Beneficiary.Beneficiary) {
                /*BeneficiaryInformationDTO ben = new BeneficiaryInformationDTO();
                mapping.BeneficiaryInformations.add(ben);
                ben.BeneficiaryName = item.Beneficiary.Beneficiary.Name;
                ben.Relationship = item.Beneficiary.Beneficiary.Relationship;
                ben.BenefitPercent = item.Beneficiary.Beneficiary.BenefitPercentage;
                */
                //drop 2 will use below code
                for (RTL_DepositProductDetailsService.BeneficiaryInfo benefit: item.Beneficiary.Beneficiary) {
                    BeneficiaryInformationDTO ben = new BeneficiaryInformationDTO();
                    mapping.BeneficiaryInformations.add(ben);
                    ben.BeneficiaryName = benefit.Name;
                    ben.Relationship = benefit.Relationship;
                    ben.BenefitPercent = benefit.BenefitPercentage;
                }


            } else {
                BeneficiaryInformationDTO ben = new BeneficiaryInformationDTO();
                mapping.BeneficiaryInformations.add(ben);
            }

            /*====================================================/
             *StandingOrder
             *    NOTE:
             *         WDSL Return only 1 item
             *====================================================*/
            if (null != item.StandingOrder && null != item.StandingOrder.StandingOrder) {
                StandingOrderDTO stdOrder = new StandingOrderDTO();
                mapping.StandingOrders.add(stdOrder);
                stdOrder.RequestDate = item.StandingOrder.StandingOrder.RequestDate;
                stdOrder.Frequency = item.StandingOrder.StandingOrder.Frequency;
                stdOrder.SettlementDate = item.StandingOrder.StandingOrder.SettlementDate;
                stdOrder.Type = item.StandingOrder.StandingOrder.Type_x;
                stdOrder.LastAmount = item.StandingOrder.StandingOrder.LastAmount;
                stdOrder.LastTrxDate = item.StandingOrder.StandingOrder.LastTransactionDate;

            }



            ret = mapping;
        }

        /*--------------------------------------------------------------------------------
          OSC03
          ----------------------------------------------------------------------------------*/
        if (request instanceof RTL_CreditCardDetailsService.CreditCardDetails) {
            RTL_CreditCardDetailsService.CreditCardDetails item = ((RTL_CreditCardDetailsService.CreditCardDetails) request);
            CreditcardInformationDTO mapping = new CreditcardInformationDTO();
            // Error Handler message
            mapping.SoapStatus = item.Status == null ? '' : item.Status;
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));

            /*====================================================/
             *CreditCardInfo
             *====================================================*/
            if (null != item.CreditCardInfo) {
                mapping.CardNumber = TypeMapper.DefaultValue(item.CreditCardInfo.CardNumber);
                mapping.CreditLimit = TypeMapper.DefaultValue(item.CreditCardInfo.CreditLimit);
                mapping.TemporaryLine = TypeMapper.DefaultValue(item.CreditCardInfo.TemporaryLine);
                mapping.CycleCut = TypeMapper.DefaultValue(item.CreditCardInfo.CycleCut);
                mapping.UsageStatus = TypeMapper.DefaultValue(item.CreditCardInfo.UsageStatus);
                mapping.BlockCode = TypeMapper.DefaultValue(item.CreditCardInfo.BlockCode);
                mapping.NextExpiredPointOn = item.CreditCardInfo.NextExpiredPointOn;
                mapping.CashChillChill = TypeMapper.DefaultValue(item.CreditCardInfo.CashChillChill);
                mapping.CashWithdrawalAccountNumber = TypeMapper.DefaultValue(item.CreditCardInfo.CashWithdrawalAccountNumber);
                mapping.OpenedDate = item.CreditCardInfo.OpenedDate;
                mapping.CurrentBalance = TypeMapper.DefaultValue(item.CreditCardInfo.CurrentBalance);
                mapping.TemporaryLinePeriod = TypeMapper.DefaultValue(item.CreditCardInfo.TemporaryLinePeriod);
                mapping.PaymentDue = item.CreditCardInfo.PaymentDue;
                mapping.PaymentBehavior = TypeMapper.DefaultValue(item.CreditCardInfo.PaymentBehavior);
                mapping.RewardPoints = TypeMapper.DefaultValue(item.CreditCardInfo.RewardPoints);
                mapping.NextExpiredPoints = TypeMapper.DefaultValue(item.CreditCardInfo.NextExpiredPoints);
                mapping.CashChillChillStatus = TypeMapper.DefaultValue(item.CreditCardInfo.CashChillChillStatus);
                mapping.DirectDebitAccountNumber = TypeMapper.DefaultValue(item.CreditCardInfo.DirectDebitAccountNumber);
                mapping.UsageBehavior = TypeMapper.DefaultValue(item.CreditCardInfo.UsageBehavior);
                mapping.LastPaymentDate = item.CreditCardInfo.LastPaymentDate;
            }


            /*====================================================/
             *SupplementaryInfo
             *NOTE:
             *         WDSL Return only 1 item
             *====================================================*/
            if (null != item.SupplementaryInfo && null != item.SupplementaryInfo.SupplementaryInfo) {
                SupplementaryInformationDTO supplementInfo = new SupplementaryInformationDTO();
                mapping.SupplementaryInformations.add(supplementInfo);
                supplementInfo.SupplementaryCardNumber = TypeMapper.DefaultValue(item.SupplementaryInfo.SupplementaryInfo.CardNumber);
                supplementInfo.SupplementaryCardholderName = TypeMapper.DefaultValue(item.SupplementaryInfo.SupplementaryInfo.CardHolderName);

            } else {
                SupplementaryInformationDTO supplementInfo = new SupplementaryInformationDTO();
                mapping.SupplementaryInformations.add(supplementInfo);
            }
            /*====================================================/
             *PayPlanRecord
             *====================================================*/
            if (null != item.PayPlanRecord) {
                SoGoodPayPlanDTO soGood = new SoGoodPayPlanDTO();
                mapping.SoGoodPayPlan = soGood;
                soGood.LastCycleTransactionNonInterestCharge = TypeMapper.DefaultValue(item.PayPlanRecord.NumberOfNonInterestChargeTransactions);
                soGood.LastCycleAmountInTHBNonInterestCharge = TypeMapper.DefaultValue(item.PayPlanRecord.AmountOfNonInterestChargeTransactions);
                soGood.LastCycleAmountInTHBNonInterestCharge = TypeMapper.DefaultValue(item.PayPlanRecord.NumberOfInterestChargeTransactions);
                soGood.LastCycleAmountInTHBInterestCharge = TypeMapper.DefaultValue(item.PayPlanRecord.AmountOfInterestChargeTransactions);
                soGood.TotalTransaction = TypeMapper.DefaultValue(item.PayPlanRecord.TotalNumberOfTransactions);
                soGood.TotalTHB = TypeMapper.DefaultValue(item.PayPlanRecord.TotalAmountOfTransactions);
            }
            ret = mapping;

        }
        //OSC04
        if (request instanceOf RTL_LoanProductDetailsService.LoanProductDetails) {
            RTL_LoanProductDetailsService.LoanProductDetails item = ((RTL_LoanProductDetailsService.LoanProductDetails) request);
            LoanProductDetailDTO mapping = new LoanProductDetailDTO();
            // Error Handler message
            mapping.SoapStatus = item.Status == null ? '' : item.Status;
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));

            /*====================================================/
             *LoanInfo
             *====================================================*/
            if (null != item.LoanInformation) {
                mapping.LoanAccountNumber = TypeMapper.DefaultValue(item.LoanInformation.AccountNumber);
                mapping.LoanProductCode = TypeMapper.DefaultValue(item.LoanInformation.ProductCode);
                //mapping.ProductName = '';
                //mapping.SubProductGroup = '';
                mapping.TenorMonth = TypeMapper.DefaultValue(item.LoanInformation.Tenor);
                mapping.AccountStatus = TypeMapper.DefaultValue(item.LoanInformation.AccountStatus);
                mapping.CreditLimit = TypeMapper.DefaultValue(item.LoanInformation.CreditLimit);
                mapping.Outstanding = TypeMapper.DefaultValue(item.LoanInformation.Outstanding);
                mapping.OpenDate = item.LoanInformation.OpenDate;
                mapping.ContractEndDate = item.LoanInformation.ContractEndDate;
                mapping.PaymentDueDate = item.LoanInformation.PaymentDueDate;
                mapping.OtherConditions = TypeMapper.DefaultValue(item.LoanInformation.OtherConditions);
                mapping.CampaignName = TypeMapper.DefaultValue(item.LoanInformation.CampaignName);
                mapping.LastPaymentDate = item.LoanInformation.LastPaymentDate;
                mapping.RetentionDate = item.LoanInformation.RetentionDate;
                mapping.CurrentTenor = TypeMapper.DefaultValue(item.LoanInformation.CurrentTenor);
                mapping.HasCoBorrowe = TypeMapper.DefaultValue(item.LoanInformation.HasCoBorrower);
            }


            /*====================================================/
             *CoBorrowerInfo
             *NOTE:
             *         WDSL Return Lists
             *====================================================*/

            if (null != item.CoBorrowerInformation && null != item.CoBorrowerInformation.CoBorrower) {
                /*CoBorrowerDTO coBorr = new CoBorrowerDTO();
                mapping.CoBorroweres.add(coBorr);
                coBorr.CoBorrowerName = TypeMapper.DefaultValue(item.CoBorrowerInformation.CoBorrower.Name);
                coBorr.CoBorrowerRelationship = TypeMapper.DefaultValue(item.CoBorrowerInformation.CoBorrower.Relationship);
                */
                //drop 2 will use below code
                for (RTL_LoanProductDetailsService.CoBorrowerInformation coborw: item.CoBorrowerInformation.CoBorrower) {
                    CoBorrowerDTO coBorr = new CoBorrowerDTO();
                    mapping.CoBorroweres.add(coBorr);
                    coBorr.CoBorrowerName = TypeMapper.DefaultValue(coborw.Name);
                    coBorr.CoBorrowerRelationship = TypeMapper.DefaultValue(coborw.Relationship);
                }


            } else {
                CoBorrowerDTO coBorr = new CoBorrowerDTO();
                mapping.CoBorroweres.add(coBorr);
            }


            /*====================================================/
             *InterestedPlanInfo
             *NOTE:
             *         WDSL Return Lists
             *====================================================*/
            if (null != item.InterestPlan && null != item.InterestPlan.InterestPlan) {

                /*InterestPlanDTO interestedPlan = new InterestPlanDTO();
                mapping.InterestPlans.add(interestedPlan);
                interestedPlan.Period = item.InterestPlan.InterestPlan.Period;
                interestedPlan.InterestRate = item.InterestPlan.InterestPlan.InterestRate;
                */
                //drop 2 will use below code
                for (RTL_LoanProductDetailsService.InterestPlan interestP: item.InterestPlan.InterestPlan) {
                    InterestPlanDTO interestedPlan = new InterestPlanDTO();
                    mapping.InterestPlans.add(interestedPlan);
                    interestedPlan.Period = interestP.Period;
                    interestedPlan.InterestRate = interestP.InterestRate;

                }


            }

            /*====================================================/
             *RelatedInsurance
             *====================================================*/
            if (null != item.RelatedInsuranceInformation && null != item.RelatedInsuranceInformation.RelatedInsurance) {
                RelatedInsuranceDTO related = new RelatedInsuranceDTO();
                mapping.RelatedInsurance = related;
                related.Insurance = item.RelatedInsuranceInformation.RelatedInsurance.Insurance;
                related.PolicyNumber = item.RelatedInsuranceInformation.RelatedInsurance.PolicyNumber;
                related.Insurer = item.RelatedInsuranceInformation.RelatedInsurance.Insurer;
                related.SumInsured = item.RelatedInsuranceInformation.RelatedInsurance.SumInsured;
                related.StartDate = item.RelatedInsuranceInformation.RelatedInsurance.StartDate;
                related.EndDate = item.RelatedInsuranceInformation.RelatedInsurance.EndDate;
            }


            /*====================================================/
             *LoanPayment
             *====================================================*/
            if (null != item.LoanPaymentInformation && null != item.LoanPaymentInformation.LoanPayment) {
                LoanPaymentDTO loan = new LoanPaymentDTO();
                mapping.LoanPayment = loan;
                loan.PaymentMethod = item.LoanPaymentInformation.LoanPayment.PaymentMethod;
                loan.SavingAccount = item.LoanPaymentInformation.LoanPayment.SavingAccount;
                loan.InstallmentBalance = item.LoanPaymentInformation.LoanPayment.InstallmentBalance;
                loan.PayrollDeductionUnit = item.LoanPaymentInformation.LoanPayment.PayrollDeductionUnit;
            }
            ret = mapping;

        }
        //OSC05
        if (request instanceOf RTL_BancPrdDetailsService.BancassuranceProductDetails) {

            RTL_BancPrdDetailsService.BancassuranceProductDetails item = ((RTL_BancPrdDetailsService.BancassuranceProductDetails) request);
            //System.debug('MULESOFT (OSC05): => RTL_BancPrdDetailsService.BancassuranceProductDetails Status = ' + (item.Status == null ? 'null : Error' : item.Status));
            BancassuranceInformationDTO mapping = new BancassuranceInformationDTO();
            // Error Handler message
            mapping.SoapStatus = item.Status == null ? '' : item.Status;
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));

            //System.debug('MULESOFT (OSC05): => RTL_BancPrdDetailsService.BancassuranceInformation size = ' + (item.BancassuranceInformation == null ? '0' : '1'));

            if (null != item.BancassuranceInformation) {
                /*====================================================/
                 *BancassuranceInfo
                 *====================================================*/
                mapping.PolicyNo = item.BancassuranceInformation.PolicyNo;
                mapping.ProductType = item.BancassuranceInformation.ProductType;
                mapping.ProductCode = item.BancassuranceInformation.TMBProductCode;
                mapping.ProductName = item.BancassuranceInformation.ProductName;
                mapping.SubProductGroup = '';
                mapping.EffectiveDate = item.BancassuranceInformation.EffectiveDate;
                mapping.PolicyStatus = TypeMapper.DefaultValue(item.BancassuranceInformation.PolicyStatus);
                mapping.PolicyNo = TypeMapper.DefaultValue(item.BancassuranceInformation.PolicyNo);
                mapping.SumInsured = TypeMapper.DefaultValue(item.BancassuranceInformation.SumInsured);
                mapping.AFYP = TypeMapper.DefaultValue(item.BancassuranceInformation.AFYP);
                mapping.ExpiryDate = item.BancassuranceInformation.ExpiryDate;
                mapping.Sales = TypeMapper.DefaultValue(item.BancassuranceInformation.Sales);
            }

            /*====================================================/
             *BancassuranceDetail
             *====================================================*/

            if (null != item.BancassuranceDetails) {
                BancassuranceDetailsDTO bancDetail = new BancassuranceDetailsDTO();
                mapping.BancassuranceDetail = bancDetail;
                bancDetail.InsuranceCompany = item.BancassuranceDetails.InsuranceCompany;
                //bancDetail.Address = '';
                //bancDetail.ContactNumber1 = '';
                //bancDetail.ContactNumber2 = '';

            }
            /*====================================================/
             *PaymentInfo
             *====================================================*/
            if (null != item.PaymentInformation) {
                PaymentInformationDTO paymentInfo = new PaymentInformationDTO();
                mapping.PaymentInformation = paymentInfo;
                paymentInfo.PaymentMode = item.PaymentInformation.PaymentMode;
                paymentInfo.PremiumAmount = TypeMapper.DefaultValue(item.PaymentInformation.PremiumAmount);
                paymentInfo.PaymentMethod = item.PaymentInformation.PaymentMethod;
                paymentInfo.TotalPremiumPaid = TypeMapper.DefaultValue(item.PaymentInformation.TotalPremiumPaid);
                paymentInfo.YearOfPayment = item.PaymentInformation.YearOfPayment;
                paymentInfo.NumberOfTimePremiumPaid = TypeMapper.DefaultValue(item.PaymentInformation.NumberOfTimePremiumPaid);
                paymentInfo.NextDueDate = item.PaymentInformation.NextDueDate;
                paymentInfo.LastPaymentDate = item.PaymentInformation.LastPaymentDate;
            }
            /*====================================================/
             *NextCashBackInfo
             *====================================================*/
            if (null != item.NextCashBackInformation) {
                NextCashBackInformationzmationDTO nextCashBack = new NextCashBackInformationzmationDTO();
                mapping.NextCashBackInformationzmation = nextCashBack;
                nextCashBack.PaymentDate = item.NextCashBackInformation.PaymentDate;
                nextCashBack.Amount = TypeMapper.DefaultValue(item.NextCashBackInformation.Amount);
                nextCashBack.TotalPaid = TypeMapper.DefaultValue(item.NextCashBackInformation.TotalPaid);
            }
            /*====================================================/
             *InsuredPropertyAsset
             *====================================================*/
            if (null != item.InsuredPropertyAsset) {
                InsuredPropertyAssetDTO insuredProperty = new InsuredPropertyAssetDTO();
                mapping.InsuredPropertyAsset = insuredProperty;
                insuredProperty.Address = TypeMapper.DefaultValue(item.InsuredPropertyAsset.Address);
                insuredProperty.Address = insuredProperty.Address == ', , , , ' ? '' : insuredProperty.Address;
            }
            /*====================================================/
             *InsuredAutomobileAsset
             *====================================================*/
            if (null != item.InsuredAutomobileAsset) {
                InsuredAutomobileAssetDTO insuredAutomobile = new InsuredAutomobileAssetDTO();
                mapping.InsuredAutomobileAsset = insuredAutomobile;
                insuredAutomobile.Brand = TypeMapper.DefaultValue(item.InsuredAutomobileAsset.Brand);
                insuredAutomobile.YearOfManufactured = TypeMapper.DefaultValue(item.InsuredAutomobileAsset.YearOfManufactured);
                insuredAutomobile.Model = TypeMapper.DefaultValue(item.InsuredAutomobileAsset.Model);
                insuredAutomobile.PlateNumber = TypeMapper.DefaultValue(item.InsuredAutomobileAsset.PlateNumber);
            }
            /*====================================================/
             *BeneficiaryInfo
             *    NOTE:
             *         WDSL Return only 1 item
             *====================================================*/
            if (null != item.BeneficiaryInformation && null != item.BeneficiaryInformation.Beneficiary) {
                for (RTL_BancPrdDetailsService.BeneficiaryInformation beneficary: item.BeneficiaryInformation.Beneficiary) {
                    BeneficiaryInformationDTO beneficaryInfo = new BeneficiaryInformationDTO();
                    mapping.BeneficiaryInformations.add(beneficaryInfo);
                    beneficaryInfo.BeneficiaryName = TypeMapper.DefaultValue(beneficary.Name);
                    beneficaryInfo.Relationship = TypeMapper.DefaultValue(beneficary.Relationship);
                    beneficaryInfo.BenefitPercent = TypeMapper.DefaultValue(beneficary.BenefitPercentage);
                }

            }
            /*====================================================/
             *InsuranceClaimRecord
             *    NOTE:
             *         WDSL Return Lists
             *====================================================*/
            if (null != item.InsuranceClaimRecord && null != item.InsuranceClaimRecord.ClaimRecord) {
                /*InsuranceClaimRecordDTO insuranceClaim = new InsuranceClaimRecordDTO();
mapping.InsuranceClaimRecords.add(insuranceClaim);
insuranceClaim.Date_x = item.InsuranceClaimRecord.ClaimRecord.Date_x;
insuranceClaim.Type_x = TypeMapper.DefaultValue(item.InsuranceClaimRecord.ClaimRecord.Type_x);
insuranceClaim.Description = TypeMapper.DefaultValue(item.InsuranceClaimRecord.ClaimRecord.Description);
insuranceClaim.RequestAmount = TypeMapper.DefaultValue(item.InsuranceClaimRecord.ClaimRecord.RequestAmount);
insuranceClaim.ApprovedAmount = TypeMapper.DefaultValue(item.InsuranceClaimRecord.ClaimRecord.ApprovedAmount);
                */
                //drop 2 will use below code
                for (RTL_BancPrdDetailsService.InsuranceClaimRecord insurance: item.InsuranceClaimRecord.ClaimRecord) {
                    InsuranceClaimRecordDTO insuranceClaim = new InsuranceClaimRecordDTO();
                    mapping.InsuranceClaimRecords.add(insuranceClaim);
                    insuranceClaim.Date_x = insurance.Date_x;
                    insuranceClaim.Type_x = TypeMapper.DefaultValue(insurance.Type_x);
                    insuranceClaim.Description = TypeMapper.DefaultValue(insurance.Description);
                    insuranceClaim.RequestAmount = TypeMapper.DefaultValue(insurance.RequestAmount);
                    insuranceClaim.ApprovedAmount = TypeMapper.DefaultValue(insurance.ApprovedAmount);
                }

            }
            ret = mapping;
        }
        //OSC06
        if (request instanceOf RTL_InvestmentPrdDetailsService.InvestmentProductDetails) {
            RTL_InvestmentPrdDetailsService.InvestmentProductDetails item = ((RTL_InvestmentPrdDetailsService.InvestmentProductDetails) request);
            InvestmentProductDetailsDTO mapping = new InvestmentProductDetailsDTO();
            // Error Handler message
            mapping.SoapStatus = item.Status == null ? '' : item.Status;
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));

            /*====================================================/
             *InvestmentInfo
             *====================================================*/
            if (null != item.InvestmentInformation) {
                InvestmentInformationDTO investmentInfo = new InvestmentInformationDTO();
                mapping.InvestmentInformation = investmentInfo;
                //investmentInfo.ProductName = '';
                //investmentInfo.ProductType = '';
                //investmentInfo.AssetType = '';
                //investmentInfo.FundType = '';

                //investmentInfo.UnitHolderNo = TypeMapper.DefaultValue(item.InvestmentInformation.UnitHolderNo);
                //investmentInfo.FundCode = '';
                investmentInfo.NumberOfUnit = TypeMapper.DefaultValue(item.InvestmentInformation.NumberOfUnit);
                investmentInfo.CostOfInvestment = TypeMapper.DefaultValue(item.InvestmentInformation.CostOfInvestment);
                investmentInfo.MarketValue = TypeMapper.DefaultValue(item.InvestmentInformation.MarketValue);
                investmentInfo.UnrealizedGL = TypeMapper.DefaultValue(item.InvestmentInformation.UnrealizedGL);
                investmentInfo.NAVUnit = TypeMapper.DefaultValue(item.InvestmentInformation.NAVUnit);
                investmentInfo.AipInstruction = TypeMapper.DefaultValue(item.InvestmentInformation.AipInstruction);
            }


            /*====================================================/
             *InvestmentTransaction
             *====================================================*/
            if (null != item.InvestmentTransaction && null != item.InvestmentTransaction.InvestmentTransaction) {
                for (RTL_InvestmentPrdDetailsService.InvestmentTransaction tran: item.InvestmentTransaction.InvestmentTransaction) {
                    InvestmentTransactionDTO investmentTransaction = new InvestmentTransactionDTO();
                    mapping.InvestmentTransactions.add(investmentTransaction);
                    investmentTransaction.TransactionDate = tran.TransactionDate;
                    investmentTransaction.SettlementDate = tran.SettlementDate;
                    investmentTransaction.TransactionType = TypeMapper.DefaultValue(tran.TransactionType);
                    investmentTransaction.UnitMovement = TypeMapper.DefaultValue(tran.UnitMovement);
                    investmentTransaction.UnitOutstanding = TypeMapper.DefaultValue(tran.UnitOutstanding);
                    investmentTransaction.TransactionValue = TypeMapper.DefaultValue(tran.TransactionValue);
                    investmentTransaction.ValuePerUnit = TypeMapper.DefaultValue(tran.ValuePerUnit);
                    investmentTransaction.Statue = TypeMapper.DefaultValue(tran.Statue);
                    investmentTransaction.InteractChannel = TypeMapper.DefaultValue(tran.InteractChannel);

                }
            }

            /*====================================================/
             *AutoInvestmentPlan
             *====================================================*/
            if (null != item.AutoInvestmentPlan && null != item.AutoInvestmentPlan.AutoInvestmentPlan) {

                //drop 2 will be a list
                for (RTL_InvestmentPrdDetailsService.AutoInvestmentPlan auto: item.AutoInvestmentPlan.AutoInvestmentPlan) {
                    //RTL_InvestmentPrdDetailsService.AutoInvestmentPlan auto = item.AutoInvestmentPlan.AutoInvestmentPlan;
                    AutoInvestmentPlanDTO autoInvestment = new AutoInvestmentPlanDTO();
                    mapping.AutoInvestmentPlans.add(autoInvestment);
                    //autoInvestment.Instruction = auto.Instruction;
                    autoInvestment.Date_x = auto.Date_x;
                    autoInvestment.SinceDate = auto.SinceDate;
                    autoInvestment.CreatedChannel = auto.CreatedChannel;
                    autoInvestment.Frequency = auto.Frequency;
                    autoInvestment.Balance = auto.Balance;
                    autoInvestment.SavingAccountBundling = auto.SavingAccountBundling;

                }
            }


            ret = mapping;
        }

        //OSC07
        if (request instanceOf RTL_CvsAnalyticsDataService.CVSAnalyticsData) {
            RTL_CvsAnalyticsDataService.CVSAnalyticsData item = ((RTL_CvsAnalyticsDataService.CVSAnalyticsData) request);
            CVSAnalyticsDataDTO mapping = new CVSAnalyticsDataDTO();
            // Error Handler message
            mapping.SoapStatus = TypeMapper.DefaultValue(item.Status);
            mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));
            //CR For BA 30 May 2019
            
            String baExtraInfo = '';
            try {
                List<Account> accountLst = [SELECT Id,RTL_BA_Privilege__c,Name
                                    From Account 
                                    Where TMB_Customer_ID_PE__c =: rmid 
                                    AND RTL_BA_Privilege__c <> null
                                  ];
                if (accountLst != null && accountLst.size() > 0 ) 
                    baExtraInfo = '- '+accountLst[0].RTL_BA_Privilege__c;
                //baExtraInfo = account.Name;
            }catch(Exception e) {
                baExtraInfo = e.getMessage();
            }
            
            if (mapping.currentPrivilege2Desc != null && mapping.currentPrivilege2Desc.length() > 0) {
                mapping.currentPrivilege2Desc = TypeMapper.DefaultValue(item.currentPrivilege2Desc) + '\n'+baExtraInfo;
            }else {
                mapping.currentPrivilege2Desc = TypeMapper.DefaultValue(item.currentPrivilege2Desc) + baExtraInfo;
            }
            //mapping.currentPrivilege2Desc = TypeMapper.DefaultValue(item.currentPrivilege2Desc);
            
            //System.debug('mapping.currentPrivilege2Desc '+mapping.currentPrivilege2Desc);
            //CR For BA 30 May 2019
            /*====================================================/
             *CVSAnalyticsData
             *====================================================*/
            mapping.MIBStatus = TypeMapper.DefaultValue(item.MIBStatus);
            mapping.UsagePercentage = TypeMapper.DefaultValue(item.UsagePercentage);
            mapping.suitability = TypeMapper.DefaultValue(item.suitability);
            mapping.privilege = TypeMapper.DefaultValue(item.privilege);
            mapping.privilege2Url = TypeMapper.DefaultValue(item.privilege2Url);
            //mapping.currentPrivilege2Desc = TypeMapper.DefaultValue(item.currentPrivilege2Desc);
            mapping.entitledPrivilege2Desc = TypeMapper.DefaultValue(item.entitledPrivilege2Desc);
            mapping.afPrivilegeFlag = TypeMapper.DefaultValue(item.afPrivilegeFlag);

            mapping.touchStatus = TypeMapper.DefaultValue(item.touchStatus);
            mapping.ibStatus = TypeMapper.DefaultValue(item.ibStatus);
            mapping.csProfFreqBr = TypeMapper.DefaultValue(item.csProfFreqBr);
            mapping.csProfAvgaum12m = TypeMapper.DefaultValue(item.csProfAvgaum12m); //decimal item.csProfAvgaum12m 
            mapping.csProfAvgaum12mDt = item.csProfAvgaum12mDt; //Date item.csProfAvgaum12mDt 
            mapping.csProfSubsegment = TypeMapper.DefaultValue(item.csProfSubsegment);
            mapping.csProfWealthExpDt = TypeMapper.DefaultValue(item.csProfWealthExpDt);

            


            // mock data
            //mapping.SoapStatus = TypeMapper.DefaultValue('SUCCESS');
            //mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue('mock data'));

            /* ====================================================/
             *CVSAnalyticsData
             *====================================================*/
            /* mapping.MIBStatus = TypeMapper.DefaultValue('A');
            mapping.UsagePercentage = TypeMapper.DefaultValue('AAA');
            mapping.suitability = TypeMapper.DefaultValue('AAA');
            mapping.privilege = TypeMapper.DefaultValue('AAA');
            mapping.privilege2Url = TypeMapper.DefaultValue('AAA');
            mapping.currentPrivilege2Desc = TypeMapper.DefaultValue('AAA');
            mapping.entitledPrivilege2Desc = TypeMapper.DefaultValue('AAA');
            mapping.afPrivilegeFlag = TypeMapper.DefaultValue('AAA');
                     
            mapping.touchStatus = TypeMapper.DefaultValue('AAA');
            mapping.ibStatus = TypeMapper.DefaultValue('AAA');
            mapping.csProfFreqBr = TypeMapper.DefaultValue('001');
            mapping.csProfAvgaum12m = TypeMapper.DefaultValue(111); //decimal item.csProfAvgaum12m 
            //mapping.csProfAvgaum12mDt = TypeMapper.DefaultValue(item.csProfAvgaum12mDt); //Date item.csProfAvgaum12mDt 
            mapping.csProfSubsegment = TypeMapper.DefaultValue('AAA');
            mapping.csProfWealthExpDt = TypeMapper.DefaultValue('AAA'); */

            ret = mapping;
        }

        return ret;
    }

    public static RTL_NBOService.NBO MappingSoapToNBO(RTL_NextBestOffer.NextBestOffer item) {
        RTL_NBOService.NBO mapping = new RTL_NBOService.NBO();
        mapping.SoapStatus = item.Status == null ? '' : item.Status;
        mapping.SoapMessage = TypeMapper.errorMessageMapping(TypeMapper.DefaultValue(item.Message));
        mapping.nboMap = new Map < RTL_NBOService.NBOHistory, List < RTL_NBOService.NBOHistoryProduct >> ();

        if (item.NextBestOfferDetails != null && item.NextBestOfferDetails.NextBestOfferDetail != null) {
            for (RTL_NextBestOffer.NextBestOfferDetail dN: item.NextBestOfferDetails.NextBestOfferDetail) {
                RTL_NBOService.NBOHistory nboDetail = new RTL_NBOService.NBOHistory();
                List < RTL_NBOService.NBOHistoryProduct > nboProducts = new List < RTL_NBOService.NBOHistoryProduct > ();

                nboDetail.RTL_NBO_ID = dN.NboId;
                //nboDetail.RTL_NBO_Name = dN.CampaignName;
                nboDetail.RTL_Campaign_Code = dN.CampaignCode;
                nboDetail.RTL_Campaign_Name = dN.CampaignName;
                nboDetail.RTL_NBO_Group = dN.NboGroup;
                nboDetail.RTL_NBO_SubGroup = dN.NboSubGroup;
                if (dN.ValidFrom != null)
                    nboDetail.RTL_Valid_From = Date.valueOf(convertDate(dN.ValidFrom)); //make sure xxxx/xx/xx is converted
                else
                    nboDetail.RTL_Valid_From = null;
                if (dN.ValidTo != null)
                    nboDetail.RTL_Valid_To = Date.valueOf(convertDate(dN.ValidTo)); //make sure xxxx/xx/xx is converted
                else
                    nboDetail.RTL_Valid_To = null;
                nboDetail.RTL_Smart_Info = dN.SmartInfo;
                if (dN.ContactDate != null)
                    nboDetail.RTL_Contact_Date = Date.valueOf(convertDate(dN.ContactDate)); //make sure xxxx/xx/xx is converted
                else
                    nboDetail.RTL_Contact_Date = null;
                nboDetail.RTL_Channel = dN.Channel;
                nboDetail.RTL_TMB_Customer_ID_PE = dN.CustomerId;
                if (item.NextBestOfferProducts != null && item.NextBestOfferProducts.NextBestOfferProduct != null) {
                    for (RTL_NextBestOffer.NextBestOfferProduct pN: item.NextBestOfferProducts.NextBestOfferProduct) {
                        if (pN.NboId == dN.NboId) {
                            RTL_NBOService.NBOHistoryProduct product = new RTL_NBOService.NBOHistoryProduct();
                            product.RTL_NBO_ID = pN.NboId;
                            product.RTL_Product = pN.Product;
                            product.RTL_Product_Group = pN.ProductGroup;
                            product.RTL_Product_SubGroup = pN.ProductSubGroup;
                            product.RTL_Product_Smart_Info = pN.ProductSmartInfo;
                            product.RTL_NBO_Product_External_ID = pN.NboProductId;
                            nboProducts.add(product);
                        }
                    }
                }
                mapping.nboMap.put(nboDetail, nboProducts);
            }
        }
        return mapping;
    }

    public static string DefaultValue(string item) {

        return item == null ? '' : item;

    }
    public static decimal DefaultValue(decimal item) {

        return item == null ? 0.0 : item;

    }

    public static date DefaultValue(date item) {

        return item == null ? null : item;

    }

    public static String errorMessageMapping(String errCode) {
        if (errCode.toUpperCase() == 'ERR001')
            return System.Label.ERR001; //Sorry, some error occurred while getting information. Please contact your system administrator.
        if (errCode.toUpperCase() == 'ERR002')
            return System.Label.ERR002; //Sorry, Internal server error. Please contact your system administrator.
        if (errCode.toUpperCase() == 'ERR003')
            return System.Label.RTL_NBO_ERR005; //Sorry, NBO product cannot decode. Please contact your system administrator.
        if (errCode.toUpperCase() == 'ERR004')
            return System.Label.RTL_NBO_ERR006; //Sorry, there is no NBO available.        
        System.debug('WebService Return Message :: ' + errCode);
        return errCode;
    }

    private static String convertDate(String input) {
        if (input.contains('/')) return input.replace('/', '-');
        else return input;
    }
}