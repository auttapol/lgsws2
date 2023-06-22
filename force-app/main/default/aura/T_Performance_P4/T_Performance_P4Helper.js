({
    setFocusedTabLabel : function(component, event, helper) {
        var branchCode = component.get('v.branchCode');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "P.4 " +'('+ branchCode + ')'
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom48",
                iconAlt: "Approval"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },
    getPerformanceData : function(component, event, helper) {
        component.set('v.loaded',true);
        var branchCode = component.get('v.branchCode');
        var userType = component.get('v.userType');
        var defaultMonthItp = component.get('v.defaultMonthItp');
        var defaultYearItp = component.get('v.defaultYearItp');
        var defaultMonthSif = component.get('v.defaultMonthSif'); ;
        var defaultYearSif = component.get('v.defaultYearSif');;
        var defaultMonthIdp = component.get('v.defaultMonthIdp'); ;
        var defaultYearIdp = component.get('v.defaultYearIdp');;
        var monthSaleInOut = component.get('v.monthSaleInOut'); ;
        var yearSaleInOut = component.get('v.yearSaleInOut');;
        var action = component.get('c.getPerformanceData');
        action.setParams({
            "branchCode" : branchCode
            //"branchCode" : "0001"
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                component.set('v.loaded', false);            
                var result =  response.getReturnValue();   
                component.set('v.performanceObj',result);
                helper.prepareBranchPerformanceData(component, event, helper, result);
                helper.prepareBranchProfileData(component, event, helper, result, defaultMonthItp, defaultYearItp);
                helper.prepareIndividualPerformanceData(component, event, helper, result,defaultMonthSif, defaultYearSif, defaultMonthIdp, defaultYearIdp);
                helper.getsumSaleInOut(component,event,helper,result,monthSaleInOut, yearSaleInOut);
                if(!component.get('v.helpLink')) {
                    helper.getHelpAndSummary(component);
                }
            } 
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                  // Display the message
                  helper.showToastError('Get Performance Failed, Message:'+message);
                  component.set('v.loaded', false);
            }  
        });
        
        $A.enqueueAction(action);       
    },
    getFinancialData : function(component,event,helper){
        component.set('v.loaded',true);
        var branchCode = component.get('v.branchCode');// at cmp
        var action = component.get('c.getSumActual');// get function at apex
        action.setParams({
            "branchCode" : branchCode
            //"branchCode" : "0001"
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result =  response.getReturnValue();
                var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];  
                component.set('v.sumFinancialProduct',result);
                if (result){
                    if (result.length>0){
                      result.forEach((sts)=> { 
                    component.set('v.dataAsOfMonthSecB',month[sts.latestMonth.replace(/^0+/,'')-1]);
                    component.set('v.dataAsOfYearSecB', sts.latestYear);
                    });   
                    }
                }
                component.set('v.loaded', false);
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get Financial Failed, Message:'+message);
                component.set('v.loaded', false);
            }
        });
        $A.enqueueAction(action);  
    },

    getsumSaleInOut : function(component,event,helper,result,monthSaleInOut, yearSaleInOut){
        if (!(monthSaleInOut && yearSaleInOut)){
            if(result.lastTeamprofile){
                if(result.lastTeamprofile.length >0){
                    result.lastTeamprofile.forEach(lsi =>{
                    monthSaleInOut = lsi.Month__c;
                    yearSaleInOut = lsi.Year__c;
                    });
                    component.set('v.monthSaleInOut',monthSaleInOut);
                    component.set('v.yearSaleInOut',yearSaleInOut);
                }
            }
        }
        var monthSale = component.get('v.monthSaleInOut');
        var yearSale = component.get('v.yearSaleInOut');
        component.set('v.loaded', true);
        var action = component.get('c.getSaleInOut');// get function at apex
        action.setParams({
            "year" : yearSale,
            "month" : monthSale
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var results =  response.getReturnValue();   
                component.set('v.sumSaleInOut',results);

            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get sumSaleInOut Failed, Message:'+message);
                component.set('v.loaded', false);
            }
            component.set('v.loaded', false);
        });
        $A.enqueueAction(action);  

    },

    prepareBranchPerformanceData : function(component, event, helper, result) {
        var UserType = component.get('v.userType')
        if (UserType == "RASC"){ 
             helper.getFinancialData(component, event ,helper);
        
        }
        else{
            if(result.lastBranchperformance){
                var defaultMonthLbpf;
                var defaultYearLbpf;
                if(result.lastBranchperformance.length > 0){
                    result.lastBranchperformance.forEach((lbpf)=> {
                        defaultMonthLbpf = lbpf.Month__c;
                        defaultYearLbpf  = lbpf.Year__c;
                    });
                component.set('v.defaultMonthLbpf',defaultMonthLbpf);
                component.set('v.defaultYearLbpf',defaultYearLbpf);    
                }
            }
            
            var branchPerformance = []; 
            for(var key in result.branchPerformance)
        {
            var obj = [];
            if(result.branchPerformance[key])
            {
                if(result.branchPerformance[key].length > 0)
                {
                    result.branchPerformance[key].forEach((field,index) => {       
                        var param = [];  
                        param.Name = field.Indicator_Name__c;
                        param.No = field.Indicator_Rank__c;
                        param.KPI_Value__c = field.KPI_Value__c; 

                        param.Branch_Team_Code__c = field.Branch_Team_Code__c;
                        param.Channel__c = field.Channel__c;
                        param.Year__c = field.Year__c;
                        param.Month__c =  field.Month__c;
                        obj.push(param);                  
                    });
                }
            }
            branchPerformance.push(obj);
            
        }

        component.set('v.branchPerformance',result.branchPerformance);  
        }
        
    },

    prepareBranchProfileData : function(component, event, helper, result, defaultMonthItp, defaultYearItp) {
        if(result.saleInfo)
        {   
            if(result.saleInfo.length > 0)
            {   
                var saleInfoObj = [];
                result.saleInfo.forEach(field => {
                    saleInfoObj.push(field);
                    component.set('v.saleInfo',saleInfoObj);
                });
        	}
        
    	}
        if (!(defaultMonthItp && defaultYearItp)){
            if(result.lastTeamprofile){
                if(result.lastTeamprofile.length >0){
                    result.lastTeamprofile.forEach(ltp =>{
                    defaultMonthItp = ltp.Month__c;
                    defaultYearItp = ltp.Year__c;
                    });
                    component.set('v.defaultMonthItp',defaultMonthItp);
                    component.set('v.defaultYearItp',defaultYearItp);
                }
            }
        }
        

    	if(result.teamProfile)
    	{
    		if(result.teamProfile.length > 0)
            {
                 var teamProfileObj = [];
                 result.teamProfile.forEach(field => {
                    teamProfileObj.push(field);
                 });
                 component.set('v.branchProfile',teamProfileObj);
        	}
         }
    },

    prepareIndividualPerformanceData : function(component, event, helper, result ,defaultMonthSif, defaultYearSif, defaultMonthIdp, defaultYearIdp) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
        var IndividualPerformance = [];
        var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
        if (!(defaultMonthSif && defaultYearSif)){
            if(result.lastSaleInfo){
                if(result.lastSaleInfo.length> 0){
                    result.lastSaleInfo.forEach(sif => {
                    defaultMonthSif = sif.Month__c;
                    defaultYearSif = sif.Year__c;
                    });
                    component.set('v.defaultMonthSif',defaultMonthSif);
                    component.set('v.defaultYearSif',defaultYearSif); 
                }
            }
        }

        if(result.saleInfo)
        {
            if(result.saleInfo.length > 0)
            {
                result.saleInfo.forEach((field,index) => {        
                    var info = [];
                    if(field.Month__c == defaultMonthSif && field.Year__c == defaultYearSif){
                  /*   info.No = index+1; */
                    info.Employee_ID__c = field.Employee_ID__c ? field.Employee_ID__c : '';
                    info.Sale_Type = field.Sale_Type__c ? field.Sale_Type__c : '';
                    info.Position = field.Position__c ? field.Position__c : '';
                    info.Name = field.Name ? field.Name : '';
                    info.No_Of_Customer = field.Number_of_Customer__c != null && field.Number_of_Customer__c != undefined ? field.Number_of_Customer__c : null;     

                    var sp = [];
                    sp.Investment = field.Fund_Grade__c ? field.Fund_Grade__c : '';
                    sp.Protection = field.Life_Grade__c ? field.Life_Grade__c : '';
                    sp.SBO = field.SME_Grade__c ? field.SME_Grade__c : '';
                    sp.HL = field.HL_Grade__c ? field.HL_Grade__c : '';
                    sp.CYC = field.CYC_Grade__c ? field.CYC_Grade__c : '';
                    info.specialist = sp;
                    
                    IndividualPerformance.push(info);
                    }
                });
                IndividualPerformance.sort((a,b) => (a.Sale_Type < b.Sale_Type) ? 1 : ((b.Sale_Type < a.Sale_Type) ? -1 : 0)) ;
            }
        }

        IndividualPerformance.forEach(element => {
            var cm1 = {
                Actual_Point__c : null,
                Target_Point__c : null,
                Percent_Success__c : null,
                Variance__c : null
            };
            var ytd1 = {
                Percent_Success_YTD__c : null,
                Rank_Bankwide__c : null
            };
            element.currentMonth = cm1;
            element.YTD = ytd1;
        });

        if (!(defaultMonthIdp && defaultYearIdp)){
            if(result.lastSaleperformance){
                if(result.lastSaleperformance.length> 0){
                    result.lastSaleperformance.forEach(idp => {
                    defaultMonthIdp = idp.Month__c;
                    defaultYearIdp = idp.Year__c;
                    });
                    component.set('v.defaultMonthIdp',defaultMonthIdp);
                    component.set('v.defaultYearIdp',defaultYearIdp); 
                }
            }
        }

        if(result.salePerformance)
        {
            if(result.salePerformance.length > 0)

            {   
                result.salePerformance.forEach(field => {
                
                    var cm = [];
                    var ytd = [];
                    if(field.Month__c == defaultMonthSif && field.Year__c == defaultYearSif)
                    {   
                        cm.Actual_Point__c = field.Actual_Point__c != null && field.Actual_Point__c!= undefined ? field.Actual_Point__c : '';
                        cm.Target_Point__c = field.Target_Point__c != null && field.Target_Point__c != undefined ? field.Target_Point__c : '';
                        cm.Percent_Success__c = field.Percent_Success__c != null && field.Percent_Success__c != undefined ? field.Percent_Success__c : '';
                        cm.Variance__c = field.Variance__c != null && field.Variance__c != undefined ? field.Variance__c : '';
                      
                        ytd.Percent_Success_YTD__c = field.Percent_Success_YTD__c != null && field.Percent_Success_YTD__c != undefined ? field.Percent_Success_YTD__c : '';
                        ytd.Rank_Bankwide__c = field.Rank_Bankwide__c ? field.Rank_Bankwide__c : '';
                        if(IndividualPerformance.length > 0)
                        {                    
                            IndividualPerformance.forEach((element,index) => {
                                if(element.Employee_ID__c != '' && element.Employee_ID__c == field.Employee_ID__c)
                                {                       
                                    if(IndividualPerformance[index]){
                                        IndividualPerformance[index].currentMonth = cm;
                                        IndividualPerformance[index].YTD = ytd;
                                    }
                                }                             
                            });  
                        }
                    }
                });
                component.set('v.dataAsOfMonthSecC',month[defaultMonthSif.replace(/^0+/,'')-1]);
                component.set('v.dataAsOfYearSecC',defaultYearSif);
            }
        }
        component.set('v.individualPerformance',IndividualPerformance);
    },

    getHelpAndSummary : function(component,event,helper){
        /* component.set('v.loaded',true); */
        var action = component.get('c.getHelpAndSummary');// get function at apex
        var branchCode  = component.get('v.branchCode');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {               
                var result = response.getReturnValue();
                if(result){
                    result.forEach(obj => {
                        if(obj.SharePoint_Type__c == 'Help') {
                            component.set('v.helpLink',obj.URL_Link__c);
                        } else {
                            // component.set('v.summaryLink',obj.URL_Link__c+saleInfo.Branch_Code__c+'.pdf');
                            component.set('v.summaryLink',obj.URL_Link__c.replaceAll('$branchcode;',branchCode));
                        }
                    });
                   /* component.set('v.loaded', false); */ 
                }
            }   
            else{
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                helper.showToastError('Get HelpAndSummary Failed, Message:'+message);
                component.set('v.loaded', false);
            }  
        });
        $A.enqueueAction(action);  

    },

    getWatermarkHTML : function(component) {
		var action = component.get("c.getWatermarkHTML");
		action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === "SUCCESS") {
            	var watermarkHTML = response.getReturnValue();
                // console.log('watermarkHTML: ', watermarkHTML);

                var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                    "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + watermarkHTML + "</text></svg>");
                var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";

                component.set('v.waterMarkImage', bg);
            } else if(state === 'ERROR') {
                console.log('STATE ERROR');
                helper.showToastError('Get WatermarkHTML Failed, Message:'+response.error);
                component.set('v.loaded', false);
            } else {
                helper.showToastError('Unknown problem, state: '+ state + ', error: ' + JSON.stringify(response.error));
                component.set('v.loaded', false);
            }
		});
		$A.enqueueAction(action);
	},
    
    showToastError : function(msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error",
            "message": msg
        });
        toastEvent.fire();
    }
})