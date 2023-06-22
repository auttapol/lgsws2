({
    navigateToP2 : function(component, event, helper) {
        var selectedMonth = component.get('v.selectedMonth');
        var selectedYear = component.get('v.selectedYear');
        // console.log('Debug selected month/year',selectedMonth,selectedYear);
        var empId = component.get('v.selectedEmpId');
        var sumProductObj = component.get('v.sumProductObj');
        
        // console.log('click id',event.target.id);
        var selectedKey = event.target.id.split('_');
        var selectedValue = '';
        var selectedFullName = '';
        if(selectedKey[0] == 'lv1') {
            selectedValue = sumProductObj[Number(selectedKey[1])].Name;
            selectedFullName = selectedValue;
        } else if(selectedKey[0] == 'lv2') {
            selectedValue = sumProductObj[Number(selectedKey[1])].Data[Number(selectedKey[2])].Name;
            var lv2Str = selectedValue == 'null' || !selectedValue ? '' : ' / '+selectedValue;
            selectedFullName = sumProductObj[Number(selectedKey[1])].Name+lv2Str;
        } else if(selectedKey[0] == 'name') {
            selectedValue = sumProductObj[Number(selectedKey[1])].Data[Number(selectedKey[2])].Data[Number(selectedKey[3])].Indicator_Name__c;
            var nameLv2 = sumProductObj[Number(selectedKey[1])].Data[Number(selectedKey[2])].Name;
            var lv2Str = nameLv2 == 'null' || !nameLv2 ? '' : ' / '+nameLv2;
            selectedFullName = sumProductObj[Number(selectedKey[1])].Name+lv2Str+' / '+selectedValue;
        }
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:T_Performance_P2",
            componentAttributes: {
                selectedEmpId: empId,
                selectedPerfKey: selectedKey[0],
                selectedPerfValue: selectedValue,
                selectedFullName: selectedFullName,
                selectedMonth: selectedMonth,
                selectedYear: selectedYear
            }
        });
        evt.fire();
    },

    handleExpand : function(component, event, helper) {
        var selectedKey = event.target.id.split('_');
        var action = selectedKey[0];
        var level = selectedKey[1];
        var idxLv1 = selectedKey[2];
        var sumProductObj = component.get('v.sumProductObj');
        if(level == 'lv1') {
            sumProductObj[idxLv1].expand = action == 'expand' ? true : false;
            // console.log(sumProductObj[idxLv1].expand);
        } else if(level == 'lv2') {
            var idxLv2 = selectedKey[3];
            sumProductObj[idxLv1].Data[idxLv2].expand = action == 'expand' ? true : false;
        }
        
        component.set('v.sumProductObj',sumProductObj);
    },
})