/* eslint-disable radix */
/* eslint-disable no-dupe-class-members */
/* eslint-disable no-loop-func */
/* eslint-disable handle-callback-err */
/* eslint-disable no-undef */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, track} from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import resourceQuestion from '@salesforce/resourceUrl/FNA_Resource';
import fnaJquery from '@salesforce/resourceUrl/fnaJquery';

import getMapGroup from '@salesforce/apex/fnaHighlightProductCtrl.getMapGroup';
import getThumbnailUrlAll from '@salesforce/apex/fnaHighlightProductCtrl.getThumbnailUrlAll';
import getAvatarDetail from '@salesforce/apex/fnaHighlightProductCtrl.getAvatarMasterDetail'; 

import sendOTP from '@salesforce/apex/fnaHighlightProductCtrl.sendOTP'; 
import sendSMSURL from '@salesforce/apex/fnaUtility.sendSMSURL'; 
import successDownload from '@salesforce/apex/fnaUtility.successDownload';
import fnaCheckExisting from '@salesforce/apex/fnaUtility.FnaCheckExisting';

import getImage from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.getImage'; 


import fnGenerateOTP from '@salesforce/apex/fnaUtility.fnGenerateOTP';
import fnVerifyOTP from '@salesforce/apex/fnaUtility.fnVerifyOTP';

import idleTime from '@salesforce/apex/fnaHighlightProductCtrl.idleTime'; 
import createRef from '@salesforce/apex/fnaHighlightProductCtrl.createRef'; 

import callServiceOSC14 from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceOSC14';
import callServiceOSC16 from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceOSC16';
import callServiceGetCardsBalances from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.callServiceGetCardsBalances';
import stampOffSet from '@salesforce/apexContinuation/fnaAvatarDetailCtrl.stampOffSet';

// import decryptParams from '@salesforce/apex/fnaUtility.decryptParams';
import encryptParams from '@salesforce/apex/fnaUtility.encryptParams';

export default class fnaHighlightProduct extends LightningElement {

    @track getID = '';
    @track lstProductPackage = [];
    @track lstProductHighlight = [];
    @track lstProductNormal = [];
    @track isDownload = false;
    @track isPackage = 'sectionSlide hide';
    @track isHighlight = 'show';
    @track isNormal = 'hide';
    @track isBtn = 'show';
    @track isLine = 'hide';
   
    @track imageResource = '';
    @track bgDisplay = 'bg hide';
    @track loadingDisplay = 'hideLoading';

    @track titleBtn = 'ผลิตภัณฑ์อื่นๆ ที่เหมาะกับคุณ';
    @track icoBtnLess = 'hide';
    @track icoBtnMore = 'show';

    @track headerTitle = 'ผลิตภัณฑ์ที่ตอบโจทย์ความต้องการของ';
    @track b64 = '';

    @track avatarName = '';

    @track phoneNumber = '';
    phone = '';
    scrollInitialized = false;
    renderedCallback() {
        if (this.scrollInitialized) {
            return;
        }

        this.scrollInitialized = true;
        Promise.all([
            loadScript(this, fnaJquery),
        ])
        .then(() => {
            // console.log('Success load jquery script');
            Promise.all([
                loadScript(this, resourceQuestion + '/public/js/bootstrap.min.js'),
                loadScript(this, resourceQuestion + '/public/js/bootstrap-slider.js'),
                loadScript(this, resourceQuestion + '/public/js/jquery.jInvertScroll.js'),
                loadScript(this, resourceQuestion + '/public/js/jquery-ui.js'),
                loadScript(this, resourceQuestion + '/src/js/script.js'),
                
                loadStyle(this, resourceQuestion + '/public/css/bootstrap.min.css'),
                loadStyle(this, resourceQuestion + '/public/css/hover.css'),
                loadStyle(this, resourceQuestion + '/src/css/styles.css'),
                
            ])
            .then(() => {
                // console.log('Success load all script and CSS');
                // this.initializeScript();
            })
            .catch(error => {
                console.log('Failed load script : ' + error);
            });
        })
        .catch(error => {
            console.log('Failed load script : ' + error);
        });
            
    }

