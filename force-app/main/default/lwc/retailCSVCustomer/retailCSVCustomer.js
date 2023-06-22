import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import userId from '@salesforce/user/Id';
import getDescribeFieldResultAndValue from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';
import getSubDebtTransaction from '@salesforce/apex/RetailCSVLightningUtil.getSubDebtTransaction';
import getCustomer from '@salesforce/apex/RetailCSVCustomerChartController.fetchAccount';
// import getCVSObject from '@salesforce/apex/RetailCSVCustomerChartController.getCVSObject';
import getCVSObject2 from '@salesforce/apex/RetailCSVCustomerChartController.getCVSObject2'; // web service
import getBranch from '@salesforce/apex/RetailCSVCustomerChartController.getBranch';
import getBranchFromID from '@salesforce/apex/RetailCSVCustomerChartController.getBranchFromID';
import getUser from '@salesforce/apex/RetailCSVCustomerChartController.getUser';
import getPdpa from '@salesforce/apex/pdpaCalloutUtil.getFagPdpa'; //web service
import getAccountForCheckQM_A from '@salesforce/apex/RetailCSVCustomerChartController.getAccountForCheckQM_A';
import dataCheckQM_A from '@salesforce/apex/RetailCSVCustomerChartController.dataCheckQM_A';
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import getProfilverifyFieldSecurityeName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity';
import getVisibleByField from '@salesforce/apex/RetailCSVLightningUtil.getVerifyByField';
import getDataAfterRefresh   from '@salesforce/apex/RetailCSVLightningUtil.getDataAfterRefresh';
import getSubSegmentCodeMapping from '@salesforce/apex/RetailCSVLightningUtil.getSubSegmentCodeMapping';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import RTL_Data_Quality_Marketing from '@salesforce/label/c.RTL_Data_Quality_Marketing';
import RTL_Data_Age from '@salesforce/label/c.RTL_Data_Age';
import RTL_Quality_More_Detail from '@salesforce/label/c.RTL_Quality_More_Detail';
import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';
import Number_Of_Retry_Times from '@salesforce/label/c.Number_Of_Retry_Times';
import Retry_SetTimeOut from '@salesforce/label/c.Retry_SetTimeOut';
import ttbTouchStatus from '@salesforce/label/c.ttbTouchStatus';

import PDPA_Accept_YES from '@salesforce/label/c.PDPA_Accept_YES';
import PDPA_Accept_NO from '@salesforce/label/c.PDPA_Accept_NO';
import PDPA_Flag_No_Message from '@salesforce/label/c.PDPA_Flag_No_Message';
import Sub_Debt_Transaction_Flag from '@salesforce/label/c.Sub_Debt_Transaction_Flag';


import {
    refreshApex
} from '@salesforce/apex';
import {
    parseObj
} from 'c/methodUtils';
import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = [
    'CSV_Customer_Image__c', 'RTL_Total_Asset__c', 'Total_Asset_image__c', 'RTL_AUM__c', 'RTL_AUM_Last_Calculated_Date__c',
    'TMB_Customer_ID_PE__c', 'RTL_Customer_Name_TH__c', 'Customer_Name_PE_Eng__c', 'Customer_Type__c', 'Core_Banking_Suggested_Segment__c',
    'Sub_segment__c', 'Customer_Status__c', 'RTL_Benefit_Status__c', 'VIP_Status__c', 'Mobile_Number_PE__c', 'Email_Address_PE__c',
    'RTL_Date_Of_Birth__c', 'RTL_Age__c', 'RTL_Income__c', 'RTL_Primary_Banking_All_Free_Benefit__c', 'RTL_Do_Not_Call__c',
    'FATCA__c', 'FATCA_Form_Completed__c', 'RTL_Risk_Level_Details__c', 'RTL_Suitability__c', 'RTL_Fund_Risk_Mismatch__c',
    'RTL_Fund_High_Concentration_Risk__c', 'ID_Type_PE__c', 'NID__c', 'RTL_Is_Employee__c', 'RTL_Most_Visited_Branch__c', 'RTL_Most_Operating_Branch__c', 'RTL_Assigned_BRC__c',
    'RTL_Wealth_RM__c', 'RTL_Commercial_RM__c', 'Hobbies__c', 'Favorite_Sport__c', 'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c',
    'RTL_Other1__c', 'Operating_Model__c', 'RTL_Special_Pref__c', 'RTL_Life_Objective_1__c', 'RTL_Life_Objective_2__c',
    'RTL_Life_Objective_3__c', 'RTL_Other2__c', 'Next_Generate_task_date__c', 'Last_Generate_task_date__c',
    'RTL_Wealth_RM__r.Name', 'Wealth_RM_EMP_Code__c', 'RTL_Commercial_RM__r.Name', 'RTL_Commercial_RM__r.Employee_ID__c', 'OwnerId',
    'RTL_Assigned_BRC__r.Name', 'RTL_Assigned_BRC__r.Employee_ID__c', 'RTL_Check_WM_RM_as_PWA__c', 'RTL_Main_Bank_Desc__c', 'RTL_Average_AUM__c', 'Name', 'Zip_Code_Primary_PE__c',
    'RTL_Privilege1__c', 'Segment_crm__c', 'KYC_Update__c', 'KYC_flag__c', 'E_KYC__c', 'IAL__c', 'Action_Box__c', 'Account_Type__c', 'RTL_OTC_ATM_ADM_IB_MIB__c', 'RTL_MIB_Status__c', 'RTL_Privilege2__c', 'RTL_RM_Name__c', 'Id'
];

