import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    refreshApex
} from '@salesforce/apex';
import {
    FIELDS
} from './fieldLayout';
import getSObjectLabelByRecordId from '@salesforce/apex/AbstractCoreClass.getSObjectLabelByRecordId';
import getReference from '@salesforce/apex/AbstractCoreClass.getReference';
import {
    NavigationMixin
} from 'lightning/navigation';

export default class PopHover extends NavigationMixin(LightningElement) {
    static delegatesFocus = false;

    @track 
    _recId;
    _sobjectName;
    _fields;
    _iconName;
    _isavailable = false;

    @api
    get recordId() {
        return this._recId;
    }
    set recordId(value) {
        this.setAttribute('recordId', value);
        this._recId = value;
        this._isavailable = false;
        this._sobjectName = false;
        this._fields = [];

        getSObjectLabelByRecordId({ recordId: value })
            .then((result) => {
                if(result && FIELDS[result] && FIELDS[result].length > 0){
                    this._sobjectName = result ? result : '';
                    this._fields = result ? FIELDS[result] : [];
                    this._iconName = !`${result}`.includes('__c') ? `standard:${result}`.toLowerCase() : 'custom:custom1';
                    this._isavailable = true;
                }
            })
    }

    @wire(getReference, {
        recordId: '$recordId'
    })
    _Name;

    constructor() {
        super();
        window.addEventListener('focus blur', this.preventEvent);
    }

    renderedCallback() {

    }

    disconnectedCallback() {
        window.removeEventListener('focus blur', this.preventEvent);
        refreshApex(this._sobjectName);
        refreshApex(this._Name);
    }

    preventEvent(event) {
        event.preventDefault();
    }

    navigateToRecord(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this._sobjectName,
                actionName: 'view'
            }
        });
        this.dispatchEvent(
            new CustomEvent('closing', {
                detail: {
                    close: true
                }
            })
        );
    }

    handleClose(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent('closing', {
                detail: {
                    close: true
                }
            })
        );
    }

    handleMouseEnter(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent('entering', {
                detail: {
                    enter: true
                }
            })
        );
    }

    handleMouseLeave(event) {
        event.preventDefault();
        this.dispatchEvent(
            new CustomEvent('entering', {
                detail: {
                    enter: false
                }
            })
        );
    }
}