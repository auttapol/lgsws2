import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import {
    NavigationMixin
} from 'lightning/navigation';

//label
import errorResponse from '@salesforce/label/c.ERR001';
import errorInternal from '@salesforce/label/c.ERR002';
import ERR001_ProductHolding from '@salesforce/label/c.ERR001_ProductHolding';
import Error_Persists_Contact from '@salesforce/label/c.Error_Persists_Contact';
import Product_Holding_ReRequest_v3 from '@salesforce/label/c.Product_Holding_ReRequest_v3';
import Product_Holding from '@salesforce/label/c.View_All';
import NoAuthorizeMSG from '@salesforce/label/c.Data_Condition_NotAuthorizedMsg';
import infoError from '@salesforce/label/c.INT_Investment_Incomplete_Info';
import Refresh from '@salesforce/label/c.Product_Holding_ReRequest';
import depositMSG from '@salesforce/label/c.Deposit_Product_Details';
import creditCardMSG from '@salesforce/label/c.Credit_Card_RDC_Product_Details';
import loanMSG from '@salesforce/label/c.Loan_Product_Details';
import baMSG from '@salesforce/label/c.Bancassurance_Product_Details';
import investmentMSG from '@salesforce/label/c.Investment_Product_Details';
import autoloanMSG from '@salesforce/label/c.Auto_loan_HP';
import HIRE_PURCHASE from '@salesforce/label/c.HIRE_PURCHASE';

//apex
import getProductHttp from '@salesforce/apex/RTL_ProductHoldingsLightningUtil.getProductHttp';
import getProductSCSCreditCard from '@salesforce/apex/RTL_ProductHoldingsLightningUtil.getProductSCSCreditCard';
import getCustomer from '@salesforce/apex/RetailCSVCustomerChartController.fetchAccount';
import getMdtProductCode from '@salesforce/apex/RTL_ProductHoldingsLightningUtil.getRedProductcode';
import getProductNameFromRTLProductCode from '@salesforce/apex/RetailCSVCustomerChartController.getProduct2NameFromRTLProductCODE';
// Retail HP
import getAppConfigMdtByKey from '@salesforce/apex/CommercialAutoLoanController.getAppConfigMdtByKey';
import getALDXWFMdt from '@salesforce/apex/CommercialAutoLoanController.getALDXWFMdtAll';
import getProductAutoLoan from '@salesforce/apexContinuation/CommercialAutoLoanController.getProduct';
import {
    getValueReference
} from 'c/methodUtils';
//data partition 
import userId from '@salesforce/user/Id';
import getProfileverifyFieldSecurityName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity'; 
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import { parseObj } from 'c/methodUtils';

import NUMBER_OF_RETRY_TIME from '@salesforce/label/c.Number_Of_Retry_Times';
import RETRY_SETTIMEOUT from '@salesforce/label/c.Retry_SetTimeOut';

const account_field_section = {
    'Outstanding' : 'RtlCust:Customer Product Holding (Medium)',
    'NumberOfProduct_Account' : 'RtlCust:Customer Product Holding (Low)',
    'ProductSubGroup' : 'RtlCust:Customer Product Holding (Low)',
    'Remark' : 'RtlCust:Customer Product Holding (Low)',
}

const dataPartitionField = ['Outstanding', 'NumberOfProduct_Account', 'ProductSubGroup', 'Remark'];


export default class RetailCSVProductHolding extends NavigationMixin(LightningElement) {
    @track DebugMSG;
    userId = userId;
    @api userAgent = 'Desktop';
    isInitialized = false;
    @api recordId;
    @track OSC01;
    OSC02 = [];
    OSC03 = [];
    SCSCredit = [];
    OSC04 = [];
    AutoLoan = [];
    OSC05 = [];
    OSC06 = [];
    // @track chartDataTotalSummary; // [0]: Deposit,Investment,BA [1]: CC,Loan
    // @track chartDataOutstandingSummary; //Deposit,Investment,BA,CC,Loan,Other 
    // @track chartDataAccountAmount;
    // @track chartDataProductAmount;
    // @track isEndService = false;
    @track refreshString = {
        start : '',
        here : '',
        end : ''
    };

    @track isEnd01 = false;
    @track isEndDeposit = false;
    @track isEndCreditCard = false;
    @track isEndLoan = false;
    @track isEndAutoLoan = false;
    @track isEndBancassurance = false;
    @track isEndInvestment = false;
    @track isCalRender01 = false;
    @track isCalRenderDeposit = false;
    @track isCalRenderCreditCard = false;
    @track isCalRenderLoan = false;
    @track isCalRenderAutoLoan = false;
    @track isCalRenderBancassurance = false;
    @track isCalRenderInvestment = false;
    @track isCalRenders = false;
    @track error01 = false;
    @track isErrorInternal = false;
    @track isTimeOut = false;
    @track isErrorService = false;
    @track isShowError = false;
    @track errorMSG = '';
    @track isNoPermission = false;
    @track isHaveCustomer_ID = true;
    @track isEndQueryPermission = false;
    @track isIPad = false;
    @track isTablet = false;
    @track isHaveRecord = true;
    @track isNeedCallService = false;
    @track isShowNoAccess = false;
    @track osc06MaxProductName = 0;
    customer;
    tmbCustId;

    @track productHoldingURL;

    label = {
        Product_Holding: Product_Holding,
        errorResponse: errorResponse,
        errorInternal: errorInternal,
        noPermission: NoAuthorizeMSG,
        Refresh: Refresh,
        infoError: infoError,
        depositMSG: depositMSG,
        creditCardMSG: creditCardMSG,
        loanMSG: loanMSG,
        autoloanMSG: autoloanMSG,
        baMSG: baMSG,
        investmentMSG: investmentMSG,
        ERR001_ProductHolding: ERR001_ProductHolding,
        Error_Persists_Contact: Error_Persists_Contact,
        Product_Holding_ReRequest_v3: Product_Holding_ReRequest_v3,
        HIRE_PURCHASE: HIRE_PURCHASE,
    }

    //data partition
    profileName;
    @track dataPartition = {
        'Outstanding': false,
        'NumberOfProduct_Account': false,
        'ProductSubGroup': false, 
        'Remark': false
    };
    get partition() {
        return this.dataPartition;
    }

    @track productHoldingDetail = {
        Deposit: this.objProductDetail(),
        Investment: this.objProductDetail(),
        BA: this.objProductDetail(),
        CC_PersonalLoan: this.objProductDetail(),
        SecuredLoan: this.objProductDetail(),
        AutoLoan: this.objProductDetail(),
        Other: this.objProductDetail(),
    }
    @track errorMessageControl = this.objectErrorMessageControl();
    @track retryService = this.retryServiceFlag(true);
    get productDetail() {
        return this.productHoldingDetail;
    }
    //test test
    @track navigatorUserAgent = '';

    connectedCallback() {
        // this.label.Refresh = 'Request Timeout. ' + this.label.Refresh.replace(
        //     '<a class="alert-link" href="javascript:location.reload();"><u>Here</u></a>'
        //     , '<a class="alert-link" href="javascript:console.log(\'something\');"><u>Here</u></a>');
        // if(this.userAgent.includes('iPad') || this.userAgent.includes('IPAD')) {
        //     this.isIPadOrTablet = true;
        // }
        
        let splitRefresh = this.label.Refresh.split('<a ', 2);
        this.refreshString.start = 'Request timeout. '+ splitRefresh[0];
        let splitEnd = splitRefresh[1].split('/a>', 2);
        this.refreshString.end = splitEnd[1];
        let splitHere = this.label.Refresh.split('<u>', 2);
        // console.log(splitHere);
        splitHere = splitHere[1].split('</u>', 2);
        this.refreshString.here = splitHere[0];
        // console.log('label', this.refreshString);
        this.initialize();
    }

