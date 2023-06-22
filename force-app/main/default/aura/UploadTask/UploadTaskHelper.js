({
	sendCSVArray : function(component, event ,helper, rows) {
		var action = component.get('c.generateCSVArray');
		var csv = component.get('v.CSVArray');
		var CSVName = component.get('v.CSVNameUpsert');
		action.setParams({
			'CSVArray': rows,
			'BatchType': 'Upsert',
			'fName': CSVName
		});
       
		action.setCallback(this,function (response){
			var state = response.getState();

			if (state === 'SUCCESS'){				
				var returnValues = response.getReturnValue();
				console.log('return: ', returnValues);
				/*component.set('v.Message', {
                    Header: 'Success',
                    TextMessageEN: 'See success and error log in next tab.',
                    TextMessageTH: '(โปรดตรวจสอบผล Upload ใน Tab ถัดไป)',
                   });
				component.set('v.colors','green');
				
				component.set('v.showResult',true);
				component.set('v.UpsertTask',false); */

			}else if (state === 'ERROR'){				
				var returnValues = response.getReturnValue();
				console.log('return: ', returnValues);
				component.set('v.Message', {
                    Header: 'Error!',
                    TextMessageEN: returnValues,
                    TextMessageTH: '(เกิดข้อผิดพลาด)',
                   });
				component.set('v.colors','red');
				
				component.set('v.showResult',true);
				component.set('v.UpsertTask',false);
			}
		});
		
		$A.enqueueAction(action);

	},

	DeleteTasks : function(component, event ,helper, rows) {
		var action = component.get('c.generateCSVArray');
		var csv = component.get('v.CSVArray');
		var CSVName = component.get('v.CSVNameDelete');
		action.setParams({
			'CSVArray': rows,
			'BatchType': 'Delete',
			'fName': CSVName
		});
		action.setCallback(this,function (response){
			var state = response.getState();
			
			if (state === 'SUCCESS'){
				var returnValues = response.getReturnValue();
				console.log('return: ', returnValues);
				/*component.set('v.Message', {
                    Header: 'Task Deleted',
                    TextMessageEN: 'See success and error log in next tab.',
                    TextMessageTH: '(โปรดตรวจสอบผล Deleted ใน Tab ถัดไป)',
				   });
				component.set('v.colors','green'); */
			} else if (state === 'ERROR'){
				var returnValues = response.getReturnValue();
				console.log('return: ', returnValues);
				component.set('v.Message', {
                    Header: 'Error!',
                    TextMessageEN: returnValues,
                    TextMessageTH: '(เกิดข้อผิดพลาด)',
                   });
				component.set('v.colors','red');
				
				component.set('v.showResult',true);
				component.set('v.UpsertTask',false);

			}
		});
		$A.enqueueAction(action);
	},
/*	getErrorMessage :function(component,event,helper){
		var action = component.get('c.getErrorMessage');
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === 'SUCCESS'){
				var Message = response.getReturnValue();
				component.set('v.ErrorMessage', Message);
				console.log('MESSAGE : ',Message);
				
			}else if (state === 'ERROR'){

			}
		});
		$A.enqueueAction(action);
	},
*/
	logFileHelper : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'File Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_self'}},
                {label: 'Total', fieldName: 'Total_Record__c', type: 'number'},
                {label: 'Success', fieldName: 'Success_Record__c', type: 'number'},
				{label: 'Fialed', fieldName: 'Failed_Record__c', type: 'number'},
				{label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes:{  
					year: 'numeric',  
					month: 'short',  
					day: 'numeric', 
					hour: '2-digit',  
					minute: '2-digit',  
					second: '2-digit',  
					hour12: true}},
				{label: 'Load Type', fieldName: 'Load_Type__c', type: 'Text'}
            ]);
        var action = component.get("c.getLogFiles");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
				var records =response.getReturnValue();
				records.forEach(function(record){
                    record.linkName = '/'+record.Id;
				});
				component.set("v.logList", records);
            }
        });
        $A.enqueueAction(action);
	}
	/*
	LoadResultMessage: function(component, event, helper) {
		var action = component.get("c.checkLoadResult");
		action.setParams({ });
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				var result =response.getReturnValue();
				if(result === true){
					component.set('v.Message', {
						Header: 'Load Success',
						TextMessageEN: 'See success and error log in next tab.',
						TextMessageTH: '(โปรดตรวจสอบผล Upload ใน Tab ถัดไป)',
					   });
					component.set('v.colors','green');
					
					component.set('v.showResult',true);
					component.set('v.UpsertTask',false);
					component.set('v.confirmUpsert',false);
					
				}

			}
		});
	
		$A.enqueueAction(action);
	}
	*/


})