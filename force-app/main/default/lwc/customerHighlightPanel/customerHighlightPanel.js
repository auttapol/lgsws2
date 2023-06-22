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

import { NavigationMixin } from 'lightning/navigation';
// import RTL_Data_Quality_Marketing from '@salesforce/label/c.RTL_Data_Quality_Marketing';
// import RTL_Data_Age from '@salesforce/label/c.RTL_Data_Age';
// import RTL_Quality_More_Detail from '@salesforce/label/c.RTL_Quality_More_Detail';
import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';
import getLatestNPS from '@salesforce/apex/HighlightPanelController.getLatestNPS';
// import getAccInfo from '@salesforce/apex/HighlightPanelController.getAccInfo';
// import getMainBank from '@salesforce/apex/HighlightPanelController.getMainBank';
// import PDPA_Accept_YES                      from '@salesforce/label/c.PDPA_Accept_YES';
// import PDPA_Accept_NO                       from '@salesforce/label/c.PDPA_Accept_NO';

import {
  refreshApex
} from '@salesforce/apex';
import {
  parseObj
} from 'c/methodUtils';
// import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = ['TMB_Customer_ID_PE__c', 'RTL_Age__c', 'Mobile_Number_PE__c', 'Core_Banking_Suggested_Segment__c',
  'RTL_AUM__c', 'RTL_Wealth_RM__c', 'Wealth_RM_BM_Name__c', 'Assigned_BRC_User_Name__c',
  'RTL_Primary_Banking_All_Free_Benefit__c', 'RMC_Regulation_Alert__c', 'RTL_Assigned_BRC__c', 'RMC_AUM__c', 'RMC_TTB_Touch__c',
  'RMC_Number_of_Product_Holdings__c', 'Stamp_TMB_Cust_ID__c'
];

const FIELDS_TRANSLATE = [
  'Hobbies__c', 'Favorite_Sport__c', 'RTL_Lifestyle__c', 'RTL_Preferred_Activity__c', 'RTL_Other1__c',
  'Favorite_Place_Travel__c', 'Favorite_Music__c', 'Favorite_Food__c',
];

const account_field_section = {
  'TMB_Customer_ID_PE__c': 'RtlCust:Customer Demographic (Low)',
  'RTL_Age__c': 'RtlCust:Customer Demographic (Medium)',
  'Mobile_Number_PE__c': 'RtlCust:Contact Number and Email Address',
  'RTL_AUM__c': 'RtlCust:Customer Product Holding (High)',
  'RTL_Wealth_RM__c': 'RtlCust:Customer Relationship',
  'RTL_Primary_Banking_All_Free_Benefit__c': 'RtlCust:MI Benefits', //osc 07
  'RMC_Number_of_Product_Holdings__c' : 'RtlCust:Wealth Customer Relationship',
  'RMC_TTB_Touch__c' : 'RtlCust:Wealth Customer Relationship',
};

const function_field_section = {
  'dataQM': 'RtlCust:Sales Support Information',
  'dataAge': 'RtlCust:Sales Support Information',
  'moreDetail': 'RtlCust:Sales Support Information',
  'pdpaDetail': 'RtlCust:Sales Support Information',
  'marketDetail': 'RtlCust:Sales Support Information',
}

export default class CockpitCSVCustomerInfo extends NavigationMixin(LightningElement) {
  // export default class CockpitCSVCustomerInfo extends LightningElement {
  function_obj = ['dataQM', 'dataAge', 'moreDetail', 'pdpaDetail', 'marketDetail'];

  @api recordId;
  @api userAgent = 'Desktop';

  @track activeSections = ['personalInformation', 'dataValidationStatus', 'consentAndRisk', 'AUMAndMainBank', 'RMInformation', 'OtherPersonalInformation', 'ContactInformation'];
  @track customerDetail = {};
  @track dataPartition = {};
  @track isGetDataPartition = false;
  @track isiPad = false;
  @track isTablet = false;

  @track watermarkImage = "";
  isRerender = false;

  label = {
    Data_Condition_Hidden_Text
  }

  nps = { isSurveyAvailable: false, class: '', icon: '', url: '' };

