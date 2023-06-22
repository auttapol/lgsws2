({
    sortsaleInfo: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.individualPerformance");
        sortAsc = sortField != field || !sortAsc;
        
        records.sort(function(a,b){
            // var t1 = a[field] == b[field],
            //     t2 = (!a[field] && b[field]) || (a[field] < b[field]);
                
            // return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            if (a[field] === b[field]) {
                return 0;
            }
            // nulls sort after anything else
            else if (a[field] === null) {
                return sortAsc? -1: 1;
            }
            else if (b[field] === null) {
                return sortAsc? 1: -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (sortAsc) {
                return a[field] < b[field] ? -1 : 1;
            }
            // if descending, highest sorts first
            else { 
                return a[field] < b[field] ? 1 : -1;
            }
        });
       /*  console.log('sorting:',records); */
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.individualPerformance", records);
    },

    sortCM: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.individualPerformance");
    
        sortAsc = sortField != field || !sortAsc; 
        records.sort(function(a,b){
            // if(!a['currentMonth']){
            //     a['currentMonth'] = -1000000;
            // }
            // if(!b['currentMonth']){
            //     b['currentMonth'] = -1000000;
            // }
            // if(a['currentMonth'] && b['currentMonth'])
            // {
            //     var t1 = a['currentMonth'][field] == b['currentMonth'][field],
            //         t2 = (!a['currentMonth'][field] && b['currentMonth'][field]) || (a['currentMonth'][field] < b['currentMonth'][field]);
            //     return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            // }
            if(a['currentMonth'] && b['currentMonth'])
            {
                if (a['currentMonth'][field] === b['currentMonth'][field]) {
                    return 0;
                }
                // nulls sort after anything else
                else if (a['currentMonth'][field] === null) {
                    return sortAsc? -1: 1;
                }
                else if (b['currentMonth'][field] === null) {
                    return sortAsc? 1: -1;
                }
                // otherwise, if we're ascending, lowest sorts first
                else if (sortAsc) {
                    return a['currentMonth'][field] < b['currentMonth'][field] ? -1 : 1;
                }
                // if descending, highest sorts first
                else { 
                    return a['currentMonth'][field] < b['currentMonth'][field] ? 1 : -1;
                }
            }
        });
       /*  console.log('sorting:',records); */
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.individualPerformance.currentmonth", records);
    },

    sortYTD: function(component, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.individualPerformance");
        sortAsc = sortField != field || !sortAsc; 
        records.sort(function(a,b){
            // if(!a['YTD']){
            //     a['YTD'] = -1000000;
            // }
            // if(!b['YTD']){
            //     b['YTD'] = -1000000;
            // }
            // if(a['YTD'] && b['YTD'])
            // {
            //     var t1 = a['YTD'][field] == b['YTD'][field],
            //         t2 = (!a['YTD'][field] && b['YTD'][field]) || (a['YTD'][field] < b['YTD'][field]);
            //     return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            // }
            if(a['YTD'] && b['YTD'])
            {
                if (a['YTD'][field] === b['YTD'][field]) {
                    return 0;
                }
                // nulls sort after anything else
                else if (a['YTD'][field] === null) {
                    return sortAsc? -1: 1;
                }
                else if (b['YTD'][field] === null) {
                    return sortAsc? 1: -1;
                }
                // otherwise, if we're ascending, lowest sorts first
                else if (sortAsc) {
                    return a['YTD'][field] < b['YTD'][field] ? -1 : 1;
                }
                // if descending, highest sorts first
                else { 
                    return a['YTD'][field] < b['YTD'][field] ? 1 : -1;
                }
            }
        });
      /*   console.log('sorting:',records); */
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.individualPerformance.YTD", records);
    },
})