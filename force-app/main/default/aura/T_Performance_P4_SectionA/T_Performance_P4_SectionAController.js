({   
  onInit : function(component, event, helper) {
    },

    scriptsLoaded : function(component, event, helper) {
        component.set('v.scriptLoaded',true);
        helper.drawChart(component, event, helper);
    },

    valueChange : function(component, event, helper) {
        var branchProfile = component.get('v.branchProfile');
        var sumSaleInOut = component.get('v.sumSaleInOut');
        if (sumSaleInOut != null){
          
            component.set('v.inBankwide',sumSaleInOut.InBankWide)
            component.set('v.outBankwide',sumSaleInOut.OutBankWide)
           
        }
        if(branchProfile != null)
        {
            var today = new Date();
            var dd = String(today.getDate()).padStart(2, '0');
            var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
            var yyyy = today.getFullYear();
            today = mm + '/' + dd + '/' + yyyy;
           
            var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
            var branchProfileData = []; 
            var teamNameTH ;
            var databranchFound = false;
            var defaultMonthItp = component.get('v.defaultMonthItp');
            var defaultYearItp = component.get('v.defaultYearItp');
            if(branchProfile.length > 0)
            {   
                branchProfile.forEach((item,index) => {
                    
                    if(item.Month__c == defaultMonthItp  && item.Year__c == defaultYearItp )
                    {  
                        databranchFound = true;
                        branchProfileData = item;
                        teamNameTH = branchProfileData.Team_Name_TH__c;
                        branchProfileData.Rank_Zone__c = branchProfileData.Rank_Zone__c;
                        branchProfileData.Number_of_Branch_Zone__c =  branchProfileData.Number_of_Branch_Zone__c;
                        branchProfileData.Rank_Region__c =  branchProfileData.Rank_Region__c;
                        branchProfileData.Number_of_Branch_Region__c = branchProfileData.Number_of_Branch_Region__c;
                        branchProfileData.Rank_Bankwide__c = branchProfileData.Rank_Bankwide__c;
                        branchProfileData.Number_of_Branch_Bankwide__c = branchProfileData.Number_of_Branch_Bankwide__c;

                       
                       
                        component.set('v.teamNameTH',teamNameTH);
                        component.set('v.kpiValue',item.KPI__c);
                        component.set('v.averageBankwide',item.Average_Bankwide__c);
                        component.set('v.branchProfileData',branchProfileData);
                        
                    }
                });
                if (!databranchFound){
                    component.set('v.teamNameTH',null);
                    component.set('v.kpiValue',null);
                    component.set('v.averageBankwide',null);
                    component.set('v.branchProfileData',null);
                }
                component.set('v.dataAsOfMonthSecA',month[defaultMonthItp.replace(/^0+/,'')-1]);
                component.set('v.dataAsOfYearSecA',defaultYearItp);
            }
        }
        if(component.get('v.scriptLoaded')) {
            helper.drawChart(component,event,helper);
        }
    },

    periodChange : function(component, event, helper) {
        var defaultMonthItp = component.get('v.defaultMonthItp');
        var defaultYearItp = component.get('v.defaultYearItp');
        var month = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
        if (defaultMonthItp!= null && defaultYearItp!= null){
            component.set('v.dataAsOfMonthSecA',month[defaultMonthItp.replace(/^0+/,'')-1]);
            component.set('v.dataAsOfYearSecA',defaultYearItp);
        }
        else{
            component.set('v.dataAsOfMonthSecA',null);
            component.set('v.dataAsOfYearSecA',null);
        }
    
    }
})