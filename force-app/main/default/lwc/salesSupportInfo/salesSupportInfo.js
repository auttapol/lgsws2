import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import userId from '@salesforce/user/Id';
import getDescribeFieldResultAndValue from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';
import getProfileName from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import getProfilverifyFieldSecurityeName from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';

import {
    refreshApex
} from '@salesforce/apex';
import {
    parseObj
} from 'c/methodUtils';
import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = [
    'RTL_Credit_Card_History__c', 'Fna_Product_Interested__c', 'RTL_Personal_Loan_History__c', 'Fna_Product_Holding__c',
    'RTL_OnSite_Service__c', 'Consolidate_Status__c', 'RTL_Credit_Card_Flag__c', 'RTL_RDC_STMT_status__c',
    'RTL_C2G_STMT_status__c', 'RTL_MIB_Status__c', 'RTL_4THANA_Info__c', 'RMC_ttb_Touch__c', 'RTL_Primary_Banking_All_Free_Benefit__c',
    'RTL_OnSite_Service_Update_Date__c', 'RTL_OnSite_Service_User_Update__c',

    'RTL_4THANA_Fund_AMT__c', 'RTL_4THANA_Aggregate_Bond_AMT__c', 'RTL_4THANA_Bond_AMT__c', 'RTL_4THANA_Short_Bond_AMT__c', 'RTL_4THANA_Total_AMT__c', ];

const FIELDS_TRANSLATE = [
    'Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'RTL_Other1__c',
    'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c',
];

const account_field_section = {
    'RTL_Credit_Card_History__c': 'RtlCust:Sales Support Information',
    'Fna_Product_Interested__c': 'RtlCust:Sales Support Information',
    'RTL_Personal_Loan_History__c': 'RtlCust:Sales Support Information',
    'Fna_Product_Holding__c': 'RtlCust:Sales Support Information',
    'RTL_4THANA_Info__c': 'RtlCust:Sales Support Information',
    'RTL_OnSite_Service__c': 'RtlCust:Sales Support Information',
    'RTL_OnSite_Service_Update_Date__c': 'RtlCust:Sales Support Information',
};

const function_field_section = {
    'dataQM': 'RtlCust:Sales Support Information',
    'dataAge': 'RtlCust:Sales Support Information',
    'moreDetail': 'RtlCust:Sales Support Information',
    'pdpaDetail': 'RtlCust:Sales Support Information',
    'marketDetail': 'RtlCust:Sales Support Information',
}

const eStatementColumn = [
    { label: 'Credit Card', fieldName: 'CreditCard' },
    { label: 'RDC', fieldName: 'RDC' },
    { label: 'C2G', fieldName: 'C2G' }
];

const regisColumn = [
    { label: 'TMB Touch',  cellAttributes: { iconName: { fieldName: 'ttbTouch' } } },
    { label: 'Internet Banking',  cellAttributes: { iconName: { fieldName: 'banking' } } },
    // { label: 'Internet Banking', fieldName: 'banking' },
    { label: 'Prompt Pay', fieldName: 'promptPay' }
];

export default class CockpitCSVCustomerInfo extends LightningElement {

    function_obj = ['dataQM', 'dataAge', 'moreDetail', 'pdpaDetail', 'marketDetail'];

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

    profileName;

    @track activeSections = ['salesSupport', 'registrationStatus', 'EStatement'];
    @track customerDetail = {};
    @track dataPartition = {};
    @track isGetDataPartition = false;
    @track isiPad = false;
    @track isTablet = false;

    @track watermarkImage = "";
    isRerender = false;

    label = {
        Data_Condition_Hidden_Text,
    };

    eStatementColumn = eStatementColumn;
    regisColumn = regisColumn;

    eStatementData = [];
    regisData = [];
    displayOnsiteServiceUser  = false;

