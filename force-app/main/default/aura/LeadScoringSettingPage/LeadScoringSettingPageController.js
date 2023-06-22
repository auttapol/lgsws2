({
    doInit : function(component, event, helper) {
		console.log(component.get("v.scoringConId"));
        console.log(component.get("v.fieldName"));
        console.log(component.get("v.fieldType"));
        
        // var FirstRowItemList = [];
        // FirstRowItemList.push({
        //     'inputrowIndex': 998,
        //     'rowIndex': 998,
        //     'Operator': '=',
        //     'Value1':'Is null',
        //     'Value2':'',
        //     'Score':'0',
        // })
        // FirstRowItemList.push({
        //     'inputrowIndex': 999,
        //     'rowIndex': 999,
        //     'Operator': '=',
        //     'Value1':'Not match',
        //     'Value2':'',
        //     'Score':'0',
        // })
        // FirstRowItemList.push({
        //     'rowIndex': 1,
        //     'Operator': '=',
        //     'Value1':'',
        //     'Value2':'',
        //     'Score':'',
        // });
        // console.log("FirstRowItemList : "+ JSON.stringify(FirstRowItemList));
        // component.set("v.OrderList",FirstRowItemList);
        helper.getScoringDetail(component, event, helper);
    },
    removeDeletedRow: function (component, event, helper) {
		var index = event.getParam("indexVar");
		var AllRowsList = component.get("v.OrderList");
		AllRowsList.splice(index, 1);
		component.set("v.OrderList", AllRowsList);
	},
	addNewRow: function (component, event, helper) {
		helper.createfirst(component, event, helper);
	},

    onSaveLevel3: function (component, event, helper) {
		// console.log(JSON.stringify(component.get("v.OrderList")))
        var result = component.get("v.OrderList");
        var result = result.filter(function(obj) {
            return obj.hasOwnProperty('inputrowIndex');
        });
        console.log(JSON.stringify(result))
        var recordId = component.get("v.scoringConId");
        var isInsert = true;
        for(var i=0;i<=result.Length;i++){
            // console.log(result[i].Score)
            if(result[i].Score <0 && result[i].Score > 100){
                isInsert = false;
            }
        }
        if(isInsert){
            var action = component.get("c.insertScoringConDetail");
            action.setParams({
                recordId : recordId,
                detailList : result
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS')
                {	
                    // var result = response.getReturnValue();
                    helper.displayToast(component, 'Success', 'Save Success.');
                    console.log('state ' + state);
                    component.set("v.showModal", false)
                }else{
                    console.log('err ' + JSON.stringify(response.getError()));
                    // component.set("v.loaded",false);
                }
            });
            $A.enqueueAction(action);
        }else{
            helper.displayToast(component, 'Error', 'Please enter Score between 0 and 100.');
        }     
	},
})