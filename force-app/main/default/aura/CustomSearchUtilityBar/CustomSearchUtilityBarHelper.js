({
    showMore : function(component) {
   
        var size = component.get("v.size");
        var dataList = component.get("v.dataList");
        size = size+parseInt(component.get("v.loadMoreSize"));
        component.set("v.size",size);
        if(dataList)
        {
            if(size != dataList.length && dataList.length > 0)
            {
                component.set('v.loaded', true);
                // $A.get('e.force:refreshView').fire();
                setTimeout(function(){
                    component.set('v.loaded', false);
                },200);
            }
        }
    },

    checkProfileAssign: function(component,event,helper){
        var action = component.get('c.checkProfileAssign');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();   
                //console.log('currentUser:',result); 
                component.set('v.checkProfileAssign',result);               
            }         
        });
        
        $A.enqueueAction(action);
    },


})