    constructor(){
        super();
        this.loadingDisplay = 'showLoading';

        this.getImageResource();
        const sPageURL = decodeURIComponent(window.location.search.substring(1));
        const parameter = this.getparameter(sPageURL);
        
        this.sessionPage = sessionStorage.getItem("1");

        if(parameter.has('Id')){
            
            this.getID = parameter.get('Id');
            this.mapGroup(this.getID);
            this.getProductDetail(this.getID, window.location.search);
            // this.callOSC(parameter.get('Id'),false);
        }
    }

    getImageResource(){

        getImage()
        .then(result => {
            this.imageResource = result;
            this.imgExit = result.cancel;
            this.imgExitInvert = result.cancelInvert;
            this.bgDisplay = 'bg show';
        })
        .catch(error => {
            console.log('catch get Image');
            console.log(error);
        });
    }

    getProductDetail(formId, sUrlPage){

        getAvatarDetail({idForm: formId, urlDropOff: sUrlPage})
        .then(result => {
            this.b64 = result.avatarImage;
            this.phoneNumber = result.mobileNumber;
            this.phone = result.mobileNumber;
        })
        .catch(error => { 
            console.log('catch');
            console.log(error);
        });
    }

    url = '';
    //PRE-LOADING IMAGES SECTION
    preLoadImagesH(event){
        let targetThumbnailHId = event.target.dataset.srcIdThumbnailHighlight;
        let targetH = this.template.querySelector(`[data-src-id-preload-highlight="${targetThumbnailHId}"]`);
        targetH.classList.add("img-fluid","hideLoading");
        event.target.classList.remove("hideLoading");
    }

    preLoadImagesN(event){
        let targetThumbnailNId = event.target.dataset.srcIdThumbnailNormal;
        let targetN = this.template.querySelector(`[data-src-id-preload-normal="${targetThumbnailNId}"]`);
        targetN.classList.add("img-fluid","hideLoading");
        event.target.classList.remove("hideLoading");
    }
    //PRE-LOADING IMAGES SECTION

    @track timeoutFn;
    prodGroup = '';
    mapGroup(rec) {

        getMapGroup({fnaActivityId: rec})
        .then(result => {
            this.resProdAll = result.resProdNormal;
            this.isDownload = result.resIsDownload;        
            this.avatarName = result.avatarName;

            if(result.resProdPackage.length !== 0){
                this.prodGroup = result;
                this.functionGetThumbnail(result.resProdPackage, 'Package');
            }else{
                this.sectionHighlighandNormalProduct(result);
            }

            
        })
        .catch(error => {
            console.log('catch');
            console.log(error);
        });
    }

    sectionHighlighandNormalProduct(result){
        if(result.resProdHightlight.length === 0 && result.resProdNormal.length !== 0){
            // console.log('-----Highlight Product Empty------')
            this.isNormal = 'show';
            this.isHighlight = 'hide';
            this.isBtn = 'hide';
            this.isLine = 'hide';
            this.functionGetThumbnail(result.resProdNormal, 'NormalProduct');

        }else if (result.resProdNormal.length === 0 && result.resProdHightlight.length !== 0){
            // console.log('-----Normal Product Empty------')
            this.isNormal = 'hide';
            this.isHighlight = 'show';
            this.isBtn = 'hide';
            this.functionGetThumbnail(result.resProdHightlight, 'HighLightProduct');

        }else if (result.resProdNormal.length === 0 && result.resProdHightlight.length === 0){
            // console.log('-----Normal Product Empty------')
            // console.log('-----Highlight Product Empty------')
            this.isNormal = 'hide';
            this.isHighlight = 'hide';
            this.isBtn = 'hide';
            this.headerTitle = '404 Product Not Found'
            this.loadingDisplay = 'hideLoading';

            this.bShowModal1 = false;
            this.bShowModal3 = true;
            this.bShowModal2 = false;
        }else{
            // console.log('-----Product not empty------')
            this.isLine = 'show';
            this.functionGetThumbnail(result.resProdHightlight, 'HighLightProduct');
        }
    }

