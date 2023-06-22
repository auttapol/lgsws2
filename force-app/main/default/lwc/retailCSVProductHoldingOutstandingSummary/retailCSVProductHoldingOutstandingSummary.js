import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

export default class RetailCSVProductHoldingOutstandingSummary extends LightningElement {
    @track chartDataOutstandingSummary;
    @track chartDataDisplay;
    @api productHolding;
    @api isCalRenders;
    chart;
    @track maxValue;

    constructor() {
        super();

        Promise.all([
            loadScript(this, chartjs)
        ]).then(() => {

            this.drawChartJs();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading ChartJS',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    connectedCallback() {}

    renderedCallback() {
        if (this.isCalRenders) {
            
            let fa = this.productHolding['Deposit'].flagMin;
            // console.log('fa :' +fa);
            let depositData = this.productHolding['Deposit'].TotalOutstanding && this.productHolding['Deposit'].TotalOutstanding >= 0 ? this.productHolding['Deposit'].TotalOutstanding : 0;
            let investmentData = this.productHolding['Investment'].TotalAvailable && this.productHolding['Investment'].TotalOutstanding >= 0 ? this.productHolding['Investment'].TotalAvailable : 0;
            let baDAta = this.productHolding['BA'].TotalAvailable && this.productHolding['BA'].TotalOutstanding >= 0 ? this.productHolding['BA'].TotalAvailable : 0;
            let cc_personalLoanData = this.productHolding['CC_PersonalLoan'].TotalOutstanding && this.productHolding['CC_PersonalLoan'].TotalOutstanding >= 0 ? this.productHolding['CC_PersonalLoan'].TotalOutstanding : 0;
            let SecuredLoanData = this.productHolding['SecuredLoan'].TotalOutstanding && this.productHolding['SecuredLoan'].TotalOutstanding >= 0 ? this.productHolding['SecuredLoan'].TotalOutstanding : 0;
            let AutoLoanData = this.productHolding['AutoLoan'].TotalOutstanding && this.productHolding['AutoLoan'].TotalOutstanding >= 0 ? this.productHolding['AutoLoan'].TotalOutstanding : 0;
            let OtherData = this.sumOther();
            this.chartDataOutstandingSummary = [
                investmentData,
                baDAta,
                depositData,
                cc_personalLoanData,
                SecuredLoanData,
                AutoLoanData,
                OtherData
            ];
            this.chartDataDisplay = [...this.chartDataOutstandingSummary];
            this.maxValue = Math.max(depositData, investmentData, baDAta, cc_personalLoanData, SecuredLoanData, AutoLoanData, OtherData);
            this.chart.data.datasets[0].data = this.chartDataDisplay;
            // fa = false;
            if(fa){
                this.chart.data.datasets[0].backgroundColor[2] = 'rgb(220,20,60,1)';
                // this.chart.data.datasets[0].backgroundColor[2] = 'rgb(220,20,60,1)';

            }
            else{
                this.chart.data.datasets[0].backgroundColor[2] = 'rgba(0, 32, 64, 1)';

            }
            this.chart.update();
            // console.log('this.isChartInit :' +this.isChartInit);
            
            // atk comment
            // if (!this.isChartInit) {
                // Promise.all([
                //     loadScript(this, chartjs)
                // ]).then(() => {
        
                //     this.drawChartJs();
                // }).catch(error => {
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //             title: 'Error loading ChartJS',
                //             message: error.message,
                //             variant: 'error',
                //         }),
                //     );
                // });
            // }
        }
    }

    @api calRenders(isCalRenders, productHolding){
        if (isCalRenders) {
            this.productHolding = productHolding;
            let fa = this.productHolding['Deposit'].flagMin;
            // console.log('fa :' +fa);
            let depositData = this.productHolding['Deposit'].TotalOutstanding && this.productHolding['Deposit'].TotalOutstanding >= 0 ? this.productHolding['Deposit'].TotalOutstanding : 0;
            let investmentData = this.productHolding['Investment'].TotalAvailable && this.productHolding['Investment'].TotalOutstanding >= 0 ? this.productHolding['Investment'].TotalAvailable : 0;
            let baDAta = this.productHolding['BA'].TotalAvailable && this.productHolding['BA'].TotalOutstanding >= 0 ? this.productHolding['BA'].TotalAvailable : 0;
            let cc_personalLoanData = this.productHolding['CC_PersonalLoan'].TotalOutstanding && this.productHolding['CC_PersonalLoan'].TotalOutstanding >= 0 ? this.productHolding['CC_PersonalLoan'].TotalOutstanding : 0;
            let SecuredLoanData = this.productHolding['SecuredLoan'].TotalOutstanding && this.productHolding['SecuredLoan'].TotalOutstanding >= 0 ? this.productHolding['SecuredLoan'].TotalOutstanding : 0;
            let AutoLoanData = this.productHolding['AutoLoan'].TotalOutstanding && this.productHolding['AutoLoan'].TotalOutstanding >= 0 ? this.productHolding['AutoLoan'].TotalOutstanding : 0;
            let OtherData = this.sumOther();
            this.chartDataOutstandingSummary = [
                investmentData,
                baDAta,
                depositData,
                cc_personalLoanData,
                SecuredLoanData,
                AutoLoanData,
                OtherData
            ];
            this.chartDataDisplay = [...this.chartDataOutstandingSummary];
            this.maxValue = Math.max(depositData, investmentData, baDAta, cc_personalLoanData, SecuredLoanData, AutoLoanData, OtherData);
            this.chart.data.datasets[0].data = this.chartDataDisplay;
            // fa = false;
            if(fa){
                this.chart.data.datasets[0].backgroundColor[2] = 'rgb(220,20,60,1)';
                // this.chart.data.datasets[0].backgroundColor[2] = 'rgb(220,20,60,1)';

            }
            else{
                this.chart.data.datasets[0].backgroundColor[2] = 'rgba(0, 32, 64, 1)';

            }
            this.chart.update();
            // console.log('this.isChartInit :' +this.isChartInit);
            
            // atk comment
            // if (!this.isChartInit) {
                // Promise.all([
                //     loadScript(this, chartjs)
                // ]).then(() => {
        
                //     this.drawChartJs();
                // }).catch(error => {
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //             title: 'Error loading ChartJS',
                //             message: error.message,
                //             variant: 'error',
                //         }),
                //     );
                // });
            // }
        }
    }

    sumOther() {
        var Other = 0;
        try {
            Other += this.productHolding['Deposit'].Other.TotalOutstanding
            Other += this.productHolding['Investment'].Other.TotalAvailable 
            Other += this.productHolding['BA'].Other.TotalAvailable
            Other += this.productHolding['CC_PersonalLoan'].Other.TotalOutstanding
            Other += this.productHolding['SecuredLoan'].Other.TotalOutstanding
            Other += this.productHolding['AutoLoan'].Other.TotalOutstanding
            Other = Other >= 0 ? Other : 0;
        } catch (error) {
            // console.log('error SUMOther error', error);  
            Other = Other && Other >= 0 ? Other : 0;
        }
        return Other;
    }
    async drawChartJs() {
        // drawChartJs() {
        const parent = this.template.querySelector('div.chart');
        const canvas = document.createElement('canvas');
        // canvas.style = 'height:110%;width:100%;'
        parent.appendChild(canvas);
        // canvas.replaceWith
        const ctx = canvas.getContext('2d');
        ctx.restore();
        // let chartDataOutstandingSummary = this.chartDataOutstandingSummary;
        this.chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: ["Investment", "BA", "Deposit", "CC & Personal Loan", "Secured Loan", "Auto Loan", "Others"],
                datasets: [{
                    label: '# Outstanding/Premium',
                    data: [0, 0, 0, 0 , 0, 0],
                    // backgroundColor: 'rgba(0, 32, 64, 1)',
                    // backgroundColor:[ 'rgba(201, 19, 73, 1)' , 'rgba(201, 19, 73, 1)'  , 'rgba(201, 19, 73, 1)', 'rgba(201, 19, 73, 1)', 'rgba(201, 19, 73, 1)', 'rgba(201, 19, 73, 1)'] 
                    backgroundColor:[ 'rgba(0, 32, 64, 1)' , 'rgba(0, 32, 64, 1)'  , 'rgba(0, 32, 64, 1)', 'rgba(0, 32, 64, 1)', 'rgba(0, 32, 64, 1)', 'rgba(0, 32, 64, 1)' , 'rgba(0, 32, 64, 1)'] 

                    // backgroundColor: 'rgba(100, 255, 255, 1)'

                }],
            },
            options: {
                "hover": {
                    "animationDuration": 0
                },
                "events": [],
                "tooltips": {
                    enabled: false
                },
                "animation": {
                    "duration": 1,
                    "onComplete": function () {
                        var chartInstance = this.chart,
                        ctx = chartInstance.ctx;

                        ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
                        // console.log(chartDataOutstandingSummary);
                        this.data.datasets.forEach(function (dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function (bar, index) {
                                var value = dataset.data[index];
                                // console.log('start forEach');
                                if(value > 1000) {
                                    // console.log(value,value/1000);
                                    value = parseFloat(Number(value/1000).toFixed(1)).toLocaleString() + 'K';
                                } else if(value > 0 ) {

                                } else {
                                    value = ' ';
                                }
                                // console.log(bar._model.x, bar._model.y);
                                // ctx.refresh();
                                ctx.fillStyle = "#000000";

                                // console.log('dataset :',  );
                                if(dataset.backgroundColor[index] == 'rgb(220,20,60,1)'){
                                    ctx.fillStyle = "#FF0000";
                                }

                                ctx.font = "bold 11px Arial";
                                ctx.fillText(value, bar._model.x, bar._model.y);
                                // console.log('index :', index);
                                // console.log('dataset :', dataset.backgroundColor[index] );
                                // console.log('dataset.data[index] :'  +dataset.data[index]);
                                // if(index == 2 && parseFloat(dataset.data[index]) > 1000){
                                //     console.log('og');
                                //     dataset.backgroundColor[index] = 'rgba(100, 255, 255, 1)';
                                //     // var value = dataset.data[index];
                                //     // var checkja = false;
                                //     // var colurDef= 'rgba(201, 19, 73, 1)';
                                //     // if(parseFloat(value) > 1000) {
                                //     //     dataset.backgroundColor[index] = 'rgba(100, 255, 255, 1)';
                                //     //     checkja = true;
                                //     // }
                                //     // else{

                                //     // }
                                //     // console.log('value L:' +  value);
                                //     // console.log('checkja :'+ checkja);
                                //     // // if(checkja == true){
                                //     // //     // dataset.backgroundColor[index] = 'rgba(100, 255, 255, 1)';
                                //     // //     colurDef = 'rgba(100, 255, 255, 1)';
                                //     // // }
                                //     // // console.log('colurDef :' + colurDef);
                                //     // // dataset.backgroundColor[index] =  String(colurDef);
                                //     // // dataset.backgroundColor[index] = 'rgba(100, 255, 255, 1)';
                                //     // // if(value > 1000) {
                                //     // //     console.log('value 1000');
                                //     //     // dataset.backgroundColor[index] = 'rgba(100, 255, 255, 1)';
                                //     // // }
                                //     // console.log('value L222:' +  value);

                                //     // console.log('dataset :', dataset.backgroundColor[index] );

                                // }
                                // console.log('dataset after:', dataset.backgroundColor[index] );

                                // ctx. = 'rgba(255, 255, 0, 0)';
                                // ctx.fillStyle('rgba(100, 255, 255, 1)', bar._model.x, bar._model.y);
                                // dataset.backgroundColor = 'rgba(100, 255, 255, 1)';
                                // ctx.style.background = 'rgba(100, 255, 255, 1)';
                                // ctx.data.backgroundColor ='rgba(100, 255, 255, 1)';
                            });
                        });
                        // console.log('restroe');
                        this.chart.update();
                        this.chart.render();
                        // console.log('restore end');


                        // this.drawChartJs();
                    }
                },
                responsive: true,
                // maintainAspectRatio: false,
                legend: {
                    position: 'top',  //test
                    display: true,
                    labels: {
                        boxWidth: 10,
                    }
                },
                scales: {
                    xAxes: [{
                        scaleLabel: {
                            position: 'right',
                            display: true,
                            labelString: 'Product Group',
                        },
                        ticks: {
                            beginAtZero: true,
                            display: true,
                        },
                        gridLines: {

                            display: false
                        },
                    }],
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            // max: this.maxValue*1.2,
                            display: false
                        },
                        scaleLabel: {
                            display: true,
                            labelString: 'Amt.'
                        },
                        gridLines: {

                            display: false
                        }
                    }]
                }
            }
        });
        this.chart.canvas.parentNode.style.height = '90%';
        this.chart.canvas.parentNode.style.width = '100%';
        this.isChartInit = true;
    }

}