    // @api
    // refreshPage(fieldUpdate) {
    //     let customerDetailChange = this.customerDetail;
    //     this.customerDetail = null;
    //     let customerTranslates = {};
    //     Object.keys(fieldUpdate).forEach(fieldName => {
    //         if (customerDetailChange[fieldName] && customerDetailChange[fieldName].value != fieldUpdate[fieldName]) {
    //             customerDetailChange[fieldName].value = fieldUpdate[fieldName];
    //         }
    //     });

    //     getDescribeFieldResultAndValue({
    //             recordId: this.recordId,
    //             fields: FIELDS_TRANSLATE,
    //             fields_translate: FIELDS_TRANSLATE,
    //         })
    //         .then(result => {
    //             customerTranslates = result;
    //             FIELDS_TRANSLATE.forEach(element => {
    //                 // console.log('fields : ', customerTranslates);
    //                 if (customerDetailChange[element]) {
    //                     customerDetailChange[element].value = customerTranslates[element].value;
    //                 }
    //             });
    //             this.customerDetail = null;
    //             this.customerDetail = customerDetailChange;
    //         })
    //         .catch(error => {
    //             console.log('Refresh Page error : ', error);
    //         })

    //     if (customerDetailChange.RTL_Assigned_BRC__c.value) {
    //         getReferenceByFieldName({
    //             recordId: customerDetailChange.RTL_Assigned_BRC__c.value,
    //             fieldName: 'Employee_ID__c'
    //         }).then(result => {
    //             this._Assigned_BRC_Employee = result ? result : '';
    //         }).catch(error => {
    //             console.log(error);
    //         });
    //     }
    //     this.customerDetail = null;
    //     this.customerDetail = customerDetailChange;
    // }


    connectedCallback() {
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
    }

