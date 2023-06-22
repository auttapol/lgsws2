({
    onInit : function(component, event, helper) {
  
        // console.log('isChangeContact:',component.get('v.isChangeContact'));
        helper.doInitPicklist(component, event, helper);
        helper.doInitselectedValues(component, event, helper);
        // helper.doInitRowList(component, event, helper)         
        //console.log('isConvert:',component.get('v.isConvert'));
        helper.getProductGroupPickList(component,event,helper);
        helper.getCampaignMember(component,event,helper);

        
    },

    changeState : function (component, event, helper) {
        var iconName = component.get('v.iconName');
        if(iconName == 'utility:chevrondown')
        {
            component.set('v.iconName','utility:chevronright');
        }
        else
        {
            component.set('v.iconName','utility:chevrondown');
        }
        component.set('v.isExpanded',!component.get('v.isExpanded'));
    },

    validateInput : function (component, event, helper) {
        var isCheck = component.get('v.isExpanded');
        //console.log('Do CrossSell validate');
        if(isCheck)
        {
            let rowList = component.get('v.rowList');
            rowList.forEach((rowObj, index) => {
                rowList[index] = helper.validateCrossSellRow(component, event, helper, rowObj, index+1);
            });
            component.set('v.rowList', rowList);
        }
        return isCheck;
    },

    clearValueToInit : function (component, event, helper) {
        //console.log('clearValueToInit CrossSell');
        component.set('v.rowList', []);
        helper.doInitRowList(component, event, helper);
    },

    addRow : function(component, event, helper) {
        var rowList = component.get("v.rowList");
        let selectedNameList = component.get("v.selectedNameList");
        rowList.push(
            helper.newRowList(component, event, helper, rowList.length + 1, false)
        );
        component.set("v.rowList", rowList);
        component.set("v.selectedNameList", selectedNameList);
        

    },

    deleteRow : function(component, event, helper) {
        //Get the account list
        var rowList = component.get("v.rowList");

        let index = event.target.value - 1

        // console.log('target value', event.target.value);
 
        rowList.splice(index, 1);
        rowList.forEach((e, i) => {
            e.value = i + 1;
        });
        component.set("v.rowList", rowList);
    },

    handleSelectedProductGroup : function(component, event) {
        // console.log('productGroupList' , component.get("v.productGroupList"));
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        // console.log('handleSelectedProductGroup' , rowList);
        //Clear value after change
        rowList.forEach((e, index) => {
            if (e.selected.productGroup != e.product.productGroup) {
                e.style.productGroup = '';
                e.product.productGroup = e.selected.productGroup
                e.product.productSubGroup = '';
                e.selected.productSubGroup = '';
                e.style.productSubGroup = '';
                e.productSubGroupList = [];
                e.product.productName = '';
                e.selected.productName = '';
                e.style.productName = '';
                e.productNameList = [];   

                e.product.stage = '';
                e.selected.stage = '';
                e.stageList = [];
                e.style.stage = '';
                e.product.status = '';
                e.selected.status = '';
                e.style.status = '';
                e.statusList = [];
                // e.status = '';
                // e.statusList = [];
            }
        });
        component.set('v.rowList', rowList);
    },
    handleSelectedProductName: function(component,event){
        var rowList = component.get('v.rowList');

        var indexVar = event.getSource().get("v.index");
        var productsubgroup = null;
        var productgroup = null;
        if(event.getSource().get("v.selectedRecord") != null){
            productsubgroup = event.getSource().get("v.selectedRecord").extraValue.RTL_Product_Sub_Group_Upper__c;
            productgroup = event.getSource().get("v.selectedRecord").extraValue.RTL_Product_Group_Upper__c;
            if((productsubgroup != null && productsubgroup != '') && (productgroup != null && productgroup != '')){
                rowList[indexVar].product.productSubGroup = productsubgroup;
                rowList[indexVar].selected.productSubGroup = productsubgroup;
                rowList[indexVar].product.productGroup = productgroup;
                rowList[indexVar].selected.productGroup = productgroup;
            }
            else{
                rowList[indexVar].product.productSubGroup = '';
                rowList[indexVar].selected.productSubGroup = '';
                rowList[indexVar].product.productGroup = '';
                rowList[indexVar].selected.productGroup = '';
            }
        }else{
            // rowList[indexVar].product.productSubGroup = '';
            // rowList[indexVar].selected.productSubGroup = '';
            // rowList[indexVar].product.productGroup = '';
            // rowList[indexVar].selected.productGroup = '';
        }
        component.set('v.rowList', rowList);

    },
    handleSelectedProductSubGroup : function(component, event) {
        // component.set('v.loading',true);
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        //console.log('handleSelectedProductSubGroup' , rowList);
        //Clear value after change
        rowList.forEach((e, index) => {
            if (e.selected.productSubGroup != e.product.productSubGroup) {
                e.style.productSubGroup = '';
                e.product.productSubGroup = e.selected.productSubGroup
                e.product.productName = '';
                e.selected.productName = '';
                e.style.productName = '';
                e.productNameList = [];
                console.log('handleSelectedProductSubGroup ' + e.selected.productSubGroup);
                var action = component.get('c.checkUpperPicklistValue');
                action.setParams({
                    "objectName" : 'CampaignMember',
                    "fieldName" : 'RTL_Sub_Group_1__c',
                    "contrlValue" : e.selected.productSubGroup
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {               
                        var result =  response.getReturnValue();   
                        if(result != null){
                            e.product.productGroup = result;
                            e.selected.productGroup = result;
                        }
                        console.log('This is Product Group ' + result);
                    }
                    component.set('v.rowList', rowList);
                    // component.set('v.loading',false);
                });
                $A.enqueueAction(action);
            }
        });
       // component.set('v.rowList', rowList);
    },

    handleSelectedStage : function (component, event, helper) {
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        // console.log('handleSelecedStage' , rowList);
        rowList.forEach((e, index) => {
            if (e.selected.stage != e.product.stage) {
                e.style.stage = '';
                e.product.stage = e.selected.stage;
                e.product.status = '';
                e.selected.status = '';
                e.statusList = [];
            }
        });
        component.set('v.rowList', rowList);
    },

    handleSelectedStatus : function (component, event, helper) {
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        // console.log('handleSelecedStage' , rowList);
        rowList.forEach((e, index) => {
            if (e.selected.status != e.product.status) {
                e.style.status = '';
                //e.product.stage = ''
                e.product.status = e.selected.status;
                //e.selected.status = '';
                // e.statusList = [];
            }
        });
        component.set('v.rowList', rowList);
    },

    handleSelectedAmount: function (component, event, helper) {
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        // console.log('handleSelecedAmount' , rowList);
        rowList.forEach((e, index) => {
            if (e.style.amount && (e.product.amount || e.product.productGroup.includes('Credit'))) {
                component.set('v.rowList['+index+'].style.amount', '');
            }
        });
    },

    handleSelectedDate: function (component, event, helper) {
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
        // console.log('handleSelecedDate' , rowList);
        rowList.forEach((e, index) => {
            if (e.style.expectedDate && e.product.expectedDate) {
                component.set('v.rowList['+index+'].style.expectedDate', '');
            }
        });
    },

    handleSelectedValue : function(component, event) {
        component.set('v.rowList', component.get('v.rowList'));
    },

    // handleDisabled : function(component, event, helper){
        // console.log('handleDisabled:',component.get("v.rowList"));
        // helper.doInitRowList(component, event, helper);   
    // },

    navigateToRecord : function(component, event, helper){
        var recordId = event.target.getAttribute('id');
        // var recordId = component.get('v.recordId');
        component.find("navService").navigate({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': recordId,
                'objectApiName': 'Opportunity',
                'actionName': 'view'
            }
        }, false);
    },

    handleSelectedOfferResult : function (component, event, helper) {
        let rowList = JSON.parse(JSON.stringify(component.get('v.rowList')));
         console.log('handleSelectedOfferResult' , rowList);
        rowList.forEach((e, index) => {
            if (e.selected.offerResult != e.product.offerResult) {
                e.product.offerResult = e.selected.offerResult;
                e.style.stage = '';
                e.product.stage = '';
                e.selected.stage = '';
                e.style.status = '';
                e.product.status = '';
                e.selected.status = '';
                e.product.expectedDate = '';
                e.selected.expectedDate = '';
                e.product.amount = 0;
                e.selected.amount = 0;
                e.stageList = [];
                e.statusList = [];
            }
        });
        component.set('v.rowList', rowList);
    },
})