    initialize = async () => {
        this.navigatorUserAgent = navigator.userAgent;
        // console.log('navigator', navigator);
        if (this.navigatorUserAgent.includes('android') || this.navigatorUserAgent.includes('Android')) {
            this.isTablet = true;
        }
        if (this.navigatorUserAgent.includes('iPad') || this.navigatorUserAgent.includes('ipad') || this.navigatorUserAgent.includes('iPhone') || this.navigatorUserAgent.includes('iphone')) {
            this.isIPad = true;
        }
        this.chartDataOutstandingSummary = [0, 0, 0, 0, 0, 0];
        this.chartDataAccountAmount = [0, 0, 0, 0, 0, 0];
        this.chartDataProductAmount = [0, 0, 0, 0, 0, 0];
        this.chartDataTotalSummary = [0, 0];
        // console.log('ProductHolding Detail', this.parseObj(this.productHoldingDetail));
        // console.log('ProductHolding Detail', this.productHoldingDetail);
        // console.log()
        this.customer = await getCustomer({
            recordId: this.recordId
        });

        /*
            Test run promise all
        */
        // this.runCallout();

        // console.log(this.customer);

        this.profileName = await getProfileName({
            userId: userId
        });
        this.lstMDT = await getMdtProductCode({}) ;
        // console.log('lstMDT!!! ');
        // console.dir(this.lstMDT);
    //     .then((result) => {
    //         console.log('getMdtProductCode');
    //        console.log(result);
    //        lstmdt=result;
       
    //    console.log('lstmdt:'  + lstmdt);
    //    console.dir(lstmdt);
        // });
        let getFieldPartitionCount = 0;
        // console.log('Call getProfileverifyFieldSecurityName ');
        
        Object.keys(account_field_section).forEach((e, i) => {
            getProfileverifyFieldSecurityName({
                section: account_field_section[e],
                userProfile: this.profileName,
                accountId: this.recordId
            })
            .then(result => {
                // console.log(e, result);
                this.dataPartition[e] = result;
                // console.log('Partition Count : '+i);
                if (getFieldPartitionCount ==  3) {
                    // console.log('Partition',this.parseObj(this.dataPartition));
                    // console.log('Partition Reactive',this.dataPartition);
                    // console.log('Partition NumberOfProduct_Account',this.dataPartition['NumberOfProduct_Account']);
                    // console.log('Partition Outstanding',this.dataPartition['Outstanding']);
                    this.isEndQueryPermission = true;
                    if (this.dataPartition['Outstanding'] === false || this.dataPartition['NumberOfProduct_Account'] === false) {
                        this.isShowNoAccess = true;
                        this.errorMessageControl.isShowNoAccess = true;
                    } else {
                        this.isShowNoAccess = false;
                        this.errorMessageControl.isShowNoAccess = false;
                    }
                    if (this.dataPartition['Outstanding'] === false && this.dataPartition['NumberOfProduct_Account'] === false) {
                        this.isNoPermission = true;
                        this.errorMessageControl.noPermission = true;
                        // console.log('NoPermission');
                    } else if (this.dataPartition['Outstanding'] === true|| this.dataPartition['NumberOfProduct_Account'] === true){
                        this.isNeedCallService = true;
                        this.isNoPermission = false;
                        this.errorMessageControl.noPermission = false;
                        // console.log('CallService');
                        this.callServices(0);
                    }
                    if(this.isNoPermission == false){
                        const ans = getALDXWFMdt({});
                        this._ALDXWFMdt = ans ? ans : {};
                        // console.log(this._ALDXWFMdt);
                    }
                }
                getFieldPartitionCount += 1;
            })
            .catch(error => {
                console.error('Get data partition error: ', error)
            })
        })
        
    }

    async callServices(round) {
        // console.log('Thes callservice isNoPermission',this.isNoPermission);
        if (this.isNoPermission == false) {
            // console.log('Not Working');
        if (this.retryService.OSC01) {
            this.isEnd01 = false;
            this.isCalRender01 = false;
            this.errorMessageControl.timeout.OSC01 = false
            this.errorMessageControl.error.OSC01 = false
            this.OSC01 = []
        }

        if (this.retryService.Deposit) {
            this.isEndDeposit = false;
            this.isCalRenderDeposit = false;
            this.errorMessageControl.timeout.Deposit = false
            this.errorMessageControl.error.Deposit = false
            this.OSC02 = []
            this.clearOtherOfProduct('Deposit')
        }

        if (this.retryService.CreditCard) {
            this.isEndCreditCard = false;
            this.isCalRenderCreditCard = false;
            this.errorMessageControl.timeout.CreditCard = false
            this.errorMessageControl.error.CreditCard = false
            this.SCSCredit = []
            this.clearOtherOfProduct('CC_PersonalLoan')
        }

        if (this.retryService.Loan) {
            this.isEndLoan = false;
            this.isCalRenderLoan = false;
            this.errorMessageControl.timeout.Loan = false
            this.errorMessageControl.error.Loan = false
            this.OSC04 = []
            this.clearOtherOfProduct('SecuredLoan')
        }

        if (this.retryService.AutoLoan) {
            this.isEndAutoLoan = false;
            this.isCalRenderAutoLoan = false;
            this.errorMessageControl.timeout.AutoLoan = false
            this.errorMessageControl.error.AutoLoan = false
            this.AutoLoan = []
            this.clearOtherOfProduct('AutoLoan')
        }

        if (this.retryService.Bancassurance) {
            this.isEndBancassurance = false;
            this.isCalRenderBancassurance = false;
            this.errorMessageControl.timeout.Bancassurance = false
            this.errorMessageControl.error.Bancassurance = false
            this.OSC05 = []
            this.clearOtherOfProduct('BA')
        }

        if (this.retryService.Investment) {
            this.isEndInvestment = false;
            this.isCalRenderInvestment = false;
            this.errorMessageControl.timeout.Investment = false
            this.errorMessageControl.error.Investment = false
            this.OSC06 = []
            this.clearOtherOfProduct('Investment')
        }

        if (this.retryService.ReCalculate) {
            this.isCalRenders = false;
        }
        // this.isNeedCallService = false;
        // this.isShowNoAccess = false;
        this.error01 = false;
        this.isTimeOut = false;
        this.isShowError = false;
        this.errorMSG = '';
        this.isNoPermission = false;

        if (this.dataPartition['Outstanding'] === false || this.dataPartition['NumberOfProduct_Account'] === false) {
            this.isShowNoAccess = true;
            this.errorMessageControl.isShowNoAccess = true;
        } else {
            this.isShowNoAccess = false;
            this.errorMessageControl.isShowNoAccess = false;
        }

        if (this.customer.TMB_Customer_ID_PE__c) {
            this.tmbCustId = this.customer.TMB_Customer_ID_PE__c;
            let RMID14 = this.tmbCustId.substring(14);
            let RMID12 = this.tmbCustId.substring(12);
            let FIIdent = this.tmbCustId.substring(0, 16);
            
            
            if (this.retryService.OSC01) {
                this.retryOSC01GetCustomerAccountRequest(RMID14,RMID12,FIIdent,0);
            }
            

           
            // M8 SCS Creditcard 
            if (this.retryService.CreditCard) {
                var body = JSON.stringify({
                    'query': {
                        "rm_id": this.tmbCustId,
                        "more_records": 'N',
                        "search_keys": '',
                        "user_interface": "",
                    }
                });
                this.SCSCredit = [];
                this.clearOtherOfProduct('CC_PersonalLoan');
                this.getCreditCard(body,0);
            } else {
                this.isEndCreditCard = true;
            }
            
            if (this.retryService.Bancassurance) {
                // console.log('this.retryService.Bancassurance', this.retryService.Bancassurance);
                this.OSC05 = [];
                this.clearOtherOfProduct('BA');
                this.retryGetBancassurance(0); 
            }else{
                this.isEndBancassurance = true;
            }
            if (this.retryService.AutoLoan) {
                // TODO Callout service Auto loan here
                this.AutoLoan = [];

                this.calloutAutoloanHP(0);
            }else{
                this.isEndAutoLoan = true;
            }
            
        } else {
            this.isHaveCustomer_ID = false;
            this.retryService = this.retryServiceFlag(false);
        }
    }
    }

    async retryOSC01GetCustomerAccountRequest(RMID14,RMID12,FIIdent,round){
        try {
            this.OSC01 = await getProductHttp({
                endpoint: 'callout:OSC01',
                body: JSON.stringify({
                    'GetCustomerAccountRequest': {
                        'RMID': RMID14,
                        'FIIdent': FIIdent,
                    }
                }),
                tmbCustId: this.tmbCustId
            });

            if (this.OSC01.StatusCode == '404') {
                this.error01 = true;
                this.errorMessageControl.error.OSC01 = true;
                this.isShowError = true;
                this.isEnd01 = true;
            } else if (this.OSC01.StatusCode == '500') {
                this.isTimeOut = true;
                this.errorMessageControl.timeout.OSC01 = true;
                this.isShowError = true;
                this.isEnd01 = true;

            } 
            else if (this.OSC01.StatusCode == '401' && round < NUMBER_OF_RETRY_TIME ){
                
                round += 1;

                setTimeout(() => {
                    this.retryOSC01GetCustomerAccountRequest(RMID14,RMID12,FIIdent,round);
                }, RETRY_SETTIMEOUT);

            } 
            else if (this.OSC01.Message) {
                if (this.OSC01.Message.includes('error') || this.OSC01.Message.includes('เกิดข้อผิดพลาด')) {
                    this.error01 = true;
                    this.errorMessageControl.error.OSC01 = true;
                    this.isShowError = true;  
                    this.isEnd01 = true;

                }
                if (this.OSC01.Message.includes('No Active Product') || this.OSC01.Message.includes('ไม่มี')) {  //Not sure 
                    // this.isHaveRecord = false;
                    this.retryService.OSC01 = false;
                }
            } else if (this.OSC01.message) {
                if (this.OSC01.message.includes('timeout')) {
                    this.isTimeOut = true;
                    this.errorMessageControl.timeout.OSC01 = true;
                    this.isShowError = true;
                    this.isEnd01 = true;

                }
            }else{
                this.isEnd01 = true;
                this.retryService.OSC01 = false;
            }

            this.choiceErrorHandle();
        } catch (error) {
            console.error('OSC01 Error', error);

            if(error.status && error.status == '500' && error.body && error.body.message && error.body.message.includes('timeout')){
                this.isTimeOut = true;
                this.errorMessageControl.timeout.OSC01 = true;
            } else {
                this.error01 = true;
                this.errorMessageControl.error.OSC01 = true;
                this.isErrorInternal = true;
            }

            this.isShowError = true;
            this.isEnd01 = true;
            this.choiceErrorHandle();
        }

        if (!this.isShowError && this.isEnd01 == true ) {
            if(this.OSC01.DepositAccount && this.OSC01.DepositAccount.length > 0 && this.retryService.Deposit){
                this.OSC02 = [];
                this.clearOtherOfProduct('Deposit');
                
                this.OSC01.DepositAccount.forEach(async (each, i) => {
                    this.retryGetDepositAccountRequest(each, RMID12, 0);
                });
            }else{
                // this.errorMessageControl.error.Deposit = true;
                this.isEndDeposit = true;
            }

            if (this.OSC01.LoanAccount && this.OSC01.LoanAccount.length> 0 && this.retryService.Loan) {
                this.OSC04 = [];
                this.clearOtherOfProduct('SecuredLoan');

                this.OSC01.LoanAccount.forEach(async (each, i) => {
                    this.retryGetLoanProd(each, RMID12, 0);
                });
            }else{
                // console.log('errorMessageControl : '+this.errorMessageControl.error.Loan);
                // this.errorMessageControl.error.Loan = true;
                this.isEndLoan = true;
            }

            if (this.OSC01.InvestmentAccount && this.OSC01.InvestmentAccount.length > 0 && this.retryService.Investment) {
                this.OSC06 = [];
                this.clearOtherOfProduct('Investment');

                this.OSC01.InvestmentAccount.forEach(async (each, i) => {
                    this.retryGetInvestmentAccount(each, 0);
                });
            }else{
                // this.errorMessageControl.error.Investment = true;
                this.isEndInvestment = true;
            }
        }
    }

