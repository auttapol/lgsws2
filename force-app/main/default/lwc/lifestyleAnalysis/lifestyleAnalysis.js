import {
    LightningElement,
    track,
    wire,
    api
} from 'lwc';
import userId                               from '@salesforce/user/Id';
import getDescribeFieldResultAndValue       from '@salesforce/apex/RetailCSVLightningUtil.getDescribeFieldResultAndValue';
import getCustomer                          from '@salesforce/apex/RetailCSVCustomerChartController.fetchAccount';
import getDataAfterRefresh                  from '@salesforce/apex/EditCustomerController.getDataAfterRefresh';

import getProfileName                       from '@salesforce/apex/RetailCSVLightningUtil.getProfileName';
import getProfilverifyFieldSecurityeName    from '@salesforce/apex/RetailCSVLightningUtil.verifyFieldSecurity';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';

import Data_Condition_Hidden_Text           from '@salesforce/label/c.Data_Condition_Hidden_Text';

import {
    refreshApex
} from '@salesforce/apex';
import {
    parseObj
} from 'c/methodUtils';
// import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = [
    'Hobbies__c', 'RTL_Preferred_Activity__c', 'Favorite_Sport__c', 'Favorite_Music__c', 
    'Favorite_Place_Travel__c', 'Favorite_Food__c', 'RTL_Special_Pref__c', 
    'RTL_Other1__c', 'Remark__c',

    'FATCA_Form_Completed__c', 'KYC_CCI1_Completed__c', 'RTL_Lifetime_Code__c', 'Assigned_BRC_User_Name__c',
    'RMC_Occupation__c', 'RTL_OnSite_Service__c', 'RTL_Lifestyle__c', 'RTL_Contact_Person_Number_1__c', 'RTL_Contact_Person_Number_2__c',
    'RTL_Contact_Person_Name_1__c', 'RTL_Contact_Person_Name_2__c', 'RTL_Other2__c',
    'RTL_Relationship_Contact_2__c', 'RTL_Relationship_Contact_1__c', 'RTL_Purpose_of_Contact2__c', 
    'RTL_Purpose_for_Contact1__c', 'RMC_No_of_Participating_Events__c', 'RMC_No_of_Management_Visits__c'
];

const FIELDS_TRANSLATE = [
    'Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'RTL_Other1__c',
    'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c', 'FATCA_Form_Completed__c', 'RMC_Occupation__c',
    'RTL_Purpose_for_Contact1__c', 'RTL_Purpose_of_Contact2__c', 'RTL_Relationship_Contact_1__c', 'RTL_Relationship_Contact_2__c'
];

export default class CockpitCSVCustomerInfo extends LightningElement {

    @api recordId;
    @api userAgent = 'Desktop';
  
    @track activeSections = ['SalesSupportInformation', 'Occupation', 'PersonalizedInformation', 'ContactNumberEmailAddress', 'VisitAndEvent', 'specialpref'];
    @track customerDetail = {};
    @track dataPartition = {};
    @track isGetDataPartition = false;
    @track isiPad = false;
    @track isTablet = false;
 
    @track watermarkImage = "";
    isRerender = false;
    // _DateOfBirth;
    label = {
        Data_Condition_Hidden_Text
    }
    connectedCallback() {
        FIELDS.forEach(k => {
            this.customerDetail[k] = {
                name:           '',
                value:          '',
                label:          '',
                type:           '',
                inlineHelpText: '',
                isAccessible:   false,
            }
            this.dataPartition[k] = {
                isVisible: false
            }
        });
        getProfileName({
            userId: userId
        }).then(data => {
            this.openPage(data, this.recordId);
        }).catch(error => {
            console.error('error : getProfileName');
        })
    }

    renderedCallback() {
        this.isRerender = true;
    }

    disconnectedCallback() {
        refreshApex(this.customerDetail);
    }

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

    @api
    refreshPage(fieldUpdate) {
        this.isLoading = true;
        let customerDetailChange = this.customerDetail;
        let customerTranslates = {}
        Object.keys(fieldUpdate).forEach(fieldName => {
            if (customerDetailChange[fieldName] && customerDetailChange[fieldName].value != fieldUpdate[fieldName]) {
                customerDetailChange[fieldName].value = fieldUpdate[fieldName];
            }
        });
        ////เหมือนได้ค่าเดิมมาก่อน update
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
            console.error('Refresh Page error : ', error);
            this.isLoading = false;
        })
    }

    openPage(profileName, recordId){
        this.isLoading = true;
        getDataAfterRefresh({
            recordId: recordId,
            fields: FIELDS,
            fields_translate: FIELDS_TRANSLATE,
        }).then(data => {
            this.customerDetail = parseObj(data);
            Object.keys(this.customerDetail).forEach((v, i) => {
                this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
            });
            this.isLoading = false;
        }).catch(error => {
            console.error('error : getDataAfterRefresh');
            this.isLoading = false;
        })
    }
}