    functionGetThumbnail(result, type){
        getThumbnailUrlAll({prodFNA: result})
        .then(resp => {
            let temp = [];
            if(type === 'Package'){
                this.isPackage = 'sectionSlide show';
                this.lstProductPackage = temp.concat(resp);
                
                // this.sectionHighlighandNormalProduct(this.prodGroup);
                
                // console.log('package' , this.lstProductPackage);
            }else if(type === 'HighLightProduct'){
                this.lstProductHighlight = temp.concat(resp)
            }else{
                this.lstProductNormal = temp.concat(resp)
            }
            this.loadingDisplay = 'hideLoading';
            this.bShowModal1 = false;
            this.bShowModal3 = true;
            this.bShowModal2 = false;

            // START SESSION TIMEOUT
            var sessionTempHighlight = sessionStorage.getItem("1");
            // console.log('sessionTempHighlight : ',sessionTempHighlight);
            if(sessionTempHighlight !== null){
                this.timeoutFn = idleTime()
                .then(idleTimeMillisec => {

                    setTimeout(() => {  
                        createRef({fnaActId: this.getID,sessionData: sessionTempHighlight})
                        .then(resultref => {
                            // console.log('create ref complete')
                            // console.log(resultref)
                            sessionStorage.clear();
                            this.loadingDisplay = 'showLoading';
                            this.url += 'avatardetail?Id=' + this.getID;
                            this.gotoURL(this.url);
                        })
                        .catch(er => {
                            console.log('create ref catch');
                            console.log(er)
                        })
                    }, idleTimeMillisec);
                })
                .catch(err => {
                    console.log('idleTime catch');
                    console.log(err)
                })
            }
            // END SESSION TIMEOUT

        })
        .catch(errr =>{
            console.log(errr)
        })
        
    }


    @track statusNow = 'Highlight';
    @track resProdAll = [];
    @track checkBool = false;
    
    moreProduct() {
       
        if(this.isNormal === 'hide') {
            this.isNormal = '';
            this.titleBtn = 'ผลิตภัณฑ์ที่ตอบโจทย์ความต้องการ';
            let iBtnL = this.template.querySelector(`[data-id="iconBtnL"]`);
            let iBtnR = this.template.querySelector(`[data-id="iconBtnR"]`);
            iBtnL.src = this.imageResource.less;
            iBtnR.src = this.imageResource.less;
        } else {
            this.isNormal = 'hide';
            this.titleBtn = 'ผลิตภัณฑ์อื่นๆ ที่เหมาะกับคุณ';
            let iBtnL = this.template.querySelector(`[data-id="iconBtnL"]`);
            let iBtnR = this.template.querySelector(`[data-id="iconBtnR"]`);
            iBtnL.src = this.imageResource.more;
            iBtnR.src = this.imageResource.more;
            let target = this.template.querySelector(`[data-id="highlight-products"]`);
            target.scrollIntoView();
        }
        if(this.resProdAll !== null){
            if(this.checkBool === false){
                this.loadingDisplay = 'showLoading';

                getThumbnailUrlAll({prodFNA: this.resProdAll})
                .then(resp => {
                    // console.log('lstProductNormal : ',resp)
                    let tempNormal = [];
                    this.lstProductNormal = tempNormal.concat(resp)
                    this.loadingDisplay = 'hideLoading';
                    
                    // START SESSION TIMEOUT
                    var sessionTempHighlight = sessionStorage.getItem("1");
                    // console.log('sessionTempHighlight : ',sessionTempHighlight);
                    if(sessionTempHighlight !== null){
                        clearTimeout(this.timeoutFn);
                        this.timeoutFn = idleTime()
                        .then(idleTimeMillisec => {
                            setTimeout(() => {  
                                createRef({fnaActId: this.getID,sessionData: sessionTempHighlight})
                                .then(resultref => {
                                    sessionStorage.clear();
                                    this.loadingDisplay = 'showLoading';
                                    this.url += 'avatardetail?Id=' + this.getID;
                                    this.gotoURL(this.url);
                                })
                                .catch(er => {
                                    console.log('create ref catch');
                                    console.log(er)
                                })
                            }, idleTimeMillisec);
                            // timeTrackFn = timeFn;
                        })
                        .catch(err => {
                            console.log('idleTime catch');
                            console.log(err)
                        })
                    }
                    // END SESSION TIMEOUT
                  
                })
                .catch(errr =>{
                    console.log(errr)
                })
                
                this.checkBool = true;
            }
        }
    }

    @track sessionPage;

    clearStorage(){
        localStorage.removeItem("Id");
        localStorage.removeItem("pId");
        localStorage.removeItem("qId");
    }