    async retryGetDepositAccountRequest(prod, RMID12, round){
        this.errorMessageControl.timeout.Deposit = false
        this.errorMessageControl.error.Deposit = false

        await getProductHttp({
            endpoint: 'callout:OSC02',
            body: JSON.stringify({
                'GetDepositAccountRequest': {
                    ProductType: prod.ProductType,
                    AccountType: prod.ProductCode,
                    AccountNumber: prod.AccountNumber,
                    FIIdent: prod.FIIdent,
                    RMID: RMID12,
                }
            }),
            tmbCustId: this.tmbCustId
        }).then(depositProd => {
            if(depositProd.message && depositProd.message.includes('timeout')){
                prod.message = depositProd.message;
                this.OSC02.push(depositProd);
                if (this.OSC02.length >= this.OSC01.DepositAccount.length) {
                    this.isEndDeposit = true;
                    this.refreshData();
                }
            }else if(depositProd.Status.StatusCode == '401' && round < NUMBER_OF_RETRY_TIME){
                round += 1;
                setTimeout(() => {
                    this.retryGetDepositAccountRequest(prod, RMID12, round);
                }, RETRY_SETTIMEOUT);
            }else if(depositProd.Status.StatusCode == '200'){
                depositProd.AccountNumber = prod.AccountNumber;
                depositProd.SeqGrp = prod.SeqGrp;

                prod.Product = depositProd;

                this.OSC02.push(depositProd);

                if (this.OSC02.length >= this.OSC01.DepositAccount.length) {
                    this.isEndDeposit = true;
                }

                this.isCalRenderDeposit = false;
                this.refreshData();
            }else{
                this.OSC02.push(depositProd);
                this.errorMessageControl.error.Deposit = true;
                if (this.OSC02.length >= this.OSC01.DepositAccount.length) {
                    this.isEndDeposit = true;
                }
                this.refreshData();
            }
        }).catch(error => {
            console.error('OSC02 Deposit error', error);
            this.OSC02.push({});
            if (this.OSC02.length >= this.OSC01.DepositAccount.length) {
                this.isEndDeposit = true;
                this.refreshData();
            }
            this.errorMessageControl.error.Deposit = true;
            this.warningMessageAdd(this.label.depositMSG);
        })
    }

    async retryGetLoanProd(prod, RMID12, round){
        this.errorMessageControl.timeout.Loan = false
        this.errorMessageControl.error.Loan = false
        
        await getProductHttp({
            endpoint: 'callout:OSC04',
            body: JSON.stringify({
                'GetLoanAccountRequest': {
                    ProductType: '',
                    AccountType: prod.ProductType,
                    AccountNumber: prod.AccountNumber,
                    FIIdent: prod.FIIdent,
                    RMID: RMID12,
                }
            }),
            tmbCustId: this.tmbCustId
        }).then(LoanProd => {
            if(LoanProd.message && LoanProd.message.includes('timeout')){
                this.OSC04.push(LoanProd);
                prod.message = LoanProd.message;
                if (this.OSC04.length >= this.OSC01.LoanAccount.length) {
                    this.isEndLoan = true;
                    this.refreshData();
                }
            }else if(LoanProd.Status.StatusCode == '401'  && round < NUMBER_OF_RETRY_TIME){
                round += 1;
                setTimeout(() => {
                    this.retryGetLoanProd(prod, RMID12, round);
                }, RETRY_SETTIMEOUT);

            }else{
                LoanProd.AccountNumber = prod.AccountNumber;
                LoanProd.SeqGrp = prod.SeqGrp;

                prod.Product = LoanProd;

                this.OSC04.push(LoanProd);

                if (this.OSC04.length >= this.OSC01.LoanAccount.length) {
                    this.isEndLoan = true;
                }

                this.isCalRenderLoan = false;
                this.refreshData();
            }
        }).catch(error => {
            console.error('OSC04 Loan error', error);
            this.OSC04.push({});
            if (this.OSC04.length >= this.OSC01.LoanAccount.length) {
                this.isEndLoan = true;
                this.refreshData();
            }
            this.errorMessageControl.error.Loan = true;
            this.warningMessageAdd(this.label.loanMSG);
        })
    }

    async retryGetInvestmentAccount(prod, round){

        this.errorMessageControl.timeout.Investment = false
        this.errorMessageControl.error.Investment = false
        
        await getProductHttp({
            endpoint: 'callout:OSC06_List',
            body: JSON.stringify({
                'GetInvestmentAccountRequest': {
                    UnitHolderNo: prod.UnitHoldNo
                }
            }),
            tmbCustId: this.tmbCustId
        }).then(async InvestProd => {
            if(InvestProd.message && InvestProd.message.includes('timeout')) {
                this.OSC06.push(InvestProd);
                if (this.OSC06.length >= this.OSC01.InvestmentAccount.length) {
                    this.isEndInvestment = true;
                    this.refreshData();
                }
            }else if(InvestProd.Status.StatusCode == '401' && round < NUMBER_OF_RETRY_TIME){
                round += 1;
                setTimeout(() => {
                    InvestProd = this.retryGetInvestmentAccount(prod, round);
                }, RETRY_SETTIMEOUT);
            }else{
                InvestProd.UnitHoldNo = prod.UnitHoldNo;
                this.OSC06.push(InvestProd);
                if (InvestProd.GetInvestmentAccountResponse && InvestProd.GetInvestmentAccountResponse.GetFundDetails && InvestProd.GetInvestmentAccountResponse.GetFundDetails.length > 0 ) {

                    var fundetailSize = InvestProd.GetInvestmentAccountResponse?.GetFundDetails?.length || 0;
    
                    if (fundetailSize > 0) {
                        this.osc06MaxProductName += fundetailSize;
                    }
                }else{
                    this.osc06MaxProductName += 1;
                }
                if (this.OSC06.length >= this.OSC01.InvestmentAccount.length) {
                    this.getInvesmentProductname();
                }   
            
            }
        }).catch(error => {
            console.error('OSC06 Investment error', error);
            this.OSC06.push({});
            if (this.OSC06.length >= this.OSC01.InvestmentAccount.length) {
                this.isEndInvestment = true;
                this.refreshData();
            }
            this.errorMessageControl.error.Investment = true;
            this.warningMessageAdd(this.label.investmentMSG);
        })
    }

    getInvesmentProductname(){
        var countProductName = 0;
        this.OSC06.forEach(eachInvestment => {
            if (eachInvestment.GetInvestmentAccountResponse && eachInvestment.GetInvestmentAccountResponse.GetFundDetails && eachInvestment.GetInvestmentAccountResponse.GetFundDetails.length > 0 ) {
                // var countGetName = 0;
                eachInvestment.GetInvestmentAccountResponse.GetFundDetails.forEach(async fundDetail => {
                    if (fundDetail.FundCode) {
                        fundDetail.Name = '';
                        await getProductNameFromRTLProductCode({
                            productCode : fundDetail.FundCode
                        }).then(ProductName => {
                            if (ProductName != '') {
                                fundDetail.Name = ProductName;
                                countProductName += 1;
                            }

                            if(countProductName >= this.osc06MaxProductName ){
                                this.isEndInvestment = true;
                                this.refreshData();

                            }
                          
                        })
                    }
                });
            } else {
                countProductName += 1;
                // console.log('Else countProductName : ',countProductName);

                if (countProductName >= this.osc06MaxProductName) {
                    this.isEndInvestment = true;
                    this.refreshData();
                }
            }
        });


        
    }

