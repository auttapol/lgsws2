({
    checkStatus : function(component, custId) {
        
        var thisObject = this;
        // var unitHolderList = result.unitHolderList;
        var action = component.get("c.isNeedUpdateOsc17");
        action.setParams({
            "custId": custId
        });

        action.setCallback(thisObject, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {              
                // After query is run then get map data
                var isNeedUpdate = response.getReturnValue();
                if (isNeedUpdate){
                    thisObject.runOSC16_17(component, custId);
                }
                else{
                    thisObject.getStampValue(component, custId);
                }
            }
            else if (state === "ERROR"){
                thisObject.throwTheErrorMessage(component, response);
            }
        });
        $A.enqueueAction(action);

    },

    getStampValue : function(component, custId) {
        
        var thisObject = this;
        // var unitHolderList = result.unitHolderList;
        var action = component.get("c.getOsc17FromStampValue");
        action.setParams({
            "custId": custId
        });

        action.setCallback(thisObject, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {              
                // After query is run then get map data
                var balanceSum = response.getReturnValue();

                thisObject.getMapData(component, custId, balanceSum);
            }
            else if (state === "ERROR"){
                thisObject.throwTheErrorMessage(component, response);
            }
        });
        $A.enqueueAction(action);
    },

    runOSC16_17 : function(component, custId) {
        
        var thisObject = this;
        // var unitHolderList = result.unitHolderList;
        var action = component.get("c.startCallAllProducts");
        action.setParams({
            "custId": custId,
            "nameCredential": "Smart_BDM_Cal_Tools_Create_Token",
            "serviceName": "GetCustomerWealth"
        });

        action.setCallback(thisObject, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {              
                // After query is run then get map data
                var balanceSum = response.getReturnValue();

                thisObject.getMapData(component, custId, balanceSum);
                thisObject.updateStampValue(component, custId, balanceSum);

                // Refresh view.
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR"){
                thisObject.throwTheErrorMessage(component, response);
            }
        });
        $A.enqueueAction(action);
    },

    updateStampValue : function(component, custId, balanceSum) {
        
        var thisObject = this;
        // var unitHolderList = result.unitHolderList;
        var action = component.get("c.updateOsc17ToCustomer");
        action.setParams({
            "custId": custId,
            "newValue": balanceSum
        });

        action.setCallback(thisObject, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {              
                // Do nothing.
            }
            else if (state === "ERROR"){
                thisObject.throwTheErrorMessage(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    getMapData: function(component, custId, balanceSum) {
        var thisObject = this;

        var action = component.get("c.getCustomerInfo");
        action.setParams({
            "accId": custId
        });

        action.setCallback(thisObject, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {                
                // Set Last update time.
                var lastUpdate = response.getReturnValue();
                component.set("v.lastUpdate", lastUpdate);
                
                // Generate chart
                // thisObject.generateGraphBar(component, balanceSum);
                thisObject.generateGraphPie(component, balanceSum, component.get('v.graphType'));
                thisObject.apexChartsGenGraphradialBar(component, balanceSum);
                // thisObject.apexChartsGenGraphDonut(component, balanceSum);
                // thisObject.apexChartsGenGraphBar(component, balanceSum);
            
            }
            else if (state === "ERROR"){
                thisObject.throwTheErrorMessage(component, response);
            }
        });
        $A.enqueueAction(action);

        // Hide spinner.
        thisObject.hideSpinner(component);
    },
    
    generateGraphBar: function(component, listdata) {

        var catagories = new Array();
        catagories.push('x');
        catagories.push(listdata[3][0]);
        catagories.push(listdata[5][0]);
        var data = new Array();
        data.push('Balance');
        data.push(parseFloat(Number(listdata[3][1]).toFixed(2)));
        data.push(parseFloat(Number(listdata[5][1]).toFixed(2)));

        var data1 = new Array();
        data1.push('Limit');
        // data1.push(parseFloat(listdata[3][1]).toFixed(2));
        data1.push(parseFloat(Number(listdata[4][1]).toFixed(2)));
        data1.push(parseFloat(Number(listdata[6][1]).toFixed(2)));
        var dataList = [catagories];
        dataList.push(data);
        dataList.push(data1);
        
        var graph = c3.generate({
            bindto: component.getElement().querySelector('.chart-canvas1'),
            data: {
                x: 'x',
                columns:[ 
                    // dataList
                ],
                groups: [
                    ['Balance', 'Limit']
                ],
                order: '',
                type: 'bar',
                labels: {
                    format: {
                        Balance: d3.format(','),
                        Limit : d3.format(',')
                    }
                }
            },
            size: {
                height: 250,
                // width: "50%"
            },
            // tooltip: {
            //     grouped: false, // Default true
            //     show: false
            // },
            bar: {
                width: {
                    ratio: 0.5 // this makes bar width 50% of length between ticks
                },
            },
            interaction: {
                enabled: false
            },
            axis: {
                x: {
                    type: 'category'
                    // categories: aggregateResult.map(function(obj) {
                    //     return obj[component.get('v.groupingField')];
                    // })
                },
                y : {
                    tick: {
                        format: d3.format(",")
                    }
                }
            },
            color: {
                pattern: ['#d4526e', '#13d8aa', '#4cae4c', '#46b8da', '#eea236', ]
            },
            legend: {
                show: true,
                position: 'bottom'
            }
        });

        setTimeout(function() {
            if (graph) {
                graph.load({
                    columns: dataList
                });
            }
        } , 1000);
        
    },
    
    generateGraphPie: function(component, listdata, type) {
        var thisObject = this;

        var data = new Array();
        data.push(listdata[0][0]);
        data.push(parseFloat(listdata[0][1]).toFixed(2));
        var data1 = new Array();
        data1.push(listdata[1][0]);
        data1.push(parseFloat(listdata[1][1]).toFixed(2));
        var data2 = new Array();
        data2.push(listdata[2][0]);
        data2.push(parseFloat(listdata[2][1]).toFixed(2));
        var dataList = [data];
        dataList.push(data1);
        dataList.push(data2);
        var sum = (parseFloat(listdata[0][1]) + parseFloat(listdata[1][1]) + parseFloat(listdata[2][1]));
        var sumText = sum.toString();

        var initialData = new Map();
        
        var graph = c3.generate({
            bindto: component.getElement().querySelector('.chart-canvas'),
            data: {
                columns: initialData,
                type: type.toLowerCase(),
                labels: true
                // onclick: function (d, i) { 
                //     console.log("onclick", d, i);
                //     var prod = d.name;
                //     prod = prod.replace(/ /g,'%20');
                //     // component.set('v.productGroup', prod);
                //     thisObject.openReportTabHelper(component, prod);
                // }
            },
            size: {
                height: 250,
            },
            color: {
                pattern: ['#cc2196', '#5bc0de', '#f0ad4e', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a']
            },
            pie: {
                label: {
                    format: function (value, ratio, id, name) {
                        return d3.format('0.2%')(ratio);
                    }
                }
            },
            donut: {
                label: {
                    format: function (value, ratio, id, name) {
                        return d3.format('0.2%')(ratio);
                    }
                },
                title: d3.format(',')(sumText) + ' ฿'
            },
            interaction: {
                enabled: true
            },
            tooltip: {
                format: {
                    // title: function (d) { return 'Value ' + d; },
                    value: function (value, ratio, id) {
                        var format = d3.format(','); //: d3.format('$');
                        return format(value);
                    }
                }
            },
            legend: {
                show: true,
                position: 'bottom'
            } 
        });
        
        setTimeout(function() {
            if (graph) {
                graph.load({
                    columns: dataList
                });
            }
        } , 500);
    },

    apexChartsGenGraphBar : function(component, listdata) {
        var catagories = new Array();
        catagories.push(listdata[3][0]);
        catagories.push(listdata[4][0]);
        var data = new Array();
        data.push(parseFloat(listdata[3][1]).toFixed(2));
        data.push(parseFloat(listdata[4][1]).toFixed(2));

        var data1 = new Array();
        // data1.push(parseFloat(listdata[3][1]).toFixed(2));
        data1.push(0);
        data1.push(parseFloat(listdata[5][1]).toFixed(2));
        // var dataList = [data];
        // dataList.push(data1);

        var option = {
            chart: {
                height: 250,
                // width: "50%",
                type: 'bar',
                stacked: true,
                stackType: '100%',
                toolbar: {
                    show: false,
                    tools: {
                        download: false,
                        selection: false,
                        zoom: true,
                        zoomin: true,
                        zoomout: true,
                        pan: true,
                        reset: true,
                        customIcons: []
                    }
                }
            },
            responsive: [{
                breakpoint: 480,
                options: {
                    legend: {
                        position: 'bottom',
                        offsetX: -10,
                        offsetY: 0
                    }
                }
            }],
            plotOptions: {
                bar: {
                        columnWidth: '50%',
                        distributed: false,
                        horizontal: false,
                        dataLabels: {
                            position: 'bottom',
                            hideOverflowingLabels: true,
                        },
                }
            },
            colors: ['#5cb85c', '#5bc0de', '#f0ad4e', '#d9534f', '#2e6da4', '#4cae4c', '#46b8da', '#eea236', '#d43f3a'],
            dataLabels: {
                enabled: false,
                textAnchor: 'start',
                style: {
                    fontSize: '8px',
                    fontFamily: 'Helvetica, Arial, sans-serif',
                    colors: ['#fff']
                },
                formatter: function(val, opt) {
                    // return val;
                    return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                    // return opt.w.globals.labels[opt.dataPointIndex] + ":  " + val
                },
                offsetX: 0,
                offsetY: 0,
                dropShadow: {
                    enabled: true
                }
            },
            series: [{
                name: 'Balance',
                data: data
            },{
                name: 'Limit',
                data: data1
            }],
            fill: {
                opacity: 1
            },
            xaxis: {
                categories: catagories,
            },
            yaxis: {
                labels: {
                    show: true,
                    formatter: function(val) {
                        // return val;
                        return val.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                        // return opt.w.globals.labels[opt.dataPointIndex] + ":  " + val
                    }
                }
            },
            legend: {
                position: 'right',
                offsetY: 40
            },
            // title: {
            //     text: '% Usage (Last Month) ',
            //     align: 'left',
            //     floating: true
            // },
            /*subtitle: {
                text: 'Category Names as DataLabels inside bars',
                align: 'center',
            },*/
            tooltip: {
                theme: 'dark',
                x: {
                    show: false
                },
                y: {
                    title: {
                        formatter: function() {
                            return ''
                        }
                    }
                }
            }
        }

        var chart = new ApexCharts(
            component.getElement().querySelector(".chart-canvas1"),
            option
        );

        chart.render();
    },

    apexChartsGenGraphDonut : function(component, listdata) {
        var catagories = new Array();
        catagories.push(listdata[0][0]);
        catagories.push(listdata[1][0]);
        var data = new Array();
        data.push(parseFloat(Number(listdata[0][1]).toFixed(2)));
        data.push(parseFloat(Number(listdata[1][1]).toFixed(2)));
        // var dataList = [data];
        // dataList.push(data1);

        var options = {
            chart: {
                type: 'donut',
            },
            series: data,
            labels: catagories,
            responsive: [{
                breakpoint: 480,
                options: {
                    chart: {
                        width: 200
                    },
                    legend: {
                        position: 'bottom'
                    }
                }
            }]
        }

        var chart1 = new ApexCharts(
            component.getElement().querySelector(".chart-canvas"),
            options
        );

        chart1.render();
    },

    apexChartsGenGraphradialBar : function(component, listdata) {

        var catagories = new Array();
        // catagories.push('x');
        catagories.push(listdata[3][0]);
        catagories.push(listdata[5][0]);

        var creditBalance = Number(listdata[3][1]);
        var creditLimit = Number(listdata[4][1]);
        var creditPercent = 0.00;
        if (creditBalance != 0 || creditLimit != 0){
            creditPercent = parseFloat(Number((creditBalance * 100) / creditLimit).toFixed(2));
        }


        var loanBalance = Number(listdata[5][1]);
        var loanLimit = Number(listdata[6][1]);
        var loanPercent = 0.00;
        if (loanBalance != 0 || loanLimit != 0){
            loanPercent = parseFloat(Number((loanBalance * 100) / loanLimit).toFixed(2));
        }

        var data = new Array();
        data.push(creditPercent);
        data.push(loanPercent);

        var optionsCircle = {
            chart: {
                type: 'radialBar',
                // width: 300,
                height: 250,
            },
            plotOptions: {
                radialBar: {
                    size: undefined,
                    inverseOrder: true,
                    hollow: {
                        margin: 5,
                        size: '48%',
                        background: 'transparent',
                    },
                    track: {
                        show: true,
                        background: '#b3b5ba',
                        strokeWidth: '25%',
                        opacity: 1,
                        margin: 3, // margin is in pixels
                    },
                    startAngle: -180,
                    endAngle: 180            
                },
            },
            stroke: {
                lineCap: 'round'
            },
            series: data,
            labels: catagories,
            legend: {
                show: true,
                floating: true,
                position: 'bottom',
                formatter: function (val, opts) {
                    return val + " - " + opts.w.globals.series[opts.seriesIndex] + '%'
                }
                // offsetX: 70,
                // offsetY: 240
            },
            fill: {
                type: 'gradient',
                gradient: {
                    shade: 'dark',
                    type: 'horizontal',
                    shadeIntensity: 0.5,
                    inverseColors: true,
                    opacityFrom: 1,
                    opacityTo: 1,
                    stops: [0, 100]
                }
              }
        }

        var chart = new ApexCharts(
            component.getElement().querySelector(".chart-canvas1"),
            optionsCircle
        );

        chart.render();
        chart.updateOptions({});
    },

    openReportTabHelper : function(component, prod) {
        var workspaceAPI = component.find("workspace");
        var link = '/lightning/r/Report/00O0p000000K0Et/view?fv0='
                    + component.get('v.recordId')
                    + '&fv1='
                    + prod;
        workspaceAPI.openTab({
            url: link,
            focus: true
        }).then(function(response) {
            workspaceAPI.getTabInfo({
                tabId: response
            }).then(function(tabInfo) {
                console.log("The recordId for this tab is: " + tabInfo.recordId);
            });
        }).catch(function(error) {
            console.log(error);
        })
    },

    // this function automatic call by aura:waiting event  
    showSpinner: function(component) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
     
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },

    throwTheErrorMessage : function(component, response){
        var thisObject = this;
        let errors = response.getError();
        let errorMsg = 'Unknown error'; // Default error message
        // Retrieve the error message sent by the server
        if (errors && Array.isArray(errors) && errors.length > 0) {
            errorMsg = errors[0].message;
        }

        component.set("v.error", true);
        component.set("v.errorMessage", errorMsg);
        thisObject.hideSpinner(component);
    }
})