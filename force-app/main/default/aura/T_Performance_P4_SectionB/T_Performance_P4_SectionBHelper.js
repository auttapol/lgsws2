({
    prepareData : function(component, event, helper) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;

        var defaultMonth =  mm == 0 ? '12' :((mm-1).toString()).padStart(2, '0');
        var defaultYear = mm == 0 ? (yyyy-1).toString() : yyyy.toString();
        component.set('v.defaultMonth',defaultMonth);
        component.set('v.defaultYear',defaultYear);

        // component.set('v.selectMonth',defaultMonth);
        // component.set('v.selectYear',defaultYear);
        
        var year = [(yyyy-1).toString(),yyyy.toString()];
        var yearList = [];
        year.forEach((year,index) => {  
            var item = {
                "label": year,
                "value": year
            };   
            yearList.push(item);
        });
        component.set('v.yearList',yearList);

        var month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var monthList = [];

        month.forEach((month,index) => {    
            var item = {
                "label": month,
                "value": index > 8 ? (index+1).toString() : '0'+(index+1)
            };
            monthList.push(item);     
        });
        
        //console.log('monthList:',monthList);
        component.set('v.monthList',monthList);
        component.set('v.loaded',false);
    },

    getYearData : function(component, event, helper) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
       /*  var defaultMonth =  mm == 0 ? '12' :((mm-1).toString()).padStart(2, '0');
        var defaultYear = mm == 0 ? (yyyy-1).toString() : yyyy.toString(); */
        var defaultMonthLbpf = component.get('v.defaultMonthLbpf');
        var defaultYearLbpf = component.get('v.defaultYearLbpf');
        var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
        /* component.set('v.defaultMonth',defaultMonth);
        component.set('v.defaultYear',defaultYear); */
        // component.set('v.selectMonth',defaultMonth);
        // component.set('v.selectYear',defaultYear);
        var branchPerformance = component.get('v.branchPerformance');
        if(branchPerformance != null)
        {
            // console.log('branchPerformance:',JSON.parse(JSON.stringify(branchPerformance)));
            var yearData = [];  
            var dataAsOfMonth;
            var dataAsOfYear;
            for (var key in branchPerformance){
               
                if(branchPerformance[key]){

                    if(branchPerformance[key].length > 0){ 
                        
                        var obj = [];
                        branchPerformance[key].forEach((item,index) => {

                            if(item.Month__c == defaultMonthLbpf && item.Year__c == defaultYearLbpf)
                                {
                                    dataAsOfMonth = item.Month__c;
                                    dataAsOfYear  = item.Year__c;
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
                                }
                        });
                    
                        if(obj.No)
                        {   
                            obj.sort((a,b) => (a.No > b.No) ? 1 : ((b.No > a.No) ? -1 : 0)) ; 
                            yearData.push(obj);
                            component.set('v.dataAsOfMonthSecB','As Of '+month[dataAsOfMonth.replace(/^0+/,'')-1]);
                            component.set('v.dataAsOfYearSecB',dataAsOfYear);
                        }            
                    }   
                }
                
            }

            yearData.sort((a,b) => (a.No > b.No) ? 1 : ((b.No > a.No) ? -1 : 0)) ; 
            component.set('v.yearData',yearData);
        }
    },

    handleMonthList : function(component, event, helper, selectYear) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;

        var defaultYear = mm == 0 ? (yyyy-1).toString() : yyyy.toString();

        var month = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        var monthList = [];

        if(selectYear == defaultYear)
        {
            try 
            {
                month.forEach((month,index) => {     
                    var item = {
                        "label": month,
                        "value": index > 8 ? (index+1).toString() : '0'+(index+1)
                    };
                    monthList.push(item);

                    if((index+1) == (mm))
                    {
                        throw 'Break';
                    }        
                });
            }
            catch (e) {
                if (e !== 'Break') throw e
            }
            
        }
        else
        {
            month.forEach((month,index) => {     
                var item = {
                    "label": month,
                    "value": index > 8 ? (index+1).toString() : '0'+(index+1)
                };
                monthList.push(item);   
            });
        }
        component.set('v.monthList',monthList);
        component.set('v.selectYear',selectYear);
        /* component.set('v.isShow',false); */

    }
})