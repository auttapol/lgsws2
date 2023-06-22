import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import userId from '@salesforce/user/Id';
import getDescribeFieldResultAndValue from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';
import getSubDebtTransaction from '@salesforce/apex/RetailCSVLightningUtil.getSubDebtTransaction';
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import getProfilverifyFieldSecurityeName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity';
import getCustomer from '@salesforce/apex/RetailCSVCustomerChartController.fetchAccount';
import getCVSObject2 from '@salesforce/apex/RetailCSVCustomerChartController.getCVSObject2';
import getUser from '@salesforce/apex/RetailCSVCustomerChartController.getUser';
import getBranchFromID from '@salesforce/apex/RetailCSVCustomerChartController.getBranchFromID';
import Number_Of_Retry_Times from '@salesforce/label/c.Number_Of_Retry_Times';
import getDataAfterRefresh   from '@salesforce/apex/EditCustomerController.getDataAfterRefresh';
import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';
import getSubSegmentCodeMapping from '@salesforce/apex/RetailCSVLightningUtil.getSubSegmentCodeMapping';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';

import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';
import Sub_Debt_Transaction_Flag from '@salesforce/label/c.Sub_Debt_Transaction_Flag';


import {
    refreshApex
} from '@salesforce/apex';
import {
    parseObj
} from 'c/methodUtils';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = [
    'CSV_Customer_Image__c', 'TMB_Customer_ID_PE__c', 'Customer_Status__c',
    'RTL_Customer_Name_TH__c', 'Customer_Name_PE_Eng__c', 'Sub_segment__c', 'VIP_Status__c', 'RTL_Date_Of_Birth__c',
    'RTL_Age__c', 'ID_Type_PE__c', 'NID__c', 'RTL_Income__c', 'RTL_Do_Not_Call__c','Segment_crm__c','RTL_Privilege1__c',

    'E_KYC__c', 'RTL_Suitability__c', 'FATCA__c', 'RTL_Fund_Risk_Mismatch__c', 'RTL_Risk_Level_Details__c', 'RTL_Fund_High_Concentration_Risk__c',
    'RTL_Primary_Banking_All_Free_Benefit__c', 'RTL_AUM_Last_Calculated_Date__c', 'KYC_Update__c','KYC_flag__c',

    'Assigned_BRC_User_Name__c', 'Business_Type_Code__c', 'Business_Type_Description__c', 'Payroll__c',
    'RTL_Education_Details__c', 'RTL_Occupation_Details__c', 'RTL_Customer_Reference_Id__c','RTL_Marital_Details__c', 
    'Nationality__c', 'RTL_Is_Employee__c', 'RTL_Preferred_Activity__c','Safebox_Status__c', 
    'Primary_Address_Line_1_PE__c','Primary_Address_Line_2_PE__c','Primary_Address_Line_3_PE__c','Province_Primary_PE__c','Zip_Code_Primary_PE__c',
    'RTL_Office_Address__c','Office_Address_Line_1_PE__c','Office_Address_Line_2_PE__c','Office_Address_Line_3_PE__c','Province_Office_PE__c','Zip_Code_Office_PE__c',
    'RTL_Registered_Address__c','Registered_Address_Line_1_PE__c','Registered_Address_Line_2_PE__c','Registered_Address_Line_3_PE__c','Province_Registered_PE__c','Zip_Code_Registered_PE__c',
    'Mobile_Number_PE__c', 'C_Home_phone_PE__c', 'RTL_Office_Phone_Number__c', 'Fax','Action_Box__c',

    'RTL_Assigned_BRC__c', 'FATCA_Form_Completed__c', 'Wealth_RM_BM_Name__c', 'RTL_Alternative_Number__c', 'Customer_Type__c', 'Core_Banking_Suggested_Segment__c',
    'RTL_Commercial_RM_Emp_ID__c', 'RTL_No_of_Children__c', 'Email_Address_PE__c', 'RTL_Wealth_RM__c', 'RTL_Preferred_Contact_Channel__c',

    'RTL_Wealth_RM__r.Name', 'Wealth_RM_EMP_Code__c', 'RTL_Commercial_RM__r.Name', 'RTL_Commercial_RM__r.Employee_ID__c',
    'RTL_Assigned_BRC__r.Name', 'RTL_Assigned_BRC__r.Employee_ID__c', 'RTL_Check_WM_RM_as_PWA__c',

    'IAL__c', 'RMC_ID_Card_Expiry_Date__c', 'RMC_Number_of_Inactive_Dormant_Account__c', 'RMC_Has_PDPA__c', 'RMC_Has_Market_Conduct__c', 'RMC_TTB_Touch__c',
    'RMC_Wow_Point__c', 'RMC_Payroll_Company__c', 'RMC_Payroll_Amount_avg_last_3_months__c', 'RTL_Most_Operating_Branch__c', 'Most_Operating_Branch_Name__c', 'RMC_No_of_Management_Visits__c',
     'Last_login_success_date__c', 'RTL_Commercial_RM__c', 'RTL_AUM__c', 'RMC_No_of_Participating_Events__c', 'RMC_Persona__c',
    'RMC_Suitability_Risk_Expiry_Date__c','RMC_Suitability_Risk_Level__c', 'RMC_Relationship_Level__c',

    'RTL_Occupation_Details__r.RTL_Occupation_Desc__c', 'RTL_Education_Details__r.RTL_Education_Level_Desc__c', 'RTL_Marital_Details__r.Marital_Status_Desc__c',
    'Account_Type__c', 'Id', 'Name', 'OwnerId', 'RTL_OTC_ATM_ADM_IB_MIB__c', 'RTL_MIB_Status__c', 'RTL_Privilege2__c', 'RTL_RM_Name__c',
    'RTL_Most_Visited_Branch__c', 'RTL_Average_AUM__c'

];