    renderedCallback() {
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
            this.customerDetail = parseObj(data);
            // console.log('CustomerDetail', this.customerDetail);
            // this._DateOfBirth = new Date(this.customerDetail.RTL_Date_Of_Birth__c.value);
            // this.customerDetail.RTL_Income__c.value = this.customerDetail.RTL_Is_Employee__c.value ? 0 : this.customerDetail.RTL_Income__c.value;

            // console.log('this.customerDetail.RTL_MIB_Status__c: '+this.customerDetail.RTL_MIB_Status__c.value);


            this.profileName = await getProfileName({
                userId: userId
            });
            this.function_obj.forEach((v, i) => {
                // console.log('vvv: '+v);
                this.dataPartition[v] = {
                    isVisible: false
                }
                if (function_field_section[v]) {
                    getProfilverifyFieldSecurityeName({
                        section: function_field_section[v],
                        userProfile: this.profileName,
                        accountId: this.recordId
                    })
                        .then(result => {
                            this.dataPartition[v].isVisible = result;
                        })
                        .catch(error => {
                            console.log('Get data partition error: ', error)
                        });
                } else {
                    this.dataPartition[v].isVisible = true;
                }
            })
            Object.keys(this.customerDetail).forEach((v, i) => {
                this.dataPartition[v] = {
                    isVisible: false
                }
                //console.log('vee voo: '+v);
                if (i >= FIELDS.length - 1) {
                    this.isGetDataPartition = true;
                }
                if (account_field_section[v]) {
                    getProfilverifyFieldSecurityeName({
                        section: account_field_section[v],
                        userProfile: this.profileName,
                        accountId: this.recordId
                    })
                        .then(result => {
                            this.dataPartition[v].isVisible = result;
                        })
                        .catch(error => {
                            console.log('Get data partition error: ', error)
                        });
                } else {
                    this.dataPartition[v].isVisible = true;
                }
            });

            this.eStatementData = [{
                'Consolidate': this.dataPartition.Consolidate_Status__c.isVisible ? this.customerDetail.Consolidate_Status__c.value : '*****',
                'CreditCard': this.dataPartition.RTL_Credit_Card_Flag__c.isVisible ? this.customerDetail.RTL_Credit_Card_Flag__c.value : '*****',
                'RDC': this.dataPartition.RTL_RDC_STMT_status__c.isVisible ? this.customerDetail.RTL_RDC_STMT_status__c.value : '*****',
                'C2G': this.dataPartition.RTL_C2G_STMT_status__c.isVisible ? this.customerDetail.RTL_C2G_STMT_status__c.value : '*****'
            }];


            var touchvalue = this.dataPartition.RMC_ttb_Touch__c.isVisible ? this.customerDetail.RMC_ttb_Touch__c.value : '*****';
            if (touchvalue) {
                touchvalue = 'utility:check';
            } else {
                touchvalue = 'utility:close';
            }
            var banking = this.dataPartition.RTL_Primary_Banking_All_Free_Benefit__c.isVisible ? this.customerDetail.RTL_Primary_Banking_All_Free_Benefit__c.value : '*****';
            if (banking) {
                banking = 'utility:check';
            } else {
                banking = 'utility:close';
            }
            this.regisData = [{
                'promptPay': this.dataPartition.RTL_MIB_Status__c.isVisible ? this.customerDetail.RTL_MIB_Status__c.value : '*****',
                'ttbTouch': touchvalue,
                'banking': banking
                // 'banking'       : this.customerDetail.RTL_RDC_STMT_status__c.value,
            }];

            var data1 = this.customerDetail.RTL_4THANA_Fund_AMT__c.value            ?   this.customerDetail.RTL_4THANA_Fund_AMT__c.value            : '0';
            var data2 = this.customerDetail.RTL_4THANA_Aggregate_Bond_AMT__c.value  ?   this.customerDetail.RTL_4THANA_Aggregate_Bond_AMT__c.value  : '0';
            var data3 = this.customerDetail.RTL_4THANA_Bond_AMT__c.value            ?   this.customerDetail.RTL_4THANA_Bond_AMT__c.value            : '0';
            var data4 = this.customerDetail.RTL_4THANA_Short_Bond_AMT__c.value      ?   this.customerDetail.RTL_4THANA_Short_Bond_AMT__c.value      : '0';
            var data5 = this.customerDetail.RTL_4THANA_Total_AMT__c.value           ?   this.customerDetail.RTL_4THANA_Total_AMT__c.value           : '0';

            var FourThanaValue =  this.customerDetail.RTL_4THANA_Fund_AMT__c.label          + ': ' +    data1  + ' บาท <br/>'
                            + this.customerDetail.RTL_4THANA_Aggregate_Bond_AMT__c.label    + ': ' +    data2  + ' บาท <br/>'
                            + this.customerDetail.RTL_4THANA_Bond_AMT__c.label              + ': ' +    data3  + ' บาท <br/>'
                            + this.customerDetail.RTL_4THANA_Short_Bond_AMT__c.label        + ': ' +    data4  + ' บาท <br/>'
                            + this.customerDetail.RTL_4THANA_Total_AMT__c.label             + ': ' +    data5  + ' บาท <br/>';

             this.customerDetail.RTL_4THANA_Info__c.value = FourThanaValue;

            if (this.customerDetail.RTL_OnSite_Service_User_Update__c.value) {
                displayOnsiteServiceUser = true;
            }

        } else if (error) {
            console.log('Get Custumer detail error', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading',
                    message: error,
                    variant: 'error',
                }),
            );
        }
    }


    @wire(getWatermarkHTML)
    getWatermark({
        error,
        data
    }) {
        if (data) {
            // var body = this.template.querySelector('div');
            var imgEncode = btoa("<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
                "<text transform='translate(20, 65) rotate(-45)' fill='rgb(240,240,240)' font-size='25' font-family='Helvetica' weight='700'>" + data + "</text></svg>");
            var bg = "url(\"data:image/svg+xml;base64," + imgEncode + "\")";
            // var bg = "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>" +
            //     "<text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >" + data + "</text></svg>\")";
            this.watermarkImage = 'background-image: ' + bg + ';width:100%;height:100%';
        }
    }
}