    async retryGetBancassurance(round){
        await getProductHttp({
            endpoint: 'callout:OSC05_List',
            body: JSON.stringify({
                'GetBancassuranceAccountRequest': {
                    RMID: this.tmbCustId,
                }
            }),
            tmbCustId: this.tmbCustId
        }).then(BAProd => {
            if(!BAProd.message && BAProd.Status.StatusCode == '401' && round < NUMBER_OF_RETRY_TIME){
                round += 1;
                setTimeout(() => {
                    this.retryGetBancassurance(round);
                }, RETRY_SETTIMEOUT);
            }else if (BAProd.Status.StatusCode != '200') {  // Add by support SCR0560980
                this.isEndBancassurance = true;
                this.errorMessageControl.error.Bancassurance = true;
                this.warningMessageAdd(BAProd.Status.StatusDesc);
                this.errorMessageControl.messages.Info = BAProd.Status.StatusDesc;
                this.refreshData(false);
            }else{
                this.isEndBancassurance = true;
                this.isCalRenderBancassurance = false;
                this.OSC05.push(BAProd);

                this.refreshData(false);

            }
        }).catch(error => {
            console.error('OSC05 BA error', error);
            this.isEndBancassurance = true;
            this.errorMessageControl.error.Bancassurance = true;
            this.warningMessageAdd(this.label.baMSG);
        })
    }

    renderedCallback() {

    }

