({
    onInit : function(component, event, helper) {
        helper.setFocusedTabLabel(component, event, helper);
        helper.getPerformanceData(component, event, helper);
        helper.getWatermarkHTML(component);
        helper.getProductList(component, helper);

        var date = new Date();
        var asOfMonth = component.get('v.selectedMonth');
        var asOfYear = component.get('v.selectedYear');
        // console.log('show data as of ',asOfMonth,asOfYear);
        // if(asOfMonth && asOfYear) {
            
        date.setFullYear(asOfYear);
        var currYear = date.getFullYear();
        var asOfMonthSre = '';
        if(asOfMonth) {
            date.setMonth(asOfMonth-1);
            asOfMonthSre = date.toLocaleString('default', { month: 'short' })
        }
        component.set('v.asOfStr',' as of '+asOfMonthSre+' '+currYear);
        component.set('v.genUniqueId',Date.now().toString());
    },
    
    handleNext : function(component, event, helper)
    {
        // var saleTranList = component.get("v.saleTranList");
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");

        var newStart = start+pageSize;
        var newEnd = end+pageSize;
        
        var saleTransData = component.get('v.saleTransData');
        if(newStart <= totalSize) {
            component.set("v.start",newStart);
            component.set("v.end",newEnd);
            // helper.getPerformanceData(component, event, helper);
            // console.log('slice from ',newStart-1,newEnd)
            var newList = saleTransData.slice(newStart-1,newEnd);

            component.set('v.saleTranList',newList);
        }
        // var paginationList = [];
        // var counter = 0;

        // for(var i = end+1; i < end+pageSize+1; i++)
        // {
        //     if(saleTranList.length > end)
        //     {
        //         if(saleTranList[i])
        //         {
        //             paginationList.push(saleTranList[i]);                   
        //         }
        //         counter++;
        //     }
        // }
        // start = start+counter;
        // end = end+counter;
       
        // component.set("v.start",start);
        // component.set("v.end",end);
        // component.set('v.paginationList', paginationList);
    },

    handlePrevious : function(component, event, helper)
    {
        var end = component.get("v.end");
        var start = component.get("v.start");
        var pageSize = component.get("v.pageSize");
        var totalSize = component.get("v.totalSize");

        var newStart = start-pageSize;
        var newEnd = end-pageSize;
        
        var saleTransData = component.get('v.saleTransData');
        if(newStart > 0) {
            component.set("v.start",newStart);
            component.set("v.end",newEnd);
            // helper.getPerformanceData(component, event, helper);
            // console.log('slice from ',newStart-1,newEnd)
            var newList = saleTransData.slice(newStart-1,newEnd);
            component.set('v.saleTranList',newList);
        }
        // var saleTranList = component.get("v.saleTranList");
        // var end = component.get("v.end");
        // var start = component.get("v.start");
        // var pageSize = component.get("v.pageSize");

        // var paginationList = [];

        // var counter = 0;

        // for(var i= start-pageSize; i < start ; i++)
        // {
        //     if(i > -1)
        //     {
        //         paginationList.push(saleTranList[i]);
        //         counter++;
        //     }
        //     else 
        //     {
        //         start++;
        //     }

        // }
        // start = start-counter;
        // end = end-counter;

        // component.set("v.start",start);
        // component.set("v.end",end);
        // component.set('v.paginationList', paginationList);
    },

    showtooltip : function(component, event, helper) {
        var id = event.target.getAttribute("data-value");
        // var index = event.target.getAttribute("data-value");
        helper.toggleHelper(component, event, id);
    },
    
    hidetooltip : function(component, event, helper) {
        var id = event.target.getAttribute("data-value");
        // var index = event.target.getAttribute("data-value");
        helper.toggleHelper(component, event, id);
    },

    sortData: function(component, event, helper) {
        var field = event.target.getAttribute("data-value");
        // console.log('field:',field);
        var currSortField = component.get('v.sortField');
        var sortAsc = component.get('v.isSortAsc');
        if(field && field == currSortField) {
            sortAsc = !sortAsc;
        } else {
            sortAsc = true;
            component.set('v.sortField',field);
        }
        component.set('v.isSortAsc',sortAsc);
        // console.log(component.get('v.isSortAsc'))
        var records = component.get('v.saleTransData');
        // console.log('before ',records)
        if(sortAsc) {
            records.sort((a, b) => {
                if(a[field] === null || a[field] === undefined) {
                    return -1;
                } else if(b[field] === null || a[field] === undefined) {
                    return 1;
                } else if (a[field] === b[field]) {
                    return 0;
                } else {
                    return a[field] < b[field] ? -1 : 1;
                }
                
            });
            // console.log("ascending",field, records);
        } else {
            records.sort((a, b) => {
                if(a[field] === null || a[field] === undefined) {
                    return 1;
                } else if(b[field] === null || b[field] === undefined) {
                    return -1;
                } else if (a[field] === b[field]) {
                    return 0;
                } else {
                    return a[field] < b[field] ? 1 : -1;
                }
            });
            // console.log("descending",field, records);
        }

        // console.log('sort by '+field,sortAsc,records)

        var newStart = component.get("v.start");
        var newEnd = component.get("v.end");
        var newList = records.slice(newStart-1,newEnd);
        component.set('v.saleTranList',newList);
        // console.log('console test ',newList)
        // component.set('v.saleTransData',records)
    },

    onClickHelp : function(component, event, helper) {
        // helper.getSharePointLink(component,'Help');
        var link = component.get('v.helpLink');
        window.open(link);
    },

    onClickSummary : function(component, event, helper) {
        // helper.getSharePointLink(component,'Branch Summary');
        var link = component.get('v.summaryLink');
        window.open(link);
    }
})