    exitPage(){
        this.loadingDisplay = 'showLoading';
        this.clearStorage();
        var urlHome = "/fin/s/";
        this.gotoURL(urlHome);
    }

    gotoURL(urlpage){
        //window.location.assign(urlpage);
        window.location.href = urlpage;
    }   

    gotoProductDetail(event) {
        // var productId = this.getID;
        this.loadingDisplay = 'showLoading';
        var RTLId = event.currentTarget.dataset.productid;

        // var originalURL = 'Id='+this.getID+'&RTLId='+RTLId;
        // // var encryptUrl = '/fin/fnaProductDetail?' + encodeURIComponent(originalURL);
        // var encryptUrl = '/fin/fnaProductDetail?' + encodeURIComponent(originalURL);
        // console.log('encryptUrl :',encryptUrl);
        // this.gotoURL(encryptUrl);

        encryptParams({FNAId: RTLId})
        .then(response => {
            // console.log('then',response);
            var productId = response;
            var originalURL = 'Id='+this.getID+'&RTLId='+productId;
            var encryptUrl = '/fin/fnaProductDetail?' + encodeURIComponent(originalURL);
            // console.log('encryptUrl :',encryptUrl);
            this.gotoURL(encryptUrl);

        })
        .catch(error => {
            console.log('catch');
            console.log(error);
        });



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
        // console.log('myMap : ', myMap)
        return myMap;
    }

    @track bShowModal  = false;
    @track bShowModal1 = false;
    @track bShowModal2  = false;
    @track bShowModal3  = false;
    @track err = 'errorlog hideLoading';
    @track textErr = '';
    @track textRef = '';
    @track btnResetOTP = 'showBtn';

    @track errPhone = 'errorlog hideLoading';

    closeModal() {    
        if(this.phoneNumber === ''){
            this.phoneNumber = this.phone;
        }
        
        this.bShowModal = false;
        this.bShowModal1 = false;
        this.bShowModal2 = false;
        this.bShowModal3 = false;
        this.btnResetOTP = 'showBtn';
        this.errPhone = 'errorlog hideLoading';
    }

    closeModalRefresh() {
        if(this.phoneNumber === ''){
            this.phoneNumber = this.phone;
        }
        
        this.bShowModal = false;
        this.bShowModal1 = false;
        this.bShowModal2 = false;
        this.bShowModal3 = false;
        this.btnResetOTP = 'showBtn';
        this.errPhone = 'errorlog hideLoading';
        location.reload();
    }

    handleClick() {
        this.bShowModal = true;
        this.bShowModal1 = true;
        this.bShowModal2 = false;
        this.bShowModal3 = false;
        this.err = 'errorlog hideLoading';
        this.textErr = ''; 
    }

    allowNumbersOnly(e) {

        let inputPhone = this.template.querySelector(`[data-id="phoneInput"]`);
        var code = (e.which) ? e.which : e.keyCode;
        if (code > 31 && (code < 48 || code > 57)) {
            e.preventDefault();
        }
        inputPhone.classList.remove('inputInvalid');
        this.errPhone = 'errorlog hideLoading';
    }

