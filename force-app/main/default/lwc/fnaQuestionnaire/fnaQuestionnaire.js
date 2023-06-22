/* eslint-disable no-console */
/* eslint-disable vars-on-top */
/* eslint-disable no-else-return */
import { LightningElement, track, api} from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import getquestion from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.getQuestion';
import getImage from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.getImage';  
import savequestion from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.saveQuestionInformation'; 
import saveBranchId from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.saveBranchId'; 
import previousQuestion from '@salesforce/apex/fnaQuestionnaireTemplateCtrl.previousQuestionInformation';
import resourceQuestion from '@salesforce/resourceUrl/FNA_Resource';
import fnaJquery from '@salesforce/resourceUrl/fnaJquery';

import encryptParams from '@salesforce/apex/fnaUtility.encryptParams';
import decryptParams from '@salesforce/apex/fnaUtility.decryptParams';
export default class FnaQuestionnaire extends LightningElement {
    buttonClicked = true ;
    @track move = 'middle scroll';

    @track temp = {};
    @track choice = [];
    @track questionTemplate = [];
    @track err = 'error hideLoading';
    // For multiple choice
    @track answer = '';
    @track loadingDisplay = 'hideLoading'; 
    @track loadingQuestion = 'contentQuestion hideLoading'
    @track ageProperty;
    @track ageValue = 0;
    @track iconName = 'utility:check';
    @track imageResource = ''; 
    

    @api progress;
    @api progressBG;
    @api progressBGs;

    /// FROM QR Code
    param_cusId = '';
    param_branchCode = '';
    param_branchAgentId = '';

