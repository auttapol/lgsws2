public class DeleteAccountPlanDuplicate {
    public DeleteAccountPlanDuplicate(){
        
    }
    public void DeleteAccountPlanDuplicateAction(Set<ID> CompanyProfileID,Boolean CRMUsers){
        Set<ID> CRMUsersID = new Set<ID>();
        if(CRMUsers){
            List<User> CRMUsersList = [SELECT id,name FROM user WHERE name ='CRM 07' OR name ='CRM 08' OR name ='CRM 09' OR name ='CRM 10'];
            for(User item : CRMUsersList){
                CRMUsersID.add(item.id);
            }
            List<AcctPlanCompanyProfile__c> CompanyProfileCRMUsers= [SELECT ID FROM AcctPlanCompanyProfile__c WHERE CreatedById IN : CRMUsersID];
            CompanyProfileID = new Set<ID>();
            for(AcctPlanCompanyProfile__c item : CompanyProfileCRMUsers){
                CompanyProfileID.add(item.id);
            }
        }
        
        List<AcctPlanCompanyProfile__c> CompanyProfileOriginal = [SELECT ID FROM AcctPlanCompanyProfile__c WHERE ID IN : CompanyProfileID];
        system.debug('CompanyProfileOriginal = '+CompanyProfileOriginal.size());
        if(CompanyProfileOriginal.size() > 0){
            List<AcctPlanWallet__c> WalletOriginal = [SELECT ID FROM AcctPlanWallet__c WHERE AcctPlanCompanyProfile__c IN : CompanyProfileID];
            if(WalletOriginal.size() >0){
                /*====== Account Plan Wallet ======*/
                Set<Id> walletIdSet = new Set<Id>();
                for(AcctPlanWallet__c item : WalletOriginal){
                    walletIdSet.add(item.id);
                }
                
                /*====== Account Plan Customer Understandings ======*/
                List<AcctPlanCusUnderstanding__c> CusUnderstandingOriginal = [SELECT ID FROM AcctPlanCusUnderstanding__c WHERE AcctPlanWallet__c IN : walletIdSet];
                system.debug('CusUnderstandingOriginal = '+CusUnderstandingOriginal.size());
                if(CusUnderstandingOriginal.size() > 0){
                    delete CusUnderstandingOriginal;
                

                /*====== Account Plan Wallet By Domain======*/
                List<AcctPlanWalletByDomain__c> WalletDomainOriginal = [SELECT ID FROM AcctPlanWalletByDomain__c WHERE AcctPlanWallet__c IN : walletIdSet];
                system.debug('WalletDomainOriginal = '+WalletDomainOriginal.size()); 
                if(WalletDomainOriginal.size() > 0){           
                    delete WalletDomainOriginal;
                }
                
                /*====== Account Plan Flow Detail ======*/
                List<Account_Plan_Flow_Details__c> FlowDetailOriginal = [SELECT ID FROM Account_Plan_Flow_Details__c WHERE Account_Plan_Wallet__c         IN : CompanyProfileID];
                system.debug('FlowDetailOriginal = '+FlowDetailOriginal.size());
                if(FlowDetailOriginal.size() > 0){
                    delete FlowDetailOriginal;
                }   
                
                
                /*====== Account Plan Wallet ======*/
                system.debug('WalletOriginal = '+WalletOriginal.size());
                delete WalletOriginal;
                }
                
                /*====== Account Plan Executive Summary ======*/
                List<Executive_Summary__c> ExecutiveSummaryOriginal = [SELECT ID FROM Executive_Summary__c WHERE Account_Plan_Company_Profile__c IN : CompanyProfileID];
                system.debug('ExecutiveSummaryOriginal = '+ExecutiveSummaryOriginal.size());
                if(ExecutiveSummaryOriginal.size() > 0 ){
                    delete ExecutiveSummaryOriginal;
                }
                
                
                /*====== Account Plan Contribution ======*/
                List<AcctPlanContribution__c> ContributionOriginal = [SELECT ID FROM AcctPlanContribution__c WHERE Account_Plan_Company_Profile__c IN : CompanyProfileID];
                system.debug('ContributionOriginal = '+ContributionOriginal.size());
                if(ContributionOriginal.size() > 0){
                    delete ContributionOriginal;
                }
               
                if(CRMUsers){                    
                    /*====== Account Plan Company Port ======*/
                    List<AcctPlanPortfolio__c> PortfolioOriginal = [SELECT ID FROM AcctPlanPortfolio__c WHERE CreatedById IN : CRMUsersID];
                    system.debug('PortfolioOriginal  = '+PortfolioOriginal .size());
                    if(PortfolioOriginal.size() > 0){
                        Set<ID> PortfolioID = new Set<ID>();
                        for(AcctPlanPortfolio__c item : PortfolioOriginal){
                            PortfolioID.add(item.id);
                        }
                        
                        /*====== Account Plan Company Port ======*/
                        List<AcctPlanCompanyPort__c> CompanyPortOriginal = [SELECT ID FROM AcctPlanCompanyPort__c WHERE Account_Plan_Portfolio__c  IN : PortfolioID];
                        system.debug('CompanyPortOriginal = '+CompanyPortOriginal.size());
                        if(CompanyPortOriginal.size() > 0){
                            delete CompanyPortOriginal;
                        }   
                        
                        /*====== Account Plan Group Port ======*/
                        List<AcctPlanGroupPort__c> GroupPortOriginal = [SELECT ID FROM AcctPlanGroupPort__c WHERE Account_Plan_Portfolio__c  IN : PortfolioID];
                        system.debug('GroupPortOriginal = '+ GroupPortOriginal.size());
                        if(GroupPortOriginal.size() > 0){
                            delete GroupPortOriginal;
                        }                          
                        delete PortfolioOriginal;
                    } 
                    /*====== Group Master ======*/
                    List<Group__c> GroupOriginal = [SELECT ID FROM Group__c WHERE CreatedById IN : CRMUsersID];
                    system.debug('GroupOriginal = '+GroupOriginal.size());
                    if(GroupOriginal.size() > 0){
                        delete GroupOriginal;
                    }

                    /*====== Group Profile ======*/
                    List<AcctPlanGroupProfile__c> GroupProfileOriginal = [SELECT ID FROM AcctPlanGroupProfile__c WHERE CreatedById IN : CRMUsersID];
                    system.debug('GroupProfileOriginal = '+GroupProfileOriginal.size());
                    if(GroupProfileOriginal.size() > 0){
                        delete GroupProfileOriginal;
                    } 
                }            

                
            }
            delete CompanyProfileOriginal;
        }

            if(CRMUsers){
                /*====== Opportunity ======*/
                List<Opportunity> OpportunityOriginal = [SELECT ID FROM Opportunity WHERE CreatedById IN : CRMUsersID];
                system.debug('OpportunityOriginal  = '+OpportunityOriginal.size());
                if(OpportunityOriginal.size() > 0){
                    delete OpportunityOriginal;
                }  
                
                /*====== Recommended Product ======*/
                List<Product_Interest__c> ProductInterestOriginal = [SELECT ID FROM Product_Interest__c WHERE CreatedById IN : CRMUsersID];
                system.debug('ProductInterestOriginal = '+ProductInterestOriginal.size());
                if(ProductInterestOriginal.size() > 0){
                    delete ProductInterestOriginal;
                }    
                
                /*====== Event ======*/
                List<Event> EventOriginal = [SELECT ID FROM Event WHERE CreatedById IN : CRMUsersID];
                system.debug('EventOriginal = '+EventOriginal.size());
                if(EventOriginal.size() > 0){
                    delete EventOriginal;
                }    
                
                /*====== Task ======*/
                List<Task> TaskOriginal = [SELECT ID FROM Task WHERE CreatedById IN : CRMUsersID];
                system.debug('TaskOriginal = '+TaskOriginal.size());
                if(TaskOriginal.size() > 0){
                    delete TaskOriginal;
                } 
                
                /*====== Visit Plan / Report ======*/
                List<Call_Report__c> VisitPlanReportOriginal = [SELECT ID FROM Call_Report__c WHERE CreatedById IN : CRMUsersID];
                system.debug('VisitPlanReportOriginal = '+VisitPlanReportOriginal.size());
                if(VisitPlanReportOriginal.size() > 0){
                    delete VisitPlanReportOriginal;
                }   
                
                /*====== Visit Report ======*/
                List<Visit_Report__c> VisitReportOriginal = [SELECT ID FROM Visit_Report__c WHERE CreatedById IN : CRMUsersID];
                system.debug('VisitReportOriginal = '+VisitReportOriginal.size());
                if(VisitReportOriginal.size() > 0){
                    delete VisitReportOriginal;
                }   
                
                /*====== Lead ======*/
                List<Lead> LeadOriginal = [SELECT ID FROM Lead WHERE CreatedById IN : CRMUsersID];
                system.debug('LeadOriginal = '+LeadOriginal.size());
                if(LeadOriginal.size() > 0){
                    delete LeadOriginal;
                } 
                
                /*====== Contact ======*/
                List<Contact> ContactOriginal = [SELECT ID FROM Contact WHERE CreatedById IN : CRMUsersID];
                system.debug('ContactOriginal = '+ContactOriginal.size());
                if(ContactOriginal.size() > 0){
                    delete ContactOriginal;
                }   
                
                /*====== Account ======*/
                List<Account> AccountOriginal = [SELECT ID FROM Account WHERE CreatedById IN : CRMUsersID];
                system.debug('AccountOriginal = '+AccountOriginal.size());
                if(AccountOriginal.size() > 0){
                    delete AccountOriginal;
                }  
            }
    }

    public void CleansingAccountPlanChangeOwner(){
       
                
                /*|||||||====== AcctAnnualPerformance__c ======|||||||*/
                List<AcctAnnualPerformance__c> AcctAnnualPerformanceList = [SELECT ID FROM AcctAnnualPerformance__c WHERE Account__c = null ];
                system.debug('AcctAnnualPerformanceList = '+AcctAnnualPerformanceList.size());
                if(AcctAnnualPerformanceList.size()>0){
                    delete AcctAnnualPerformanceList;
                }

                    
                    /*|||||||====== Account Plan Action Plan ======|||||||*/
                    List<AcctPlanActionPlan__c> ActionPlanOriginal = [SELECT ID FROM AcctPlanActionPlan__c WHERE AcctPlanWalletByDomain__c = null];
                    system.debug('ActionPlanOriginal = '+ActionPlanOriginal.size());
                    if(ActionPlanOriginal.size() > 0){
                        delete ActionPlanOriginal;
                    }                      
                        
                        /*====== Account Plan NI Project ======*/
                        List<AcctPlanNIProject__c> NIProjectOriginal = [SELECT ID FROM AcctPlanNIProject__c WHERE AcctPlanActionPlanID__c = null];
                        system.debug('NIProjectOriginal = '+NIProjectOriginal.size());
                        if(NIProjectOriginal.size() > 0){
                            delete NIProjectOriginal;
                        }
                        
                        /*====== Account Plan Activity ======*/
                        List<AcctPlanActivity__c> ActivityOriginal = [SELECT ID FROM AcctPlanActivity__c WHERE AccountPlanActionPlanID__c = null];
                        system.debug('ActivityOriginal = '+ActivityOriginal.size());
                        if(ActivityOriginal.size() > 0){
                            delete ActivityOriginal;  
                            
                        }

                       /*|||||| ====== Account Plan Stakeholder ======|||||| */
                            List<AcctPlanStakeholder__c> StakeHolderOriginal = [SELECT ID FROM AcctPlanStakeholder__c WHERE AcctPlanActivity__c = null];
                            system.debug('StakeHolderOriginal = '+StakeHolderOriginal.size());
                            if(StakeHolderOriginal.size() > 0){
                                delete StakeHolderOriginal;
                            }
                                       
                

                /*====== Account Plan Product Strategy ======*/
                List<AcctPlanProdStrategy__c> ProductStrategyOriginal = [SELECT ID FROM AcctPlanProdStrategy__c WHERE AcctPlanCompanyProfileID__c = null];
                system.debug('ProductStrategyOriginal = '+ProductStrategyOriginal.size());
                if(ProductStrategyOriginal.size() > 0){
                    delete ProductStrategyOriginal;
                }

              
                /*|||||| ====== Account Plan Foreign Trans ======|||||| */
                List<AcctPlanForeignTrans__c> ForeignTransOriginal = [SELECT ID FROM AcctPlanForeignTrans__c WHERE AcctPlanWallet__c = null];
                system.debug('ForeignTransOriginal = '+ForeignTransOriginal.size());
                if(ForeignTransOriginal.size() > 0){
                    delete ForeignTransOriginal;
                }
                
                /*|||||| ====== Account Plan Collection Or Payment Currency ======|||||| */
                List<AcctPlanCollectionOrPaymentCurrency__c> CollectionOrPaymentCurrencyOriginal = [SELECT ID FROM AcctPlanCollectionOrPaymentCurrency__c WHERE AcctPlanWallet__c = null];
                system.debug('CollectionOrPaymentCurrencyOriginal = '+CollectionOrPaymentCurrencyOriginal.size());
                if(CollectionOrPaymentCurrencyOriginal.size() > 0){
                    delete CollectionOrPaymentCurrencyOriginal;
                }
                
                /*====== Account Plan Questionnaire  ======*/
                List<AcctPlanQuestionnaire__c> QuestionnaireOriginal = [SELECT ID FROM AcctPlanQuestionnaire__c WHERE AcctPlanWallet__c = null];
                system.debug('QuestionnaireOriginal = '+QuestionnaireOriginal.size());
                if(QuestionnaireOriginal.size() > 0){
                    delete QuestionnaireOriginal;
                }
                
                /*====== Account Plan Other Revenue Expenditure  ======*/
                List<AcctPlanOtherRevenueExpenditure__c> OtherRevenueExpenditureOriginal = [SELECT ID FROM AcctPlanOtherRevenueExpenditure__c WHERE AcctPlanWallet__c = null];
                system.debug('OtherRevenueExpenditureOriginal = '+OtherRevenueExpenditureOriginal.size());
                if(OtherRevenueExpenditureOriginal.size() > 0){
                    delete OtherRevenueExpenditureOriginal;
                }
                
                /*====== Account Plan Existing Long Term Loan ======*/
                List<AcctPlanExistingLongTermLoan__c> ExistingLongTermLoanOriginal = [SELECT ID FROM AcctPlanExistingLongTermLoan__c WHERE AcctPlanWallet__c = null];
                system.debug('ExistingLongTermLoanOriginal = '+ExistingLongTermLoanOriginal.size());
                if(ExistingLongTermLoanOriginal.size() > 0){
                    delete ExistingLongTermLoanOriginal;
                }
                
                /*====== Account Plan Capital Expenditure Plan ======*/
                List<AcctPlanCapitalExpenditurePlan__c> CapitalExpenditurePlanOriginal = [SELECT ID FROM AcctPlanCapitalExpenditurePlan__c WHERE AcctPlanWallet__c = null];
                system.debug('CapitalExpenditurePlanOriginal = '+CapitalExpenditurePlanOriginal.size());
                if(CapitalExpenditurePlanOriginal.size() > 0){
                    delete CapitalExpenditurePlanOriginal; 
                }
                
                /*====== Account Plan Working Capital ======*/
                List<AcctPlanWorkingCapital__c> WorkingCapitalOriginal = [SELECT ID FROM AcctPlanWorkingCapital__c WHERE AcctPlanWallet__c = null];
                system.debug('WorkingCapitalOriginal = '+WorkingCapitalOriginal.size());
                if(WorkingCapitalOriginal.size() > 0){
                    delete WorkingCapitalOriginal;
                }
                
                /*====== Account Plan Wallet Credit Facility ======*/
                List<AcctPlanWalletCreditFacility__c> WalletCreditFacilityOriginal = [SELECT ID FROM AcctPlanWalletCreditFacility__c WHERE AcctPlanWallet__c = null];
                system.debug('WalletCreditFacilityOriginal = '+WalletCreditFacilityOriginal.size());
                if(WalletCreditFacilityOriginal.size() > 0){
                    delete WalletCreditFacilityOriginal;
                }
                
                /*====== Account Plan LG Project ======*/
                List<AcctPlanLGProject__c> LGProjectOriginal = [SELECT ID FROM AcctPlanLGProject__c WHERE AcctPlanWallet__c = null];
                system.debug('LGProjectOriginal = '+LGProjectOriginal.size());
                if(LGProjectOriginal.size() > 0){
                    delete LGProjectOriginal;
                }
                /*====== Account Plan AS Fee ======*/
                List<Account_Plan_AS_Fee__c> ASFeeOriginal = [SELECT ID FROM Account_Plan_AS_Fee__c WHERE Account_Plan_Wallet__c = null];
                system.debug('ASFeeOriginal = '+ASFeeOriginal.size());
                if(ASFeeOriginal.size() > 0){
                    delete ASFeeOriginal;
                }   
                
                /*====== Account Plan Flow Detail ======*/
                List<Account_Plan_Flow_Details__c> FlowDetailOriginal = [SELECT ID FROM Account_Plan_Flow_Details__c WHERE Account_Plan_Wallet__c   = null];
                system.debug('FlowDetailOriginal = '+FlowDetailOriginal.size());
                if(FlowDetailOriginal.size() > 0){
                    delete FlowDetailOriginal;
                }   
                
                /*====== Account Plan Deposit Domestic ======*/
                List<AcctPlanDepositDomestic__c> DepositDomesticOriginal = [SELECT ID FROM AcctPlanDepositDomestic__c WHERE AccountPlanDepositDomesticDeposit__c = null];
                system.debug('DepositDomesticOriginal = '+DepositDomesticOriginal.size());
                if(DepositDomesticOriginal.size() > 0){
                    delete DepositDomesticOriginal;
                }
                
                /*====== Account Plan Deposit International ======*/
                List<AcctPlanDepositInternational__c> DepositInternationalOriginal = [SELECT ID FROM AcctPlanDepositInternational__c WHERE AccountPlanDepositInternationalDeposit__c = null];
                system.debug('DepositInternationalOriginal = '+DepositInternationalOriginal.size());
                if(DepositInternationalOriginal.size() > 0){
                    delete DepositInternationalOriginal;
                }
                
                /*|||||| ====== Account Plan Collection Domestic ======|||||| */
                List<AcctPlanCollectionDomestic__c> CollectionDomesticOriginal = [SELECT ID FROM AcctPlanCollectionDomestic__c WHERE AcctPlanCollectionMethodDomestic__c = null];
                system.debug('CollectionDomesticOriginal = '+CollectionDomesticOriginal.size());
                if(CollectionDomesticOriginal.size() > 0){
                    delete CollectionDomesticOriginal;   
                }
                
                /*====== Account Plan Collection Export ======*/
                List<AcctPlanCollectionExport__c> CollectionExportOriginal = [SELECT ID FROM AcctPlanCollectionExport__c WHERE AcctPlanCollectionMethodExport__c = null];
                system.debug('CollectionExportOriginal = '+CollectionExportOriginal.size());
                if(CollectionExportOriginal.size() > 0){
                    delete CollectionExportOriginal; 
                }
                
                /*====== Account Plan Payment Domestic ======*/
                List<AcctPlanPaymentDomestic__c> PaymentDomesticOriginal = [SELECT ID FROM AcctPlanPaymentDomestic__c WHERE AcctPlanPaymentMethodDomestic__c = null];
                system.debug('PaymentDomesticOriginal = '+PaymentDomesticOriginal.size());
                if(PaymentDomesticOriginal.size() > 0){
                    //delete PaymentDomesticOriginal;
                }
                
                /*====== Account Plan Payment Import ======*/
                List<AcctPlanPaymentImport__c> PaymentImportOriginal = [SELECT ID FROM AcctPlanPaymentImport__c WHERE AcctPlanPaymentMethodImport__c = null];
                system.debug('PaymentImportOriginal = '+PaymentImportOriginal.size());
                if(PaymentImportOriginal.size() > 0){
                    delete PaymentImportOriginal;
                }
                
                /*====== Account Plan Wallet Other Bank ======*/
                List<AcctPlanWalletOtherBank__c> WalletOtherBankOriginal = [SELECT ID FROM AcctPlanWalletOtherBank__c WHERE AcctPlanWallet__c = null];
                system.debug('WalletOtherBankOriginal = '+WalletOtherBankOriginal.size());
                if(WalletOtherBankOriginal.size() > 0 ){
                    delete WalletOtherBankOriginal;
                }
                
            
                /*====== Account Plan Supplier Or Buyer ======*/
                List<AcctPlanSupplierOrBuyer__c> SupplierOrBuyerOriginal = [SELECT ID FROM AcctPlanSupplierOrBuyer__c WHERE Account_Plan_Company_Profile__c = null];
                system.debug('SupplierOrBuyerOriginal = '+SupplierOrBuyerOriginal.size());
                if(SupplierOrBuyerOriginal.size() > 0){
                    delete SupplierOrBuyerOriginal;
                }
                
                /*====== Account Plan Company Top 5 ======*/
                List<Account_Plan_Company_Top_5__c> CompanyTop5Original = [SELECT ID FROM Account_Plan_Company_Top_5__c WHERE Account_Plan_Company_Profile__c = null];
                system.debug('CompanyTop5Original = '+CompanyTop5Original.size());
                if(CompanyTop5Original.size() > 0){
                    delete CompanyTop5Original;
                }
                
                /*====== Account Plan Completion ======*/
                List<Account_Plan_Completion__c> CompletionOriginal = [SELECT ID FROM Account_Plan_Completion__c WHERE Account_Plan_Company_Profile__c = null];
                system.debug('CompletionOriginal = '+CompletionOriginal.size());
                if(CompletionOriginal.size() > 0){
                    delete CompletionOriginal;
                }                                
                
           
    }
}