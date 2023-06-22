/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import resourceQuestion from '@salesforce/resourceUrl/FNA_Resource';

import checkCustomerId from '@salesforce/apex/fnaUtility.checkCustomerId'; 
import getImage from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.getImage'; 

export default class FnaHome extends LightningElement {

    @track imageResource = '';
    @track loadingDisplay = 'hideLoading'; 
    @track bgDisplay = 'bg hideLoading'; 
    @track move = 'middle scroll';
    sPageURL = '';
    constructor(){
        super();
        this.loadingDisplay = 'showLoading';
        this.sPageURL = decodeURIComponent(window.location.search.substring(1));
        // console.log('sPageURL ' , this.sPageURL);
        window.history.pushState({}, document.title, "/fin/s/");
        this.clearStorage();
        this.functionLoadScript();
        this.getImageResource();

        this.detectBrowser();

        setTimeout(() => { 
            this.move = 'middle scroll movePosition';    

        }, 3000);
    }

    redirectNextpage(){
        // console.log('sPageURL ' , this.sPageURL);
        var parameter = this.getparameter(this.sPageURL);
        var params_branchCode = parameter.get('branchCode');
        if(parameter.get('cusId') !== null && parameter.get('cusId') !== ''  && parameter.get('cusId') !== undefined){
            // console.log('From scan QR Code');
            this.checkFnabyCustomerId(parameter);
        }else{ 
            
            if(params_branchCode !== '' && params_branchCode !== undefined){
                localStorage.setItem("branchCode", params_branchCode);
            }
            
            this.gotoQuestionnairepage();
        }
    }

    checkFnabyCustomerId(parameter){
        // console.log('paramter : ' + parameter.get('cusId'));
        // console.log('paramter : ' + parameter.get('branchCode'));
        // console.log('paramter : ' + parameter.get('branchAgentId'));
        checkCustomerId({cusId : parameter.get('cusId'), branchCode : parameter.get('branchCode'), branchAgentId : parameter.get('branchAgentId')}).then(result => {
            // console.log('result : ' + result);
            if(result !== '' && result !== null){
                localStorage.setItem("Id", result); 
            }

            localStorage.setItem("branchCode", parameter.get('branchCode'));
            this.gotoQuestionnairepage();
        })
        .catch(error => {
            console.log('catch : ' + error);
        });

    }

    gotoQuestionnairepage(){
        var url = '/fin/s/fnaquestionnaire';
        window.location.href = url;
    }

    getparameter(param){
        var myMap = new Map();
        if(param !== ''){
            var sURLVariables = param.split('&');
        
            var i;
            var sParameterName;
            for (i = 0; i < sURLVariables.length; i++) {
                sParameterName = sURLVariables[i].split('='); //to split the key from the value.
                myMap.set(sParameterName[0], sParameterName[1]);
            }
        }
        return myMap;
    }

    clearStorage(){
        var local_branchCode = localStorage.getItem("branchCode");
        localStorage.clear();
        // console.log('local_branchCode : ' + local_branchCode);
        if(local_branchCode !== 'undefined' && local_branchCode !== '' && local_branchCode !== null){
            localStorage.setItem("branchCode", local_branchCode);
        }
    }

    getImageResource(){

        getImage()
        .then(result => {
            this.imageResource = result;
            // console.log('this.imageResource : ',this.imageResource)
            // console.log('succes load Image');  
            this.bgDisplay = 'bg showLoading';
            this.loadingDisplay = 'hideLoading';
        })
        .catch(error => {
            console.log('catch : ' + error);
            // console.log('catch get Image');
            // console.log(error);
        });
    }

    functionLoadScript(){
        Promise.all([
            loadStyle(this, resourceQuestion + '/public/css/bootstrap.min.css'),
            loadStyle(this, resourceQuestion + '/public/css/hover.css'),
            loadStyle(this, resourceQuestion + '/public/css/picker.css'),
            loadStyle(this, resourceQuestion + '/src/css/styles.css')
        ])
            .then(() => {
                // console.log('Files loaded.');
            })
            .catch(error => {
                console.log('catch : ' + error);
                // console.log(error.body.message);
            });
        }
    
    @track browser;
    @track notSupportBrowser = "hideLoading";
    @track displayAll = "displayPDF";
    @track topbar = "topbar";
    detectBrowser(){
        // console.log('Browser :',navigator.userAgent)
        this.browser = navigator.userAgent;
        // this.browser = this.browser.includes("Line");
        if((navigator.userAgent).includes("Line")){
            this.displayAll = "hideLoading";
            this.notSupportBrowser = "showLoading";
            this.topbar = "hideLoading";
        }
    }
}