    refreshData(){
       var CC_PersonalLoan_SubGroup = this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup;

        if (this.OSC01) {
            if (!this.OSC01.Message && !this.OSC01.message) {
                if (this.OSC02 && this.OSC01.DepositAccount &&  this.isEndDeposit && !this.isCalRenderDeposit) {
                    var error02Count = 0;
                    let depositSum = 0;
                    let depositAvail = 0;
                    let otherSum = 0;
                    let otherAvail = 0;

                    this.productHoldingDetail['Deposit'].flagMin = false; // atk flagMin productHoldingDetail
                    this.OSC01.DepositAccount.forEach((depositAccount, j) => {

                        if (depositAccount.Product != undefined && !depositAccount.message) {
                        var depositProd = depositAccount.Product;

                            depositProd.isGetData = false;
                            try {
                                let AcctBal = depositProd.GetDepositAccountResponse.AcctInqRs.AcctBal.reduce((l, i) => {
                                    if (!l[i.BalType])
                                        l[i.BalType] = Number(i.CurAmt.Amt);
                                    return l;
                                }, {});
                                // depositSum = depositSum + (AcctBal['Ledger'] ? AcctBal['Ledger'] : 0);
                                if (depositProd.SeqGrp == '1' || depositProd.SeqGrp == '2') {
                                    // this.productHoldingDetail['Deposit'].flagMin = false; // atk flagMin

                                    // "ST225"
                                    var productCode =  depositProd.GetDepositAccountDetailResponse.Result.DepositAccount.ProductCode;
                                    var lstmdt = this.lstMDT;

                                    for(var indexmdt = 0 ; indexmdt < lstmdt.length ; indexmdt++){
                                        if(productCode == lstmdt[indexmdt].Product_Code__c && AcctBal['Ledger'] < 5000){
                                            this.productHoldingDetail['Deposit'].flagMin = true; // atk flagMin
                                        }
                                    }

                                    depositSum = this.calculateSum(depositSum, AcctBal['Ledger']);
                                    depositAvail = this.calculateSum(depositAvail, AcctBal['Avail']);
                                    // this.productHoldingDetail['Deposit'].flagMin = true; // atk flagMin

                                    this.productHoldingDetail['Deposit'].TotalOutstanding = depositSum;
                                    this.productHoldingDetail['Deposit'].TotalAvailable = depositAvail;

                                    depositProd.isGetData = true;
                                } else {
                                    otherSum = this.calculateSum(otherSum, AcctBal['Ledger']);
                                    otherAvail = this.calculateSum(otherAvail, AcctBal['Avail']);
                                    this.productHoldingDetail['Deposit'].Other.TotalOutstanding = otherSum;
                                    this.productHoldingDetail['Deposit'].Other.TotalAvailable = otherAvail;
                                }
                            } catch (error) {
                                console.error('Process data after callservice deposit error', error);
                                error02Count += 1;
                                if (error02Count == 1) {
                                    this.errorMessageControl.error.Deposit = true;
                                    this.warningMessageAdd(this.label.depositMSG);
                                }
                            }
                            depositAccount.Product = depositProd;
                        } else if (depositAccount != undefined && depositAccount.message && depositAccount.message.includes('timeout')) {
                            this.errorMessageControl.timeout.Deposit = true;
                        } else {
                            this.errorMessageControl.error.Deposit = true;
                        }
                    })
                        
                    if(this.OSC01.DepositAccount){
                        try { //Deposit Account
                            let depositSubFamily = [];
                            let depositName = [];

                            this.OSC01.DepositAccount.forEach((e, i) => {
                                try {
                                    if ((e.SeqGrp == '1' || e.SeqGrp == '2') && e.Product && e.Product.isGetData){
                                        this.countProductActiveInActive(e, 'Deposit', 'Deposit');

                                    }else {
                                        this.countProductActiveInActive(e, 'Other', 'Deposit');
                                        this.productHoldingDetail['Deposit'].Other.NumberOfProduct += 1;
                                    }
                                    if (e.Product && e.Product.isGetData) {
                                        if (e.ProductSubGroup && e.ProductSubGroup != '#N/A'){
                                            depositSubFamily.push(e.ProductSubGroup);
                                            this.productHoldingDetail['Deposit'].ProductSubGroup = [...new Set(depositSubFamily)];
                                        }
                                        if (e.ProductName && e.ProductName != '#N/A' ) {
                                            depositName.push(e.ProductName);
                                            this.productHoldingDetail['Deposit'].ProductName = [...new Set(depositName)];
                                            this.updateNumberOfProductFromName('Deposit');
                                        }
                                    }
                                } catch (error) {
                                    console.error('OSC01 Deposit error', e.AccountNumber, error);
                                }
                            })
                        } catch (error) {
                            console.error('OSC01 Deposit error', error);
                        }
                    }
                    
                    this.isCalRenderDeposit = true;
                    this.choiceErrorHandle();
                }

                //After callservice OSC04 Loan
                if (this.OSC04 && this.OSC01.LoanAccount && this.isEndLoan && !this.isCalRenderLoan) {
                    var error04Count = 0;
                    let personalLoanSUM = this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding ? this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding : 0;
                    let securedLoanSUM = 0;
                    let personalLoanAvailSUM = this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable ? this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable : 0;
                    let securedLoanAvailSUM = 0;
                    let otherSum = 0;
                    let otherAvail = 0;

                    this.OSC01.LoanAccount.forEach((LoanAccount, i) => {
                        if (LoanAccount.Product && !LoanAccount.message) {
                        var LoanProd = LoanAccount.Product;
                            LoanProd.isGetData = false;
                            try {
                                let AcctInq = LoanProd.GetLoanAccountResponse.AcctInqRs;
                                let loanOutstand = Number(AcctInq ? AcctInq.AcctBal[0].CurAmt.Amt : 0); 
                                let LoanInfo = LoanProd.GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon;
                                let AcctAvailble = Number(LoanInfo ? LoanInfo.LOCLimit.Amt : 0);
                                if (LoanProd.SeqGrp == '7'){
                                    personalLoanSUM = this.calculateSum(personalLoanSUM, loanOutstand);
                                    personalLoanAvailSUM = this.calculateSum(personalLoanAvailSUM, AcctAvailble);
                                    this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding = personalLoanSUM;
                                    this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable = personalLoanAvailSUM;
                                    LoanProd.isGetData = true;
                                }
                                if (LoanProd.SeqGrp == '8'){
                                    securedLoanSUM = this.calculateSum(securedLoanSUM, loanOutstand);
                                    securedLoanAvailSUM = this.calculateSum(securedLoanAvailSUM, AcctAvailble);
                                    this.productHoldingDetail['SecuredLoan'].TotalOutstanding = securedLoanSUM;
                                    this.productHoldingDetail['SecuredLoan'].TotalAvailable = securedLoanAvailSUM;
                                    LoanProd.isGetData = true;
                                }
                                if (LoanProd.SeqGrp == 'OTHERS') {
                                    otherSum = this.calculateSum(otherSum, loanOutstand);
                                    otherAvail = this.calculateSum(otherAvail, AcctAvailble);
                                    this.productHoldingDetail['SecuredLoan'].Other.TotalOutstanding = otherSum;
                                    this.productHoldingDetail['SecuredLoan'].Other.TotalAvailable = otherAvail;
                                }
                            } catch (error) {
                                console.error('Process data after callservice loan error', error);
                                error04Count += 1;
                                if (error04Count == 1) {
                                    this.errorMessageControl.error.Loan = true;
                                    this.warningMessageAdd(this.label.loanMSG);
                                }
                            }
                            LoanAccount.Product = LoanProd;
                        } else if (LoanAccount && LoanAccount.message && LoanAccount.message.includes('timeout')) {
                            this.errorMessageControl.timeout.Loan = true;
                        } else {
                            this.errorMessageControl.error.Loan = true;
                        }
                        
                    });
                    
                    if(this.OSC01.LoanAccount){
                        try {
                            let secureLoanSubFamily = [];
                            let secureLoanName = [];
                            // let personalLoanSubFamily = [];
                            let personalLoanName = this.productHoldingDetail['CC_PersonalLoan'].ProductName;
                            this.OSC01.LoanAccount.forEach((e, i) => {
                                try {
                                    if (e.SeqGrp && e.SeqGrp == '7' && e.Product && e.Product.isGetData) {
                                        // personalLoanSubFamily.push(e.ProductSubGroup);
                                        CC_PersonalLoan_SubGroup.push(e.ProductSubGroup);
                                        if (e.ProductSubGroup != '#N/A' && e.Product && e.Product.isGetData) {
                                            // this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup = [...new Set(personalLoanSubFamily)];
                                            this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup = [...new Set(CC_PersonalLoan_SubGroup)];
                                        }
                                        if (e.ProductName && e.ProductName != '#N/A') {
                                            personalLoanName.push(e.ProductName);
                                            this.productHoldingDetail['CC_PersonalLoan'].ProductName = [...new Set(personalLoanName)];
                                            this.updateNumberOfProductFromName('CC_PersonalLoan');
                                        }
                                        this.countProductActiveInActive(e, 'CC_PersonalLoan', 'CC_PersonalLoan');
                                    } else if (e.SeqGrp && e.SeqGrp == '8' && e.Product && e.Product.isGetData){
                                        secureLoanSubFamily.push(e.ProductSubGroup);
                                        if (e.ProductSubGroup != '#N/A') {
                                            this.productHoldingDetail['SecuredLoan'].ProductSubGroup = [...new Set(secureLoanSubFamily)];
                                        }
                                        if (e.ProductName && e.ProductName != '#N/A' && e.Product && e.Product.isGetData) {
                                            secureLoanName.push(e.ProductName);
                                            this.productHoldingDetail['SecuredLoan'].ProductName = [...new Set(secureLoanName)];
                                            this.updateNumberOfProductFromName('SecuredLoan');
                                        }
                                        this.countProductActiveInActive(e, 'SecuredLoan', 'SecuredLoan');
                                    } else {
                                        this.countProductActiveInActive(e, 'Other', 'SecuredLoan');
                                        this.productHoldingDetail['SecuredLoan'].Other.NumberOfProduct += 1;
                                    }
                                } catch (error) {
                                    console.error('OSC01 Loan error', error);
                                }
                            })
                        } catch (error) {
                            console.error('OSC01 Loan error', error);
                        }
                    }

                    this.isCalRenderLoan = true;
                    this.choiceErrorHandle();
                }

                // //After callservice OSC06 Investment
                if (this.OSC06 && this.OSC01.InvestmentAccount && this.isEndInvestment && !this.isCalRenderInvestment) {
                    var error06Count = 0;
                    let investAvailSUM = 0;
                    let otherAvail = 0;
                    let investName = [];
                    let isGetError = false;
                    
                    this.OSC06.forEach((e, i) => {
                        let investProduct = e;
                        if (investProduct && !investProduct.message) {
                            try {
                                if (investProduct.GetInvestmentAccountResponse.GetFundDetails && investProduct.GetInvestmentAccountResponse.GetFundDetails.length > 0){
                                    let getFundDetails = investProduct.GetInvestmentAccountResponse.GetFundDetails;
                                    let isHaveProductName = false;
                                    // this.productHoldingDetail['Investment'].NumberOfProduct += 1;
                                    getFundDetails.forEach(FundDetail => {
                                        let investValue = Number(FundDetail.detailFund.InvestmentValue ? FundDetail.detailFund.InvestmentValue : 0);
                                        // FundDetail.detailFund.FundNameEN = '#N/A';
                                        // console.log('FundDetail', this.parseObj(FundDetail));
                                        if (FundDetail.Name != '#N/A') {
                                            investAvailSUM = this.calculateSum(investAvailSUM, investValue);
                                            this.productHoldingDetail['Investment'].TotalAvailable = investAvailSUM;
                                            investName.push(FundDetail.Name);
                                            this.productHoldingDetail['Investment'].ProductName = [...new Set(investName)];
                                            this.updateNumberOfProductFromName('Investment');
                                            isHaveProductName = true;
                                        } else {
                                            otherAvail = this.calculateSum(otherAvail, investValue);
                                            this.productHoldingDetail['Investment'].Other.TotalAvailable = otherAvail;
                                            this.productHoldingDetail['Investment'].Other.NumberOfProduct += 1;
                                        }
                                    })
                                    if (isHaveProductName) {
                                        this.productHoldingDetail['Investment'].NumberOfAccount.Active += 1;
                                        this.productHoldingDetail['Investment'].NumberOfAccount.Total += 1;
                                    } else {
                                        this.productHoldingDetail['Investment'].Other.NumberOfAccount.Active += 1;
                                        this.productHoldingDetail['Investment'].Other.NumberOfAccount.Total += 1;
                                    }
                                } else {
                                    isGetError = true;
                                    this.productHoldingDetail['Investment'].Other.NumberOfAccount.Total += 1;
                                    this.productHoldingDetail['Investment'].Other.NumberOfAccount.Inactive += 1;
                                    this.productHoldingDetail['Investment'].Other.NumberOfProduct += 1;
                                }
                            } catch (error) {
                                console.error('Process data after callservice investment error', error);
                                error06Count += 1;
                            }
                        } else if (investProduct && investProduct.message && investProduct.message.includes('timeout')) {
                            this.errorMessageControl.timeout.Investment = true;
                            this.productHoldingDetail['Investment'].Other.NumberOfAccount.Total += 1;
                            this.productHoldingDetail['Investment'].Other.NumberOfAccount.Inactive += 1;
                            this.productHoldingDetail['Investment'].Other.NumberOfProduct += 1;
                        } else {
                            this.errorMessageControl.error.Investment = true;
                            this.productHoldingDetail['Investment'].Other.NumberOfAccount.Total += 1;
                            this.productHoldingDetail['Investment'].Other.NumberOfAccount.Inactive += 1;
                            this.productHoldingDetail['Investment'].Other.NumberOfProduct += 1;
                        }
                    });
                    if (isGetError || error06Count >= 1) {
                        this.errorMessageControl.error.Investment = true;
                        this.warningMessageAdd(this.label.investmentMSG);
                    }
                    this.isCalRenderInvestment = true;
                    this.choiceErrorHandle();
                }

                this.isCalRender01 = true;
            } else {
                this.isCalRender01 = true;
                this.isCalRenderDeposit = true;
                this.isCalRenderLoan = true;
                this.isCalRenderInvestment = true;
            }
        }

        if(this.isEndCreditCard && this.SCSCredit && !this.isCalRenderCreditCard){
            // this.productHoldingDetail.CC_PersonalLoan = this.objProductDetail();
            try { //Creditcard Account
                // let creditcardSubFamily = [];
                let creditcardName = this.productHoldingDetail['CC_PersonalLoan'].ProductName;
                this.SCSCredit.forEach((e, i) => {
                    try {
                        
                        if (e.SeqGrp == '3'){
                            this.countProductActiveInActive(e, 'CC_PersonalLoan', 'CC_PersonalLoan');
                        }else if (e.SeqGrp == 'OTHERS'){
                            this.countProductActiveInActive(e, 'Other', 'CC_PersonalLoan');
                            this.productHoldingDetail['CC_PersonalLoan'].Other.NumberOfProduct += 1;
                        }
                        if (e.SubProductGroup && e.SubProductGroup != '#N/A') {
                            // creditcardSubFamily.push(e.SubProductGroup);
                            CC_PersonalLoan_SubGroup.push(e.SubProductGroup);
                            // this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup = [...new Set(creditcardSubFamily)];
                            this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup = [...new Set(CC_PersonalLoan_SubGroup)];
                        }
                        if (e.ProductName && e.ProductName != '#N/A') {
                            creditcardName.push(e.ProductName);
                            this.productHoldingDetail['CC_PersonalLoan'].ProductName = [...new Set(creditcardName)];
                            this.updateNumberOfProductFromName('CC_PersonalLoan');
                        }
                    } catch (error) {
                        console.error('OSC01 Creditcard error', e.CardNumber, error);
                    }
                })
                // this.isCalRenderCreditCard = true;
            } catch (error) {
                this.isCalRenderCreditCard = true;
                console.error('OSC01 Creditcard error', error);
            }
        }

        //After callservice SCS Creditcard
        var error03Count = 0;
        if (this.SCSCredit && this.isEndCreditCard && !this.isCalRenderCreditCard) {
            
            let creditcardSUM = this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding ? this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding : 0;
            let creditcardAvail = this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable ? this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable : 0;
            let otherSum = 0;
            let otherAvail = 0;
            this.SCSCredit.forEach((creditcardProd) => {
                try {
                    let AcctAmt = Number(creditcardProd.Outstanding ? creditcardProd.Outstanding : 0);
                    let AcctAvailble = Number(creditcardProd.VLimit ? creditcardProd.VLimit : 0);
                    if (creditcardProd.SeqGrp == '3') {
                        creditcardSUM = this.calculateSum(creditcardSUM, AcctAmt);
                        creditcardAvail = this.calculateSum(creditcardAvail, AcctAvailble);
                        this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding = creditcardSUM;
                        this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable = creditcardAvail;
                    } else {
                        otherSum = this.calculateSum(otherSum, AcctAmt);
                        otherAvail = this.calculateSum(otherAvail, AcctAvailble);
                        this.productHoldingDetail['CC_PersonalLoan'].Other.TotalOutstanding = otherSum;
                        this.productHoldingDetail['CC_PersonalLoan'].Other.TotalAvailable = otherAvail;
                        // this.warningMessageAdd(this.label.creditCardMSG);
                    }
                } catch (error) {
                    console.error('Process data after callservice creditcard error', error);
                    error03Count += 1;
                    if (error03Count == 1) {
                        this.errorMessageControl.error.CreditCard = true;
                        this.warningMessageAdd(this.label.creditCardMSG);
                    }
                }
            })
            this.isCalRenderCreditCard = true;
            this.choiceErrorHandle();
        }

        if (this.OSC05 && this.isEndBancassurance && !this.isCalRenderBancassurance) {

            let baAvailSUM = 0;
            let baSubGroup = [];
            let baName = [];
            let isGetError = false;
            this.OSC05.forEach((BAProd, i)=> {
                if (!BAProd.message) {
                    try {
                        if (BAProd.GetBancassuranceAccountResponse && BAProd.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets.length > 0){
                            let productDataSets= BAProd.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets;
                            productDataSets.forEach(Policy => {
                                if (Policy.SUM_INSURE != null) {
                                    if (Policy.STATUS == 'Active') {
                                        this.productHoldingDetail['BA'].NumberOfAccount.Active += 1; 
                                    } else {
                                        this.productHoldingDetail['BA'].NumberOfAccount.Inactive += 1; 
                                    }
                                    this.productHoldingDetail['BA'].NumberOfAccount.Total += 1;
        
                                    let sumInsure = Number(Policy.SUM_INSURE ? Policy.SUM_INSURE : 0);
                                    baAvailSUM = this.calculateSum(baAvailSUM, sumInsure);
                                    this.productHoldingDetail['BA'].TotalAvailable = baAvailSUM;
                                    baSubGroup.push(Policy.PRODUCT_GROUP);
                                    baName.push(Policy.POLICY_NAME);
                                    this.productHoldingDetail['BA'].ProductSubGroup = [...new Set(baSubGroup)];
                                    this.productHoldingDetail['BA'].ProductName = [...new Set(baName)];
                                    
                                    this.updateNumberOfProductFromName('BA');
                                } else {
                                    isGetError = true;
                                }
                            })
                        }
                    } catch (error) {
                        console.error('Process data after callservice BA error', error);
                        isGetError = true;
                    }
                } else if (BAProd.message && BAProd.message.includes('timeout')) {
                    // this.productHoldingDetail['BA'].Other.NumberOfAccount.Inactive += 1;
                    this.errorMessageControl.timeout.Bancassurance = true;
                } else {
                    this.productHoldingDetail['BA'].Other.NumberOfAccount.Inactive += 1;
                    this.errorMessageControl.error.Bancassurance = true;
                }
            })
            if (isGetError) {
                this.errorMessageControl.error.Bancassurance = true;
                this.warningMessageAdd(this.label.baMSG);
            }
            this.isCalRenderBancassurance = true;
            this.choiceErrorHandle();
        }

        // // TODO Autu loan rerender call back here
        if (this.AutoLoan && this.isEndAutoLoan && !this.isCalRenderAutoLoan) {

            this.productHoldingDetail['AutoLoan'].NumberOfAccount.Total = [...new Set(this.AutoLoan.reduce((l, i) => {
                l.push(i.ContractNo)
                return l
            }, []))].length;
            this.productHoldingDetail['AutoLoan'].NumberOfAccount.Active = [...new Set(this.AutoLoan.reduce((l, i) => {
                if (this._ALDXWFMdt[i.ContractStatusCode] && this._ALDXWFMdt[i.ContractStatusCode].IS_ACTIVE__c) l.push(i.ContractNo)
                return l
            }, []))].length;
            this.productHoldingDetail['AutoLoan'].NumberOfAccount.Inactive = this.productHoldingDetail['AutoLoan'].NumberOfAccount.Total - this.productHoldingDetail['AutoLoan'].NumberOfAccount.Active
            this.productHoldingDetail['AutoLoan'].NumberOfProduct = [...new Set(this.AutoLoan.reduce((l, i) => {
                if (i._ProductName) l.push(i._ProductName) // FIX Here product name
                return l
            }, []))].length;

            this.productHoldingDetail['AutoLoan'].ProductSubGroup = this.productHoldingDetail['AutoLoan'].NumberOfAccount.Total > 0 ? [this.label.HIRE_PURCHASE] : []
            this.productHoldingDetail['AutoLoan'].TotalOutstanding = this.AutoLoan.reduce((l, i) => l + (i._OutstandingAmount ? i._OutstandingAmount : 0), 0);
            this.productHoldingDetail['AutoLoan'].TotalAvailable = this.AutoLoan.reduce((l, i) => l + (i._HPTotalAmount ? i._HPTotalAmount : 0), 0);
            this.isCalRenderAutoLoan = true;
            this.choiceErrorHandle();
        }
        if (!this.isCalRenders &&
            this.isCalRender01 && 
            this.isCalRenderDeposit &&
            this.isCalRenderCreditCard &&
            this.isCalRenderLoan &&
            this.isCalRenderAutoLoan &&
            this.isCalRenderBancassurance &&
            this.isCalRenderInvestment
            //  &&
            // this.isCalRenderCreditCard
            ) {

            this.isCalRenders = true;
        }

        if (this.errorMSG) {
            this.isErrorService = true;
        }

        this.retryService.OSC01 = !this.isEnd01;
        this.retryService.Deposit = !this.isEndDeposit;
        this.retryService.CreditCard = !this.isEndCreditCard;
        this.retryService.Loan = !this.isEndLoan;
        this.retryService.AutoLoan = !this.isEndAutoLoan;
        this.retryService.Bancassurance = !this.isEndBancassurance;
        this.retryService.Investment = !this.isEndInvestment;
        this.retryService.ReCalculate = !this.isCalRenders;
        // var otherSum = this.productHoldingDetail['Other'].TotalOutstanding;
        // var otherAvail = this.productHoldingDetail['Other'].TotalAvailable;
        this.sumTotalOther();

        // console.log('RefreshData productHolding : '+JSON.stringify(this.productHoldingDetail));
        // const holdingSummary = this.template.querySelector('c-retail-c-s-v-product-holding-total-summary');
        // return player !== null && player.paused === false;
        if(this.isCalRenders){
            this.template.querySelector('c-retail-c-s-v-product-holding-total-summary') != undefined? this.template.querySelector('c-retail-c-s-v-product-holding-total-summary').calRenders(this.isCalRenders,this.productHoldingDetail ):null;
            this.template.querySelector('c-retail-c-s-v-product-holding-outstanding-summary') != undefined? this.template.querySelector('c-retail-c-s-v-product-holding-outstanding-summary').calRenders(this.isCalRenders,this.productHoldingDetail ):null;
            this.template.querySelector('c-retail-c-s-v-product-holding-product-account-amount') != undefined? this.template.querySelector('c-retail-c-s-v-product-holding-product-account-amount').calRenders(this.isCalRenders,this.productHoldingDetail ):null;
            this.template.querySelector('c-retail-c-s-v-product-holding-each-group-detail') != undefined? this.template.querySelector('c-retail-c-s-v-product-holding-each-group-detail').calRenders(this.isCalRenders,this.productHoldingDetail,this.dataPartition ):null;
        }

    }

