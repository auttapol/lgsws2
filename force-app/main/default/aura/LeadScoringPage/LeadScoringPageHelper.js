({
	createfirst: function (component, event, helper) {
		// get the caseList from component and add(push) New Object to List
		var RowItemList = component.get("v.LeadList");
		// console.log('RowItemList: ',RowItemList);
        // console.log('RowItemList: ',JSON.stringify(RowItemList));

		var size = RowItemList.length;
        // console.log('Size ' + size);
		if (RowItemList != undefined){
			if (size < 10){
				RowItemList.push({
					'LObject': '--None--',
					'FieldName':'--None--',
					'Label':'',
					'FieldType':'',
					'Length': '',
					'APIName': '',
					'Weight':'',
					'Id':''
				});
			}else {
				helper.displayToast(component, 'Error', 'สามารถสร้าง Lead Scoring ได้สูงสุด 10 เคสเท่านั้น');
			}
			
		}
		// set the updated list to attribute (contactList) again   
		component.set("v.LeadList", RowItemList);
		// console.log('RowItemList: ',RowItemList[9]);
		// console.log('v.caseList: ',component.get('v.caseList'));
	}, 
    displayToast: function (component, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            message: message
        });
        toastEvent.fire();
	},

	parseRecord: function (component, helper) {
		var result = component.get("v.LeadList")
		var recordId = component.get("v.recordId")
		var isActive;
		var description;
		var name;
		var totalWeight;
		if(!recordId){
			totalWeight = component.get("v.totalWeight")
			description = component.get("v.Description")
			name = component.get("v.Name");
			isActive = component.get("v.isActive");
			
		}else{
			totalWeight = component.get("v.level1Rec.Total_Weight__c")
			description = component.get("v.level1Rec.Description__c")
			isActive = component.get("v.level1Rec.IsActive__c");
			name = component.get("v.level1Rec.Name");
		}
		// console.log('isActive' + isActive);
		var action = component.get("c.insertLeadScoring");
        action.setParams({
			recordId : recordId,
			Name : name,
			totalWeight : totalWeight,
			description : description,
			isActive : isActive
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {	
				var result = response.getReturnValue();
				helper.parseLevel2(component, helper, result)
				// console.log('Id return: '+result)
				if(result){
					helper.navigateToRecord(component, event, helper, result)
				}
                // console.log('state ' + state);
            }else{
                console.log('err ' + JSON.stringify(response.getError()));
                // component.set("v.loaded",false);
            }
        });
        $A.enqueueAction(action);
		helper.displayToast(component, 'Success', 'Save Success.');
	},

	getScoringList: function (component, event, helper) {
		var recordId = component.get("v.recordId")
		if(recordId){
			var action = component.get("c.getRecord");
			action.setParams({
				"recordId" : recordId
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if(state === 'SUCCESS')
				{	
					var result = response.getReturnValue();
					component.set("v.level1Rec", result.LSL);
					if(result.LSL.IsActive__c == true){
						component.set("v.isEdit", true);
					}
					component.set("v.level2Rec", result.LSC);
					// console.log(result.LSL)
					if(result.LSL.Summary_weight__c == result.LSL.Total_Weight__c){
						component.set("v.isActiveShowed", true);
					}else{
						component.set("v.isActiveShowed", false);
					}
					// console.log(result.LSC)
					// console.log(component.get("v.isEdit"))
					helper.pushLevel2(component, event, helper)
					// console.log('state ' + state);
				}else{
					console.log('err ' + JSON.stringify(response.getError()));
					// component.set("v.loaded",false);
				}
			});
			
			$A.enqueueAction(action);
			
		}else{
			// component.set("v.level1Rec.Total_Weight__c", 100);
		}
	},

	navigateToRecord : function(component, event, helper, recordId){
        // var recordId = event.target.getAttribute('id');
        // var recordId = component.get('v.recordId');
		// console.log('navigateToRecord '+recordId)
        component.find("navService").navigate({
            'type': 'standard__recordPage',
            'attributes': {
                'recordId': recordId,
                'objectApiName': 'Lead_Scoring_List__c',
                'actionName': 'view'
            }
        }, true);
    },

	parseLevel2: function (component, helper, recordId) {
		var result = component.get("v.LeadList")
		for(let i=0;i<result.length;i++){
			result[i].FieldList = null;
			if(result[i].Length == "-"){
				result[i].Length = null;
			}
		}
		result = result.filter(x => x.APIName !== '');
		var action = component.get("c.insertScoringCon");
        action.setParams({
			recordId : recordId,
			LeadList : result
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS')
            {	
				// var result = response.getReturnValue();
                // console.log('state ' + state);
            }else{
                console.log('err ' + JSON.stringify(response.getError()));
                // component.set("v.loaded",false);
            }
        });
        $A.enqueueAction(action);
	},

	pushLevel2: function (component, event, helper) {
		var result = component.get("v.LeadList")
		// console.log('Lead List : '+JSON.stringify(result));
        var scoringCon = component.get("v.level2Rec");
		var mapfieldtypelist = component.get("v.mapfieldtype");
		// console.log(JSON.stringify(mapfieldtypelist))
		var mapfieldlengthlist = component.get("v.mapfieldLength");
		// console.log(JSON.stringify(mapfieldlengthlist))
		var mapfieldLabellist = component.get("v.mapfieldAPI");
		var newMapAPiNameLabel = component.get("v.mapWrapperLabel");
		
		
		// console.log(JSON.stringify(mapfieldLabellist))
		var mapLabel = component.get("v.mapfieldList");
		for(var i=0; i < scoringCon.length;i++){
			// console.log(('Field name'+mapfieldLabellist[scoringCon[i].Object__c])[scoringCon[i].Field_Mapping__c])
			var FIELDAPINAME = newMapAPiNameLabel[scoringCon[i].Object__c];
			// console.log('API ' + scoringCon[i].Field_Mapping__c)
			var mapObjWithAPI = mapfieldLabellist[scoringCon[i].Object__c];
			// console.log('mapObjWithAPI ' + JSON.stringify(mapObjWithAPI))
			// console.log(mapObjWithAPI[scoringCon[i].Field_Mapping__c])
			result.push({
				'LObject': scoringCon[i].Object__c,
				'FieldName': (FIELDAPINAME.API.indexOf(scoringCon[i].Field_Mapping__c)) ,
				'Label': FIELDAPINAME.Label[(FIELDAPINAME.API.indexOf(scoringCon[i].Field_Mapping__c))],
				'FieldType':(mapfieldtypelist[scoringCon[i].Object__c])[scoringCon[i].Field_Mapping__c],
				'Length': (mapfieldlengthlist[scoringCon[i].Object__c])[scoringCon[i].Field_Mapping__c],
				'APIName': scoringCon[i].Field_Mapping__c,
				'Weight':scoringCon[i].Weight__c,
				'FieldList': mapLabel[scoringCon[i].Object__c],
				'readonly': false,
				'Id' : scoringCon[i].Id
			});
		}
		component.set("v.LeadList", result);
		var recordId = component.get("v.recordId")
		if(!recordId || scoringCon.length == 0){
            var FirstRowItemList = [];
            FirstRowItemList.push({
                'LObject': '--None--',
                'FieldName':'--None--',
				'Label':'',
                'FieldType':'',
                'Length':'',
                'APIName': '',
                'Weight':'',
            });
            component.set("v.LeadList",FirstRowItemList);
        }
		// console.log('Lead List : '+ JSON.stringify(component.get("v.LeadList")));
		component.set("v.loaded",false);
	},
})