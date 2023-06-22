({
    getAdvisoryPlanningItem : function(component) {
        var action      = component.get("c.getAdvisoryPlanningItems");
        var recordId    = component.get("v.recordId");
        var itemType    = component.get("v.itemType");

        return new Promise(function (resolve, reject) {
            action.setParams({
                advisoryId      : recordId,
                itemType        : itemType
            });

            action.setCallback(this, function (response) {
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(response.getError()[0]);
                }
            });

            $A.enqueueAction(action);
        });
    },

    getColumn : function(component){
        var action      = component.get("c.getColumnByFieldSet");
        var objectName = "Advisory_Planning_Item__c";
        var fieldSet    = component.get("v.fieldSet");
        console.log('fieldSet = ' + fieldSet);

        return new Promise(function (resolve, reject) {
            action.setParams({
                objectName      : objectName,
                fieldSetName    : fieldSet
            });

            action.setCallback(this, function (response) {
               var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                else if (component.isValid() && state === "ERROR") {
                    var errors = response.getError();
                    reject(response.getError()[0]);
                }
            });

            $A.enqueueAction(action);
        });
    },
    
    processDataTable : function(component, records, dataColumn){
        console.log('-----processDataTable-------');
        var column = this.setColumn(dataColumn);
        console.log(column);
        console.log(records);
        component.set("v.columns", column);
        component.set("v.data", records);
    },

    setColumn : function(dataColumn){
        var result = [];
        if(dataColumn != undefined){
            for(let i = 0; i < dataColumn.length; i++){
                var col = dataColumn[i];
                var eachColumn = {
                    label       : col.label,
                    fieldName   : col.fieldName,
                    type        : col.fieldtype,
                    sortable    : col.sortable,
                    cellAttributes : { 
                        alignment: col.cellAttributes
                    }
                }

                if(col.fieldtype == 'percent' || col.fieldtype == 'number' || col.fieldType == 'currency'){
                    eachColumn.typeAttributes = { 
                        minimumFractionDigits : 2,
                        maximumFractionDigits : 2
                    }
                }

                console.log(eachColumn);
                result.push(eachColumn);
            }
        }

        return result;
    },

    handleSort: function(component, event) {
        var sortedBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        var originalData  = component.get("v.data");

        var cloneData = originalData.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1)));
        
        component.set("v.data", cloneData);
        component.set("v.sortDirection", sortDirection);
        component.set("v.sortedBy", sortedBy);
    },

    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

})