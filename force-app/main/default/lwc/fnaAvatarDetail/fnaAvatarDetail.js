/* eslint-disable no-unreachable */
/* eslint-disable no-else-return */
/* eslint-disable no-unused-vars */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
import getImage from '@salesforce/apex/fnaAvatarDetailCtrl.getImage';  
import getAvatarMasterDetail from '@salesforce/apex/fnaAvatarDetailCtrl.getAvatarMasterDetail'; 
import getProductOffer from '@salesforce/apex/fnaAvatarDetailCtrl.getProductOffer'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import fnaAvatarDetailResource from '@salesforce/resourceUrl/fnaAvatarDetail';
import resourceQuestion from '@salesforce/resourceUrl/FNA_Resource';
import sendOTP from '@salesforce/apex/fnaAvatarDetailCtrl.sendOTP'; 

import successDownload from '@salesforce/apex/fnaUtility.successDownload';
import sendSMSURL from '@salesforce/apex/fnaUtility.sendSMSURL'; 
import fnaCheckExisting from '@salesforce/apex/fnaUtility.FnaCheckExisting';

import fnGenerateOTP from '@salesforce/apex/fnaUtility.fnGenerateOTP';
import fnVerifyOTP from '@salesforce/apex/fnaUtility.fnVerifyOTP';

import callServiceOSC14 from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceOSC14';
import callServiceOSC16 from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceOSC16';
import callServiceGetCardsBalances from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceGetCardsBalances';
import stampOffSet from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.stampOffSet';

export default class fnaAvatarDetail extends LightningElement {
    
    @track bShowModal  = false;
    @track bShowModal1 = false;
    @track bShowModal2  = false;
    @track bShowModal3  = false;
    @track temp = {};
    @track b64 = '';
    @track name1 = '';
    @track err = 'errorlog hideLoading';
    @track loading;
    @track loadingDisplay = 'hideLoading'; 
    @track loadingQuestion = 'contentQuestion hideLoading'
    @track getID = '';
    @track imageResource = ''; 
    @track params = '';
    @track phoneNumber = '';
    phone = '';

    fnaAvatarDetailInitialized = false;
    renderedCallback() {
        if (this.fnaAvatarDetailInitialized) {
            return;
        }

        this.fnaAvatarDetailInitialized = true;
    
        Promise.all([
            loadStyle(this, resourceQuestion + '/public/css/bootstrap.min.css'),
            loadStyle(this, resourceQuestion + '/public/css/hover.css'),
            loadStyle(this, resourceQuestion + '/public/css/picker.css'),
            loadStyle(this, resourceQuestion + '/src/css/styles.css'),
            loadStyle(this, 'https://fonts.googleapis.com/icon?family=Material+Icons'),
            loadStyle(this, fnaAvatarDetailResource + '/css/fnaAvatarDetail.css')
        ]).then(() => {
            // console.log("= Load Style Success =");  
        })
        .catch(error => {
            console.log('Erorr' + error);
        });
    }

    constructor(){
        super();
        // this.renderedCallback();
        // this.jqueryReady();
        this.loadingDisplay = 'showLoading';
        this.getImageResource(); 
        // console.log('window.location.search :',window.location.search);
        const sPageURL = decodeURIComponent(window.location.search.substring(1));
        // console.log('sPageURL :',sPageURL);
        const parameter = this.getparameter(sPageURL);
        this.params = parameter.get('Id');
        //  console.log('params:',this.params)
        // console.log('has parameter ' + parameter.has('qId'));
        if(parameter.has('Id')){
            this.getAvatarDetail(parameter.get('Id'), window.location.search);
            this.callOSC(parameter.get('Id'),false);
        }else{
            this.getAvatarDetail();
        }
    }