  isDisplayRMBM = false;
  mainBank = '';

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

    var score = 0;

    console.log('score1: ' + score);
    getLatestNPS({ accId: this.recordId }).then(
      (result) => {
        score = result.score;
        var nps = {};
        console.log('score2: ' + score);
        nps.score = score;
        if (score == '-') {
          nps.class = 'greyFace';
          nps.icon = 'utility:sentiment_neutral';
          nps.url = '#';
        } else if (score >= 9) {
          nps.class = 'greenFace';
          nps.icon = 'utility:smiley_and_people';
          nps.url = result.recordId;
        } else if (score >= 7) {
          nps.class = 'yellowFace';
          nps.icon = 'utility:sentiment_neutral';
          nps.url = result.recordId;
        } else {
          nps.class = 'redFace';
          nps.icon = 'utility:sentiment_negative';
          nps.url = result.recordId;
        }
        this.nps = nps;
      }
    ).catch(
      error => {
        console.log('error: ' + error);
        // return error;
      }
    );

    // getMainBank({ accId: this.recordId }).then(
    //   (result) => {
    //     console.log('highlight mainBank: ' + result)
    //     this.mainBank = result;
    //   }
    // ).catch(
    //   error => {
    //     console.log('error: ' + error);
    //     // return error;
    //   }
    // );
    console.log('score4: ' + score);
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

      this.profileName = await getProfileName({
        userId: userId
      });
      this.function_obj.forEach((v, i) => {
        console.log('vvv: ' + v);
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

      var primaryBank = this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value;
      console.log('primaryBank: ' + primaryBank);
      if (primaryBank) {
        this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value = 'Yes';
      } else {
        this.customerDetail['RTL_Primary_Banking_All_Free_Benefit__c'].value = 'No';
      }

      var regulation = this.customerDetail['RMC_Regulation_Alert__c'].value;
      if (regulation) {
        this.customerDetail['RMC_Regulation_Alert__c'].value = 'Yes';
      } else {
        this.customerDetail['RMC_Regulation_Alert__c'].value = 'No';
      }

      var regulation = this.customerDetail['RMC_TTB_Touch__c'].value;
      if (regulation) {
        this.customerDetail['RMC_TTB_Touch__c'].value = 'มี';
      } else {
        this.customerDetail['RMC_TTB_Touch__c'].value = 'ไม่มี';
      }

      Object.keys(this.customerDetail).forEach((v, i) => {
        this.dataPartition[v] = {
          isVisible: false
        }
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

        console.log('highlight panel wealth: '+JSON.stringify(this.customerDetail['RTL_Wealth_RM__c'].value));
        console.log('highlight panel brc: '+JSON.stringify(this.customerDetail['RTL_Assigned_BRC__c'].value));       
        if( this.customerDetail['RTL_Wealth_RM__c'].value || !this.customerDetail['RTL_Assigned_BRC__c'].value){
          this.isDisplayRMBM = true
        }

        // if (ethis.dataPartition['Customer_Persona__c'].isVisibl) {
        //   getAccInfo({ accId: this.recordId }).then(
        //     (result) => {
        //       console.log('persona: ' + JSON.stringify(result));
        //       // this.persona = result;
        //       this.customerDetail.Customer_Persona__c.value = result.Customer_Persona__c

        //       if (result.RTL_Wealth_RM__r || !result.RTL_Assigned_BRC__c) {
        //         this.isDisplayRMBM = true
        //       }
        //     }
        //   ).catch(
        //     error => {
        //       console.log('error: ' + error);
        //       // return error;
        //     }
        //   )
        // }
      });
    } else if (error) {
      console.log('Get Custumer detail error', error);
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error loading.',
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

  navigateToRecord(event) {
    // console.log(navigate);
    this[NavigationMixin.Navigate]({
      "type": "standard__recordPage",
      "attributes": {
        "recordId": event.target.dataset.id,
        "actionName": "view"
      }
    });
  }

  navigate(url) {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: url,
        actionName: 'view'
      }
    });
  }

  navigateToNPS() {
    this.navigate(this.nps.url);
  }

  navigateToManager(event) {
    this.navigate(event.target.dataset.url);
  }
}