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

import CREATED_FIELD from '@salesforce/schema/Account.CreatedDate';

import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

const account_field_section = {
    'Outstanding': 'RtlCust:Customer Product Holding (Medium)',
    'NumberOfProduct_Account': 'RtlCust:Customer Product Holding (Low)',
    'ProductSubGroup': 'RtlCust:Customer Product Holding (Low)',
    'Remark': 'RtlCust:Customer Product Holding (Low)',
}

const dataPartitionField = ['Outstanding', 'NumberOfProduct_Account', 'ProductSubGroup', 'Remark'];

import ALL_FREE from '@salesforce/schema/Account.RMC_All_Free__c';
import NO_FIXED from '@salesforce/schema/Account.RMC_No_Fixed__c';
import RESERVE from '@salesforce/schema/Account.RMC_Reserve__c';
import MF from '@salesforce/schema/Account.RMC_MF__c';
import TSP from '@salesforce/schema/Account.RMC_Number_of_TSP__c';
import HEALTHBA from '@salesforce/schema/Account.RMC_Health_BA__c';
import SAVINGBA from '@salesforce/schema/Account.RMC_Saving_BA__c';
import LIFEBA from '@salesforce/schema/Account.RMC_Life_BA__c';
import TTBLASTUSE from '@salesforce/schema/Account.Last_login_success_date__c';
import TTBTOUCH from '@salesforce/schema/Account.RMC_TTB_Touch__c';
import ISEXPIRED from '@salesforce/schema/Account.RMC_ttb_Touch_Expired__c';
import NOFIXBONUS from '@salesforce/schema/Account.RMC_No_Fix_Bonus_Flag__c';

//import logo
import AllFreeLogo      from '@salesforce/resourceUrl/RMC_Allfreelogo';
import AllFreeLogoGrey  from '@salesforce/resourceUrl/RMC_Allfreegrey';

import NoFixed          from '@salesforce/resourceUrl/RMC_Nofixed';
import NoFixedGrey      from '@salesforce/resourceUrl/RMC_Nofixedgrey';

import SavingBA         from '@salesforce/resourceUrl/RMC_Savingba';
import SavingBAGrey     from '@salesforce/resourceUrl/RMC_Savingbagrey';

import mfLogo           from '@salesforce/resourceUrl/RMC_MF';
import mfLogoGrey       from '@salesforce/resourceUrl/RMC_MFGrey';

import healthBALogo     from '@salesforce/resourceUrl/RMC_Healthba';
import healthBALogogrey  from '@salesforce/resourceUrl/RMC_Healthbagrey';

import lifeBALogo       from '@salesforce/resourceUrl/RMC_LifeBA';
import lifeBAGreyLogo   from '@salesforce/resourceUrl/RMC_LifeBAGrey';

import TSPLogo          from '@salesforce/resourceUrl/RMC_TSP';
import TSPLogoGrey      from '@salesforce/resourceUrl/RMC_TSPGrey';

import reserveLogo      from '@salesforce/resourceUrl/RMC_Reserve';
import reserveLogoGrey  from '@salesforce/resourceUrl/RMC_ReserveGrey';

import touchLogo from '@salesforce/resourceUrl/RMC_TouchBlue';
import touchLogoGrey from '@salesforce/resourceUrl/RMC_TouchGrey';


const fields = [CREATED_FIELD, ALL_FREE, NO_FIXED, RESERVE, MF, TSP, HEALTHBA, SAVINGBA,
    LIFEBA, TTBLASTUSE, TTBTOUCH, ISEXPIRED, NOFIXBONUS];
// , TTBTOUCH];