    //CALL OSC
    @track btnViewHighlight = 'btn-lg cta download IOS ctaDisabed';
    callOSC(fnaId,sendSms){

        // console.log('call OSC Id : ',fnaId)

        // console.log('call OSC Id : ',fnaId)
        const promises = [
            //CALL SERVICE OSC14
            callServiceOSC14({fnaActivityId: fnaId})
            .then(result =>{
                // console.log('Call Service OSC01 Complete')
                // console.log('result OSC01 : ', result)
                if(result !== null){
                    // if(!(result.statusCode)){
                        return result;
                    // }
                }                
            })
            .catch(err => {
                console.log('Failed to call Service OSC14')
                console.log(err)
            }),
            

            //CALL SERVICE OSC16
            callServiceOSC16({fnaActivityId: fnaId})
            .then(result =>{
                // console.log('call Service OSC16 Complete')
                // console.log('result OSC05 : ', result)
                if(result !== null){
                    // if(!(result.statusCode)){
                        return result;
                    // }
                } 
                
            })
            .catch(err => {
                console.log('Failed to call Service OSC16')
                console.log(err)
            }),

            // call service get-cards-balances
            callServiceGetCardsBalances({fnaActivityId: fnaId})
            .then(result =>{
                // console.log('call Service get-cards-balances Complete')
                // console.log('result get-cards-balances : ', result)
                if(result !== null){
                    // if(!(result.statusCode)){
                        return result;
                    // }
                } 
                
            })
            .catch(err => {
                console.log('Failed to call Service get-cards-balances')
                console.log(err)
            })

        ];

        Promise.all(promises)
        .then(res =>{
            // console.log('res : ' , res);
            // console.log('res[0] : ' , res[0]);
            // console.log('res[1] : ' , res[1]);
            // console.log('res[2] : ' , res[2]);
            var loadOSC14, loadOSC16, loadGetCardsBalance = false;

            loadOSC14 = (res[0] !== undefined || res[0] !== null)? true: false;
            loadOSC16 = (res[1] !== undefined || res[1] !== null)? true: false;
            loadGetCardsBalance = (res[2] !== undefined) || res[2] !== null? true: false;

            // console.log('sendSms : ' + sendSms);
            if(sendSms){
                // console.log('send URL');
                this.sendURL();
            }

            if(loadOSC14 || loadOSC16 || loadGetCardsBalance){
                // console.log('StampOffset');
                stampOffSet({fnaActivityId: this.getID, responseBodyOSC14: res[0], responseBodyOSC16: res[1], responseBodyGetCardsBalance: res[2]})
                .then(response => {
                    console.log("stampOffSet: ",response)
                    this.loadingDisplay = 'hideLoading';
                    // this.bShowModal = true;
                    this.bShowModal1 = false;
                    this.bShowModal3 = true;//editmodalaom
                    this.bShowModal2 = false;
                    this.btnViewHighlight = 'btn-lg cta hvr-grow-shadow download IOS';
                })
                .catch(err => {
                    console.log('Failed to call Services')
                    console.log(err)
                    this.loadingDisplay = 'hideLoading';
                    // this.bShowModal = true;
                    this.bShowModal1 = false;
                    this.bShowModal3 = true;//editmodalaom
                    this.bShowModal2 = false;
                    this.btnViewHighlight = 'btn-lg cta hvr-grow-shadow download IOS';
                })
                                
            }else{
                this.loadingDisplay = 'hideLoading';
                // this.bShowModal = true;
                this.bShowModal1 = false;
                this.bShowModal3 = true;//editmodalaom
                this.bShowModal2 = false;
                this.btnViewHighlight = 'btn-lg cta hvr-grow-shadow download IOS';
            }

        })
        



    }

    getImageResource(){
       
        // console.log('Image resource');
        getImage()
        .then(result => {
            this.imageResource = result;            
            // console.log('succes load Image', result);
            this.loadingDisplay = 'hideLoading'; 
            this.loadingQuestion = 'contentQuestion showLoading';
            this.imgExit = result.cancel;
            this.imgExitInvert = result.cancelInvert;     
        })
        .catch(error => {
            console.log('catch get Image');
            console.log(error);
        });
    }
    
    getAvatarDetail(formId,sUrlPage){
       
        // console.log('Form ID ' + formId);
        // console.log('sUrlPage ' + sUrlPage);

        this.getID = formId;
        //'a3b0l0000003r1EAAQ'
        getAvatarMasterDetail({idForm: formId, urlDropOff: sUrlPage})
        .then(result => {
            this.temp = result.avatar;
            this.b64 = result.urlImage;
            this.name1 = result.avatarName;
            this.phoneNumber = result.phone;
            this.phone = result.phone;
            // console.log('result ' ,result);
            // console.log('then');
            // console.log(this.temp);
            this.loadingDisplay = 'hideLoading'; 
            this.loadingQuestion = 'contentQuestion showLoading'  

            //get Product Offering
            this.getProductOffering(formId);
        })
        .catch(error => { 
            console.log('catch');
            console.log(error);
        });
    }

