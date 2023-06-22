({
    parseObj: function (objFields) {
      return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
    
    helperMethod : function() {

    },
    
    createGraph : function(component,helper,TotalNI,TotalOriTarget,TotalProbHigh,TotalProbMed){
        
        var TotalNIArray = [];
        var TotalOriTargetArray = [];
        var thisMonth = (new Date()).getMonth();
        var TotalProbHighArray = [];
        var TotalProbMedArray = [];
        var iStr;
        var TotalNIAmout = 0 ;
        var TotalProbHighAmout = 0 ;
        var TotalProbMedAmout = 0 ;
        for (var i = 1; i <= 12; i++) {
            iStr = i < 10 ? '0' + i.toString() : i.toString();
            TotalNIAmout += TotalNI['NI_'+ iStr +'__c'];
            TotalProbHighAmout += thisMonth < i ? TotalProbHigh['NI_'+ iStr +'__c'] : 0;
            TotalProbMedAmout += thisMonth < i ? TotalProbMed['NI_'+ iStr +'__c'] : 0;
            TotalNIArray.push((TotalNIAmout));
            TotalProbHighArray.push(TotalProbHighAmout);
            TotalProbMedArray.push(TotalProbMedAmout);
            TotalOriTargetArray.push(TotalOriTarget * i / 12 );
        }
        var el = component.find('myChart').getElement();
        // var ctx = el.getContext('2d');

         new Chart(el, {
            type: 'bar',
            data: {
                datasets: [{
                    label: 'Accummulate NI-RR',
                    data: TotalNIArray,
                    backgroundColor: "rgb(173,216,230)",
                    borderColor: "rgb(173,216,230)",
                    // this dataset is drawn below
                    order: 2
                }, 
                {
                    label: 'Prob-High',
                    data: TotalProbHighArray,
                    backgroundColor: "rgb(173,255,47)",
                    borderColor: "rgb(173,255,47)",
                    // this dataset is drawn below
                    order: 3
                }, 
                {
                    label: 'Prob-Medium',
                    data: TotalProbMedArray,
                    backgroundColor: "rgb(255,255,102)",
                    borderColor: "rgb(255,255,102)",
                    // this dataset is drawn below
                    order: 4
                }, 
                {
                    label: 'Accummulate Target',
                    data: TotalOriTargetArray,
                    type: 'line',
                    backgroundColor: "rgba(0,0,0,0)",
                    borderColor: "rgb(213,0,0)",
                    // this dataset is drawn on top
                    order: 1
                }],
                labels: ['Jan' + helper.isActual(1), 'Feb' + helper.isActual(2), 'Mar'+ helper.isActual(3), 'Apr'+ helper.isActual(4), 'May'+ helper.isActual(5), 'Jun'+ helper.isActual(6), 'Jul'+ helper.isActual(7), 'Aug'+ helper.isActual(8), 'Sep'+ helper.isActual(9), 'Oct'+ helper.isActual(10), 'Nov'+ helper.isActual(11), 'Dec'+ helper.isActual(12)]
            },
            options: {
                responsive: false,
                legend: {
                   position: 'top' // place legend on the right side of chart
                },
                scales: {
                   xAxes: [{
                      stacked: true // this should be set to make the bars stacked
                   }],
                   yAxes: [{
                      stacked: true // this also..
                   }]
                },
                tooltips: {
                    callbacks: {
                        label: function(tooltipItem, data) {
                            return tooltipItem.yLabel.toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
                        }
                    }
                }
              
             }
        });
        
      component.set('v.isLoading',false);
    },

	numberWithCommas : function (x) {
		var parts = x.toString().split(".");
		parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		return parts.join(".");
	},
    isActual: function (x) {
        var today = new Date();
        if (today.getMonth() + 1 > x) {
            return ' (A)';
        }else{
            return ' (E)';
        }
    }
})