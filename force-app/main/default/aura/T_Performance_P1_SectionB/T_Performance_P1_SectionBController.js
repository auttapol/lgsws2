({
    // onInit : function(component, event, helper) {
    //     // var date = new Date();
    //     // var asOfMonth = component.get('v.dataAsOfMonth');
    //     // var asOfYear = component.get('v.dataAsOfYear');
    //     // if(asOfMonth && asOfYear) {
    //     //     console.log('show data as of',component.get('v.dataAsOfMonth'));
    //     //     date.setMonth(date.getMonth()-1);
    //     //     var currYear = date.getFullYear();
    //     //     if(date.getMonth() == 12) {
    //     //         currYear = date.getFullYear()-1;
    //     //     }
    //     //     var previousMonth = date.toLocaleString('default', { month: 'short' })
    //     //     component.set('v.asOfStr',previousMonth+' '+currYear);
    //     //     // $A.localizationService.formatDate(date, "YYYY-MM-DD");
    //     // }
    //     console.log('init');
    //     var date = new Date();
    //     var asOfMonth = component.get('v.dataAsOfMonth');
    //     var asOfYear = component.get('v.dataAsOfYear');
    //     console.log('show data as of ',asOfMonth,asOfYear);
    //     if(asOfMonth && asOfYear) {
    //         date.setMonth(asOfMonth);
    //         date.setFullYear(asOfYear);
    //         var currYear = date.getFullYear();
    //         // if(date.getMonth() == 12) {
    //         //     currYear = date.getFullYear()-1;
    //         // }
    //         var previousMonth = date.toLocaleString('default', { month: 'short' })
    //         component.set('v.asOfStr',previousMonth+' '+currYear);
    //         // $A.localizationService.formatDate(date, "YYYY-MM-DD");
    //     }
    // },

    valueChange : function(component, event, helper) {
        var date = new Date();
        var asOfMonth = component.get('v.dataAsOfMonth');
        var asOfYear = component.get('v.dataAsOfYear');
        var monthLst = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        ];
        // if(asOfMonth && asOfYear) {
            
            date.setFullYear(asOfYear);
            var currYear = date.getFullYear();
            var previousMonth = '';
            if(asOfMonth) {
                // date.setMonth(asOfMonth-1);
                // previousMonth = date.toLocaleString('default', { month: 'short' })
                previousMonth = monthLst[asOfMonth-1];
            }
            component.set('v.asOfStr','Official Point as of '+previousMonth+' '+currYear);
            // component.set('v.asOfStr',previousMonth+' '+currYear);
            // $A.localizationService.formatDate(date, "YYYY-MM-DD");
        // } else {
        //     component.set('v.asOfStr','-');
        // }
    },

    valueChange2 : function(component, event, helper) {
        var date = new Date();
        var asOfMonth = component.get('v.dataAsOfMonth');
        var asOfYear = component.get('v.dataAsOfYear');
        var monthLst = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec'
        ];
        // if(asOfMonth && asOfYear) {
            
            date.setFullYear(asOfYear);
            var currYear = date.getFullYear();
            var previousMonth = '';
            if(asOfMonth) {
                // date.setMonth(asOfMonth-1);
                // previousMonth = date.toLocaleString('default', { month: 'short' })
                previousMonth = monthLst[asOfMonth-1];
            }
            component.set('v.asOfStr','Official Point as of '+previousMonth+' '+currYear);
        // } else {
        //     component.set('v.asOfStr','-');
        // }
    },
  
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
        
        var data = [
            { label: 'Total Finance', fieldName: 'totalFinance', type: 'button', cellAttributes: { class: {fieldName:'subGroupLevelClass'}}, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'totalFinance'
                },
                title: {
                    fieldName: 'totalFinance'
                },
                name: {
                    fieldName: 'totalFinance'
                },
            } },
            { label: 'Unit', fieldName: 'unit', type: 'button', cellAttributes: { class: 'min-width-unit'}, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'unit'
                },
                title: {
                    fieldName: 'unit'
                },
                name: {
                    fieldName: 'unit'
                },
            }},
            { label: '%Weight KPIs', fieldName: 'weightKPIs', type: 'button', cellAttributes: {alignment: 'right'} ,fixedWidth: 110 , typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'weightKPIs'
                },
                title: {
                    fieldName: 'weightKPIs'
                },
                name: {
                    fieldName: 'weightKPIs'
                },
            }},
            { label: 'Target_Unit', fieldName: 'targetUnit', type: 'button', cellAttributes: {alignment: 'right'}, fixedWidth: 120, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'targetUnit'
                },
                title: {
                    fieldName: 'targetUnit'
                },
                name: {
                    fieldName: 'targetUnit'
                },
            }}, 
            { label: 'Actual_Unit', fieldName: 'actualUnit', type: 'button', cellAttributes: {alignment: 'right'}, fixedWidth: 100, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'actualUnit'
                },
                title: {
                    fieldName: 'actualUnit'
                },
                name: {
                    fieldName: 'actualUnit'
                },
            }}, 
            { label: '%Success_Unit', fieldName: 'successUnit', type: 'button', cellAttributes: {alignment: 'right'}, fixedWidth: 120, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'successUnit'
                },
                title: {
                    fieldName: 'successUnit'
                },
                name: {
                    fieldName: 'successUnit'
                },
            }}, 
            { label: '%Achivement', fieldName: 'achivement', type: 'button', cellAttributes: {alignment: 'right', class: 'last-col'}, fixedWidth: 120, typeAttributes: {
                variant: 'base',
                label: {
                    fieldName: 'achivement'
                },
                title: {
                    fieldName: 'achivement'
                },
                name: {
                    fieldName: 'achivement'
                },
            }}, 
        ]
        component.set('v.mycolumns',data );
    },

    closeModel: function(component, event, helper) { 
        component.set("v.isOpen", false);
    }
})