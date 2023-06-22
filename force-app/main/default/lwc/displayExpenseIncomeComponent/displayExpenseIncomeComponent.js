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
import getExpenseIncome from '@salesforce/apex/DisplayExpenseIncomeController.getIncomeExpense';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';

import { NavigationMixin } from 'lightning/navigation';

import Data_Condition_Hidden_Text from '@salesforce/label/c.Data_Condition_Hidden_Text';
import notAuthorize from '@salesforce/label/c.Data_Condition_NotAuthorizedMsg';

import {
  refreshApex
} from '@salesforce/apex';
import {
  parseObj
} from 'c/methodUtils';
// import getReferenceByFieldName from '@salesforce/apex/AbstractCoreClass.getReferenceByFieldName';

import getWatermarkHTML from '@salesforce/apex/RTL_CSVLightningUtil.getWatermarkHTML';

const FIELDS = [
  'Hobbies__c'
];

const ExpenseColumn = [
{ label: 'หมวดหมู่',  fieldName: 'Expense_Category__c' },
{ label: 'ความถี่',         fieldName: 'Frequency__c' },
{ label: 'ยอดรายจ่ายต่อปี',    fieldName: 'Expense_Amount__c' },
{ label: 'หมายเหตุ',       fieldName: 'Remark__c' },
];
const IncomeColumn = [
{ label: 'หมวดหมู่',     fieldName: 'Income_Category__c' },
{ label: 'ความถี่',           fieldName: 'Frequency__c' },
{ label: 'ยอดรายรับต่อปี',       fieldName: 'Income_Amount__c' },
{ label: 'หมายเหตุ',         fieldName: 'Remark__c' },
];

export default class CockpitCSVCustomerInfo extends NavigationMixin(LightningElement) {
  // export default class CockpitCSVCustomerInfo extends LightningElement {
  ExpenseColumn = ExpenseColumn;
  IncomeColumn = IncomeColumn;
  @api recordId;
  @api userAgent = 'Desktop';

  @track activeSections = ['Income', 'Expense'];
  @track customerDetail = {};
  @track dataPartition = {};
  @track isGetDataPartition = false;
   
  @track watermarkImage = "";
  isRerender = false;

  @track IncomeData = [];
  @track ExpenseData = [];
  label = {
    Data_Condition_Hidden_Text,
    notAuthorize
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

    getExpenseIncome({
      accountId: this.recordId
    }).then(result => {
      console.log('Income result: '+JSON.stringify(result));
      if(result.success){          
        this.IncomeData = result.income;
        this.ExpenseData = result.expense;

      }
    }).catch(error => {
      console.error('Income Expense Error: ', error);
    });
 
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
    fields_translate: [],
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

      Object.keys(this.customerDetail).forEach((v, i) => {
        this.dataPartition[v].isVisible = this.customerDetail[v].isAccessible;
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

  @api
  refreshPage(fieldUpdate) {
      this.isLoading = true;
      getExpenseIncome({
        accountId: this.recordId
      }).then(result => {
        console.log('Income result: '+JSON.stringify(result));
        if(result.success){          
          this.IncomeData = result.income;
          this.ExpenseData = result.expense;
        }
        this.isLoading = false;
      }).catch(error => {
        console.error('Income Expense Error: ', error);
        this.isLoading = false;
      });
  }


}