({
    doInit : function(component, event, helper){
        var retrySetTimeOut = parseInt($A.get('$Label.c.Retry_SetTimeOut'));
        var numOfRetryTime = parseInt($A.get('$Label.c.Number_Of_Retry_Times'));
        component.set("v.retrySetTimeOut", retrySetTimeOut);
        component.set("v.numOfRetryTime", numOfRetryTime);
        

        Promise.all([
            helper.getRedProductcodeList(component, helper), 
            helper.getALDXWFMdt(component, event, helper),
            helper.getCoreHPCompany(component, event, helper)
        ]).then(function(results) {
            console.log('----- AdvisoryPlanning Product Holding : doInit ------');
            console.log(results);
            var result_redProduct = results[0];
            if(result_redProduct) component.set("v.mainBankProductCode", result_redProduct);

            var result_aldx = results[1];
            if(result_aldx)  component.set("v.alds_wf", result_aldx);

            var company = results[2];
            component.set("v.company", company ? company : "TBANK");

            helper.doInitErrorMessageControl(component, event, helper);
            var planningRecord = component.get("v.planningRecord");
            var ttbCustomerId  = planningRecord.ttb_Customer_ID__c;
            var isSyncProduct  = planningRecord.Is_Sync_Product_Holding__c;

            if(ttbCustomerId){
                component.set("v.tmbCustId",ttbCustomerId );
                component.set("v.customerId",planningRecord.Customer__c );
                console.log(component.get("v.tmbCustId"));
                if(isSyncProduct == false){
                    /* Callout to get related information based on ttb customer Id
                        DONE 'callout:OSC01' => 'CustomerAccount - OSC01',
                            DONE 'callout:OSC02' => 'DepositAccount - OSC02',
                            DONE 'callout:OSC04' => 'LoanAccount - OSC04',
                            DONE 'callout:OSC06_List' => 'InvestmentAccount - OSC06 High Level',
    
                        NO NEED FOR ADVISORY PLANNING 'callout:OSC03' => 'CreditCardAccount - OSC03',
                        DONE 'callout:OSC05_List' => 'BancassuranceAccount - OSC05 High Level',
                        DONE 'callout:AutoLoan_HpFleetHpList' => 'Auto Loan'
                        DONE 'callout:AutoLoan_HpFleetHpDetail' => 'Auto Loan Detail'
                    */
                    helper.calloutCustomerAccount(component, helper, 0 ); //CustomerAccount
                    if (component.get("v.tmbCustId") && component.get('v.company')) {
                        
                        //helper.calloutCreditCard(component, helper, 'N', '', null, 0); //CreditCardAccount
                        helper.calloutBancassuranceAccount(component, helper,0 ); //BancassuranceAccount
                        helper.calloutAutoLoan(component, helper,  0); //AutoLoan
                    } else {
                        helper.getCoreHPCompany(component, event, helper);
                    }
                    
                }
            }

        }).catch(function (err) {
            console.log(err);
            helper.showToast(component, 'Cannot save the record', err[0].message, 'sticky', 'error');
        });
    },

    handleRetryProcess : function(component, event, helper){
        console.log('----- Handle Retry Process ------');
        var errorControlObj = component.get('v.errorMessageControl');
        var errorObject = {'state':false,'message':'','messages':{'AllRetry':'','OSC01':'','CardBal':'','Bancassurance':'', 'AutoLoan' :'','someInfoError':''},'hrefList':'', 'title' :'Error Occur'};
        component.set('v.error', errorObject);
        if (errorControlObj.timeout.OSC) {
            component.set('v.depositProduct.isLoading', true);
            component.set('v.depositProduct.isDone', false);
            component.set('v.depositProduct.isError', false);

            component.set('v.loanProduct.isLoading', true);
            component.set('v.loanProduct.isDone', false);
            component.set('v.loanProduct.isError', false);

            component.set('v.investmentProduct.isLoading', true);
            component.set('v.investmentProduct.isDone', false);
            component.set('v.investmentProduct.isError', false);
            helper.calloutCustomerAccount(component, helper, 0 ); //CustomerAccount
        } else {
            if(errorControlObj.timeout.Deposit || errorControlObj.timeout.Loan || errorControlObj.timeout.Investment ||
               errorControlObj.error.Deposit || errorControlObj.error.Loan || errorControlObj.error.Investment ||
               component.get('v.depositProduct.isError') || component.get('v.loanProduct.isError') || component.get('v.investmentProduct.isError')){
                component.set('v.depositProduct.isLoading', true);
                component.set('v.depositProduct.isDone', false);
                component.set('v.depositProduct.isError', false);

                component.set('v.loanProduct.isLoading', true);
                component.set('v.loanProduct.isDone', false);
                component.set('v.loanProduct.isError', false);

                component.set('v.investmentProduct.isLoading', true);
                component.set('v.investmentProduct.isDone', false);
                component.set('v.investmentProduct.isError', false);
                helper.calloutCustomerAccount(component, helper, 0 ); //CustomerAccount
            } 

            if(errorControlObj.timeout.AutoLoan || errorControlObj.error.AutoLoan ||component.get('v.autoLoanProduct.isError')){
                component.set('v.autoLoanProduct.isLoading', true);
                component.set('v.autoLoanProduct.isDone', false);
                component.set('v.autoLoanProduct.isError', false);
                helper.calloutAutoLoan(component, helper,  0); //AutoLoan
            }

            // if(errorControlObj.timeout.CardBal || errorControlObj.error.CardBal || component.get('v.creditCardRDCProduct.isError')){
            //     component.set('v.creditCardRDCProduct.isLoading', true);
            //     helper.calloutCreditCard(component, helper, 'N', '', null, 0); //CreditCardAccount
            // }

            if(errorControlObj.timeout.Bancassurance || errorControlObj.error.Bancassurance ||component.get('v.bancassuranceProduct.isError')){
                component.set('v.bancassuranceProduct.isLoading', true);
                component.set('v.bancassuranceProduct.isDone', false);
                component.set('v.bancassuranceProduct.isError', false);
                helper.calloutBancassuranceAccount(component, helper,0 ); //BancassuranceAccount
            }
        }
    },

    handleSuccess : function(component, event, helper){
        console.log('-------------- SUCCESS JAAAA -----------------');
        console.log(component.get('v.depositProduct.datas'));
        // console.log(component.get('v.creditCardRDCProduct'));
        console.log(component.get('v.loanProduct.datas'));
        console.log(component.get('v.autoLoanProduct.datas'));
        console.log(component.get('v.bancassuranceProduct.datas'));
        console.log(component.get('v.investmentProduct.datas'));

        var isHadProductHolding = false;
        var planningItemList    = helper.parseProductHoldingToPlanning(component, helper);
        if(planningItemList && planningItemList.length > 0){
            isHadProductHolding = true;
        }
        
        console.log(JSON.stringify(planningItemList));
        
        Promise.all([
            helper.createAdvisoryPlanning(component, isHadProductHolding, planningItemList)
        ]).then(function(results) {
            console.log('----- AdvisoryPlanning Product Holding : handleSuccess ------');
            var result = results[0];
            console.log(results);

            if(result.isSuccess){
                helper.showToast(component, 'Success !', 'The Advisory Planning was updated.', 'dismissible', 'success');
                $A.get('e.force:refreshView').fire();
                // window.location.reload();
            }else{
                var message = result.errorMessage;
                helper.showToast(component, 'Cannot save the record', message, 'sticky', 'error');
            }

        }).catch(function (err) {
            console.log(err);
            helper.showToast(component, 'Cannot save the record', err[0].message, 'sticky', 'error');
        });
    }
})