const FIELDS_TRANSLATE = [
    'Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'RTL_Other1__c', 'RTL_Preferred_Contact_Channel__c',
    'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c', 'RMC_Has_PDPA__c', 'RMC_Has_Market_Conduct__c'
];

export default class CockpitCSVCustomerInfo extends NavigationMixin(LightningElement) {
    // export default class CockpitCSVCustomerInfo extends LightningElement {

    @api recordId;
    @api userAgent = 'Desktop';

    @track activeSections = ['personalInformation', 'dataValidationStatus', 'consentAndRisk', 'AUMAndMainBank', 'RMInformation', 'OtherPersonalInformation', 'ContactInformation'];
    @track customerDetail = {};
    @track dataPartition = {};
    @track isGetDataPartition = false;
    @track isiPad = false;
    @track isTablet = false;
    @track subDebtTransDetail = Data_Condition_Hidden_Text;
    @track subSegment = {};
    isLoading = true;


    @track watermarkImage = "";
    isRerender = false;

    label = {
        Data_Condition_Hidden_Text,
        Sub_Debt_Transaction_Flag
    }
    isKYCExpired = false;
    isIDCardExpired = false;
    riskExpired = false;

    primaryAddress;
    officeAddress;
    registeredAddress;

    _Wealth_RM;
    _Commercial_RM;
    _Assigned_BRC;
    _Wealth_RM_Url;
    _Commercial_RM_Url;
    _Assigned_BRC_Url;
    _Assigned_BRC_Employee;
    _BranchOperateUrl;
    _BranchOperateName;

    vipHelpText;
    fontColor = '';

    @track HoverID;
    @track isOutHover;
    @track top = 50;
    @track left = 50;
    @track HoverObjAPIName;

