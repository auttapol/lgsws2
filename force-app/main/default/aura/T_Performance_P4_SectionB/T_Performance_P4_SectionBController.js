({
    onInit : function(component, event, helper) {
        // component.set('v.loaded',true);
        //   var branchPerformance = JSON.parse(JSON.stringify(component.get('v.branchPerformance')));
         /* if(branchPerformance != null) { 
            component.set('v.branchPerformance',JSON.parse(JSON.stringify(component.get('v.branchPerformance'))));
        }    */
        //var saleTransaction = JSON.parse(JSON.stringify(component.get('v.')));
        helper.getYearData(component, event, helper);
        component.set('v.firstRender',true);
        component.set('v.tabYear',true);
        
    },

    handleSelect : function(component, event ,helper){
        component.set('v.loaded',true);
        var firstRender = component.get('v.firstRender');
        var tabYear = component.get('v.tabYear');
        var tabHistory = component.get('v.tabHistory');
        // $A.get("e.force:refreshView").fire();
        if(firstRender)
        {   
            if (tabYear){
                helper.prepareData(component, event, helper);
                component.set('v.selectMonth',null);
                component.set('v.selectYear',null);
                component.set('v.historyData',null);
                component.set('v.isShow',false);
                component.set('v.firstRender',false);
                component.set('v.tabYear',false);
            }
            if(tabHistory){
                var parentComponent = component.get("v.cmpParent");  
                component.set('v.defaultYearItp',null);
                component.set('v.defaultMonthItp',null);
                component.set('v.defaultYearIdp',null);
                component.set('v.defaultMonthIdp',null);
                component.set('v.defaultYearSif',null);
                component.set('v.defaultMonthSif',null);
                component.set('v.monthSaleInOut',null);
                component.set('v.yearSaleInOut',null);
                parentComponent.prepareData();
                component.set('v.tabHistory',false);
                component.set('v.firstRender',false);
                component.set('v.dataAsOfMonthHistory',null);
                component.set('v.selectMonth',null);
                component.set('v.selectYear',null);
                component.set('v.loaded',false);
            }
          
        }
        else
        {   
            component.set('v.loaded',false);
        }
    },

    showHandle : function(component, event ,helper){ 
        var branchPerformance = component.get('v.branchPerformance');
        var selectMonth = component.get('v.selectMonth');
        var selectYear = component.get('v.selectYear');
        var allValid = true;
        var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
        // console.log('branchPerformance:',JSON.parse(JSON.stringify(branchPerformance)));
        if(selectMonth == null || selectMonth == '')
        {
            allValid = false;
            $A.util.addClass(component.find('month'), "slds-has-error");                         
        }
        if(selectYear == null || selectYear == '')
        {
            allValid = false;
            $A.util.addClass(component.find('year'), "slds-has-error");         
        }
        if(allValid)
        {
            if(branchPerformance != null)
            {
                var historyData = [];  
                for(var key in branchPerformance)
                {   
                    if(branchPerformance[key])
                    {   
                        if(branchPerformance[key].length > 0)
                        {     
                            var obj = [];  
                            branchPerformance[key].forEach((item,index) => {                      
                                if(item.Month__c == selectMonth && item.Year__c == selectYear)
                                {  ;
                                    if(item.Indicator_Rank__c.length == 1)
                                    { 
                                        obj.Name = item.Indicator_Name__c;
                                        obj.No = item.Indicator_Rank__c;
                                        obj.KPI_Value__c = item.KPI_Value__c; 
                                        obj.Branch_Team_Code__c = item.Branch_Team_Code__c;
                                        obj.Channel__c = item.Channel__c;
                                        obj.Year__c = item.Year__c;
                                        obj.Month__c =  item.Month__c;     
                                    }
                                    else
                                    {
                                        var param = [];  
                                        param.Name = item.Indicator_Name__c;
                                        param.No = item.Indicator_Rank__c;
                                        param.KPI_Value__c = item.KPI_Value__c; 
                                        param.Branch_Team_Code__c = item.Branch_Team_Code__c;
                                        param.Channel__c = item.Channel__c;
                                        param.Year__c = item.Year__c;
                                        param.Month__c =  item.Month__c;                              
                                        obj.push(param);
                                        
                                    }    
                                    obj.sort((a,b) => (a.No > b.No) ? 1 : ((b.No > a.No) ? -1 : 0)) ;
                                    component.set('v.dataAsOfMonthHistory','As Of '+month[selectMonth.replace(/^0+/,'')-1]+' '+selectYear);          
                                }
                            }); 
                            if(obj.No)
                            {   
                                historyData.push(obj); 
                            }
                        }   
                    }
                
                }
                if(historyData.length > 0)
                {   historyData.sort((a,b) => (a.No > b.No) ? 1 : ((b.No > a.No) ? -1 : 0)) ;
                    component.set('v.historyData',historyData);
                }
                else
                {
                    component.set('v.historyData',null);
                }
        
            }
        var parentComponent = component.get("v.cmpParent");  
        component.set('v.defaultYearItp',selectYear);
        component.set('v.defaultMonthItp',selectMonth);
        component.set('v.defaultYearIdp',selectYear);
        component.set('v.defaultMonthIdp',selectMonth);
        component.set('v.defaultYearSif',selectYear);
        component.set('v.defaultMonthSif',selectMonth);
        component.set('v.monthSaleInOut',selectMonth);
        component.set('v.yearSaleInOut',selectYear);
        parentComponent.prepareData();
        component.set('v.isShow',true);
        component.set('v.firstRender',true);
        component.set('v.tabHistory',true);
        }
    },
    handleMonth : function(component, event ,helper){
        var value = event.getSource().get("v.value");
        component.set('v.selectMonth',value);

     /*    component.set('v.isShow',false); */
        $A.util.removeClass(component.find('month'), "slds-has-error"); // remove red border
        $A.util.addClass(component.find('month'), "hide-error-message");
    },
    handleYear : function(component, event ,helper){
        var value = event.getSource().get("v.value");
        component.set('v.selectMonth',null);
        helper.handleMonthList(component, event ,helper, value);

        $A.util.removeClass(component.find('year'), "slds-has-error"); // remove red border
        $A.util.addClass(component.find('year'), "hide-error-message"); 
    },
    onHelp: function(component, event,helper) {
        var link = component.get('v.helpLink');
        window.open(link);
    },
    onSummary: function(component, event,helper) {
        var link = component.get('v.summaryLink');
        window.open(link);
    }
})