    next(){
        let inputPhone = this.template.querySelector(`[data-id="phoneInput"]`);
        var phoneno = /^[0]{1}[6,8,9]{1}[0-9]{8}$/;
        if(inputPhone.value.match(phoneno) && (inputPhone.value).length === 10) {
            
            fnGenerateOTP({fnaId: this.getID})
            .then(response => {
                this.textRef = response.Otp_Ref__c;
                this.bShowModal = true;
                this.bShowModal1 = false;
                this.bShowModal2 = true;
                this.bShowModal3 = false;
                this.btnResetOTP = 'showBtn';
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
        }
    }

    checkNext(event){
        var inputName = event.target.name;

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
                this.btnResetOTP = 'showBtn';
            }
            else{
                // console.log('OTP กรอกครบกำลัง validate')
                let inputValue_1 = (inputOTP_1.value).toString();
                let inputValue_2 = (inputOTP_2.value).toString();
                let inputValue_3 = (inputOTP_3.value).toString();
                let inputValue_4 = (inputOTP_4.value).toString();
                let inputValue_5 = (inputOTP_5.value).toString();
                let inputValue_6 = (inputOTP_6.value).toString();
                var inputValue = inputValue_1 + inputValue_2 + inputValue_3 + inputValue_4 + inputValue_5 + inputValue_6;
                fnVerifyOTP({fnaId: this.getID,otpCode: inputValue})
                .then(response => {
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
                            this.btnResetOTP = 'showBtn';
                            break;
                        case 2:
                            // this.textErr = 'Cannot use old OTP Code.';
                            this.textErr = 'รหัส OTP ไม่ถูกต้อง คุณอาจนำรหัสที่ถูกใช้งานไปแล้วมากรอก กรุณาตรวจสอบ SMS ใหม่ หรือ ขอรหัส OTP ใหม่';
                            this.btnResetOTP = 'showBtn';
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
                            this.btnResetOTP = 'showBtn';
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
                            this.btnResetOTP = 'showBtn';
                            break;
                        case 5:
                            // this.textErr = 'OTP Code miss match.';
                            this.textErr = 'รหัส OTP ไม่ถูกต้อง กรุณาตรวจสอบ SMS ใหม่ หรือ ขอรับรหัส OTP ใหม่';
                            this.btnResetOTP = 'showBtn';
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
                            this.btnResetOTP = 'showBtn';
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
                                this.checkExsiting();
                                this.loadingDisplay = 'showLoading';
                                this.bShowModal = true;
                                this.err = 'errorlog hideLoading';
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

    sendSMSOTP(inputPhone, otp){
        // console.log('inputPhone :' + inputPhone);
        // console.log('otp :' + otp);
        // console.log('fnaId :' + this.params);
        sendOTP({phone: inputPhone,fnaId: this.getID, otpId: otp})  
        .then(response => {
            // console.log('then', response)
            // console.log('OTP Success');

        })
        .catch(error => {
            console.log('catch');
            console.log(error);

        });

    }

    sendURL(){
        sendSMSURL({fnaId: this.getID})
        .then(response => {
            // console.log('then', response)
            // console.log('Send Url success');

            successDownload({fnaId: this.getID})
            .then(responses => {
                this.isDownload = true;
                // console.log('then', responses)
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

    @track loadOSC14 = false;
    @track loadOSC16 = false;
    @track responseBodyOSC14;
    @track responseBodyOSC16;
    isSendSMS = false;

    callOSC(fnaId,sendSms){
        // console.log('call OSC Id : ',fnaId)

       
        const promises = [
            //CALL SERVICE OSC14
            callServiceOSC14({fnaActivityId: fnaId})
            .then(result =>{
                // console.log('Call Service OSC14 Complete')
                // console.log('result OSC14 : ', result)
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
                // console.log('result OSC16 : ', result)
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
            var loadOSC14, loadOSC16, loadGetCardsBalance = false;

            loadOSC14 = res[0] !== undefined? true: false;
            loadOSC16 = res[1] !== undefined? true: false;
            loadGetCardsBalance = res[2] !== undefined? true: false;

            // console.log('sendSms : ' + sendSms);
            if(sendSms){
                // console.log('send URL');
                this.sendURL();
            }

            if(loadOSC14 || loadOSC16 || loadGetCardsBalance){
                // console.log('StampOffset');
                stampOffSet({fnaActivityId: this.getID, responseBodyOSC14: res[0], responseBodyOSC16: res[1], responseBodyGetCardsBalance: res[2]})
                .then(response => {
                    console.log(response)
                    this.mapGroup(this.getID);
                   
                    // this.loadingDisplay = 'hideLoading';
                })
                .catch(err => {
                    console.log('Failed to call Service')
                    console.log(err)
                    this.loadingDisplay = 'hideLoading';
                    this.bShowModal = true;
                    this.bShowModal1 = false;
                    this.bShowModal3 = true;
                    this.bShowModal2 = false;
                })
                                
            }else{
                this.loadingDisplay = 'hideLoading';
                this.bShowModal = true;
                this.bShowModal1 = false;
                this.bShowModal3 = true;
                this.bShowModal2 = false;
            }

        })
        



    }

    resetOTP(){
        let inputOTP_1 = this.template.querySelector(`[data-id="otpInput_1"]`);
        let inputOTP_2 = this.template.querySelector(`[data-id="otpInput_2"]`);
        let inputOTP_3 = this.template.querySelector(`[data-id="otpInput_3"]`);
        let inputOTP_4 = this.template.querySelector(`[data-id="otpInput_4"]`);
        let inputOTP_5 = this.template.querySelector(`[data-id="otpInput_5"]`);
        let inputOTP_6 = this.template.querySelector(`[data-id="otpInput_6"]`);
        let btnSubmitOTP = this.template.querySelector(`[data-id="btnSubmitOTP"]`);

        fnGenerateOTP({fnaId: this.getID})
        .then(response => {
            // console.log('then',response);
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
            this.btnResetOTP = 'showBtn';
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

    @track slideIndex = 1;
    @track leftButton = 'prevSlide hide';
    @track rightButton = 'nextSlide hide';
    @track dotSection = 'dotSection hide';

    timeOutFunction = '';
    time = 5000;

    plusSlides(event) {
        clearTimeout(this.timeOutFunction);
        var n = parseInt(event.target.dataset.value);
        console.log('plus n ' + n);
        this.slideIndex = this.slideIndex + n
        console.log('slideIndex ' + this.slideIndex);
        this.showSlides(this.slideIndex);
    }

    currentSlide(event) {
        clearTimeout(this.timeOutFunction);
        var n = parseInt(event.target.dataset.value) + 1;
        console.log('plus n ' + n);
        this.slideIndex = n;
        console.log('slideIndex ' + this.slideIndex);

        this.showSlides(this.slideIndex);
    }
    isStart = false;
    startSlide(){
        if(this.isStart === true){
            return;
        }
        this.isStart = true;
        this.sectionHighlighandNormalProduct(this.prodGroup);

        //clearTimeout(this.timeOutFunction);
        this.showSlides(this.slideIndex);
    }

    showSlides(n) {
        var i;
        var slides = this.template.querySelectorAll('.mySlides');
        var dots = this.template.querySelectorAll('.dot');
        if (n > slides.length) {this.slideIndex = 1}
        if (n < 1) {this.slideIndex = slides.length}

        // console.log('slides : ', slides);
        // console.log('dots : ', dots);
        // console.log('slides : '+ slides.length);
        // console.log('dots : '+ dots.length);
        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
        }

        for (i = 0; i < dots.length; i++) {
            dots[i].className = dots[i].className.replace(" active", "");
        }

        if(slides.length > 0){
            slides[this.slideIndex-1].style.display = "block";
            dots[this.slideIndex-1].className += " active";

            if(slides.length > 1){
                this.leftButton = 'prevSlide';
                this.rightButton = 'nextSlide';
                this.dotSection = 'dotSection show';
                this.timeOutFunction = setTimeout(() => {
                    this.nextSlide();
                }, this.time);
            }
        }
    }

    nextSlide(){
        /*auto play */
        // console.log('Auto Play');
        this.slideIndex = this.slideIndex + 1;
        // console.log('slideIndex ' + this.slideIndex);
        this.showSlides(this.slideIndex);

    }

    downloadHandle(event){

        // let targetThumbnailNId = event.target.dataset.srcIdThumbnailNormal;
        // let targetN = this.template.querySelector(`[data-src-id-preload-normal="${targetThumbnailNId}"]`);
        // targetN.classList.add("img-fluid","hideLoading");
        var isIE11 = !!window.MSInputMethodContext && !!document.documentMode;
        var notSupport = false;
        if(isIE11 || this.detectIEEdge() != false){
            notSupport = true;
        }

        if(notSupport){
            var downloadButton = this.template.querySelector(`[data-id="iconDownload"]`);
            console.log('downloadButton.contains' + downloadButton.classList.contains("showDownload"));
            if(downloadButton.classList.contains("showDownload")){
                downloadButton.classList.remove("showDownload");
            }else{
                downloadButton.classList.add("showDownload");
            }
        }
        

    }

    detectIEEdge() {
        var ua = window.navigator.userAgent;

        var msie = ua.indexOf('MSIE ');
        if (msie > 0) {
            // IE 10 or older => return version number
            return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
        }

        var trident = ua.indexOf('Trident/');
        if (trident > 0) {
            // IE 11 => return version number
            var rv = ua.indexOf('rv:');
            return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
        }

        var edge = ua.indexOf('Edge/');
        if (edge > 0) {
        // Edge => return version number
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
        }

        // other browser
        return false;
    }   

}