    clearOtherOfProduct (productName) {
        this.productHoldingDetail[productName].Other = {
            NumberOfAccount: {
                Active: 0,
                Inactive: 0,
                Total: 0
            },
            NumberOfProduct: 0,
            TotalOutstanding: 0,
            TotalAvailable: 0,
        }
    }

    sumTotalOther() {
        var DepositOther = this.productHoldingDetail['Deposit'].Other;
        var CreditCardOther = this.productHoldingDetail['CC_PersonalLoan'].Other;
        var LoanOther = this.productHoldingDetail['SecuredLoan'].Other;
        var BAOther = this.productHoldingDetail['BA'].Other;
        var InvestmentOther = this.productHoldingDetail['Investment'].Other;
        this.productHoldingDetail['Other'].TotalOutstanding = DepositOther.TotalOutstanding + CreditCardOther.TotalOutstanding + LoanOther.TotalOutstanding + BAOther.TotalOutstanding + InvestmentOther.TotalOutstanding
        this.productHoldingDetail['Other'].TotalAvailable = DepositOther.TotalAvailable + CreditCardOther.TotalAvailable + LoanOther.TotalAvailable + BAOther.TotalAvailable + InvestmentOther.TotalAvailable
        this.productHoldingDetail['Other'].NumberOfProduct = DepositOther.NumberOfProduct + CreditCardOther.NumberOfProduct + LoanOther.NumberOfProduct + BAOther.NumberOfProduct + InvestmentOther.NumberOfProduct
        this.productHoldingDetail['Other'].NumberOfAccount.Active = DepositOther.NumberOfAccount.Active + CreditCardOther.NumberOfAccount.Active + LoanOther.NumberOfAccount.Active + BAOther.NumberOfAccount.Active + InvestmentOther.NumberOfAccount.Active
        this.productHoldingDetail['Other'].NumberOfAccount.Inactive = DepositOther.NumberOfAccount.Inactive + CreditCardOther.NumberOfAccount.Inactive + LoanOther.NumberOfAccount.Inactive + BAOther.NumberOfAccount.Inactive + InvestmentOther.NumberOfAccount.Inactive
        this.productHoldingDetail['Other'].NumberOfAccount.Total = this.productHoldingDetail['Other'].NumberOfAccount.Active + this.productHoldingDetail['Other'].NumberOfAccount.Inactive
        // console.log('productOther', this.productHoldingDetail['Other']);
    }