    checkExsiting(){
        fnaCheckExisting({fnaId: this.getID})
        .then(responses => {
            // console.log('Update FNA success');
            this.callOSC(this.getID,true);
            
        })
        .catch(error => {
            console.log('catch Update FNA');
            console.log(error);
        });
    }

    //get Product Offering
    getProductOffering(fnaId){
        getProductOffer({fnaActivityId: fnaId})
        .then(result => {
            // console.log('getProductOffering function')
            // console.log(result)
        })
        .catch(error => { 
            console.log('catch');
            console.log(error);
        });
    }

    handleClick() {
        this.bShowModal = true;
        this.bShowModal1 = true;
        this.bShowModal2 = false;
        this.bShowModal3 = false;
        this.err = 'errorlog hideLoading';
        this.textErr = ''; 
    }
    
    handleDialogClose() {
        this.hide();
    }

    closeModal() {    
        if(this.phoneNumber === ''){
            this.phoneNumber = this.phone;
        }
        
        this.bShowModal = false;
        this.bShowModal1 = false;
        this.bShowModal2 = false;
        this.bShowModal3 = false;
        this.btnResetOTP = 'showLoading';
        this.errPhone = 'errorlog hideLoading';
        this.err = 'errorlog hideLoading';
    }

    @track textRef = '';
    @track errPhone = 'errorlog hideLoading';


    allowNumbersOnly(e) {
        // console.log('allowNumbersOnly')
        let inputPhone = this.template.querySelector(`[data-id="phoneInput"]`);
        var code = (e.which) ? e.which : e.keyCode;
        if (code > 31 && (code < 48 || code > 57)) {
            // console.log('prevent')
            e.preventDefault();
        }
        inputPhone.classList.remove('inputInvalid');
        this.errPhone = 'errorlog hideLoading';
    }

    next(){
        let inputPhone = this.template.querySelector(`[data-id="phoneInput"]`);

        // console.log((inputPhone.value).length)

        // let regax = '^[0]{1}[6,8,9]{1}[0-9]{8}$'

        var phoneno = /^[0]{1}[6,8,9]{1}[0-9]{8}$/;
        if(inputPhone.value.match(phoneno) && (inputPhone.value).length === 10) {
            // console.log('true')
            // console.log('success'+ this.params)
           
            fnGenerateOTP({fnaId: this.params})
            .then(response => {
                // console.log('then333',response);
                this.textRef = response.Otp_Ref__c;
                this.bShowModal = true;
                this.bShowModal1 = false;
                this.bShowModal2 = true;
                this.bShowModal3 = false;
                this.btnResetOTP = 'showLoading';
                this.errPhone = 'errorlog hideLoading';
                inputPhone.classList.remove('inputInvalid');
                this.phoneNumber = inputPhone.value;
                this.phone = inputPhone.value;
                this.sendSMSOTP(this.phoneNumber, response.Id);
            })
            .catch(error => {
                console.log('catch');
                console.log(error);
            });
        }
        else {
            this.phoneNumber = '';
            this.errPhone = 'errorlog showLoading';
            inputPhone.classList.add('inputInvalid');
            // console.log('false')
        }
    }

    sendSMSOTP(inputPhone, otp){
        // console.log('inputPhone :' + inputPhone);
        // console.log('otp :' + otp);
        // console.log('fnaId :' + this.params);
        sendOTP({phone: inputPhone,fnaId: this.params, otpId: otp})  
        .then(response => {
            // console.log('OTP Success');

        })
        .catch(error => {
            console.log('catch');
            console.log(error);

        });

    }

    handleProduct() {
        this.loadingDisplay = 'showLoading';
        var originalURL = 'Id='+this.getID;
        this.gotoURL('/fin/s/fnaHighlightProduct?' + encodeURIComponent(originalURL));
        this.loading = true;
    }