    @api
    refreshPage(fieldUpdate) {
        this.isLoading = true;
        this.getSubDebtTransaction();
        let customerDetailChange = this.customerDetail;
        let customerTranslates = {};
        Object.keys(fieldUpdate).forEach(fieldName => {
            if (customerDetailChange[fieldName] && customerDetailChange[fieldName].value != fieldUpdate[fieldName]) {
                customerDetailChange[fieldName].value = fieldUpdate[fieldName];
            }
        });
        getDataAfterRefresh({
            recordId: this.recordId,
            fields: FIELDS_TRANSLATE,
            fields_translate: FIELDS_TRANSLATE,
        }).then(result => {
                customerTranslates = result;
                FIELDS_TRANSLATE.forEach(element => {
                    if (customerDetailChange[element]) {
                        customerDetailChange[element].value = customerTranslates[element].value;
                    }
                });
                this.customerDetail = null;
                this.customerDetail = customerDetailChange;
                this.isLoading = false;
            }).catch(error => {
                console.error('error : getDataAfterRefresh');
                this.isLoading = false;
            })

        if (customerDetailChange.RTL_Assigned_BRC__c.value) {
            getReferenceByFieldName({
                recordId: customerDetailChange.RTL_Assigned_BRC__c.value,
                fieldName: 'Employee_ID__c'
            }).then(result => {
                this._Assigned_BRC_Employee = result ? result : '';
            }).catch(error => {
                console.error('error : getReferenceByFieldName');
            })
        }
        this.customerDetail = null;
        this.customerDetail = customerDetailChange;
    }

    connectedCallback() {
        var bar = new Promise((resolve, reject) => {
            FIELDS.forEach((value, index, array) => {
                this.customerDetail[value] = {
                       name: '',
                       value: '',
                       label: '',
                       type: '',
                       inlineHelpText: '',
                       isAccessible: false,
                   }
                   this.dataPartition[value] = {
                       isVisible: false
                   }
                if (index === array.length -1){
                    resolve();
                } 
            });
        });
        bar.then(() => {
            getProfileName({
                userId: userId
            }).then(profile => {
                this.openPage(profile, this.recordId);
            }).catch(error => {
                console.error('error : getProfileName');
            });
            this.getSubDebtTransaction();        
        })
    }

    renderedCallback() {
        this.isRerender = true;
    }

    disconnectedCallback() {
        refreshApex(this.customerDetail);
    }

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
            this.top = event.pageY - 600; 
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

    // @wire(getCustomer, {
        // recordId: '$recordId'
    // })
    // fetchAccount({
        // error,
        // data
    // }) {
        // if (data) {
            // this.customerData = JSON.stringify(data);
            // let acc = JSON.parse(this.customerData);

            // this.callGetCVSObject(acc);
        // }
    // }

