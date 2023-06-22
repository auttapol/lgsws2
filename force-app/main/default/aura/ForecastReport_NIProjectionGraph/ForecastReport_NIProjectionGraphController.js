({
    setData:function(component, event, helper) {
      component.set('v.isLoading',true);
      var Cube1Data = [];
      var Cube2Data = [];
      var targetList = [];
      var NewDealData = [];
      var allData = component.get('v.allData');
      allData.forEach(regionData => {
        Cube2Data = regionData.regionData.allFee ? Cube2Data.concat(regionData.regionData.allFee): regionData.regionData.allFee;
        Cube1Data = regionData.regionData.cube1 ? Cube1Data.concat(regionData.regionData.cube1): regionData.regionData.cube1;
        NewDealData = regionData.regionData.newDeal ? NewDealData.concat(regionData.regionData.newDeal): regionData.regionData.newDeal;
        targetList = regionData.regionData.target ? targetList.concat(regionData.regionData.target): regionData.regionData.target;
      });
      
        var TotalNI = {};
        var feeType = [
            'TF Fee',
            'FX Fee',
            'Credit Fee',
            'Derivative Fee',
            'IB Fee',
            'CM Fee',
            'EDC Fee',
            'L/G Fee',
            'Fleet Fee',
            'BA Fee',
            'AS Fee',
            'MF Fee',
            'AL Fee',
            'Supply Chain',
            'Front End Fee',
            'Other CM Fee',
            'Direct CM Fee',
            'NIIc',
            'NIId'
        ];
        var TotalOriTarget = 0;
        var TotalProbHigh = {
            NI_01__c : 0,
            NI_02__c :0,
            NI_03__c :0,
            NI_04__c :0,
            NI_05__c :0,
            NI_06__c :0,
            NI_07__c :0,
            NI_08__c :0,
            NI_09__c :0,
            NI_10__c :0,
            NI_11__c :0,
            NI_12__c :0,
        };
        var TotalProbMed = {
            NI_01__c : 0,
            NI_02__c :0,
            NI_03__c :0,
            NI_04__c :0,
            NI_05__c :0,
            NI_06__c :0,
            NI_07__c :0,
            NI_08__c :0,
            NI_09__c :0,
            NI_10__c :0,
            NI_11__c :0,
            NI_12__c :0,};
        var iStr;
        Cube1Data.forEach(cube1 => {
            for(var i = 1 ; i <= 12 ; i++){
                iStr = i < 10 ? '0' + i.toString() : i.toString();
                TotalNI['NI_'+iStr+'__c'] != null ? TotalNI['NI_'+iStr+'__c'] += cube1['NI_'+iStr+'__c'] : TotalNI['NI_'+iStr+'__c'] = cube1['NI_'+iStr+'__c'];
            }
        });
        Cube2Data.forEach(cube2 => {
            for(var i = 1 ; i <= 12 ; i++){
                iStr = i < 10 ? '0' + i.toString() : i.toString();
                TotalNI['NI_'+iStr+'__c'] != null ? TotalNI['NI_'+iStr+'__c'] += cube2['NI_'+iStr+'__c'] : TotalNI['NI_'+iStr+'__c'] = cube2['NI_'+iStr+'__c'];
            }
            
        });
        targetList.forEach(target => {
            TotalOriTarget += target.NI_Target_Monthly__c ? target.NI_Target_Monthly__c : 0;
        });

        NewDealData.forEach(newDeal => {
            if(feeType.includes(newDeal.Income_Type__c)){
                if(newDeal.Probability__c == 'High'){
                    TotalProbHigh['NI_'+ newDeal.Month__c + '__c'] += newDeal.NI_Formula__c;
                }else if (newDeal.Probability__c == 'Medium') {
                    TotalProbMed['NI_'+ newDeal.Month__c + '__c'] += newDeal.NI_Formula__c;
                }
            }
        });

        helper.createGraph(component,helper,TotalNI,TotalOriTarget,TotalProbHigh,TotalProbMed);
    },
    closeModel  : function(component, event, helper) {
      component.set("v.isModalOpen", false);
    },

    ctr : function(component, event, helper){
    },

    
    
})