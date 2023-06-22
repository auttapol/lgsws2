import {
    api,
    LightningElement,
    wire
} from 'lwc';
import {
    getRecord,
    getFieldValue
} from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import Employee_ID__c from '@salesforce/schema/User.Employee_ID__c';

export default class Watermark extends LightningElement {
    isRerender = false;
    _userId;
    _EmployeeId;

    @wire(getRecord, {
        recordId: '$_userId',
        fields: [
            Employee_ID__c
        ]
    })
    getEmployeeId({
        error,
        data
    }) {
        if (data) {
            this._EmployeeId = getFieldValue(data, Employee_ID__c);
            this.dispatchEvent(new CustomEvent('init'))
        }
    }

    connectedCallback() {
        this._userId = userId;
    }

    // Handle re-render
    renderedCallback() {
        if (this.isRerender) {
            return;
        }
        this.isRerender = true;
    }

    @api
    get watermarkHtml() {
        return this.generateHTML(this._EmployeeId ? this._EmployeeId : '');
    }

    generateHTML(employeeId) {
        let imgEncode = btoa(`<svg xmlns='http://www.w3.org/2000/svg' version='1.1' height='90px' width='140px'>
                                <text transform='translate(20, 65) rotate(-45)' fill='rgb(226,226,226)' font-size='30' >${employeeId}</text>
                            </svg>`);
        return `url(data:image/svg+xml;base64,${imgEncode})`;
    }
}