    @wire(getWatermarkHTML)
    getWatermark({
        error,
        data
    }) {
        if (data) {
            var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + data + "</text></svg>");
            var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
            this.watermarkImage = 'background-image: ' + bg + ';width:100%;height:100%';
        }
    }

    navigateToRecord(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": event.target.dataset.id,
                "actionName": "view"
            }
        });
    }

    async callGetCVSObject(acc) {
        let noOfRetry = parseInt(Number_Of_Retry_Times);
        let isSuccess = false;
        while (!isSuccess && noOfRetry >= 0) {
            await getCVSObject2({
                recordId: this.recordId,
                account: acc
            })
                .then(async result => {
                    result = JSON.parse(result);
                    let subSegmentNumber = result['csProfSubsegment'];
                    isSuccess = true;
                    await getSubSegmentCodeMapping({
                        subSegmentCode : subSegmentNumber
                    }).then((data) => {
                        this.subSegment['value'] = data;
                    })
                })
                .catch(async error => {
                    console.error('retail customer OSC07 error\n\n', error);
                    noOfRetry = -1;
                });
        }
        if (!isSuccess) {
            this.ttbtouch = 'Error getting data';
        }
    }

    getSubDebtTransaction(){
        getSubDebtTransaction({
            accId : this.recordId
        }).then(result => {
            this.subDebtTransDetail = result;
        }).catch(error => {
            console.error('Get data partition error: ', error)
        });
    }

    openPage(profileName, recordId){
        this.isLoading = true;

        getDescribeFieldResultAndValue({
            recordId: recordId,
            fields: FIELDS,
            fields_translate: FIELDS_TRANSLATE,
        }).then(async data => {
            this.customerDetail = parseObj(data);

            await getProfilverifyFieldSecurityeName({
                section: 'RtlCust:Customer Relationship',
                userProfile: profileName,
                accountId: this.recordId
            }).then( async result => {
                if(result == true){
                    const cvsPdpaAcc = this.makeAccForCVSPDPA(this.customerDetail);
                    await this.callGetCVSObject(cvsPdpaAcc);
                }
            }).catch(error => {
                console.error(error);
            });

            var primaryBank = this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value;
            var primaryBankVis = this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].isAccessible;

            if(primaryBankVis == true){
                if (primaryBank) {
                    this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value = 'Yes';
                } else {
                    this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value = 'No';
                }
            }      

            var ttbTouch = this.customerDetail['RMC_TTB_Touch__c'].value;
            var ttbTouchVis = this.customerDetail['RMC_TTB_Touch__c'].isAccessible;

            if(ttbTouchVis == true){
                if (ttbTouch) {
                    this.customerDetail['RMC_TTB_Touch__c'].value = 'มี';
                } else {
                    this.customerDetail['RMC_TTB_Touch__c'].value = 'ไม่มี';
                }
            }   

            //this.customerDetail.RTL_Income__c.value = this.customerDetail.RTL_Is_Employee__c.isAccessible == true ? this.customerDetail.RTL_Income__c.value : '***********';
            
            var employeeFlag = this.customerDetail['RTL_Is_Employee__c'].value;
            var employeeFlagVis = this.customerDetail['RTL_Is_Employee__c'].isAccessible;

            if(employeeFlagVis == true){
                if (employeeFlag) {
                    this.customerDetail['RTL_Is_Employee__c'].value = 'Yes';
                } else {
                    this.customerDetail['RTL_Is_Employee__c'].value = 'No';
                }
            }

            switch (this.customerDetail['VIP_Status__c'].value) {
                case '1':
                    this.vipHelpText = 'รัฐมนตรี, ข้าราชการ, และ พนักงานรัฐวิสาหกิจ';
                    break;
                case '2':
                    this.vipHelpText = 'ผู้บริหารธนาคาร';
                    break;
                case '3':
                    this.vipHelpText = 'ข้าราชการ และพนักงานรัฐวิสาหกิจของหน่วยงานที่ไม่ได้อยู่ใต้การกำกับของกระทรวง';
                    break;
                case '4':
                    this.vipHelpText = 'สมาชิกราชวงศ์';
                    break;
                case '5':
                    this.vipHelpText = 'องคมนตรี';
                    break;
                case '6':
                    this.vipHelpText = 'สมาชิกสภาผู้แทนราษฎรและนักการเมือง';
                    break;
                case '7':
                    this.vipHelpText = 'สื่อมวลชนและผู้มีชื่อเสียง';
                    break;
                case '8':
                    this.vipHelpText = 'ผู้บริหารกลุ่ม commercial';
                    break;
                default:
                    this.vipHelpText = '-';
                    break              
            }
            
            var today = new Date();
            var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();

            var IdCardExpiryDate = this.customerDetail['RMC_ID_Card_Expiry_Date__c'].value;           
            if(IdCardExpiryDate && IdCardExpiryDate <= date){
                this.isIDCardExpired = true;
            }

            var riskSuitabilityDate = this.customerDetail['RMC_Suitability_Risk_Expiry_Date__c'].value;                    
            if(riskSuitabilityDate <= date){
                this.riskExpired = true;
            }
            
            this.fontColor = '';
            var kycUpdate = this.customerDetail['KYC_Update__c'].value;
            if (kycUpdate.includes('ใกล้หมดอายุ')) {
                this.fontColor = '#d09b05';
            } else if (kycUpdate == 'กรุณาปรับปรุงข้อมูล') {
                this.fontColor = 'Red';
            }

            this.primaryAddress = this.customerDetail['Primary_Address_Line_1_PE__c'].value + ' ' +
                                this.customerDetail['Primary_Address_Line_2_PE__c'].value + ' ' +
                                this.customerDetail['Primary_Address_Line_3_PE__c'].value + ' ' +
                                this.customerDetail['Province_Primary_PE__c'].value + ' ' +
                                this.customerDetail['Zip_Code_Primary_PE__c'].value + ' ';
            
            this.officeAddress = this.customerDetail['Office_Address_Line_1_PE__c'].value + ' ' +
                                    this.customerDetail['Office_Address_Line_2_PE__c'].value + ' ' +
                                    this.customerDetail['Office_Address_Line_3_PE__c'].value + ' ' +
                                    this.customerDetail['Province_Office_PE__c'].value + ' ' +
                                    this.customerDetail['Zip_Code_Office_PE__c'].value + ' ';
            
            this.registeredAddress = this.customerDetail['Registered_Address_Line_1_PE__c'].value + ' ' +
                                    this.customerDetail['Registered_Address_Line_2_PE__c'].value + ' ' +
                                    this.customerDetail['Registered_Address_Line_3_PE__c'].value + ' ' +
                                    this.customerDetail['Province_Registered_PE__c'].value + ' ' +
                                    this.customerDetail['Zip_Code_Registered_PE__c'].value + ' ';

            this.customerDetail.RTL_Education_Details__c.value =  this.customerDetail.RTL_Education_Details__c.isAccessible == true ?  this.customerDetail['RTL_Education_Details__r.RTL_Education_Level_Desc__c'].value : '***********';  
            this.customerDetail.RTL_Occupation_Details__c.value = this.customerDetail.RTL_Occupation_Details__c.isAccessible == true ? this.customerDetail['RTL_Occupation_Details__r.RTL_Occupation_Desc__c'].value : '***********';  
            this.customerDetail.RTL_Marital_Details__c.value =    this.customerDetail.RTL_Marital_Details__c.isAccessible == true ? this.customerDetail['RTL_Marital_Details__r.Marital_Status_Desc__c'].value : '***********';  
            
            //Object.keys(this.customerDetail).forEach((v, i) => {
            //    this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
            //});
            FIELDS.forEach(v => {
                this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
            });

            if (this.customerDetail.RTL_Wealth_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Wealth_RM__c.value
                }).then(result => {
                    var pwa = this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value != 'Undefined' ? this.customerDetail['RTL_Check_WM_RM_as_PWA__c'].value + ' ' : '';
                    this._Wealth_RM = `${result.Name} (${pwa}${this.customerDetail['Wealth_RM_EMP_Code__c'].value})`;
                    this._Wealth_RM_Url = '/lightning/r/' + result.Id + '/view';
                }).catch(error => {
                    console.error('Get Wealth_RM_EMP_Code__c for display error', error);
                })
            }

            if (this.customerDetail.RTL_Commercial_RM__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Commercial_RM__c.value
                }).then(result => {
                    this._Commercial_RM = `${result.Name} (${this.customerDetail['RTL_Commercial_RM__r.Employee_ID__c'].value})`;
                    this._Commercial_RM_Url = '/lightning/r/' + result.Id + '/view';
                }).catch(error => {
                    console.error('Get RTL_Commercial_RM__r for display error', error);
                })
            }

            if (this.customerDetail.RTL_Assigned_BRC__c.value) {
                getUser({
                    recordId: this.customerDetail.RTL_Assigned_BRC__c.value
                }).then(result => {
                    if (this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value) {
                        this._Assigned_BRC = `${result.Name} (${this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value})`;
                    } else {
                        this._Assigned_BRC = `${result.Name} ()`;
                    }
                    this._Assigned_BRC_Url = '/lightning/r/' + result.Id + '/view';
                    this._Assigned_BRC_Employee = this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'] ? this.customerDetail['RTL_Assigned_BRC__r.Employee_ID__c'].value : '';
                }).catch(error => {
                    console.error('Get RTL_Assigned_BRC__r for display error', error);
                })
            }

            if (this.customerDetail.RTL_Most_Operating_Branch__c.value) {
                getBranchFromID({
                    branchId: this.customerDetail.RTL_Most_Operating_Branch__c.value
                }).then(result => {
                    var branchOperateData = result;
                    if (branchOperateData.Branch_Code__c) {
                        this._BranchOperateName = branchOperateData.Name;
                        this._BranchOperateUrl = '/lightning/r/' + branchOperateData.Id + '/view';
                    }
                })
                .catch(error => {
                    console.error('Get Operate Branch for display error', error);
                })
            }

            this.isLoading = false;
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading',
                    message: error,
                    variant: 'error',
                }),
            );
            this.isLoading = false;
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

    
}