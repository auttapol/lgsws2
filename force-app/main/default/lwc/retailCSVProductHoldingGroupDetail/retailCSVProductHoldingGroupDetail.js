import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/ChartJs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RetailCSVProductHoldingGroupDetail extends LightningElement {
    @track isChartJsInitialized = false;
    @track selectedTab;
    chart;
    chart2;

    @api productSubGroup;
    @api remark;
    @api chartData;
    @api isCalRenders;
    @api currProduct = '';

    // chartData = {
    //     Active: 2,
    //     Inactive: 1,
    //     Outstanding: 85700,
    //     Available: 87452
    // }
    constructor() {
        super();

        Promise.all([
            loadScript(this, chartjs)
        ]).then(() => {
            // console.log(this.currProduct);
            this.drawChartAccount();
            this.drawChartOustanding_Available();
            this.updateChart();
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading ChartJS',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });

        // Promise.all([
        //     loadScript(this, chartjs)
        // ]).then(() => {

        //     // this.drawChartAccount();
        //     this.drawChartOustanding_Available();
        // }).catch(error => {
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Error loading ChartJS',
        //             message: error.message,
        //             variant: 'error',
        //         }),
        //     );
        // });
    }


    renderedCallback() {
        // console.log(this.productSubGroup)
        if (this.chart && this.chart2 && this.isCalRenders && this.chartData) {
            this.updateChart();
        }
    }   

    updateChart() {
        this.chart.data.datasets[0].data = [this.chartData.Active];
        this.chart.data.datasets[1].data = [this.chartData.Inactive];
        this.chart2.data.datasets[0].data = [this.chartData.Outstanding, this.chartData.Available];
        this.chart.update();
        // console.log(this.chartData.Active, this.chartData.Inactive);
        this.chart2.update();
        // console.log(this.chartData.Outstanding, this.chartData.Available);
    }

    async drawChartAccount() {
        const parent = this.template.querySelector('div.chart');
        const canvas = document.createElement('canvas');
        // canvas.style = 'height:110%;width:100%;'
        parent.appendChild(canvas);
        const ctx1 = canvas.getContext('2d');
        this.chart = new Chart(ctx1, {
            type: 'horizontalBar',
            data: {
                labels: ["#Account (Active/Inactive)"],
                datasets: [{                      
                    data: [0],
                    backgroundColor: 'rgba(170, 202, 112, 1)',
                    stack: 1
                },
                {                   
                    data: [0],
                    backgroundColor: 'rgb(219,219,219,1)',  
                    stack: 1  
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
                    "onComplete": function() {                          
                        var chartInstance = this.chart,
                        ctx1 = chartInstance.ctx;
        
                        // console.log('Chart1', this.chart);
                        ctx1.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx1.textAlign = 'center';
                        ctx1.textBaseline = 'bottom';
                        // console.log(this.data.datasets);   
                        var dataset = this.data.datasets;   
                        var bar = chartInstance.controller.getDatasetMeta(0);
                        // console.log(bar.data[0]);
                        var data1 = '0';
                        var data2 = '0';
                        try {
                            if (dataset[0].data[0] || dataset[1].data[0]) {
                                if(dataset[0].data[0] > 0 || dataset[1].data[0] > 0) {
                                    data1 = dataset[0].data[0];
                                    data2 = dataset[1].data[0];
                                    // console.log('Data Group :', data1, data2);
                                }
                            }
                        } catch (error) {
                            console.log('fillText Active/Inactive error', error);
                        }
                        ctx1.textAlign = "start";
                        ctx1.font = "bold 12px Arial";
                        ctx1.fillText("("+data1+"/"+data2+")", 160, bar.data[0]._model.y + 7);  
                        
                    }
                },
                responsive: true,
                maintainAspectRatio: false,
                legend: {
                    display: false,
                },
                scales: {
                    xAxes: [{
                        stacked: true,
                        ticks: {
                            beginAtZero: true,   
                            // max: 10,                        
                            display: false
                        },
                        gridLines: { 
                            drawBorder: false,
                            display: false 
                        }
                    }],
                    yAxes: [{
                        barThickness: 20,
                        stacked: true,
                        barPercentage: 0.3,
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
        });
        this.chart.canvas.parentNode.style.height = '100%';
        this.chart.canvas.parentNode.style.width = '100%';
    }

    async drawChartOustanding_Available() {
        const parent2 = this.template.querySelector('div.chart2');
        const canvas2 = document.createElement('canvas');
        // canvas.style = 'height:110%;width:100%;'
        parent2.appendChild(canvas2);
        const ctx2 = canvas2.getContext('2d');
        this.chart2 = new Chart(ctx2, {
            type: 'horizontalBar',
            data: {       
                labels: ["      Total Outstanding Bal.","Total Availble Bal."],
                datasets: [{                      
                    data: [0, 0],
                    backgroundColor: ['rgba(170, 202, 112, 1)',
                    'rgba(170, 202, 112, 1)'],
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
                        ctx2 = chartInstance.ctx;
        
                        ctx2.font = Chart.helpers.fontString(Chart.defaults.global.defaultFontSize, Chart.defaults.global.defaultFontStyle, Chart.defaults.global.defaultFontFamily);
                        ctx2.textAlign = 'center';
                        ctx2.textBaseline = 'bottom';
        
                        this.data.datasets.forEach(function(dataset, i) {
                            var meta = chartInstance.controller.getDatasetMeta(i);
                            meta.data.forEach(function(bar, index) {
                            var data = dataset.data[index];
                                if(data == 0){
                                    var value = '0';
                                }else{
                                    var value = data.toLocaleString();
                                }
                                ctx2.textAlign = "start";
                                // ctx2.fillStyle = "rgb(0, 255, 255)";
                                ctx2.font = "bold 13px Arial";
                                ctx2.fillText(value, 160, bar._model.y + 7);
                                // ctx2.fillText(value, bar._model.x - 150, bar._model.y + 7);
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
                            // max: 100000,                           
                            display: false
                        },
                        gridLines: { 
                            drawBorder: false,
                            display: false 
                        }
                    }],
                    yAxes: [{
                        barThickness: 20,
                        barPercentage: 0.5,
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
        });
    
        this.chart2.canvas.parentNode.style.height = '100%';
        this.chart2.canvas.parentNode.style.width = '100%';
    }

    parseObj(obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : obj;
    }

    tabSelect(event){

        this.tabContent = `Tab ${
            event.target.value
        } is now active`;
    }
}