export default class RetailCSVProductHolding extends NavigationMixin(LightningElement) {
    AllFreeURL          = `${AllFreeLogo}#allfreelogo`
    AllFreeLogoGrey     = `${AllFreeLogoGrey}#allfreelogogrey`
    NoFixedURL          = `${NoFixed}#nofixed`
    NoFixedGrey         = `${NoFixedGrey}#nofixedgrey`
    SavingBAURL         = `${SavingBA}#savingBA`
    SavingBAGreyURL     = `${SavingBAGrey}#savingBAGrey`
    MFURL               = `${mfLogo}#MF`
    MFGreyURL           = `${mfLogoGrey}#MFGrey`
    healthbaurl         = `${healthBALogo}#healthba`
    healthbagreyurl     = `${healthBALogogrey}#healthbagrey`
    tspurl              = `${TSPLogo}#TSP`
    tspgreyurl          = `${TSPLogoGrey}#TSPGrey`
    lifeBAUrl           = `${lifeBALogo}#LifeBA`
    lifeBAgreyUrl       = `${lifeBAGreyLogo}#LifeBAGrey`
    reserveURL          = `${reserveLogo}#reserve`
    reserveGreyURL      = `${reserveLogoGrey}#reserveGrey`
    touchURL            = `${touchLogo}#touchBlue`
    touchGreyURL        = `${touchLogoGrey}#touchGrey`

    
    // displayGraph = false;
    @api isProductSummaryOnly = false;
    @api displayGraph = !this.isProductSummaryOnly;

    @wire(getRecord, { recordId: '$recordId', fields })
    account;

    get AllFree() {
        return getFieldValue(this.account.data, ALL_FREE);
    }
    get NOFIXED() {
        return getFieldValue(this.account.data, NO_FIXED);
    }
    get RESERVE() {
        return getFieldValue(this.account.data, RESERVE);
    }
    get MF() {
        return getFieldValue(this.account.data, MF);
    }
    get TSP() {
        var resp = getFieldValue(this.account.data, TSP);
        if(resp > 0){
            return true;
        }else{
            return false;
        }
    }
    get HEALTHBA() {
        return getFieldValue(this.account.data, HEALTHBA);
    }
    get SAVINGBA() {
        return getFieldValue(this.account.data, SAVINGBA);
    }
    get LIFEBA() {
        return getFieldValue(this.account.data, LIFEBA);
    }
    get TTBTOUCH() {
        return getFieldValue(this.account.data, TTBTOUCH);
    }
    get ISTOUCHEXPIRED() {
        return getFieldValue(this.account.data, ISEXPIRED);
    }
    get HASNOFIXBONUS() {
        return getFieldValue(this.account.data, NOFIXBONUS);
    }

