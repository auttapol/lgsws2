import {
    LightningElement,
    track,
    // wire,
    api
} from 'lwc';
import {
    loadScript
} from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

const productSection = {
    "Investment": 'Investment',
    "BA": 'BA',
    "Deposit": 'Deposit',
    "CC & Personal Loan": 'CC_PersonalLoan',
    "Secured Loan": 'SecuredLoan',
    "Auto Loan": 'AutoLoan',
    "Other": 'Other',
};
export default class RetailCSVProductHoldingProductAccountAmount extends LightningElement {
    @track chartDataAccountAmount;
    @track chartDataProductAmount;
    @api productHolding;
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
        if (this.chart) {
            // this.chartDataAccountAmount = [this.productHolding['Investment'].NumberOfAccount.Total, this.productHolding['BA'].NumberOfAccount.Total, this.productHolding['Deposit'].NumberOfAccount.Total, this.productHolding['CC_PersonalLoan'].NumberOfAccount.Total, this.productHolding['SecuredLoan'].NumberOfAccount.Total, this.productHolding['Other'].NumberOfAccount.Total];
            // this.chartDataProductAmount = [this.productHolding['Investment'].NumberOfProduct, this.productHolding['BA'].NumberOfProduct, this.productHolding['Deposit'].NumberOfProduct, this.productHolding['CC_PersonalLoan'].NumberOfProduct, this.productHolding['SecuredLoan'].NumberOfProduct, this.productHolding['Other'].NumberOfProduct];
            this.chartDataAccountAmount = Object.keys(productSection).map(m => this.productHolding[productSection[m]].NumberOfAccount.Total)
            this.chartDataProductAmount = Object.keys(productSection).map(m => this.productHolding[productSection[m]].NumberOfProduct)
            this.chart.data.datasets[0].data = this.chartDataAccountAmount;
            this.chart.data.datasets[1].data = this.chartDataProductAmount;
            this.chart.update();
        }
    }
    
    @api calRenders(isCalRenders, productHolding){
        this.productHolding = productHolding;
        if (this.chart) {
            // this.chartDataAccountAmount = [this.productHolding['Investment'].NumberOfAccount.Total, this.productHolding['BA'].NumberOfAccount.Total, this.productHolding['Deposit'].NumberOfAccount.Total, this.productHolding['CC_PersonalLoan'].NumberOfAccount.Total, this.productHolding['SecuredLoan'].NumberOfAccount.Total, this.productHolding['Other'].NumberOfAccount.Total];
            // this.chartDataProductAmount = [this.productHolding['Investment'].NumberOfProduct, this.productHolding['BA'].NumberOfProduct, this.productHolding['Deposit'].NumberOfProduct, this.productHolding['CC_PersonalLoan'].NumberOfProduct, this.productHolding['SecuredLoan'].NumberOfProduct, this.productHolding['Other'].NumberOfProduct];
            this.chartDataAccountAmount = Object.keys(productSection).map(m => this.productHolding[productSection[m]].NumberOfAccount.Total)
            this.chartDataProductAmount = Object.keys(productSection).map(m => this.productHolding[productSection[m]].NumberOfProduct)
            this.chart.data.datasets[0].data = this.chartDataAccountAmount;
            this.chart.data.datasets[1].data = this.chartDataProductAmount;
            this.chart.update();
        }
    }

    drawChartJs() {
        const parent = this.template.querySelector('div.chart');
        const canvas = document.createElement('canvas');
        // canvas.style = 'height:300px;width:100%;'
        parent.appendChild(canvas);
        const ctx = canvas.getContext('2d');

        this.chart = new Chart(ctx, {
            type: 'horizontalBar',
            data: {
                labels: Object.keys(productSection),
                datasets: [{
                        label: 'Number of Account',
                        data: Object.keys(productSection).map(m => 0),
                        backgroundColor: 'rgba(255,128, 64, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Number of Product',
                        data: Object.keys(productSection).map(m => 0),
                        backgroundColor: 'rgba(45, 122, 237, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                "hover": {
                    "animationDuration": 0
                },
                "tooltips": {
                    enabled: false
                },
                "events": [],
                "animation": {
                    "duration": 1,
                    "onComplete": function () {
                        var chartInstance = this.chart,
                            ctx = chartInstance.ctx;

                        ctx.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        //ctx.textAlign = 'center';
                        //ctx.textBaseline = 'bottom';

                        this.data.datasets.forEach(function (dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function (bar, index) {
                                var data = dataset.data[index];
                                var value = data == 0 ? ' ' : data;
                                ctx.textAlign = "start";
                                ctx.font = "bold 12px Arial";
                                ctx.fillStyle = "#000000";
                                ctx.fillText(value, 130, bar._model.y + 1);
                            });
                        });
                    }
                },
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    position: 'bottom',
                    display: true,
                    labels: {
                        boxWidth: 10,
                    }
                },
                scales: {
                    xAxes: [{
                        ticks: {
                            beginAtZero: true,
                            // max: this.max,
                            display: false
                        },
                        gridLines: {
                            drawBorder: false,
                            display: false
                        }
                    }],
                    yAxes: [{
                        ticks: {
                            beginAtZero: true,
                            suggestedMin: 50
                        },
                        gridLines: {
                            display: false
                        }
                    }]
                }
            },
        });
        this.chart.canvas.parentNode.style.height = '100%';
        this.chart.canvas.parentNode.style.width = '100%';
    }
}