import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
// import chartjs from '@salesforce/resourceUrl/ChartJS371';
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
            // let depositData = 10901000;
            // let investmentData = 35089000;
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
            // this.chartDataTotalSummary = [Assets, Liabilities];
            // this.chartDataDisplay = [...this.chartDataTotalSummary];
            // if(this.chartDataTotalSummary[1] < 0){
            //     this.chartDataDisplay[1] = 0;
            // }
            // this.chartDataDisplay[0].label = 'TTT';
            // console.log('grap data: '+this.chartDataDisplay);
            console.log('graph Assets dep: ' + JSON.stringify(depositData));
            console.log('graph Assets inv: ' + JSON.stringify(investmentData));
            console.log('graph Assets ba: ' + JSON.stringify(baData));

            console.log('graph liability personal loan: ' + JSON.stringify(cc_personalLoanData));
            console.log('graph liability secure loan: ' + JSON.stringify(securedLoanData));
            console.log('graph liability auto loan: ' + JSON.stringify(AutoLoanData));
            var chartData = [{
                label: 'Investment',
                data: [investmentData, 0],
                backgroundColor: "#854605",
                stack: 0,
                pointStyle: "rectRot"
            },
            {
                label: 'BA',
                data: [baData, 0],
                backgroundColor: "#F68B1F",
                stack: 0,
                pointStyle: "rectRot"
            },
            {
                label: 'Deposit',
                data: [depositData, 0],
                backgroundColor: "#FBD1A5",
                stack: 0,
                pointStyle: "rectRot"
            },
            {
                label: 'Personal Loan',
                data: [0, cc_personalLoanData],
                backgroundColor: "#002D63",
                stack: 0,
                pointStyle: "rectRot"
            },
            {
                label: 'Secure Loan',
                data: [0, securedLoanData],
                backgroundColor: "#0050F0",
                stack: 0,
                pointStyle: "rectRot"
            },
            {
                label: 'Auto Loan',
                data: [0, AutoLoanData],
                backgroundColor: "#93B7FF",
                stack: 0,
                pointStyle: "rectRot"
            },
            ];

            this.chart.data.datasets = chartData;
            // this.chart.data.datasets[1].data = this.chartDataDisplay;
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
                // labels: ["Assets"],
                datasets: [
                    {
                        data: [0, 0]
                    }
                ],

            },
            options: {
                plugins: {
                    datalabels: {
                        formatter: function (context) {
                            return context / 1000 + "k";
                        },
                        font: {
                            color: "black"
                        }
                    }
                },
                "hover": {
                    "animationDuration": 0
                },
                "events": [],
                "tooltips": {
                    // enabled: true,
                    backgroundColor: '#FFF',
                    titleFontSize: 16,
                    titleFontColor: '#0066ff',
                    bodyFontColor: '#000',
                    bodyFontSize: 14,
                    displayColors: false
                },
                "animation": {
                    // "duration": 1,
                    "onComplete": function () {
                        var chartInstance = this.chart,
                            ctx = chartInstance.ctx;

                        ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        // ctx.font = Chart.helpers.fontString(12, 'normal', "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif");
                        // ctx.textAlign = 'center';
                        // ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function (dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function (bar, index) {
                                var value = dataset.data[index];
                                // console.log('graph data: ' + index + ' ' + data);
                                // if (data == 0) {
                                //     var value = ' ';
                                // } else {
                                //     var value = data.toLocaleString();
                                // }
                                if (value > 1000) {
                                    // console.log(value,value/1000);
                                    value = parseFloat(Number(value / 1000).toFixed(1)).toLocaleString() + 'K';
                                } else if (value > 0) {

                                } else {
                                    value = ' ';
                                }
                                // ctx.textAlign = "start";
                                ctx.font = "bold 12px Arial";

                                var barWidth = bar._model.x - bar._model.base;
                                var centerX = bar._model.base + barWidth / 2;
                                ctx.fillStyle = "#000000";
                                ctx.fillText(value, centerX, bar._model.y + 4);
                                // ctx.fillText(value, 70, bar._model.y + 8);

                            });
                        });
                    }
                },
                responsive: true,
                showTooltips: true,

                maintainAspectRatio: false,
                legend: {
                    display: true,
                    align: 'start',
                    labels: {
                        usePointStyle: true
                    }
                },
                // indexAxis: 'y',
                scales: {
                    xAxes: [{
                        ticks: {
                            // min: 0, //minimum tick
                            // max: 100000, //maximum tick
                            callback: function (value, index, values) {
                                return value / 1000 + "k";
                                //return Number(value.toString()); //pass tick values as a string into Number function
                            }
                        },
                        // ticks: {
                        //     beginAtZero: false,
                        //     // max: 100,
                        //     display: false
                        // },
                        // gridLines: { 
                        //     drawBorder: true,
                        //     display: true 
                        // },
                        stacked: true
                    }],
                    yAxes: [{
                        barThickness: 50,
                        // ticks: {
                        //     beginAtZero: false,
                        // },
                        // gridLines: { 
                        //     drawBorder: true,
                        //     display: true 
                        // },
                        stacked: true
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