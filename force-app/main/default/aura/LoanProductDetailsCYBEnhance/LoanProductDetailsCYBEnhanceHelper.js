({
    calloutService: function (component, event, helper) {
        var params = event.getParam('arguments');
        var callback = params ? params.callback : null;

        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_CYBDetail',
            'callback': 'callbackCYBDetail',
            'body': JSON.stringify({
                "cyb_account": {
                    "account_no": component.get('v.AccountNumber')
                }
            }),
            'service': 'DWH',
            'state': {
                'service': 'DWH',
                'recordId': component.get('v.recordId'),
                'tmbCustId': component.get('v.tmbCustId')
            },
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                // console.log(result);
                component.set('v.error.CYB.isSuccess', result.isSuccess ? result.isSuccess : undefined); // for validate display value
                component.set('v.error.CYB.isError', result.isError ? result.isError : false);
                component.set('v.error.CYB.isTimeout', result.isTimeout ? result.isTimeout : false);
                component.set('v.error.CYB.isLoading', true);
                component.set('v.error.CYB.message', result.Message ? result.Message : '');
                component.set('v.error.CYB.label', $A.get('$Label.c.VehicleInformation'));

                component.set('v.product', result);
                // callback to parent
                if (callback) callback();
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });
        $A.enqueueAction(action);
    },
    callIsALGuarantorMdt: function (component, callbackAction) {
        var action = component.get('c.getIsALGuarantorMdt');
        action.setStorable();
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.isMark', result ? !result : component.get('v.isMark'));
                $A.enqueueAction(callbackAction);
            } else {
                var errors = response.getError();
                errors.forEach(error => console.log(error.message));
            }
        });
        return action;
    },
    calloutGuarantorService: function (component, event, helper) {
        var params = event.getParam('arguments');
        var callback = params ? params.callback : null;

        var action = component.get('c.getProduct');
        action.setParams({
            'endpoint': 'callout:AutoLoan_Guarantor',
            'callback': 'callbackGuarantor',
            'body': JSON.stringify({
                "query": {
                    "acct_nbr": component.get('v.AccountNumber'),
                    "appl_code": "10"
                }
            }),
            'service': 'DWH',
            'state': {
                'service': 'DWH',
                'recordId': component.get("v.recordId"),
                'tmbCustId': component.get("v.tmbCustId")
            },
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                var result = response.getReturnValue();
                component.set('v.result', result);
                component.set('v.error.Guarantor.isError', result.isError || result.isThrow ? result.isError || result.isThrow : false);
                component.set('v.error.Guarantor.isTimeout', result.isTimeout ? result.isTimeout : false);
                component.set('v.error.Guarantor.isNoData', result.isNoData ? result.isNoData : false);
                component.set('v.error.Guarantor.isLoading', true);
                component.set('v.error.Guarantor.message', result.Message ? result.Message : '');
                component.set('v.error.Guarantor.label', $A.get('$Label.c.Guarantor'));

                component.set('v.guarantor', component.get('v.result.account.guarantors') ? component.get('v.result.account.guarantors').map(m => {
                    /*m.id_no = component.get('v.isMark') ?
                        'xxx' + `${m.id_no}`.slice(`${m.id_no}`.length - 3, `${m.id_no}`.length) :
                        m.id_no;*/

                    return m;
                }) : []);
                // callback to parent
                if (callback) callback();
            } else {
                var errors = response.getError();
                errors.forEach(function (error) {
                    console.log(error.message);
                });
            }
        });
        $A.enqueueAction(helper.callIsALGuarantorMdt(component, action));
    },
})