const FIELDS_TRANSLATE = [
    'Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'RTL_Other1__c',
    'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c',
];


const function_field_section = {
    'dataQM': 'RtlCust:Customer Demographic (Low)',
    'dataAge': 'RtlCust:Customer Demographic (Low)',
    'moreDetail': 'RtlCust:Customer Demographic (Low)',
    'pdpaDetail': 'RtlCust:Customer Demographic (Low)',
    'marketDetail': 'RtlCust:Customer Demographic (Low)'
}


export default class RetailCSVCustomer extends LightningElement {
    function_obj = ['pdpaDetail', 'marketDetail'];

    // Device size
    devicesize = {
        size: 12,
        small: 12,
        medium: 6,
        large: 6
    }
    devicesizeiPad = {
        sizeSmallLeft: 12,
        sizeSmallMiddle: 12,
        sizeMediumLeft: 4,
        sizeMediumMiddle: 8
    }

    @api recordId;
    @api userAgent = 'Desktop';
    // @api wireCustomer;
    // @api realFormCustomer;
    profileName;
    customerData;
    accountQM_A;
    branchData;
    branchID;
    branchOperateData;
    @track activeSections = ['custHilightSummary'];
    @track customerDetail = {};
    @track dataPartition = {};
    @track isGetDataPartition = false;
    @track isiPad = false;
    @track isTablet = false;
    // Water Mark
    @track watermarkImage = "";
    @track isSubsidiary = false;
    isRerender = false;

    fontColor = '';
    fontColorTTBTouch = '';
    fontColorPDPA = '';
    backgroundColor = '';

    _DateOfBirth;

    _Wealth_RM;
    _Commercial_RM;
    _Assigned_BRC;
    _Wealth_RM_Url;
    _Commercial_RM_Url;
    _Assigned_BRC_Url;
    _Assigned_BRC_Employee;

    CVSObject;
    primaryBank;
    suitability;
    mostVisitBr;
    mostOperateBR;
    @track subSegment;
    ttbtouch;
    subDebtData = Data_Condition_Hidden_Text;
    _BranchName;
    _BranchUrl;
    _BranchOperateName;
    _BranchOperateUrl;
    dataQM;
    dataAge;
    _moreDetailURL;
    _moreDetailURLTest;

    pdpdDetail;
    marketDetail;

    label = {
        RTL_Data_Quality_Marketing,
        RTL_Data_Age,
        RTL_Quality_More_Detail,
        Data_Condition_Hidden_Text,
        ttbTouchStatus,
        Sub_Debt_Transaction_Flag
    };

