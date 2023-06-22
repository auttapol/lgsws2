({
    // formatDate : function(date) {
    //     let dateArr = date.split("-");
    //     let retDate = '';
    //     console.log(date,dateArr);
    //     if(dateArr.length > 2) {
    //         retDate = dateArr[2]+'/'+dateArr[1]+'/'+dateArr[0];
    //     }
    //     console.log('debug format date',retDate);
    //     return retDate;
    // }

    toggleHelper : function(component,event,index) {
        var toggleText = component.find("tooltip");
        $A.util.toggleClass(toggleText[index], "toggle");
    },
})