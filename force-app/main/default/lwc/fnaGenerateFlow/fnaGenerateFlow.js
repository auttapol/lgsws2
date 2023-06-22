/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
import generateFlow from '@salesforce/apex/fnaGenerateFlow.generateFlow';
import confirmFlow from '@salesforce/apex/fnaGenerateFlow.confirmFlow';
import checkTemp from '@salesforce/apex/fnaGenerateFlow.checkTemp';
import fnaGenMetricMessge from '@salesforce/label/c.fnaGenMetricMessge';
import fnaGenMetricBtn from '@salesforce/label/c.fnaGenMetricBtn';
import fnaConfirmMetricMessge from '@salesforce/label/c.fnaConfirmMetricMessge';
import fnaConfirmMetricBtn from '@salesforce/label/c.fnaConfirmMetricBtn';


export default class FnaGenerateFlow extends LightningElement {
    @track generateData;
    @track alert;
    @track alert2;

    @track checkTempBoolean = false;

    label = {
        fnaGenMetricMessge,fnaGenMetricBtn,fnaConfirmMetricMessge,fnaConfirmMetricBtn
    };

    constructor(){
        super()
        this.btnCheckCustom();
    }

    changeHandler(event){
        this.checkFlow = event.target.value;
    }

    btnGenerate(){
        console.log('Generate!')
        generateFlow()
        .then(result => {
            console.log('then')
            console.log(result)
            this.alert = 'Please check your email for result.'
            this.btnCheckCustom();
        })
        .catch(error => {
            console.log('catch')
            console.log(error)
        });
    }

    btnConfirmGenerate(){
        confirmFlow()
        .then(result => {
            console.log('then')
            console.log(result)
            this.alert2 = 'Please check your email for result.'
        })
        .catch(error => {
            console.log('catch')
            console.log(error)
        });
    }

    btnCheckCustom(){
        checkTemp()
        .then(result => {
            console.log('then')
            console.log(result)
            this.checkTempBoolean = result
        })
        .catch(error => {
            console.log('catch')
            console.log(error)
        });
    }
}