    @api
    refreshPage(fieldUpdate) {
        let customerDetailChange = this.customerDetail;
        this.customerDetail = null;
        let customerTranslates = {};
        Object.keys(fieldUpdate).forEach(fieldName => {
            if (customerDetailChange[fieldName] && customerDetailChange[fieldName].value != fieldUpdate[fieldName]) {
                customerDetailChange[fieldName].value = fieldUpdate[fieldName];
            }
        });
        getDataAfterRefresh({
            recordId: this.recordId,
            fields: FIELDS,
            fields_translate: FIELDS_TRANSLATE,
        }).then(result => {
            // customerTranslates = result;
            // FIELDS_TRANSLATE.forEach(element => {
                // if (customerDetailChange[element]) {
                    // customerDetailChange[element].value = customerTranslates[element].value;
                // }
            // });
            // this.customerDetail = null;
            // this.customerDetail = customerDetailChange;
            this.fontColor = '';
            this.customerDetail = parseObj(result);
            this._DateOfBirth = new Date(this.customerDetail.RTL_Date_Of_Birth__c.value);
            this.customerDetail.RTL_Income__c.value = this.customerDetail.RTL_Is_Employee__c.value ? 0 : this.customerDetail.RTL_Income__c.value;
            var kycUpdate = this.customerDetail.KYC_Update__c.value;
            if (kycUpdate.includes('ใกล้หมดอายุ')) {
                this.fontColor = '#d09b05';
            } else if (kycUpdate == 'กรุณาปรับปรุงข้อมูล') {
                this.fontColor = 'Red';
            }

            let isSubsidiary = this.profileName.includes("Subsidiary");
            this.isSubsidiary = isSubsidiary;

            getVisibleByField({
                field: 'pdpaDetail',
                profileName: this.profileName,
                recordId: this.recordId
            }).then(result => {
                this.dataPartition['pdpaDetail'].isVisible = result;
                if(result == true){
                    const cvsPdpaAcc = this.makeAccForCVSPDPA(parseObj(result));
                    this.callGetPDPA(cvsPdpaAcc);
                }
            }).catch(error => {
                console.error(error);
            });

            getVisibleByField({
                field: 'marketDetail',
                profileName: this.profileName,
                recordId: this.recordId
            }).then(result => {
                this.dataPartition['marketDetail'].isVisible = result;
                if(result == true){
                    const cvsPdpaAcc = this.makeAccForCVSPDPA(this.customerDetail);
                    this.callGetCVSObject(cvsPdpaAcc);
                }
            }).catch(error => {
                console.error(error);
            });

            Object.keys(this.customerDetail).forEach((v, i) => {
                this.dataPartition[v] = {
                    isVisible: false
                }
                if (i >= FIELDS.length - 1) {
                    this.isGetDataPartition = true;
                }
                this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
            });
            if (this.customerDetail.RTL_Wealth_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Wealth_RM__c.value
                })
                    .then(result => {
                        var pwa = this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
                        this._Wealth_RM = `${result.Name} (${pwa}${this.customerDetail['Wealth_RM_EMP_Code__c'].value})`;
                        this._Wealth_RM_Url = '/lightning/r/' + result.Id + '/view';
                    })
                    .catch(error => {
                        console.error('Get Wealth_RM error', error);
                    });
            }
            if (this.customerDetail.RTL_Commercial_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Commercial_RM__c.value
                })
                    .then(result => {
                        this._Commercial_RM = `${result.Name} (${this.customerDetail['RTL_Commercial_RM__r.Employee_ID__c'].value})`;
                        this._Commercial_RM_Url = '/lightning/r/' + result.Id + '/view';
                    })
                    .catch(error => {
                        console.error('Get Commercial_RM error', error);
                    });
            }
            if (this.customerDetail.RTL_Assigned_BRC__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Assigned_BRC__c.value
                })
                    .then(result => {
                        if (this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value) {
                            this._Assigned_BRC = `${result.Name} (${this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value})`;
                        } else {
                            this._Assigned_BRC = `${result.Name} ()`;
                        }
                        this._Assigned_BRC_Url = '/lightning/r/' + result.Id + '/view';
                        this._Assigned_BRC_Employee = this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'] ? this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value : '';
                    })
                    .catch(error => {
                        console.error('Get RTL_Assigned_BRC__c error', error);
                    });
            }
            if (this.customerDetail.RTL_Most_Operating_Branch__c.value) {
                getBranchFromID({
                    branchId: this.customerDetail.RTL_Most_Operating_Branch__c.value
                })
                    .then(result => {
                        this.branchOperateData = result;
                        if (this.branchOperateData.Branch_Code__c) {
                            this._BranchOperateName = this.branchOperateData.Name;
                            this._BranchOperateUrl = '/lightning/r/' + this.branchOperateData.Id + '/view';
                        }
                    })
                    .catch(error => {
                        console.error('Get Operate Branch for display error', error);
                    })
            }
            if(this.customerDetail.RTL_Primary_Banking_All_Free_Benefit__c.isAccessible == true){
                var primaryBankFlag = this.customerDetail.RTL_Primary_Banking_All_Free_Benefit__c.value == true ? 'Yes' : 'No';
                if (this.customerDetail.RTL_Main_Bank_Desc__c.value != '') {
                    this.primaryBank = primaryBankFlag + ' [' + this.customerDetail.RTL_Main_Bank_Desc__c.value + ']';
                } else {
                    this.primaryBank = primaryBankFlag
                }
            }
            else{
                this.primaryBank = '***********';
            }
        })
        .catch(error => {
            console.error('Refresh Page error : ', error);
        })

        // if (customerDetailChange.RTL_Assigned_BRC__c.value) {
            // getReferenceByFieldName({
                // recordId: customerDetailChange.RTL_Assigned_BRC__c.value,
                // fieldName: 'Employee_ID__c'
            // }).then(result => {
                // this._Assigned_BRC_Employee = result ? result : '';
            // }).catch(error => {
                // console.error(error);
            // });
        // }
        // this.customerDetail = null;
        // this.customerDetail = customerDetailChange;
    }


    connectedCallback() {
        this._moreDetailURL = '/apex/RTL_DataQualityDetails?Id=' + this.recordId + '&isdtp=vw';
        this._moreDetailURLTest = 'javascript:srcUp(\'' + this._moreDetailURL + '\');';
        FIELDS.forEach(k => {
            this.customerDetail[k] = {
                name: '',
                value: '',
                label: '',
                type: '',
                inlineHelpText: '',
                isAccessible: false,
            }
            this.dataPartition[k] = {
                isVisible: false
            }
        });
        this.function_obj.forEach(k => {
            this.dataPartition[k] = {
                isVisible: false
            }
        })
        let NavigationUserAgent = navigator.userAgent;
        if (NavigationUserAgent.includes('iPad') || NavigationUserAgent.includes('IPAD') || NavigationUserAgent.includes('iPhone') || NavigationUserAgent.includes('iphone')) {
            this.isiPad = true;
        }
        if (NavigationUserAgent.includes('android') || NavigationUserAgent.includes('Android')) {
            this.isTablet = true;
        }

        this.getSubDebtTransaction();
    }

    renderedCallback() {
        // if (this.isRerender) {
        //     return;
        // }
        this.isRerender = true;
    }

    disconnectedCallback() {
        refreshApex(this.customerDetail);
    }

    @wire(getDescribeFieldResultAndValue, {
        recordId: '$recordId',
        fields: FIELDS,
        fields_translate: FIELDS_TRANSLATE,
    })
    async wiredGetDescribeFieldResultAndValue({
        error,
        data
    }) {
        if (data) {
            this.fontColor = '';
            this.customerDetail = parseObj(data);
            this._DateOfBirth = new Date(this.customerDetail.RTL_Date_Of_Birth__c.value);
            this.customerDetail.RTL_Income__c.value = this.customerDetail.RTL_Is_Employee__c.value ? 0 : this.customerDetail.RTL_Income__c.value;
            var kycUpdate = this.customerDetail.KYC_Update__c.value;
            if (kycUpdate.includes('ใกล้หมดอายุ')) {
                this.fontColor = '#d09b05';
            } else if (kycUpdate == 'กรุณาปรับปรุงข้อมูล') {
                this.fontColor = 'Red';
            }
             this.profileName = await getProfileName({
                userId: userId
            });

            let isSubsidiary = this.profileName.includes("Subsidiary");
            this.isSubsidiary = isSubsidiary;
            await getVisibleByField({
                field: 'pdpaDetail',
                profileName: this.profileName,
                recordId: this.recordId
            }).then(async result => {
                this.dataPartition['pdpaDetail'].isVisible = result;
                if(result == true){
                    const cvsPdpaAcc = this.makeAccForCVSPDPA(parseObj(data));
                    await this.callGetPDPA(cvsPdpaAcc);
                }
            }).catch(error => {
                console.error(error);
            });    
            
            await getVisibleByField({
                field: 'marketDetail',
                profileName: this.profileName,
                recordId: this.recordId
            }).then(async result => {
                this.dataPartition['marketDetail'].isVisible = result;
            }).catch(error => {
                console.error(error);
            });    

            await getProfilverifyFieldSecurityeName({
                section: 'RtlCust:Customer Relationship',
                userProfile: this.profileName,
                accountId: this.recordId
            }).then( async result => {
                if(result == true){
                    const cvsPdpaAcc = this.makeAccForCVSPDPA(this.customerDetail);
                    await this.callGetCVSObject(cvsPdpaAcc);
                }
            }).catch(error => {
                console.error(error);
            });

            Object.keys(this.customerDetail).forEach((v, i) => {
                this.dataPartition[v] = {
                    isVisible: false
                }
                if (i >= FIELDS.length - 1) {
                    this.isGetDataPartition = true;
                }
                this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
            });
            if (this.customerDetail.RTL_Wealth_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Wealth_RM__c.value
                })
                    .then(result => {
                        var pwa = this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
                        this._Wealth_RM = `${result.Name} (${pwa}${this.customerDetail['Wealth_RM_EMP_Code__c'].value})`;
                        this._Wealth_RM_Url = '/lightning/r/' + result.Id + '/view';
                    })
                    .catch(error => {
                        console.error('Get Wealth_RM error', error);
                    });
            }
            if (this.customerDetail.RTL_Commercial_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Commercial_RM__c.value
                })
                    .then(result => {
                        this._Commercial_RM = `${result.Name} (${this.customerDetail['RTL_Commercial_RM__r.Employee_ID__c'].value})`;
                        this._Commercial_RM_Url = '/lightning/r/' + result.Id + '/view';
                    })
                    .catch(error => {
                        console.error('Get Commercial_RM error', error);
                    });
            }
            if (this.customerDetail.RTL_Assigned_BRC__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Assigned_BRC__c.value
                })
                    .then(result => {
                        if (this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value) {
                            this._Assigned_BRC = `${result.Name} (${this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value})`;
                        } else {
                            this._Assigned_BRC = `${result.Name} ()`;
                        }
                        this._Assigned_BRC_Url = '/lightning/r/' + result.Id + '/view';
                        this._Assigned_BRC_Employee = this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'] ? this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value : '';
                    })
                    .catch(error => {
                        console.error('Get RTL_Assigned_BRC__c error', error);
                    });
            }
            if (this.customerDetail.RTL_Most_Operating_Branch__c.value) {
                getBranchFromID({
                    branchId: this.customerDetail.RTL_Most_Operating_Branch__c.value
                })
                    .then(result => {
                        this.branchOperateData = result;
                        if (this.branchOperateData.Branch_Code__c) {
                            this._BranchOperateName = this.branchOperateData.Name;
                            this._BranchOperateUrl = '/lightning/r/' + this.branchOperateData.Id + '/view';
                        }
                    })
                    .catch(error => {
                        console.error('Get Operate Branch for display error', error);
                    })
            }
            if(this.customerDetail.RTL_Primary_Banking_All_Free_Benefit__c.isAccessible == true){
                var primaryBankFlag = this.customerDetail.RTL_Primary_Banking_All_Free_Benefit__c.value == true ? 'Yes' : 'No';
                if (this.customerDetail.RTL_Main_Bank_Desc__c.value != '') {
                    this.primaryBank = primaryBankFlag + ' [' + this.customerDetail.RTL_Main_Bank_Desc__c.value + ']';
                } else {
                    this.primaryBank = primaryBankFlag
                }
            }
            else{
                this.primaryBank = '***********';
            }
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading',
                    message: error,
                    variant: 'error',
                }),
            );
        }
    }

    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    async callGetCVSObject(acc) {
        this.fontColorTTBTouch = '';
        let noOfRetry = parseInt(Number_Of_Retry_Times);
        let isSuccess = false;
        let delay = parseInt(Retry_SetTimeOut);
        let retry = 0;
        while (!isSuccess && noOfRetry >= 0) {
            if(retry > 0) {
                this.ttbtouch = 'Error getting data, retrying... ('+retry+')';
                await this.sleep(delay); // sleep 20sec
            }
            await getCVSObject2({
                recordId: this.recordId,
                account: acc
            })
                .then(async result => {
                    result = JSON.parse(result);
                    if (result['errorMessage'] == 'invalid_token') {
                        noOfRetry -= 1;
                        retry++;
                    } else {
                        if (result['touchStatus'] == 'YES') {
                            let last_login = result['LastLoginSuccessDate'];
                            let date_format = '';
                            if (last_login) {
                                const date = new Date(last_login);
                                date_format = date.toLocaleDateString('th-TH', {
                                    year: '2-digit',
                                    month: 'short',
                                    day: 'numeric',
                                })
                            }
                            this.ttbtouch = 'มี (เข้าใช้งานล่าสุด ' + date_format + ')';
                            this.fontColorTTBTouch = '';
                        } else {
                            this.ttbtouch = 'ไม่มี';
                            this.fontColorTTBTouch = 'Red';
                        }
                        this.mostVisitBr = result['csProfFreqBr'];
                        this.subSegment = result['csProfSubsegment'];
                        this.suitability = result['suitability'];
                        isSuccess = true;
                        await getSubSegmentCodeMapping({
                            subSegmentCode: this.subSegment
                        }).then (async result => {
                            this.subSegment = result;                                
                        })
                        .catch(error => {
                            console.log('Get Sub Segment Code Description error\n\n', error);
                        })
                            
                        getBranch({
                            brCode: this.mostVisitBr
                        }).then(result => {
                            this.branchData = result;
                            this.branchID = this.branchData.Id;
                            if (this.branchData.Branch_Code__c) {
                                this._BranchName = this.branchData.Name;
                                this._BranchUrl = '/lightning/r/' + this.branchID + '/view';
                            }
                        }).catch(error => {
                            console.log('retail customer OSC07 Get Branch Name error\n\n', error);
                        })
                    }
                })
                .catch(async error => {
                    console.error(error);
                    noOfRetry = -1;
                });
        }
        if (!isSuccess) {
            this.ttbtouch = 'Error getting data';
            this.fontColorTTBTouch = 'Red';
        }
    }
    async callGetPDPA(acc) {
        let isSuccess = false;
        let retry = 0;
        let noOfRetry = parseInt(Number_Of_Retry_Times);
        let delay = parseInt(Retry_SetTimeOut);
        while (!isSuccess && noOfRetry >= 0) {
            if(retry > 0) {
                this.pdpdDetail = 'Error getting data, retrying... ('+retry+')';
                this.marketDetail = 'Error getting data, retrying... ('+retry+')';
                await this.sleep(delay); // sleep 20sec
            }
            await getPdpa({
                tmbCustId: acc.TMB_Customer_ID_PE__c,
                serviceName: 'PDPA_GET_CONSENT_FAG_CSV_RETAIL_PAGE'
            })
                .then(result => {
                    var resultObj = JSON.parse(result);
                    if(resultObj['errorMessage'] == 'invalid_token') {
                        noOfRetry -= 1;
                        retry++;
                    }
                    else if (resultObj.isSuccess == 'true') {
                        this.backgroundColor = 'padding-left: 3%;';
                        if (resultObj.PDPAFag == 'Y') {
                            this.pdpdDetail = PDPA_Accept_YES;
                            this.backgroundColor += 'background-color: rgb(0, 176, 85);'
                        } else if (resultObj.PDPAFag == 'N') {
                            this.pdpdDetail = PDPA_Accept_NO +'\n'+PDPA_Flag_No_Message;
                            this.backgroundColor += 'background-color: red;'
                        }

                        if (resultObj.MARKETFag == 'Y') {
                            this.marketDetail = PDPA_Accept_YES;
                        } else if (resultObj.MARKETFag == 'N') {
                            this.marketDetail = PDPA_Accept_NO;
                        }
                        isSuccess = true;
                    } else {
                        noOfRetry = -1;
                    }
                }).catch(error => {
                    console.error(error);
                    noOfRetry = -1;
                })
        }
        if (!isSuccess) {
            this.pdpdDetail = 'Error getting data';
            this.marketDetail = 'Error getting data';
            this.fontColorPDPA = 'Red';
            this.backgroundColor += 'color: red;'
        }
    }

    //hover
    @track HoverID;
    @track isOutHover;
    @track top = 50;
    @track left = 50;
    @track HoverObjAPIName;

    showData(event) {
        if (!this.isTablet && !this.isiPad) {
            this.isOutHover = false;
            this.HoverID = event.currentTarget.dataset.objectId;
            this.HoverObjAPIName = event.currentTarget.dataset.objApiName;
            this.left = event.clientX;
            this.top = event.pageY - 220;
        }

    }
    hideData(event) {
        this.isOutHover = true;
    }
    overHover(event) {
        this.isOutHover = false;
    }

    outHover(event) {
        this.isOutHover = true;
    }

    get hoverStatus() {
        let styleText = (this.isOutHover) ? `display: none` : ``;
        return styleText;
    }
    //hover

    @wire(getWatermarkHTML)
    getWatermark({
        error,
        data
    }) {
        if (data) {
            var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + data + "</text></svg>");
            var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
            this.watermarkImage = 'background-image: ' + bg + ';width:100%;height:100%';
        }
        else{
            console.error(error);
        }
    }

    getSubDebtTransaction(){
        getSubDebtTransaction({
            accId : this.recordId
        }).then(result => {
            this.subDebtData = result;
        }).catch(error => {
            console.error(error);
        });
    }

    makeAccForCVSPDPA(customerDetail){
        const acc = {
            Account_Type__c : customerDetail['Account_Type__c'].value == undefined ? '' : customerDetail['Account_Type__c'].value,
            Core_Banking_Suggested_Segment__c : customerDetail['Core_Banking_Suggested_Segment__c'].value == undefined ? '' : customerDetail['Core_Banking_Suggested_Segment__c'].value,
            E_KYC__c : customerDetail['E_KYC__c'].value == undefined ? '' : customerDetail['E_KYC__c'].value,
            Id : customerDetail['Id'].value == undefined ? '' : customerDetail['Id'].value,
            KYC_Update__c : customerDetail['KYC_Update__c'].value == undefined ? '' : customerDetail['KYC_Update__c'].value,
            Name : customerDetail['Name'].value  == undefined ? '' : customerDetail['Name'].value,
            Zip_Code_Primary_PE__c : customerDetail['Zip_Code_Primary_PE__c'].value == undefined ? '' : customerDetail['Zip_Code_Primary_PE__c'].value,
            TMB_Customer_ID_PE__c : customerDetail['TMB_Customer_ID_PE__c'].value == undefined ? '' : customerDetail['TMB_Customer_ID_PE__c'].value,
            OwnerId : customerDetail['OwnerId'].value == undefined ? '' : customerDetail['OwnerId'].value,
            RTL_OTC_ATM_ADM_IB_MIB__c : customerDetail['RTL_OTC_ATM_ADM_IB_MIB__c'].value == undefined ? '' : customerDetail['RTL_OTC_ATM_ADM_IB_MIB__c'].value,
            RTL_MIB_Status__c : customerDetail['RTL_MIB_Status__c'].value == undefined ? '' : customerDetail['RTL_MIB_Status__c'].value,
            RTL_Suitability__c : customerDetail['RTL_Suitability__c'].value == undefined ? '' : customerDetail['RTL_Suitability__c'].value,
            RTL_Privilege2__c : customerDetail['RTL_Privilege2__c'].value == undefined ? '' : customerDetail['RTL_Privilege2__c'].value,
            RTL_RM_Name__c : customerDetail['RTL_RM_Name__c'].value == undefined ? '' : customerDetail['RTL_RM_Name__c'].value,
            RTL_Wealth_RM__c : customerDetail['RTL_Wealth_RM__c'].value == undefined ? '' : customerDetail['RTL_Wealth_RM__c'].value,
            Wealth_RM_EMP_Code__c : customerDetail['Wealth_RM_EMP_Code__c'].value == undefined ? '' : customerDetail['Wealth_RM_EMP_Code__c'].value,
            RTL_Commercial_RM__c : customerDetail['RTL_Commercial_RM__c'].value == undefined ? '' : customerDetail['RTL_Commercial_RM__c'].value,
            RTL_AUM_Last_Calculated_Date__c : customerDetail['RTL_AUM_Last_Calculated_Date__c'].value == undefined || customerDetail['RTL_AUM_Last_Calculated_Date__c'].value == '***********' ? '' : customerDetail['RTL_AUM_Last_Calculated_Date__c'].value,
            Sub_segment__c : customerDetail['Sub_segment__c'].value == undefined ? '' : customerDetail['Sub_segment__c'].value,
            RTL_Fund_Risk_Mismatch__c : customerDetail['RTL_Fund_Risk_Mismatch__c'].value == undefined ? '' : customerDetail['RTL_Fund_Risk_Mismatch__c'].value,
            RTL_Fund_High_Concentration_Risk__c : customerDetail['RTL_Fund_High_Concentration_Risk__c'].value == undefined ? '' : customerDetail['RTL_Fund_High_Concentration_Risk__c'].value,
            IAL__c : customerDetail['IAL__c'].value == undefined ? '' : customerDetail['IAL__c'].value,
            KYC_flag__c : customerDetail['KYC_flag__c'].value == undefined ? '' : customerDetail['KYC_flag__c'].value,
            RTL_Most_Visited_Branch__c: customerDetail['RTL_Most_Visited_Branch__c'].value == undefined ? '' : customerDetail['RTL_Most_Visited_Branch__c'].value,
            RTL_Average_AUM__c : customerDetail['RTL_Average_AUM__c'].value == undefined || customerDetail['RTL_Average_AUM__c'].value == '***********' ? '' : customerDetail['RTL_Average_AUM__c'].value,
        }
        return acc;
    }

    makeAccForDataQm(customerDetail){
        const acc = {
            Account_Type__c : customerDetail.Account_Type__c.value,
            Core_Banking_Suggested_Segment__c : customerDetail.Core_Banking_Suggested_Segment__c.value,
            Email_Address_PE__c : customerDetail.Email_Address_PE__c.value,
            ID_Number_PE__c : customerDetail.ID_Number_PE__c.value,
            ID_Type_PE__c : customerDetail.ID_Type_PE__c.value,
            Id : customerDetail.Id.value,
            Mobile_Number_PE__c : customerDetail.Mobile_Number_PE__c.value,
            Name : customerDetail.Name.value,
            Office_Address_Line_1_PE__c : customerDetail.Office_Address_Line_1_PE__c.value,
            Primary_Address_Line_1_PE__c : customerDetail.Primary_Address_Line_1_PE__c.value,
            RTL_Date_Of_Birth__c : customerDetail.RTL_Date_Of_Birth__c.value,
            Registered_Address_Line_1_PE__c : customerDetail.Registered_Address_Line_1_PE__c.value,
            Segment_crm__c : customerDetail.Segment_crm__c.value,
            TMB_Customer_ID_PE__c : customerDetail.TMB_Customer_ID_PE__c.value,
            Zip_Code_Office_PE__c : customerDetail.Zip_Code_Office_PE__c.value,
            Zip_Code_Primary_PE__c : customerDetail.Zip_Code_Primary_PE__c.value,
            Zip_Code_Registered_PE__c : customerDetail.Zip_Code_Registered_PE__c.value,
            RTL_Occupation_Details__c : customerDetail.RTL_Occupation_Details__c.value,
            RTL_RM_Last_Update__c : customerDetail.RTL_RM_Last_Update__c.value,
        }
        return acc;
    }
}