import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RetailCSVProductHoldingTotalSummary extends LightningElement {
    @track chartDataTotalSummary;
    @api productHolding;
    @track chartDataDisplay;
    @api isCalRenders;

    chart;

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

    connectedCallback() {

    }

    renderedCallback() {
        if (this.chart && this.isCalRenders) {
            // console.log('Outstanding');
            var Assets = 0; // (Deposit + Investment + BA) 
            var Liabilities = 0; // (CC & Personal Loan + Secured Loan)
            let depositData = Number(this.productHolding['Deposit'].TotalOutstanding && this.productHolding['Deposit'].TotalOutstanding > 0 ? this.productHolding['Deposit'].TotalOutstanding : 0);
            let investmentData = Number(this.productHolding['Investment'].TotalAvailable ? this.productHolding['Investment'].TotalAvailable : 0);
            let baData = Number(this.productHolding['BA'].TotalAvailable ? this.productHolding['BA'].TotalAvailable : 0);
            Assets = this.calculateSum(Assets, depositData);
            Assets = this.calculateSum(Assets, investmentData);
            Assets = this.calculateSum(Assets, baData);
            // console.log('Total Assets', depositData, investmentData, baData, depositData+investmentData+baData);
            let cc_personalLoanData = Number(this.productHolding['CC_PersonalLoan'].TotalOutstanding ? this.productHolding['CC_PersonalLoan'].TotalOutstanding : 0); 
            let securedLoanData = Number(this.productHolding['SecuredLoan'].TotalOutstanding ? this.productHolding['SecuredLoan'].TotalOutstanding : 0);
            let AutoLoanData = Number(this.productHolding['AutoLoan'].TotalOutstanding ? this.productHolding['AutoLoan'].TotalOutstanding : 0);
            Liabilities = this.calculateSum(Liabilities, cc_personalLoanData);
            Liabilities = this.calculateSum(Liabilities, securedLoanData);
            Liabilities = this.calculateSum(Liabilities, AutoLoanData);
            // console.log('Assets |', Assets, 'Liabilities |', Liabilities);
            this.chartDataTotalSummary = [Assets, Liabilities];
            this.chartDataDisplay = [...this.chartDataTotalSummary];
            if(this.chartDataTotalSummary[1] < 0){
                this.chartDataDisplay[1] = 0;
            }
            this.chart.data.datasets[0].data = this.chartDataDisplay;
            // console.log('update TotalSum with Data: ', this.chartDataDisplay[0]);
            this.chart.update();
        }
    }

    @api calRenders(isCalRenders, productHolding){
        if (this.chart && isCalRenders) {
            // console.log('Outstanding');
            var Assets = 0; // (Deposit + Investment + BA) 
            var Liabilities = 0; // (CC & Personal Loan + Secured Loan)
            let depositData = Number(productHolding['Deposit'].TotalOutstanding && productHolding['Deposit'].TotalOutstanding > 0 ? productHolding['Deposit'].TotalOutstanding : 0);
            let investmentData = Number(productHolding['Investment'].TotalAvailable ? productHolding['Investment'].TotalAvailable : 0);
            let baData = Number(productHolding['BA'].TotalAvailable ? productHolding['BA'].TotalAvailable : 0);
            Assets = this.calculateSum(Assets, depositData);
            Assets = this.calculateSum(Assets, investmentData);
            Assets = this.calculateSum(Assets, baData);
            // console.log('Total Assets', depositData, investmentData, baData, depositData+investmentData+baData);
            let cc_personalLoanData = Number(productHolding['CC_PersonalLoan'].TotalOutstanding ? productHolding['CC_PersonalLoan'].TotalOutstanding : 0); 
            let securedLoanData = Number(productHolding['SecuredLoan'].TotalOutstanding ? productHolding['SecuredLoan'].TotalOutstanding : 0);
            let AutoLoanData = Number(productHolding['AutoLoan'].TotalOutstanding ? productHolding['AutoLoan'].TotalOutstanding : 0);
            Liabilities = this.calculateSum(Liabilities, cc_personalLoanData);
            Liabilities = this.calculateSum(Liabilities, securedLoanData);
            Liabilities = this.calculateSum(Liabilities, AutoLoanData);
            // console.log('Assets |', Assets, 'Liabilities |', Liabilities);
            this.chartDataTotalSummary = [Assets, Liabilities];
            this.chartDataDisplay = [...this.chartDataTotalSummary];
            if(this.chartDataTotalSummary[1] < 0){
                this.chartDataDisplay[1] = 0;
            }
            this.chart.data.datasets[0].data = this.chartDataDisplay;
            // console.log('update TotalSum with Data: ', this.chartDataDisplay[0]);
            this.chart.update();
        }
    }

    async drawChartJs() {
        const parent = this.template.querySelector('div.chart');
        const canvas = document.createElement('canvas');
        parent.appendChild(canvas);
        const ctx = canvas.getContext('2d');
        this.chart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: ["Assets", "Liabilities"],
                datasets: [{
                    data: [0, 0],
                    backgroundColor: [
                    'rgba(0, 255, 0, 1)',
                    'rgba(255,128, 64, 1)'
                    ],
                }]
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
                    "onComplete": function() {
                        var chartInstance = this.chart,
                        ctx = chartInstance.ctx;
        
                        ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'bottom';
                        this.data.datasets.forEach(function(dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function(bar, index) {
                                var data = dataset.data[index];
                                if(data == 0){
                                    var value = ' ';
                                }
                                // else if (data > 1000){
                                //     var value = parseInt(Number(data/1000).toFixed(0)).toLocaleString();
                                //     value += ' k';
                                // }
                                    else {
                                    var value = data.toLocaleString();
                                }
                                ctx.textAlign = "start";
                                ctx.font = "bold 12px Arial";
                                ctx.fillText(value, 70, bar._model.y + 8);
                            });
                        });
                    }
                },
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    display: false,
                },
                scales: {
                    xAxes: [{
                        ticks: {
                            beginAtZero: true,
                            // max: 100,
                            display: false
                        },
                        gridLines: { 
                            drawBorder: false,
                            display: false 
                        }
                    }],
                    yAxes: [{
                        barThickness: 20,
                        ticks: {
                            beginAtZero: true,
                        },
                        gridLines: { 
                            drawBorder: false,
                            display: false 
                        }
                    }]
                }
            }
        })
        this.chart.canvas.parentNode.style.height = '100%';
        this.chart.canvas.parentNode.style.width = '100%';
    }


    calculateSum(total, ...arg) {
        return this.toFixedTwoDigits(arg.reduce((l, i) => l + (i ? i : 0), total));
    }

    toFixedTwoDigits(num) {
        return Number(num.toFixed(2));
    }
}