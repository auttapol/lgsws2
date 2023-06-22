({
    chartJs: null,
    drawChart : function(component, event, helper) {
        var kpi = component.get('v.individual');
        var chartObj = component.get("v.chartObj"); 
        var chartID = component.get('v.chartID');
            var chartNeedleObj = component.get("v.chartNeedleObj"); 
        // if chartobj is not empty, then destory the chart in the view
        if(chartObj){
            chartObj.destroy();
        }
        if(kpi == null || kpi == undefined)
        {
            kpi = 0;
        }

        // kpi = 130; // ******* change this

        var dataList = [60,30,20,30,60];
        if(kpi > 200) {
          kpi = 200;
        } else if(kpi < 0) {
          kpi = 0;
        }
        var option1 = {
          type: 'doughnut',
          data: {
          // labels: [
          //     "KPIs < 70%",
          //     "KPIs 70%-90%",
          //     "KPIs 90%-100%",
          //     "KPIs > 100%",
          // ],
          datasets: [
            {   
                data: dataList,
                backgroundColor: [
                "#fe4e4e",
                "#e5c952",
                "#cefe9b",
                "#5fcdb2",
                "#379fff"
                ],
                borderColor: "White",
                borderWidth: 1,
                needleValue: kpi,
                cutout: '75%'
            }],
          },
          options: {
              responsive: false,
              rotation: -Math.PI,
              cutoutPercentage: 75,
              circumference: Math.PI,
              legend: {
              display: false
              },
              animation: {
              animateRotate: false,
              animateScale: true
              }
          },
      }
        // const data = {
        //     datasets: [
        //     {   
        //         data: dataList,
        //         backgroundColor: [
        //         "#fe4e4e",
        //         "#e5c952",
        //         "#cefe9b",
        //         "#5fcdb2",
        //         "#379fff"
        //         ],
        //         borderColor: "White",
        //         borderWidth: 1,
        //         needleValue: kpi,
        //         cutout: '75%'
        //     }],
        // };
        var el = component.find("chart").getElement();
        var ctx = el.getContext("2d");
        chartObj = new Chart(ctx, option1); 

        var el2 = component.find("chartNeedle").getElement();
        var ctx2 = el2.getContext("2d");
        ctx2.clearRect(0, 0, el2.width, el2.height);
        // chartNeedleObj = new Chart(ctx2, options2);
        var needleValue = chartObj.config.data.datasets[0].needleValue;
        var dataTotal = chartObj.config.data.datasets[0].data.reduce((a, b) => a + b, 0);
      //   var needleValue = kpi;
      //   var dataTotal = dataList.reduce((a, b) => a + b, 0)
        var angle = Math.PI + (1 / dataTotal * needleValue * Math.PI);
        // var ctx = chart.ctx;
        var cw = 250;
        var ch = 160;
        var cx = cw / 2;
        var cy = ch - 6;
        const needleSize = 6;
        const dotSize = 10;
        const offsetY = 12;
      
        ctx2.translate(cx, cy-offsetY);
        ctx2.rotate(angle);
        ctx2.beginPath();
      //   ctx.moveTo(0, 0);
        ctx2.moveTo(0, -needleSize);
      //   ctx.lineTo(40, 60);
        ctx2.lineTo(ch*0.57, 0);
        ctx2.lineTo(0, needleSize);
      //   ctx.moveTo(0, -40);
      //   ctx.lineTo(200, 0);
      // ctx.lineTo(40, 60);
  
        ctx2.fillStyle = 'rgb(0, 0, 0)';
        //   ctx.stroke();
        ctx2.fill();
        ctx2.rotate(-angle);
        ctx2.translate(-cx, -cy+offsetY);
        ctx2.beginPath();
        ctx2.arc(cx, cy-offsetY, dotSize, 0, Math.PI * 2);
        //   ctx.stroke();
        ctx2.fill();
  
        var el2 = component.find("chartLabel").getElement();
        var ctx3 = el2.getContext("2d");
        ctx3.clearRect(0, 0, el2.width, el2.height);

      this.chartFillText(ctx3,'60%',0.178*chartObj.width,0.18475*chartObj.height,-35);
      this.chartFillText(ctx3,'90%',0.4*chartObj.width,0.042*chartObj.height,-10);
      this.chartFillText(ctx3,'110%',0.61*chartObj.width,0.045*chartObj.height,10);
      this.chartFillText(ctx3,'140%',0.85*chartObj.width,0.215*chartObj.height,35);
      //store the chart in the attribute
      this.chartFillText2(ctx3,'I',20,'500',0.125*chartObj.width,0.55*chartObj.height,0);
      this.chartFillText2(ctx3,'M',20,'500',0.33*chartObj.width,0.25*chartObj.height,0);
      this.chartFillText2(ctx3,'G',20,'500',0.5*chartObj.width,0.20*chartObj.height,0);
      this.chartFillText2(ctx3,'V',20,'500',0.67*chartObj.width,0.25*chartObj.height,0);
      this.chartFillText2(ctx3,'E',20,'500',0.875*chartObj.width,0.55*chartObj.height,0);

      
      component.set("v.chartNeedleObj",chartNeedleObj);

        // const needle2 = {
        //     afterDraw: chart => {
        //       var needleValue = chart.config.data.datasets[0].needleValue;
        //       var dataTotal = chart.config.data.datasets[0].data.reduce((a, b) => a + b, 0);
        //       var angle = Math.PI + (1 / dataTotal * needleValue * Math.PI);
        //       var ctx = chart.ctx;
        //       var cw = chart.canvas.offsetWidth;
        //       var ch = chart.canvas.offsetHeight;
        //       var cx = cw / 2;
        //       var cy = ch - 6;
        //       const needleSize = 6;
        //       const dotSize = 10;
        //     const offsetY = 7;

        //       ctx.translate(cx, cy-offsetY);
        //       ctx.rotate(angle);
        //       ctx.beginPath();
        //       ctx.moveTo(0, -needleSize);
        //       ctx.lineTo(ch*0.57, 0);
        //       ctx.lineTo(0, needleSize);

        //       ctx.fillStyle = 'rgb(0, 0, 0)';
        //     //   ctx.stroke();
        //       ctx.fill();
        //       ctx.rotate(-angle);
        //       ctx.translate(-cx, -cy+offsetY);
        //       ctx.beginPath();
        //       ctx.arc(cx, cy-offsetY, dotSize, 0, Math.PI * 2);
        //     //   ctx.stroke();
        //       ctx.fill();

        //     // this.chartFillText(ctx,'60%',0.04*chart.width,0.36375*chart.height,-50);
        //     // this.chartFillText(ctx,'90%',0.32*chart.width,0.0645*chart.height,-15);
        //     // this.chartFillText(ctx,'110%',0.7*chart.width,0.07*chart.height,15);
        //     // this.chartFillText(ctx,'140%',0.97*chart.width,0.4*chart.height,50);
        //     this.chartFillText(ctx,'60%',0.178*chart.width,0.18475*chart.height,-35);
        //     this.chartFillText(ctx,'90%',0.4*chart.width,0.042*chart.height,-10);
        //     this.chartFillText(ctx,'110%',0.61*chart.width,0.045*chart.height,10);
        //     this.chartFillText(ctx,'140%',0.85*chart.width,0.215*chart.height,35);
        // }
        //   }

        // var labels = ['I','M','G','V','E'];

        // const config = {
        //     type: 'doughnut',
        //     data,
        //     options: {
        //         rotation: -90,
        //         cutoutPercentage: 70,
        //         circumference: 180,
        //         legend: {
        //         display: false
        //         },
        //         animation: {
        //         animateRotate: false,
        //         animateScale: true
        //         },
        //         responsive: false,
        //         plugins: {
        //             datalabels: {
        //               labels: {
        //               value: {
        //                   color: 'black',
        //                   font: {size: 20, weight: 500},
        //                 }
        //               },
        //               formatter: function(value, ctx) {
        //                 return labels[ctx.dataIndex]
        //               }
        //             }
        //           }
        //     },
        //     plugins: [ChartDataLabels,needle2]
        // };

        //     var ctx = document.getElementById(chartID).getContext('2d');
        //     var el = component.find("chart").getElement();
        //     var ctx = el.getContext("2d");
        //     chartObj = new this.chartJs(ctx, config);    
        //     // chartObj = new Chart(ctx, config);    

        component.set('v.chartObj',chartObj);
    },

    chartFillText : function(ctx,text,x,y,rotateDegree) {
        var font = 14;
        var lineHeight = 15; // this is guess and check as far as I know

        ctx.font = 'bold ' + font + 'px Arial';
        ctx.save();
        ctx.translate(x, y);
        ctx.rotate((rotateDegree/180)*Math.PI);
        ctx.textAlign = 'center';
        ctx.fillText(text, 0, lineHeight / 2);
        ctx.restore();
    },
    chartFillText2 : function(ctx,text,size,weight,x,y,rotateDegree) {
      // var x = 0;
      // var y = 70;
      var font = size ? size : 16;
      var lineHeight = 15; // this is guess and check as far as I know
      // var rotateDegree = -45;

      ctx.font = font + 'px Arial';
      if(weight) {
        ctx.font = weight + ' ' + font + 'px Arial';
      }
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate((rotateDegree/180)*Math.PI);
      ctx.textAlign = 'center';
      ctx.fillText(text, 0, lineHeight / 2);
      ctx.restore();
  },

    setChartClass : function() {
      this.chartJs = Chart;
      // console.log('Debug chart set variable P3',this.chartJs);
    },
})