    openProductholding(event) {
        if (this.isIPad || this.isTablet) {
            // let iPadProductHoldingURL = '/one/one.app#' + btoa(JSON.stringify({
            //     "componentDef": "c:CallCenterCSV_ProductHolding",
            //     "attributes": {
            //         recordId: this.recordId,
            //         tmbCustId: this.tmbCustId,
            //     }
            // }));
            let iPadProductHoldingURL = `/apex/CallCenterCSV_ProductHoldingVF?id=${this.recordId}`;

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: iPadProductHoldingURL
                }
            }); 
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__CallCenterCSV_ProductHolding',
                },
                state: {
                    "c__recordId": this.recordId,
                    "c__tmbCustId": this.tmbCustId
                }
            }); 
        }
        
    }

    calculateSum(total, ...arg) {
        return this.toFixedTwoDigits(arg.reduce((l, i) => l + (i ? i : 0), total));
    }

    toFixedTwoDigits(num) {
        return Number(num.toFixed(2));
    }

    parseObj(obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : obj;
    }

    objProductDetail() {
        let obj = {
            NumberOfAccount: {
                Active: 0,
                Inactive: 0,
                Total: 0
            },
            NumberOfProduct: 0,
            TotalOutstanding: 0,
            TotalAvailable: 0,
            ProductSubGroup: [],
            ProductName: [],
            Remark: '',
            Other: {
                NumberOfAccount: {
                    Active: 0,
                    Inactive: 0,
                    Total: 0
                },
                NumberOfProduct: 0,
                TotalOutstanding: 0,
                TotalAvailable: 0,
            }
        };
        return obj;
    }

    countProductActiveInActive(obj, objtype, productType) {
        if (objtype == 'Deposit') {
            if (obj.AccountStatus == 'Active | ปกติ (Active)') {
                this.productHoldingDetail[objtype].NumberOfAccount.Active += 1;
            } else {
                this.productHoldingDetail[objtype].NumberOfAccount.Inactive += 1;
            }
        } else if (objtype != 'Other'){
            if (obj.AccountStatus == 'Active') {
                this.productHoldingDetail[objtype].NumberOfAccount.Active += 1;
            } else {
                this.productHoldingDetail[objtype].NumberOfAccount.Inactive += 1;
            }
        } else if (objtype == 'Other') {
            if (obj.AccountStatus == 'Active' || obj.AccountStatus == 'Active | ปกติ (Active)') {
                this.productHoldingDetail[productType].Other.NumberOfAccount.Active += 1;
            } else {
                this.productHoldingDetail[productType].Other.NumberOfAccount.Inactive += 1;
            }
        }
        this.productHoldingDetail[objtype].NumberOfAccount.Total += 1;
    }

    updateNumberOfProductFromName(objtype) {
        this.productHoldingDetail[objtype].NumberOfProduct = this.productHoldingDetail[objtype].ProductName.length;
    }

    warningMessageAdd(LabelObjtype) {
        if (this.errorMSG == '') {
            this.errorMSG = LabelObjtype;
        } else {
            this.errorMSG = this.errorMSG.includes(LabelObjtype) ? this.errorMSG : this.errorMSG + '\n ' + LabelObjtype;
        }
    }

    async getCreditCard(body,round) {
        await getProductSCSCreditCard({
            endpoint: 'callout:get_cards_balances',
            body: body,
            tmbCustId: this.tmbCustId
        }).then(creditcardProds => {
            if (creditcardProds && creditcardProds.CreditCardAccounts) {

                creditcardProds.CreditCardAccounts.forEach((e, i) => {
                    this.SCSCredit.push(e);
                });
                if (creditcardProds.result && creditcardProds.result.more_records == 'Y' && creditcardProds.result.search_keys) {
                    body = JSON.stringify({
                        'query': {
                            "rm_id": this.tmbCustId,
                            "more_records": 'Y',
                            "search_keys": creditcardProds.result.search_keys,
                            "user_interface": "",
                        }
                    });
                    this.isEndCreditCard = false;
                    this.isCalRenderCreditCard = false;
                    this.getCreditCard(body,0);
                }
            } else if (creditcardProds && (creditcardProds.error_status || creditcardProds.Status)) {
                if (creditcardProds.error_status) {

                    if (!this.errorCodeSCSIncludes('CIF0003', creditcardProds.error_status)) {

                        this.errorMessageControl.error.CreditCard = true;
                        this.warningMessageAdd(this.label.creditCardMSG);
                    }
                } else if (creditcardProds.Status && creditcardProds.Status.StatusDesc.includes('Timeout')) {
                    this.errorMessageControl.timeout.CreditCard = true;
                    this.warningMessageAdd(this.label.creditCardMSG);
                }else if(creditcardProds.Status.StatusCode == '401' && round< NUMBER_OF_RETRY_TIME){

                    round += 1;
                    this.errorMessageControl.timeout.CreditCard = false
                    this.errorMessageControl.error.CreditCard = false
                    
                    setTimeout(() => {
                        this.getCreditCard(body,round);
                    }, RETRY_SETTIMEOUT);
                } 
                else {
                    this.errorMessageControl.error.CreditCard = true;
                    this.isEndCreditCard = true;
                    this.isCalRenderCreditCard = false;
                    this.refreshData();

                }
            } else if (creditcardProds && ['System error', 'is Null'].some(substring=>creditcardProds.includes(substring))) {
                this.errorMessageControl.error.CreditCard = true;
                this.warningMessageAdd(this.label.creditCardMSG);
            } else if (creditcardProds && ['Timeout', 'timeout', 'เรียกดูข้อมูลอีกครั้ง'].some(substring=>creditcardProds.includes(substring))) {
                this.errorMessageControl.timeout.CreditCard = true;
            } 
            if (creditcardProds.result && creditcardProds.result.more_records == 'Y') {
                this.isEndCreditCard = false;

            } else {
                this.isCalRenderCreditCard = false;
                this.isEndCreditCard = true;
                this.refreshData();

            }
        }).catch(error => {
            console.error('SCS CreditCard error', error);
            this.isEndCreditCard = true;
            this.errorMessageControl.error.CreditCard = true;
            this.warningMessageAdd(this.label.creditCardMSG);
        })

    }

    errorCodeSCSIncludes(error_code, error_status) {
        var isInclude = false;
        error_status.forEach((e, i) => {
            if (e.error_code == error_code) {
                isInclude = true;
            }
        });
        return isInclude;
    }
    
    objectErrorMessageControl() {
        let obj = {
            showMessage: false,
            isHaveCustomer_ID: true,
            isNoPermission: false,
            isShowNoAccess: false,
            message: '',
            error: {
                OSC01: false,
                Deposit: false,
                CreditCard: false,
                Loan: false,
                AutoLoan: false,
                Bancassurance: false,
                Investment: false,
            },
            isShowMessage: {
                Snow: false,
                Retry: false,
                Info: false,
                isShow: false
            },
            messages: {
                Snow: this.label.ERR001_ProductHolding,
                Retry: {
                    message : '',
                    beforeLink : '',
                    afterLink : '',
                    clickHere : '',
                },
                InfoProducts : '',
                RetryInfo: '',
                Info: this.label.infoError,
                tryContact: this.label.Error_Persists_Contact,
            },
            retry: {
                OSC01: false,
                CreditCard: false,
                Bancassurance: false,
                AutoLoan: false,
            },
            timeout: {
                OSC01: false,
                Deposit: false,
                CreditCard: false,
                Loan: false,
                AutoLoan: false,
                Bancassurance: false,
                Investment: false,
            },
            ErrorMessage: '',
        };
        return obj;
    }

    retryServiceFlag(flag){
        let obj = {
            OSC01: flag,
            Deposit: flag,
            CreditCard: flag,
            Loan: flag,
            AutoLoan: flag,
            Bancassurance: flag,
            Investment: flag,
            ReCalculate: flag,
        };
        return obj;
    }

    choiceErrorHandle() {
        var errorControlObj = this.errorMessageControl;
        var checkObj = errorControlObj.timeout;
        var retryMessageProductNames = [];
        var InfoMessageProductNames = [];
        errorControlObj.isShowMessage.Retry = this.checkedServiceFromErrorMessageControl(errorControlObj.timeout);

        if (errorControlObj.isShowMessage.Retry) {
            errorControlObj.retry.OSC01 = checkObj.Deposit || checkObj.Investment || checkObj.Loan || checkObj.OSC01;
            errorControlObj.retry.CreditCard = checkObj.CreditCard;
            errorControlObj.retry.Bancassurance = checkObj.Bancassurance;
            errorControlObj.retry.AutoLoan = checkObj.AutoLoan;
            retryMessageProductNames = this.productNameMessage(errorControlObj.timeout);
            this.setMessageRetry(retryMessageProductNames);
        }
        errorControlObj.isShowMessage.Snow = this.checkedServiceFromErrorMessageControl(errorControlObj.error);

        errorControlObj.showMessage = errorControlObj.message ? true : false;
        errorControlObj.isShowMessage.Info = errorControlObj.isShowMessage.Snow && !(errorControlObj.isShowMessage.Retry);
        if (errorControlObj.isShowMessage.Info) {
            InfoMessageProductNames = this.productNameMessage(errorControlObj.error);
            this.setMessageInfo(InfoMessageProductNames);

        }
        if (errorControlObj.isShowMessage.Snow || errorControlObj.isShowMessage.Info || errorControlObj.isShowMessage.Retry) {
            errorControlObj.isShowMessage.isShow = true;
        } else {
            errorControlObj.isShowMessage.isShow = false;
        }
        this.errorMessageControl = errorControlObj;
    }

    onClickRetry() {
        this.checkRetryService();
        var isRetry = this.errorMessageControl.retry;
        this.errorMessageControl.messages.Retry = {
            message : '',
            beforeLink : '',
            afterLink : '',
            clickHere : '',
        }
        this.errorMessageControl.isShowMessage.Retry = false;
        if (isRetry.OSC01 || isRetry.CreditCard || isRetry.Bancassurance || isRetry.AutoLoan) {
            this.retryService.ReCalculate = true;
            this.callServices(0);
        }
    }

    productNameMessage(checkObj) {
        var ProductNames = [];
        if (checkObj.OSC01) {
            ProductNames.push(this.label.depositMSG);
            ProductNames.push(this.label.loanMSG);
            ProductNames.push(this.label.investmentMSG);
        } else {
            if (checkObj.Deposit) {
                ProductNames.push(this.label.depositMSG);
            }
            if (checkObj.Loan) {
                ProductNames.push(this.label.loanMSG);
            }
            if (checkObj.Investment) {
                ProductNames.push(this.label.investmentMSG);
            }
        }
        if (checkObj.CreditCard) {
            ProductNames.push(this.label.creditCardMSG);
        }
        if (checkObj.Bancassurance) {
            ProductNames.push(this.label.baMSG);
        }
        if (checkObj.AutoLoan) {
            ProductNames.push(this.label.autoloanMSG);
        }
        return ProductNames;
    }

    setMessageRetry(productNames) {
        var message = this.label.Product_Holding_ReRequest_v3;
        var messageTimeout = message.split('{1}');
        var messageTimeoutLink = messageTimeout[1].split('{0}');
        this.errorMessageControl.messages.Retry.message = messageTimeout[0];
        this.errorMessageControl.messages.Retry.beforeLink = messageTimeoutLink[0];
        this.errorMessageControl.messages.Retry.afterLink = messageTimeoutLink[1];
        this.errorMessageControl.messages.Retry.clickHere = message.includes('Timeout') ? ' Click Here ' : 'คลิกที่นี่';
        this.errorMessageControl.messages.RetryInfo = '';
        var isNeedComma = false;
        var RetryInfo = '';
        productNames.forEach(e => {
            if (isNeedComma) {
                RetryInfo += ', ';
            }
            RetryInfo += e;
            isNeedComma = true;
        });
        this.errorMessageControl.messages.RetryInfo = RetryInfo;
    }

    setMessageInfo(productNames) {
        var isNeedComma = false;
        var InfoMessage = '';

        productNames.forEach(e => {
            if (isNeedComma) {
                InfoMessage += ', ';
            }
            InfoMessage += e;
            isNeedComma = true;
        })
        this.errorMessageControl.messages.InfoProducts = InfoMessage;
    }

    checkedServiceFromErrorMessageControl(checkObject) {
        return Object.keys(checkObject)
            .reduce((status, productType) => status || checkObject[productType], false);
    }

    checkRetryService() {
        let retryServiceTemp = this.parseObj(this.retryService);
        let timeoutFlags = this.errorMessageControl.timeout;
        if (timeoutFlags.OSC01) {
            retryServiceTemp.OSC01 = true;
            retryServiceTemp.Deposit = true;
            retryServiceTemp.Loan = true;
            retryServiceTemp.Investment = true;
        } else {
            if (timeoutFlags.Deposit) {
                retryServiceTemp.Deposit = true;
            }
            if (timeoutFlags.Loan) {
                retryServiceTemp.Loan = true;
            }
            if (timeoutFlags.Investment) {
                retryServiceTemp.Investment = true;
            }
        }
        if (timeoutFlags.CreditCard) {
            retryServiceTemp.CreditCard = true;
        }
        if (timeoutFlags.Bancassurance) {
            retryServiceTemp.Bancassurance = true;
        }
        if (timeoutFlags.AutoLoan) {
            retryServiceTemp.AutoLoan = true;
        }
        this.retryService = retryServiceTemp;
    }


    @track
    _ALDXWFMdt

    @wire(getALDXWFMdt, {})
    callbackALDXWF({
        error,
        data
    }) {
        this._ALDXWFMdt = data ? data : {};
    }

    async calloutAutoloanHP(round) {
        try {
            let company = await getAppConfigMdtByKey({
                'key': 'CoreHP_Company'
            })
            let result = await getProductAutoLoan({
                'endpoint': 'callout:AutoLoan_HpFleetHpList',
                'callback': 'callbackHpFleetHpList',
                'body': JSON.stringify({
                    "Company": company,
                    "RMID": this.tmbCustId,
                    "HPType": "HP",
                    "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                    "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
                }),
                'service': 'CoreHP',
                'state': {
                    'service': 'CoreHP',
                    'recordId': this.recordId,
                    'tmbCustId': this.tmbCustId
                },
            })
            if(result.HTTPStatusCode == '401' && round < NUMBER_OF_RETRY_TIME ){
                round += 1;
                setTimeout(() => {
                    result = this.calloutAutoloanHP(round);
                }, RETRY_SETTIMEOUT);
            }else{
                this.errorMessageControl.timeout.AutoLoan = result.isTimeout ? true : false
                this.errorMessageControl.error.AutoLoan = result.isError || result.isThrow ? true : false
                if (this.errorMessageControl.timeout.AutoLoan || this.errorMessageControl.error.AutoLoan) {
                    this.warningMessageAdd(this.label.autoloanMSG)
                }
    
                let addx_warning = Object.keys(this._ALDXWFMdt).reduce((l, i) => {
                    if (this._ALDXWFMdt[i].WARNING_MESSAGE__c) l[i] = this._ALDXWFMdt[i]
                    return l;
                }, {})
                if( getValueReference('Output.length', result)){
                    var autoLoanDetailLength = getValueReference('Output.length', result);
                    var autoLoanList = getValueReference('Output', result);
                    autoLoanList.forEach(async eachAuto => {
                        this.retryGetProductAutoLoanDetail(0,company,eachAuto,addx_warning,autoLoanDetailLength);
                        
                    })
                }else{
                    this.isEndAutoLoan = true;
                    this.refreshData();
                }
            }
        } catch (e) {
            this.warningMessageAdd(this.label.autoloanMSG)
            console.error(e)
        } finally {
        }
    }


    async retryGetProductAutoLoanDetail(round,company,eachAuto,addx_warning,autoLoanDetailLength){
        await getProductAutoLoan({
            'endpoint': 'callout:AutoLoan_HpFleetHpDetail',
            'callback': 'callbackHpFleetHpDetail',
            'body': JSON.stringify({
                "Company": company,
                "ContractNo": eachAuto.ContractNo,
                "TranDate": new Date().toJSON().slice(0, 10).replace(/-/g, ''),
                "TranTime": new Date().toJSON().slice(11, 22).replace(/[:.]/g, '')
            }),
            'service': 'CoreHP',
            'state': {
                'service': 'CoreHP',
                'recordId': this.recordId,
                'tmbCustId': this.tmbCustId
            },
        }).then(eachAutoLoanDetail=>{
            if(eachAutoLoanDetail.HTTPStatusCode == '401'&& round < NUMBER_OF_RETRY_TIME){
                setTimeout(() => {
                    round += 1;
                    this.retryGetProductAutoLoanDetail(round,company,eachAuto,addx_warning,autoLoanDetailLength);
                }, RETRY_SETTIMEOUT);
            }else{
                eachAuto._OutstandingAmount = addx_warning[eachAuto.ContractStatusCode] ? 0 : Number(Number(eachAuto.OutstandingAmount).toFixed(2));
                eachAuto._HPTotalAmount = Number(Number(eachAuto.HPTotalAmount).toFixed(2));
                eachAuto._ProductName = getValueReference('Output.0.ProductCode', eachAutoLoanDetail);
                eachAuto.HTTPStatusCode = getValueReference('HTTPStatusCode', eachAutoLoanDetail);
                this.AutoLoan.push(eachAuto);
                if(this.AutoLoan.length >= autoLoanDetailLength){
                    this.isEndAutoLoan = true;
                    this.refreshData();
                }
              
            }
        })
    }
}