    scrollInitialized = false;
    renderedCallback() {
        console.log('renderedCallback');
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
                loadStyle(this, resourceQuestion + '/src/css/styles.css')
            ])
            .then(() => {
                // console.log('Success load all script and CSS');
                this.initializeScript();
            })
            .catch(error => {
                console.log('Failed load script : ' + error);
            });
        })
        .catch(error => {
            console.log('Failed load script : ' + error);
        });
            
    }

    constructor() {
        super();
        this.temp.question = {};
        this.loadingDisplay = 'showLoading';
        this.localBranchCode = localStorage.getItem("branchCode") == null? '': localStorage.getItem("branchCode");
        // console.log('this.localBranchCode: ' + this.localBranchCode);
        this.getQuestionTemplate();
        this.getImageResource();
    }

    saveBranch(formId) {
        // console.log('return idForm>>>>>>>>>>>>>>> ',formId);          
        saveBranchId({idForm: formId,branchId: this.localBranchCode})
        .then(response => {
            // console.log('then');
            // console.log('save branch return : ',response);          
        })
        .catch(error => {
            // console.log('catch');
            console.log('catch : ' + error);
        });
    }

    handleEventChangeYear(event) {
        //event.preventDefault();
        this.answer = event.detail;
        // console.log("Main Year : " + this.answer);
    }

    getImageResource(){

        getImage()
        .then(result => {
            this.imageResource = result;
            this.imgExit = result.cancel;
            this.imgExitInvert = result.cancelInvert;
            this.imgBack = result.back;
            this.imgBackInvert = result.backInvert;   
        })
        .catch(error => {
            // console.log('catch get Image');
            console.log('catch : ' + error);
        });

    }

    getQuestionTemplate(){
        var formID = localStorage.getItem("Id") == null? '': localStorage.getItem("Id");
        var questionID = localStorage.getItem("qId") == null? '': localStorage.getItem("qId");
        var preQuestionID = localStorage.getItem("pId") == null? '': localStorage.getItem("pId");

        if(preQuestionID !== ''){
            decryptParams({FNAId: preQuestionID})
            .then(response => {
                // console.log('decryptParams :', response);
                preQuestionID = response;

                // console.log('localStorageformID ' + formID);
                // console.log('localStoragequestionID ' + questionID);
                // console.log('localStoragepreQuestionID ' + preQuestionID);
                getquestion({thisQuestion: questionID, thisForm: formID, preQuestion : preQuestionID })
                .then(result => {
                    // console.log('DATA FOR RESULT :',result)

                    this.temp = result;
                    this.questionTemplate = result.template;
                    this.choice = result.choiceObj;
                    this.answer = '';
                    this.err = 'error hideLoading';

                    // console.log('then');
                    // console.log('this.temp : ', this.temp)
                    // console.log('this.questionTemplate : ', this.questionTemplate);
                    // console.log('this.choice ' , this.choice);

                    // animation
                    // console.log('this.temp.progress= ' + this.temp.progress);
                    this.progress = 'margin-left:'+this.temp.progress+'%;display: block;';
                    // console.log('this.progress= ' + this.progress);
                    this.progressBG = 'margin-left: -'+this.temp.progress+'%;';
                    this.progressBGs = 'margin-left: -'+this.temp.progress+'%;';
                
                    if(this.progressBGs === 'margin-left: -55%;' ){

                        this.progressBGs = 'margin-left: -130%;';

                    }

                    if(this.questionTemplate.template5 === true){
                        this.progressBGs = 'margin-left: -150%;';
                    }
                    //-----------------------retrive data when click back-----------------------

                    //for template 6 scroll for choose date of birth
                    if(this.questionTemplate.template6 === true){
                        if(this.temp.answer>0){
                            this.ageValue = this.temp.answer;
                        }
                        this.answer = this.ageValue;
                    }

                    //for template 1 name of avatar
                    if(this.questionTemplate.template1 === true){
                        this.answer = this.temp.answer
                    }

                    var splitText = [];
                    //
                    if(this.questionTemplate.template5 === true && this.temp.answer !== undefined){
                        this.answer = this.temp.answer;
                        splitText = this.temp.answer.split(";");
                    }else{
                        splitText.push(this.temp.answer);
                    }

                    this.answer = this.answer === undefined ? '' : this.answer;

                    //for template 3 choose Male or Female
                    // console.log('splitText ' + splitText);
                    for(var q=0; q < this.choice.length; q++){
                        if(splitText.includes(this.choice[q].choice)){
                            // console.log('choice Active ' + this.choice[q].choice);
                            if(this.questionTemplate.template5 === true){
                                this.choice[q].btnClass = 'btn btn-primary hvr-grow active';
                            }else{
                                this.choice[q].btnClass = 'hvr-grow active';
                            }
                            
                        }else{
                            // console.log('choice notActive ' + this.choice[q].choice);
                            if(this.questionTemplate.template5 === true){
                                this.choice[q].btnClass = 'btn btn-primary hvr-grow';
                            }else{
                                this.choice[q].btnClass  = 'hvr-grow';
                            }
                        }
                    }
                    // console.log('this.temp.answer='+this.temp.answer);
                    this.loadingQuestion = 'contentQuestion showLoading';
                    
                    //// fixed focus
                    var fix = this.template.querySelectorAll('a');
                    for (var k = 0; k < fix.length; k++) {
                        fix[k].blur();
                    }
                    this.loadingDisplay = 'hideLoading';
                    this.scrollToTopFn();
                })
                .catch(error => {
                    // console.log('catch');
                    console.log('catch : ' + error);
                });
            })
            .catch(err => {
                console.log('catch : ' + err);
            })
        }
        else{
            getquestion({thisQuestion: questionID, thisForm: formID, preQuestion : preQuestionID })
            .then(result => {
                // console.log('DATA FOR RESULT :',result)  

                this.temp = result;
                this.questionTemplate = result.template;
                this.choice = result.choiceObj;
                this.answer = '';
                this.err = 'error hideLoading';

                // animation
                this.progress = 'margin-left:'+this.temp.progress+'%;display: block;';
                this.progressBG = 'margin-left: -'+this.temp.progress+'%;';
                this.progressBGs = 'margin-left: -'+this.temp.progress+'%;';
            
                if(this.progressBGs === 'margin-left: -55%;' ){

                    this.progressBGs = 'margin-left: -130%;';

                }

                if(this.questionTemplate.template5 === true){
                    this.progressBGs = 'margin-left: -150%;';
                }
                //-----------------------retrive data when click back-----------------------

                //for template 6 scroll for choose date of birth
                if(this.questionTemplate.template6 === true){
                    if(this.temp.answer>0){
                        this.ageValue = this.temp.answer;
                    }
                    this.answer = this.ageValue;
                }

                //for template 1 name of avatar
                if(this.questionTemplate.template1 === true){
                    this.answer = this.temp.answer
                }

                var splitText = [];
                //
                if(this.questionTemplate.template5 === true && this.temp.answer !== undefined){
                    this.answer = this.temp.answer;
                    splitText = this.temp.answer.split(";");
                }else{
                    splitText.push(this.temp.answer);
                }

                this.answer = this.answer === undefined ? '' : this.answer;

                //for template 3 choose Male or Female
                // console.log('splitText ' + splitText);
                for(var q=0; q < this.choice.length; q++){
                    if(splitText.includes(this.choice[q].choice)){
                        // console.log('choice Active ' + this.choice[q].choice);
                        if(this.questionTemplate.template5 === true){
                            this.choice[q].btnClass = 'btn btn-primary hvr-grow active';
                        }else{
                            this.choice[q].btnClass = 'hvr-grow active';
                        }
                        
                    }else{
                        // console.log('choice notActive ' + this.choice[q].choice);
                        if(this.questionTemplate.template5 === true){
                            this.choice[q].btnClass = 'btn btn-primary hvr-grow';
                        }else{
                            this.choice[q].btnClass  = 'hvr-grow';
                        }
                    }
                }
                // console.log('this.temp.answer='+this.temp.answer);
                this.loadingQuestion = 'contentQuestion showLoading';
                
                //// fixed focus
                var fix = this.template.querySelectorAll('a');
                // console.log('fix ' , fix);
                for (var k = 0; k < fix.length; k++) {
                    fix[k].blur();
                }

                this.loadingDisplay = 'hideLoading';
                
            })
            .catch(error => {
                // console.log('catch');
                console.log('catch : ' + error);
            });
        }

        setTimeout(() => { 
            this.move = 'middle scroll movePosition';    

        }, 3000);
    }

    @track saveBranchBool = true;

    nextPage(event){
        this.loadingDisplay = 'showLoading';

        var ansQuestion = event.currentTarget.dataset.value;
        // console.log('Event ' , event.currentTarget);
        // console.log('Event ' + ansQuestion);

        // this.template_3 = event.target.value
        
        if(ansQuestion === 'multipleChoice' || ansQuestion === 'singleValue' ){
            // console.log('This answer ' + this.answer);
            ansQuestion = this.answer;
            
            if(this.questionTemplate.template1 === true){
                var inputAvatarname = this.template.querySelector('input.avatarName');
                // console.log('inputAvatarname ' , inputAvatarname);
                if(ansQuestion === ''|| ansQuestion === undefined){
                    
                    inputAvatarname.classList.add('inputInvalid'); 
                }else{
                    
                    inputAvatarname.classList.remove('inputInvalid'); 
                }
            }

            if(ansQuestion === ''|| ansQuestion === undefined){
                // console.log('Invalid message');
                this.err = 'error';
                this.loadingQuestion = 'contentQuestion showLoading';
                this.loadingDisplay = 'hideLoading';
                return;
            }
            else {
                this.err = 'error hideLoading';
                // console.log('Valid message');
            }
        }else{
            for(var q=0; q < this.choice.length; q++){
                if(this.choice[q].choice === ansQuestion){
                    this.choice[q].btnClass = 'hvr-grow active';
                }else{
                    this.choice[q].btnClass  = 'hvr-grow';
                }
            }
        }

        // console.log('This ansQuestion ' + ansQuestion);
        // console.log('This temp ', this.temp);

        savequestion({thisQuestion: this.temp, answerQuestion: ansQuestion})
        .then(result => {
            // console.log('this.saveBranchBool : >><><><>>', this.saveBranchBool)
            // console.log('DATA IS HERE :',result)
            if(result.success){
                var url = "/fin/s/";
                // console.log('response' , result.nextPage);
                localStorage.setItem("Id", result.idForm);
                if(this.saveBranchBool === true){
                    this.saveBranch(result.idForm);
                    this.saveBranchBool = false;
                }
                localStorage.setItem("qId", result.nextPage);
                encryptParams({FNAId: this.temp.question.Id})
                .then(response=>{
                    // console.log('pId :',response)
                    localStorage.setItem("pId", response);

                    if(result.nextPage !== "" && result.nextPage !== undefined){
                        this.getQuestionTemplate();
                    }else{
                        this.clearStorage();
                        // console.log(result.idForm)
                        var originalURL = 'Id=' + result.idForm;
                        url += 'avatardetail?' + encodeURIComponent(originalURL);
                        // console.log('url :', url)
                        this.gotoURL(url);
                        // encryptParams({FNAId: result.idForm})
                        // .then(results=>{
                        //     var originalURL = 'Id=' + results;
                        //     url += 'avatardetail?' + encodeURIComponent(originalURL);
                        //     console.log('url :', url)
                        //     this.gotoURL(url);
                        // })
                        // .catch(error => {
                        //     console.log('catch');
                        //     console.log(error);
                        // });
                    }
                })
                .catch(err=>{
                    console.log('catch : ' + err);
                })
            }
            // console.log('then');
            // console.log(result);
        })
        .catch(error => {
            // console.log('catch');
            console.log('catch : ' + error);
        });
    }

    backPage(){
        this.loadingDisplay = 'showLoading';
        var preQuestionID = localStorage.getItem("pId") == null? '': localStorage.getItem("pId");

        if(preQuestionID !== ''){
            decryptParams({FNAId: preQuestionID})
            .then(response => {
                // console.log('decryptParams :',response);
                preQuestionID = response;

                // console.log('this.temp.idForm :',this.temp.idForm);
                previousQuestion({idForm : this.temp.idForm, idQuestion : this.temp.question.Id, preQusetion: preQuestionID})
                .then(result => {
                    // console.log('then')
                    // console.log(result);
                    // console.log('-------')
                    if(result !== '' && this.temp.idForm !== undefined){
                        // console.log('then if');
                        localStorage.setItem("Id", this.temp.idForm);
                        localStorage.setItem("qId", result);
                        localStorage.removeItem("pId");
                        this.getQuestionTemplate();
                    }
                    else{
                        // console.log('then else')
                        this.clearStorage();
                        var urlHome = "/fin/s/";
                        this.gotoURL(urlHome);
                    }
                })
                .catch(error => {
                    // console.log('catch');
                    console.log('catch : ' + error);
                    var urlHome = "/fin/s/";
                    this.gotoURL(urlHome);
                })
            })
            .catch(err => {
                console.log('catch : ' + err);
            })
        }
        else{
            previousQuestion({idForm : this.temp.idForm, idQuestion : this.temp.question.Id, preQusetion: preQuestionID})
            .then(result => {
                // console.log('then')
                // console.log(result);
                // console.log('-------')
                if(result !== '' && this.temp.idForm !== undefined){
                    // console.log('then if');
                    localStorage.setItem("Id", this.temp.idForm);
                    localStorage.setItem("qId", result);
                    localStorage.removeItem("pId");
                    this.getQuestionTemplate();
                }
                else{
                    // console.log('then else')
                    this.clearStorage();
                    var urlHome = "/fin/s/";
                    this.gotoURL(urlHome);
                }
            })
            .catch(error => {
                // console.log('catch');
                console.log('catch : ' + error);
                var urlHome = "/fin/s/";
                this.gotoURL(urlHome);
            })
        }
    }

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
        window.location.href = urlpage;
    }

    @track imgExit = '';
    @track imgExitInvert = '';
    ImageOverExit(){
        let imgCancel = this.template.querySelector(`[data-id="imgCancel"]`);
        imgCancel.src = this.imgExitInvert;
    }
    ImageUnOverExit(){
        let imgCancel = this.template.querySelector(`[data-id="imgCancel"]`);
        imgCancel.src = this.imgExit;
    }

    @track imgBack = '';
    @track imgBackInvert = '';
    ImageOverBack(){

        if( ((navigator.userAgent.match(/Android/i)) && window.screen.availWidth > 500) // no Android and width > 500
        && !(navigator.userAgent.match(/webOS/i))
        && !(navigator.userAgent.match(/iPhone/i))
        && (navigator.userAgent.match(/iPad/i))
        && !(navigator.userAgent.match(/iPod/i))
        && !(navigator.userAgent.match(/BlackBerry/i))
        && !(navigator.userAgent.match(/Windows Phone/i))
        ){
            let imgCancel = this.template.querySelector(`[data-id="imgBack"]`);
            imgCancel.src = this.imgBackInvert;

            // console.log('H :',window.screen.availHeight)
            // console.log('W :',window.screen.availWidth)
        }

    }
    ImageUnOverBack(){

        if( ((navigator.userAgent.match(/Android/i)) && window.screen.availWidth > 500)
        && !(navigator.userAgent.match(/webOS/i))
        && !(navigator.userAgent.match(/iPhone/i))
        && (navigator.userAgent.match(/iPad/i))
        && !(navigator.userAgent.match(/iPod/i))
        && !(navigator.userAgent.match(/BlackBerry/i))
        && !(navigator.userAgent.match(/Windows Phone/i))
        ){
            let imgCancel = this.template.querySelector(`[data-id="imgBack"]`);
            imgCancel.src = this.imgBack;

            // console.log('H :',window.screen.availHeight)
            // console.log('W :',window.screen.availWidth)
        }

    }

    chooseMuti(event){
        // console.log(event)
    }

    addAnswer(event){

        var checkValue = event.currentTarget.dataset.value;
        // console.log('checkValue' + checkValue);
        // console.log('Before Answer ' + this.answer);
        if(this.answer.search(checkValue) !== -1){
            // console.log('-1');
            this.answer = this.answer.replace(checkValue + ';', '');
        }else{
            this.answer += checkValue + ';';
        }
        // console.log('After Answer ' + this.answer);

        // active button when click
        const evt = event.currentTarget;
        if(evt.classList.contains('active') === true){
            evt.classList.remove('active');
        }else{
            evt.classList.add('active');  
        }
      
    }
    
    handleChange(event){
        // console.log('Value : ' + event.target.value);
        this.answer = event.target.value;
        event.target.classList.remove('inputInvalid');
        this.err = 'error hideLoading';
    }

    @track classInput = 'name pb-question';
    @track headerInput = 'display-4';
    @track imgInputAvatarName = 'male';
    // @track testDevice = /AirWatch/.test(navigator.userAgent);

    handleCheckFocus(event){
        // console.log('And :', /Android/.test(navigator.userAgent))
        // console.log('what : ',navigator.userAgent)

        if (/Android/.test(navigator.userAgent) || /AirWatch/.test(navigator.userAgent)) {
            // console.log('Value : ' , event.target.style);
            this.classInput = 'name fixedTabletFocus pb-question';
            this.headerInput = 'display-4 hideOpacityFocus';
            this.imgInputAvatarName = 'male imgAvatarFocus';
            // console.log('-----end change class handleCheckFocus-----');
        }
    }
    handleCheckUnFocus(event){
        // console.log('And :', /Android/.test(navigator.userAgent))
        // console.log('what : ',navigator.userAgent)

        if (/Android/.test(navigator.userAgent) || /AirWatch/.test(navigator.userAgent)) {
            // console.log('Value : ' , event.target.style);
            this.classInput = 'name fixedTabletUnFocus pb-question';
            this.headerInput = 'display-4 hideOpacityUnFocus';
            this.imgInputAvatarName = 'male';
            // console.log('-----end change class handleCheckUnFocus-----');
        }
    }

    scrollToTopFn(){
        let target = this.template.querySelector(`[data-id="headerTop"]`);
        target.scrollIntoView();
    }

    initializeScript(){

        // console.log('Start Jqeury !')
 
        // this.template.querySelector('input[name="inputName"]').click(function() {
        //     console.log('dwakdniowad')
        // });

        // if (/Android/.test(navigator.userAgent)) {
        //     $(".avatarName").off('focus').on('focus', function () {
        //         $('.name').css({
        //             transition: 'margin-top .3s',
        //             marginTop: -20
        //         });
        //         console.log('focus')
        //     }).off('blur').on('blur', function () {
        //         $('.name').css({
        //             marginTop: 0
        //         });
        //         console.log('blur')
        //     });
        // }
        
        $('a#start').removeClass('-hide');
        
        var height = $(window).height();
        var width = $(window).width();
        // console.log('this browser height : ',height)
        // console.log('this browser width : ',width);

        if(height >= 650) { 
            $('.animation img').css('display', 'block');
            $('.front').css('display', 'block');
            $('.horizon').css('display', 'block');
        }else { 
            $('.animation img',).css('display', 'none');
            $('.front').css('display', 'none');
            $('.horizon').css('display', 'none');
        }
        
        // if(height <= 480) { 
        //     this.template.querySelector('main').classList.add('hide');
        //     this.template.querySelector('.topbar').classList.add('hide');
        //     this.template.querySelector('.notSupport').classList.remove('hide');
        // }
        
        var $fab = $(".fab");
        var opacity = $fab.css("opacity");
        var scrollStopped;
    
        var fadeInCallback = function () {
            if (typeof scrollStopped != 'undefined') {
                clearInterval(scrollStopped);
            }
    
            scrollStopped = setTimeout(function () {
                $fab.animate({ opacity: 1 }, "fast");
            }, 100);
        }
    
        $(window).scroll(function () {
            if (!$fab.is(":animated") && opacity == 1) {
                $fab.animate({ opacity: 0 }, "fast", fadeInCallback);
            } else {
                fadeInCallback.call(this);
            }
        });

        jQuery(document).ready(function(){
            jQuery('input, button, a, textarea, span').focus(function () {
              var footerHeight = 120; //footerHeight = footer height + element height + buffer
              var element = jQuery(this);
              if (element.offset().top - (jQuery(window).scrollTop()) > 
                   (jQuery(window).height() - footerHeight)) {
                  jQuery('html, body').animate({
                      scrollTop: element.offset().top - (jQuery(window).height() - footerHeight)
                  }, 500);
               }
            });
          });
    }

}