    exitPage(){
        this.loadingDisplay = 'showLoading';
        this.phoneNumber = this.phone;
        this.gotoURL('/fin/s');
    }

    gotoURL(urlpage){
        this.loadingDisplay = 'showLoading';
        // Navigate to a URL
        window.location.href = urlpage;
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

    @track textErr = '';
    @track btnResetOTP = 'showLoading';
    checkNext(event){
        // console.log('checkNext = ',event.target.value)
        var inputName = event.target.name;
        // console.log('inputName = ',inputName)

        let inputOTP_1 = this.template.querySelector(`[data-id="otpInput_1"]`);
        let inputOTP_2 = this.template.querySelector(`[data-id="otpInput_2"]`);
        let inputOTP_3 = this.template.querySelector(`[data-id="otpInput_3"]`);
        let inputOTP_4 = this.template.querySelector(`[data-id="otpInput_4"]`);
        let inputOTP_5 = this.template.querySelector(`[data-id="otpInput_5"]`);
        let inputOTP_6 = this.template.querySelector(`[data-id="otpInput_6"]`);
        let btnSubmitOTP = this.template.querySelector(`[data-id="btnSubmitOTP"]`);

        if(inputOTP_1.value === '' || 
        inputOTP_2.value === '' || 
        inputOTP_3.value === '' ||
        inputOTP_4.value === '' ||
        inputOTP_5.value === '' ||
        inputOTP_6.value === ''){
            this.textErr = '';
        }

        // inputOTP_6.value || 
        if(inputName === 'submitOTP'){
            if( (inputOTP_1).value === '' || 
            (inputOTP_2).value === '' ||
            (inputOTP_3).value === '' ||
            (inputOTP_4).value === '' ||
            (inputOTP_5).value === '' ||
            (inputOTP_6).value === '' ){
                // console.log('OTP กรอกไม่ครบ')
                this.err = 'errorlog showLoading';
                // this.textErr = 'Please fill OTP Code.';   
                this.textErr = 'กรุณาระบุรหัส OTP ที่ได้รับ'; 
                this.btnResetOTP = 'showLoading';
            }
            else{
                // this.loadingDisplay = 'showLoading';
                // console.log('OTP กรอกครบกำลัง validate')
                let inputValue_1 = (inputOTP_1.value).toString();
                let inputValue_2 = (inputOTP_2.value).toString();
                let inputValue_3 = (inputOTP_3.value).toString();
                let inputValue_4 = (inputOTP_4.value).toString();
                let inputValue_5 = (inputOTP_5.value).toString();
                let inputValue_6 = (inputOTP_6.value).toString();
                var inputValue = inputValue_1 + inputValue_2 + inputValue_3 + inputValue_4 + inputValue_5 + inputValue_6;
                // console.log('inputValue : ',inputValue)
                fnVerifyOTP({fnaId: this.params,otpCode: inputValue})
                .then(response => {
                    // this.loadingDisplay = 'hideLoading';
                    // console.log('then', response)
                    this.err = 'errorlog showLoading';
                    switch(response){
                        case 1:
                            // this.textErr = 'Please request the new OTP.';
                            this.textErr = 'ขอรับรหัส OTP ใหม่';
                            inputOTP_1.setAttribute("disabled", "");
                            inputOTP_2.setAttribute("disabled", "");
                            inputOTP_3.setAttribute("disabled", "");
                            inputOTP_4.setAttribute("disabled", "");
                            inputOTP_5.setAttribute("disabled", "");
                            inputOTP_6.setAttribute("disabled", "");
                            btnSubmitOTP.setAttribute("disabled", "");
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 2:
                            // this.textErr = 'Cannot use old OTP Code.';
                            this.textErr = 'รหัส OTP ไม่ถูกต้อง คุณอาจนำรหัสที่ถูกใช้งานไปแล้วมากรอก กรุณาตรวจสอบ SMS ใหม่ หรือ ขอรหัส OTP ใหม่';
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 3://disabled
                            // this.textErr = 'OTP Code was expired. Please request the new OTP.';
                            this.textErr = 'รหัส OTP ของคุณหมดอายุ กรุณาขอรับรหัส OTP ใหม่';
                            inputOTP_1.setAttribute("disabled", "");
                            inputOTP_2.setAttribute("disabled", "");
                            inputOTP_3.setAttribute("disabled", "");
                            inputOTP_4.setAttribute("disabled", "");
                            inputOTP_5.setAttribute("disabled", "");
                            inputOTP_6.setAttribute("disabled", "");
                            btnSubmitOTP.setAttribute("disabled", "");
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 4://disabled
                            // this.textErr = 'OTP Code was hit max retry. Please request the new OTP.';
                            this.textErr = 'ขออภัยค่ะ คุณกรอกรหัสผิดเกินจำนวนครั้งที่กำหนด กรุณาขอรับรหัส OTP ใหม่';
                            inputOTP_1.setAttribute("disabled", "");
                            inputOTP_2.setAttribute("disabled", "");
                            inputOTP_3.setAttribute("disabled", "");
                            inputOTP_4.setAttribute("disabled", "");
                            inputOTP_5.setAttribute("disabled", "");
                            inputOTP_6.setAttribute("disabled", "");
                            btnSubmitOTP.setAttribute("disabled", "");
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 5:
                            // this.textErr = 'OTP Code miss match.';
                            this.textErr = 'รหัส OTP ไม่ถูกต้อง กรุณาตรวจสอบ SMS ใหม่ หรือ ขอรับรหัส OTP ใหม่';
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 6://disabled
                            // this.textErr = 'Cannot use old OTP Code. Please request the new OTP.';
                            this.textErr = 'รหัส OTP ไม่ถูกต้อง คุณอาจนำรหัสที่ถูกใช้งานไปแล้วมากรอก กรุณาตรวจสอบ SMS ใหม่ หรือ ขอรหัส OTP ใหม่';
                            inputOTP_1.setAttribute("disabled", "");
                            inputOTP_2.setAttribute("disabled", "");
                            inputOTP_3.setAttribute("disabled", "");
                            inputOTP_4.setAttribute("disabled", "");
                            inputOTP_5.setAttribute("disabled", "");
                            inputOTP_6.setAttribute("disabled", "");
                            btnSubmitOTP.setAttribute("disabled", "");
                            this.btnResetOTP = 'showLoading';
                            break;
                        case 7:
                            this.err = 'successlog showLoading';
                            this.textErr = 'Verify success.';
                            inputOTP_1.setAttribute("disabled", "");
                            inputOTP_2.setAttribute("disabled", "");
                            inputOTP_3.setAttribute("disabled", "");
                            inputOTP_4.setAttribute("disabled", "");
                            inputOTP_5.setAttribute("disabled", "");
                            inputOTP_6.setAttribute("disabled", "");
                            if(inputName === 'submitOTP'){
                                this.bShowModal = true;
                                // this.bShowModal1 = false;
                                // this.bShowModal3 = true;//editmodalaom
                                // this.bShowModal2 = false;
                                this.err = 'errorlog hideLoading';
                                this.errPhone = 'errorlog hideLoading';
                                //CALL OSC
                                this.loadingDisplay = 'showLoading';
                                this.checkExsiting();
                                // this.callOSC(this.getID,true);
                            }

                            break;
                        default:
                            break;
                    }
                })
                .catch(error => { 
                    console.log('catch');
                    console.log(error);
                });
            }
        }
        else{
            // console.log('value in OTPInput 6 =  null')
        }
        // console.log('err : ', this.err)

      
        if(event.target.value !== ''){
            var inputNameCount = inputName.substring(inputName.length-1, inputName.length);
            var integer = parseInt(inputNameCount, 10);
            integer = integer+1;
            var otpInput;

            switch (true) {
                case (integer === 1 && event.target.value !== ''):
                    otpInput = inputOTP_1;
                    // console.log(event.target.value);  
                    break;
                case (integer === 2 && event.target.value !== ''):
                    otpInput = inputOTP_2;
                    // console.log(event.target.value);        
                    break;
                case (integer === 3 && event.target.value !== ''):
                    otpInput = inputOTP_3;
                    // console.log(event.target.value);             
                    break;
                case (integer === 4 && event.target.value !== ''):
                    otpInput = inputOTP_4;      
                    // console.log(event.target.value);        
                    break;
                case (integer === 5 && event.target.value !== ''):
                    otpInput = inputOTP_5;
                    // console.log(event.target.value);        
                    break;
                case (integer === 6 && event.target.value !== ''):
                    otpInput = inputOTP_6;
                    // console.log(event.target.value);        
                    break;
                default:
                    break;
            }
            otpInput.focus();
        }
        else{
            // console.log('else')
            var inputNameCountElse = inputName.substring(inputName.length-1, inputName.length);
            var integerElse = parseInt(inputNameCountElse, 10);
            if(integerElse-1 !== 0){
                // console.log(integerElse)
                integerElse = integerElse-1;
                // console.log(integerElse)
            }
            var otpInputElse;

            switch (true) {
                case (integerElse === 1):
                    otpInputElse = inputOTP_1;
                    // console.log(event.target.value);  
                    break;
                case (integerElse === 2):
                    otpInputElse = inputOTP_2;
                    // console.log(event.target.value);        
                    break;
                case (integerElse === 3):
                    otpInputElse = inputOTP_3;
                    // console.log(event.target.value);             
                    break;
                case (integerElse === 4):
                    otpInputElse = inputOTP_4;      
                    // console.log(event.target.value);        
                    break;
                case (integerElse === 5):
                    otpInputElse = inputOTP_5;
                    // console.log(event.target.value);        
                    break;
                case (integerElse === 6):
                    otpInputElse = inputOTP_6;
                    // console.log(event.target.value);        
                    break;
                default:
                    break;
            }
            otpInputElse.focus();
        } 
    }

    sendURL(){
        sendSMSURL({fnaId: this.params})
        .then(response => {
            // console.log(response)
            // console.log('Send Url success');
            successDownload({fnaId: this.getID})
            .then(responses => {
                // console.log(responses)
                // console.log('Update FNA success');
            })
            .catch(error => {
                console.log('catch Update FNA');
                console.log(error);
            });
        })
        .catch(error => {
            console.log('catch');
            console.log(error);
        });
    }

    resetOTP(){
        let inputOTP_1 = this.template.querySelector(`[data-id="otpInput_1"]`);
        let inputOTP_2 = this.template.querySelector(`[data-id="otpInput_2"]`);
        let inputOTP_3 = this.template.querySelector(`[data-id="otpInput_3"]`);
        let inputOTP_4 = this.template.querySelector(`[data-id="otpInput_4"]`);
        let inputOTP_5 = this.template.querySelector(`[data-id="otpInput_5"]`);
        let inputOTP_6 = this.template.querySelector(`[data-id="otpInput_6"]`);
        let btnSubmitOTP = this.template.querySelector(`[data-id="btnSubmitOTP"]`);

        fnGenerateOTP({fnaId: this.params})
        .then(response => {
            // console.log('then22',response);
            this.textRef = response.Otp_Ref__c;
            this.textErr = '';
            inputOTP_1.value = '';
            inputOTP_2.value = '';
            inputOTP_3.value = '';
            inputOTP_4.value = '';
            inputOTP_5.value = '';
            inputOTP_6.value = '';

            inputOTP_1.removeAttribute("disabled");
            inputOTP_2.removeAttribute("disabled");
            inputOTP_3.removeAttribute("disabled");
            inputOTP_4.removeAttribute("disabled");
            inputOTP_5.removeAttribute("disabled");
            inputOTP_6.removeAttribute("disabled");
            btnSubmitOTP.removeAttribute("disabled");
            this.sendSMSOTP(this.phoneNumber, response.Id);
            this.btnResetOTP = 'showLoading';
        })
        .catch(error => {
            console.log('catch');
            console.log(error);
        });
    }

    @track imgExit = '';
    @track imgExitInvert = '';
    ImageOverExit(element){
        // console.log('ImageOver')
        let imgCancel = this.template.querySelector(`[data-id="imgCancel"]`);
        imgCancel.src = this.imgExitInvert;
    }
    ImageUnOverExit(element){
        // console.log('ImageUnOver')
        let imgCancel = this.template.querySelector(`[data-id="imgCancel"]`);
        imgCancel.src = this.imgExit;
    }
}