    // @track depositDataEvent
    @track isALLFREERED = false;
    handleDepositValue(event) {
    }

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
        start: '',
        here: '',
        end: ''
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
        let splitRefresh = this.label.Refresh.split('<a ', 2);
        this.refreshString.start = 'Request timeout. ' + splitRefresh[0];
        let splitEnd = splitRefresh[1].split('/a>', 2);
        this.refreshString.end = splitEnd[1];
        let splitHere = this.label.Refresh.split('<u>', 2);
        splitHere = splitHere[1].split('</u>', 2);
        this.refreshString.here = splitHere[0];
        this.initialize();
    }

    initialize = async () => {
        this.navigatorUserAgent = navigator.userAgent;
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
        this.customer = await getCustomer({
            recordId: this.recordId
        });

        this.displayGraph = !this.isProductSummaryOnly;

        this.profileName = await getProfileName({
            userId: userId
        });
        this.lstMDT = await getMdtProductCode({});
        let getFieldPartitionCount = 0;
        Object.keys(account_field_section).forEach((e, i) => {
            getProfileverifyFieldSecurityName({
                section: account_field_section[e],
                userProfile: this.profileName,
                accountId: this.recordId
            })
                .then(result => {
                    this.dataPartition[e] = result;
                    if (getFieldPartitionCount == 3) {
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
                        } else if (this.dataPartition['Outstanding'] === true || this.dataPartition['NumberOfProduct_Account'] === true) {
                            this.isNeedCallService = true;
                            this.isNoPermission = false;
                            this.errorMessageControl.noPermission = false;
                            this.callServices();
                        }

                        if(this.isShowNoAccess == false){
                            const ans = getALDXWFMdt({});
                            this._ALDXWFMdt = ans ? ans : {};
                        }
                    }
                    getFieldPartitionCount += 1;
                })
                .catch(error => {
                    console.error('Get data partition error: ', error)
                })
        })

    }

    async callServices() {
        if(this.isShowNoAccess == false){

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
                        this.isEnd01 = true;

                        if (this.OSC01.StatusCode == '404') {
                            this.error01 = true;
                            this.errorMessageControl.error.OSC01 = true;
                            this.isShowError = true;
                        } else if (this.OSC01.StatusCode == '500') {
                            this.isTimeOut = true;
                            this.errorMessageControl.timeout.OSC01 = true;
                            this.isShowError = true;
                        } else if (this.OSC01.Message) {
                            if (this.OSC01.Message.includes('error') || this.OSC01.Message.includes('เกิดข้อผิดพลาด')) {
                                this.error01 = true;
                                this.errorMessageControl.error.OSC01 = true;
                                this.isShowError = true;
                            }
                            if (this.OSC01.Message.includes('No Active Product') || this.OSC01.Message.includes('ไม่มี')) {  //Not sure 
                                this.retryService.OSC01 = false;
                            }
                        } else if (this.OSC01.message) {
                            if (this.OSC01.message.includes('timeout')) {
                                this.isTimeOut = true;
                                this.errorMessageControl.timeout.OSC01 = true;
                                this.isShowError = true;
                            }
                        }
                        this.retryService.OSC01 = false;
                        this.choiceErrorHandle();
                        // if(this.OSC01) time out error
                    } catch (error) {
                        if (error.status && error.status == '500' && error.body && error.body.message && error.body.message.includes('timeout')) {
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
                }
                if (!this.isShowError && this.OSC01.DepositAccount && this.OSC01.DepositAccount.length > 0 && this.retryService.Deposit) {
                    let depositCallCount = 0;
                    let depositCallMax = this.OSC01.DepositAccount.length;
                    this.OSC01.DepositAccount.forEach(async (e, i) => {
                        getProductHttp({
                            endpoint: 'callout:OSC02',
                            body: JSON.stringify({
                                'GetDepositAccountRequest': {
                                    ProductType: e.ProductType,
                                    AccountType: e.ProductCode,
                                    AccountNumber: e.AccountNumber,
                                    FIIdent: e.FIIdent,
                                    RMID: RMID12,
                                }
                            }),
                            tmbCustId: this.tmbCustId
                        }).then(depositProd => {
                            depositProd.AccountNumber = e.AccountNumber;
                            depositProd.SeqGrp = e.SeqGrp;
                            e.Product = depositProd;
                            this.OSC02.push(depositProd);
                            depositCallCount += 1;
                            if (depositCallCount >= depositCallMax) {
                                this.isEndDeposit = true;
                            }
                        }).catch(error => {
                            depositCallCount += 1;
                            if (depositCallCount >= depositCallMax) {
                                this.isEndDeposit = true;
                            }
                            this.errorMessageControl.error.Deposit = true;
                            this.warningMessageAdd(this.label.depositMSG);
                        })
                    });
                } else {
                    this.isEndDeposit = true;
                }
                //M8 SCS Creditcard 
                if (this.retryService.CreditCard) {
                    // let creditCallCount = 0;
                    // let creditCallMax = this.OSC01.CreditCardAccount.length;
                    // if (e.AccountStatus != 'NOTFND') {
                    var body = JSON.stringify({
                        'query': {
                            "rm_id": this.tmbCustId,
                            "more_records": 'N',
                            "search_keys": '',
                            "user_interface": "",
                        }
                    });
                    this.getCreditCard(body);
                } else {
                    this.isEndCreditCard = true;
                }
                if (!this.isShowError && this.OSC01.LoanAccount && this.OSC01.LoanAccount.length > 0 && this.retryService.Loan) {
                    let loanCallCount = 0;
                    let loanCallMax = this.OSC01.LoanAccount.length;
                    this.OSC01.LoanAccount.forEach(async (e, i) => {
                        getProductHttp({
                            endpoint: 'callout:OSC04',
                            body: JSON.stringify({
                                'GetLoanAccountRequest': {
                                    ProductType: '',
                                    AccountType: e.ProductType,
                                    AccountNumber: e.AccountNumber,
                                    FIIdent: e.FIIdent,
                                    RMID: RMID12,
                                }
                            }),
                            tmbCustId: this.tmbCustId
                        }).then(LoanProd => {
                            LoanProd.AccountNumber = e.AccountNumber;
                            LoanProd.SeqGrp = e.SeqGrp;
                            e.Product = LoanProd;
                            this.OSC04.push(LoanProd);
                            loanCallCount += 1;
                            if (loanCallCount >= loanCallMax) {
                                this.isEndLoan = true;
                            }
                        }).catch(error => {
                            loanCallCount += 1;
                            if (loanCallCount >= loanCallMax) {
                                this.isEndLoan = true;
                            }
                            this.errorMessageControl.error.Loan = true;
                            this.warningMessageAdd(this.label.loanMSG);
                        })
                    });
                } else {
                    this.isEndLoan = true;
                }
                if (this.retryService.Bancassurance) {
                    getProductHttp({
                        endpoint: 'callout:OSC05_List',
                        body: JSON.stringify({
                            'GetBancassuranceAccountRequest': {
                                RMID: this.tmbCustId,
                            }
                        }),
                        tmbCustId: this.tmbCustId
                    }).then(BAProd => {
                        this.OSC05.push(BAProd);
                        this.isEndBancassurance = true;
                    }).catch(error => {
                        this.isEndBancassurance = true;
                        this.errorMessageControl.error.Bancassurance = true;
                        this.warningMessageAdd(this.label.baMSG);
                    })
                }

                if (this.retryService.AutoLoan) {
                    // TODO Callout service Auto loan here
                    this.calloutAutoloanHP();
                }

                if (!this.isShowError && this.OSC01.InvestmentAccount && this.OSC01.InvestmentAccount.length > 0 && this.retryService.Investment) {
                    let investCallCount = 0;
                    let investCallMax = this.OSC01.InvestmentAccount.length;
                    this.OSC01.InvestmentAccount.forEach(async (e, i) => {
                        getProductHttp({
                            endpoint: 'callout:OSC06_List',
                            body: JSON.stringify({
                                'GetInvestmentAccountRequest': {
                                    UnitHolderNo: e.UnitHoldNo
                                }
                            }),
                            tmbCustId: this.tmbCustId
                        }).then(InvestProd => {
                            InvestProd.UnitHoldNo = e.UnitHoldNo;
                            if (InvestProd.GetInvestmentAccountResponse && InvestProd.GetInvestmentAccountResponse.GetFundDetails && InvestProd.GetInvestmentAccountResponse.GetFundDetails.length > 0) {
                                var countGetName = 0;

                                var fundetailSize = InvestProd.GetInvestmentAccountResponse?.GetFundDetails?.length || 0;
                                if (fundetailSize > 1) {
                                    investCallMax += (fundetailSize - 1);
                                }

                                InvestProd.GetInvestmentAccountResponse.GetFundDetails.forEach(fundDetail => {
                                    if (fundDetail.FundCode) {
                                        fundDetail.Name = '';
                                        getProductNameFromRTLProductCode({
                                            productCode: fundDetail.FundCode
                                        }).then(ProductName => {
                                            if (ProductName != '') {
                                                fundDetail.Name = ProductName;
                                            }
                                            countGetName += 1;
                                            if (countGetName >= InvestProd.GetInvestmentAccountResponse.GetFundDetails.length) {
                                                e.Product = InvestProd;
                                                this.OSC06.push(InvestProd);
                                            }
                                            investCallCount += 1;
                                            if (investCallCount >= investCallMax) {
                                                this.isEndInvestment = true;
                                            }
                                        })
                                    }
                                });
                            } else {
                                e.Product = InvestProd;
                                this.OSC06.push(InvestProd);
                                investCallCount += 1;
                                if (investCallCount >= investCallMax) {
                                    this.isEndInvestment = true;
                                }
                            }
                        }).catch(error => {
                            investCallCount += 1;
                            if (investCallCount >= investCallMax) {
                                this.isEndInvestment = true;
                            }
                            this.errorMessageControl.error.Investment = true;
                            this.warningMessageAdd(this.label.investmentMSG);
                        })
                    });
                } else {
                    this.isEndInvestment = true;
                }
            } else {
                this.isHaveCustomer_ID = false;
                this.retryService = this.retryServiceFlag(false);
            }
        }
    }

    renderedCallback() {
        if(this.isShowNoAccess == false){
            var CC_PersonalLoan_SubGroup = this.productHoldingDetail['CC_PersonalLoan'].ProductSubGroup;
            if (this.OSC01) {
                if (!this.OSC01.Message && !this.OSC01.message) {
                    //After callservice OSC02 Deposit
                    var error02Count = 0;
                    if (this.OSC02 && this.OSC01.DepositAccount && this.isEndDeposit && !this.isCalRenderDeposit) {
                        let depositSum = 0;
                        let depositAvail = 0;
                        let otherSum = 0;
                        let otherAvail = 0;
                        var lstmdt;
                        this.productHoldingDetail['Deposit'].flagMin = false; // atk flagMin productHoldingDetail
                        this.OSC01.DepositAccount.forEach((depositAccount, j) => {
                            var depositProd = depositAccount.Product;
                            if (depositProd && !depositProd.message) {
                                depositProd.isGetData = false;
                                try {
                                    let AcctBal = depositProd.GetDepositAccountResponse.AcctInqRs.AcctBal.reduce((l, i) => {
                                        if (!l[i.BalType])
                                            l[i.BalType] = Number(i.CurAmt.Amt);
                                        return l;
                                    }, {});
                                    if (depositProd.SeqGrp == '1' || depositProd.SeqGrp == '2') {

                                        var productCode = depositProd.GetDepositAccountDetailResponse.Result.DepositAccount.ProductCode;
                                        var lstmdt = this.lstMDT;
                                        for (var indexmdt = 0; indexmdt < lstmdt.length; indexmdt++) {
                                            if (productCode == lstmdt[indexmdt].Product_Code__c && AcctBal['Ledger'] < 5000) {
                                                this.productHoldingDetail['Deposit'].flagMin = true; // atk flagMin
                                                this.isALLFREERED = true;
                                            }
                                        }
                                        depositSum = this.calculateSum(depositSum, AcctBal['Ledger']);
                                        depositAvail = this.calculateSum(depositAvail, AcctBal['Avail']);

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
                                    error02Count += 1;
                                    if (error02Count == 1) {
                                        this.errorMessageControl.error.Deposit = true;
                                        this.warningMessageAdd(this.label.depositMSG);
                                    }
                                }
                                depositAccount.Product = depositProd;
                            } else if (depositProd.message && depositProd.message.includes('timeout')) {
                                this.errorMessageControl.timeout.Deposit = true;
                            } else {
                                this.errorMessageControl.error.Deposit = true;
                            }
                        })

                        // })

                        if (this.OSC01.DepositAccount) {
                            try { //Deposit Account
                                let depositSubFamily = [];
                                let depositName = [];
                                this.OSC01.DepositAccount.forEach((e, i) => {
                                    try {
                                        if ((e.SeqGrp == '1' || e.SeqGrp == '2') && e.Product && e.Product.isGetData) {
                                            this.countProductActiveInActive(e, 'Deposit', 'Deposit');

                                        } else {
                                            this.countProductActiveInActive(e, 'Other', 'Deposit');
                                            this.productHoldingDetail['Deposit'].Other.NumberOfProduct += 1;
                                        }
                                        if (e.Product && e.Product.isGetData) {
                                            if (e.ProductSubGroup && e.ProductSubGroup != '#N/A') {
                                                depositSubFamily.push(e.ProductSubGroup);
                                                this.productHoldingDetail['Deposit'].ProductSubGroup = [...new Set(depositSubFamily)];
                                            }
                                            if (e.ProductName && e.ProductName != '#N/A') {
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
                    var error04Count = 0;
                    if (this.OSC04 && this.OSC01.LoanAccount && this.isEndLoan && !this.isCalRenderLoan) {
                        let personalLoanSUM = this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding ? this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding : 0;
                        let securedLoanSUM = 0;
                        let personalLoanAvailSUM = this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable ? this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable : 0;
                        let securedLoanAvailSUM = 0;
                        let otherSum = 0;
                        let otherAvail = 0;
                        this.OSC01.LoanAccount.forEach((LoanAccount, i) => {
                            var LoanProd = LoanAccount.Product;
                            if (LoanProd && !LoanProd.message) {
                                LoanProd.isGetData = false;
                                try {
                                    let AcctInq = LoanProd.GetLoanAccountResponse.AcctInqRs;
                                    let loanOutstand = Number(AcctInq ? AcctInq.AcctBal[0].CurAmt.Amt : 0);
                                    let LoanInfo = LoanProd.GetLoanAccountResponse.AcctInqRs.LOCAcctRec.LoanInfoCommon;
                                    let AcctAvailble = Number(LoanInfo ? LoanInfo.LOCLimit.Amt : 0);
                                    if (LoanProd.SeqGrp == '7') {
                                        personalLoanSUM = this.calculateSum(personalLoanSUM, loanOutstand);
                                        personalLoanAvailSUM = this.calculateSum(personalLoanAvailSUM, AcctAvailble);
                                        this.productHoldingDetail['CC_PersonalLoan'].TotalOutstanding = personalLoanSUM;
                                        this.productHoldingDetail['CC_PersonalLoan'].TotalAvailable = personalLoanAvailSUM;
                                        LoanProd.isGetData = true;
                                    }
                                    if (LoanProd.SeqGrp == '8') {
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
                            } else if (LoanProd.message && LoanProd.message.includes('timeout')) {
                                this.errorMessageControl.timeout.Loan = true;
                            } else {
                                this.errorMessageControl.error.Loan = true;
                            }
                            LoanAccount.Product = LoanProd;
                        })

                        if (this.OSC01.LoanAccount) {
                            try { //Loan Account
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
                                        } else if (e.SeqGrp && e.SeqGrp == '8' && e.Product && e.Product.isGetData) {
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

                    //After callservice OSC06 Investment
                    var error06Count = 0;
                    if (this.OSC06 && this.OSC01.InvestmentAccount && this.isEndInvestment && !this.isCalRenderInvestment) {
                        let investAvailSUM = 0;
                        let otherAvail = 0;
                        let investName = [];
                        let isGetError = false;
                        this.OSC01.InvestmentAccount.forEach((e, i) => {
                            let investProduct = e.Product;
                            if (investProduct && !investProduct.message) {
                                try {
                                    if (investProduct.GetInvestmentAccountResponse.GetFundDetails && investProduct.GetInvestmentAccountResponse.GetFundDetails.length > 0) {
                                        let getFundDetails = investProduct.GetInvestmentAccountResponse.GetFundDetails;
                                        let isHaveProductName = false;
                                        getFundDetails.forEach(FundDetail => {
                                            let investValue = Number(FundDetail.detailFund.InvestmentValue ? FundDetail.detailFund.InvestmentValue : 0);
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
                        })

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

            if (this.isEndCreditCard && this.SCSCredit && !this.isCalRenderCreditCard) {
                try { 
                    let creditcardName = this.productHoldingDetail['CC_PersonalLoan'].ProductName;
                    this.SCSCredit.forEach((e, i) => {
                        try {

                            if (e.SeqGrp == '3') {
                                this.countProductActiveInActive(e, 'CC_PersonalLoan', 'CC_PersonalLoan');
                            } else if (e.SeqGrp == 'OTHERS') {
                                this.countProductActiveInActive(e, 'Other', 'CC_PersonalLoan');
                                this.productHoldingDetail['CC_PersonalLoan'].Other.NumberOfProduct += 1;
                            }
                            if (e.SubProductGroup && e.SubProductGroup != '#N/A') {
                                CC_PersonalLoan_SubGroup.push(e.SubProductGroup);
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
                } catch (error) {
                    this.isCalRenderCreditCard = true;
                    console.error('OSC01 Creditcard error', error);
                }
            }

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
                this.OSC05.forEach((BAProd, i) => {
                    if (!BAProd.message) {
                        try {
                            if (BAProd.GetBancassuranceAccountResponse && BAProd.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets.length > 0) {
                                let productDataSets = BAProd.GetBancassuranceAccountResponse.InsurancePolicyListCRMInqResponse.InsurancePolicyListCRMInqResult.DataSets;
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

            // TODO Autu loan rerender call back here
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
                this.isCalRenderInvestment &&
                this.isCalRenderCreditCard) {
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
            this.sumTotalOther();
        }
    }

    clearOtherOfProduct(productName) {
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
    }

    openProductholding(event) {
        if (this.isIPad || this.isTablet) {
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
        } else if (objtype != 'Other') {
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

    getCreditCard(body) {
        getProductSCSCreditCard({
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
                    this.getCreditCard(body);
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
                } else {
                    console.error('Credit Card error');
                    this.errorMessageControl.error.CreditCard = true;
                }
            } else if (creditcardProds && ['System error', 'is Null'].some(substring => creditcardProds.includes(substring))) {
                console.error('Chart credit service System error');
                this.errorMessageControl.error.CreditCard = true;
                this.warningMessageAdd(this.label.creditCardMSG);
            } else if (creditcardProds && ['Timeout', 'timeout', 'เรียกดูข้อมูลอีกครั้ง'].some(substring => creditcardProds.includes(substring))) {
                this.errorMessageControl.timeout.CreditCard = true;
            }
            if (creditcardProds.result && creditcardProds.result.more_records == 'Y') {
                this.isEndCreditCard = false;
            } else {
                this.isEndCreditCard = true;
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
                    message: '',
                    beforeLink: '',
                    afterLink: '',
                    clickHere: '',
                },
                InfoProducts: '',
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

    retryServiceFlag(flag) {
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
            message: '',
            beforeLink: '',
            afterLink: '',
            clickHere: '',
        }
        this.errorMessageControl.isShowMessage.Retry = false;
        if (isRetry.OSC01 || isRetry.CreditCard || isRetry.Bancassurance || isRetry.AutoLoan) {
            this.retryService.ReCalculate = true;
            this.callServices();
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
        // return checkObject.Bancassurance ||
        //     checkObject.CreditCard ||
        //     checkObject.Deposit ||
        //     checkObject.Investment ||
        //     checkObject.Loan ||
        //     checkObject.OSC01;
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

    // @wire(getALDXWFMdt, {})
    // callbackALDXWF({
    //     error,
    //     data
    // }) {
    //     this._ALDXWFMdt = data ? data : {};
    // }

    async calloutAutoloanHP() {
        try {
            // Retail Hire purchase (HP)
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

            this.errorMessageControl.timeout.AutoLoan = result.isTimeout ? true : false
            this.errorMessageControl.error.AutoLoan = result.isError || result.isThrow ? true : false
            if (this.errorMessageControl.timeout.AutoLoan || this.errorMessageControl.error.AutoLoan) {
                this.warningMessageAdd(this.label.autoloanMSG)
            }

            let addx_warning = Object.keys(this._ALDXWFMdt).reduce((l, i) => {
                if (this._ALDXWFMdt[i].WARNING_MESSAGE__c) l[i] = this._ALDXWFMdt[i]
                return l;
            }, {})
            this.AutoLoan = getValueReference('Output.length', result) ?
                await Promise.all(getValueReference('Output', result).map(async (m) => {
                    m._OutstandingAmount = addx_warning[m.ContractStatusCode] ? 0 : this.toFixedTwoDigits(Number(m.OutstandingAmount))
                    m._HPTotalAmount = this.toFixedTwoDigits(Number(m.HPTotalAmount))
                    let productDetail = await getProductAutoLoan({
                        'endpoint': 'callout:AutoLoan_HpFleetHpDetail',
                        'callback': 'callbackHpFleetHpDetail',
                        'body': JSON.stringify({
                            "Company": company,
                            "ContractNo": m.ContractNo,
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
                    m._ProductName = getValueReference('Output.0.ProductCode', productDetail)
                    return m
                })) : [];
        } catch (e) {
            this.warningMessageAdd(this.label.autoloanMSG)
            console.error(e)
        } finally {
            this.isEndAutoLoan = true;
        }
    }
}