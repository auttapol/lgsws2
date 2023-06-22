import { api, LightningElement, wire } from 'lwc'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

// Constant
import formFactor from '@salesforce/client/formFactor'
import userId from '@salesforce/user/Id';
import label from './customLabel';

// Method
import { uuid } from 'c/methodUtils';
import calloutPopup from '@salesforce/apexContinuation/RTL_TMBProtectionAPIOneApp.calloutPopupBAViewTMBProtection'
import { getRecord } from 'lightning/uiRecordApi';

export default class RtlPopupLink extends NavigationMixin(LightningElement) {

    @api
    recordId
    _tmb_cust_id
    @api
    isInit = false

    // link pop ba view
    url

    // private property
    _isLoading = false
    get isLoading() {
        return this._isLoading || this.isInit
    }
    set isLoading(val) {
        this._isLoading = val
    }

    // private property
    _msgError
    _msgError_opt
    _isError = false
    get isError() {
        return this._isError
    }
    set isError(val) {
        this._isError = val
    }

    _title = label.BA_View
    _formFactor = formFactor
    _windowObjRef // window obj reference 

    _account
    @wire(getRecord, {
        recordId: '$recordId', fields: [
            'Account.TMB_Customer_ID_PE__c'
        ]
    })
    callbackGetRecord({ data }) {
        if (data) {
            this._account = Object.keys(data.fields).reduce((l, i) => {
                l[i] = data.fields[i].value
                return l
            }, {})

            this._tmb_cust_id = this._account.TMB_Customer_ID_PE__c;
            // if (this._tmb_cust_id) {
            this.calloutInit();
            // } else {
            //     this.isLoading = true
            //     this.isError = true
            //     this._msgError = `${label.TMB_CUST_ID_Required} `
            // }
        }
    }

    _isRetailProfile = false
    @wire(getRecord, {
        recordId: userId,
        fields: [
            'User.Profile.Name'
        ]
    })
    callbackGetProfileName({ data }) {
        if (data) {
            this._isRetailProfile =
                `${data.fields.Profile.displayValue}`.includes('Admin') ||
                `${data.fields.Profile.displayValue}`.includes('Retail')
        }
    }

    @api
    async handlepopUpLink() {
        if (!this._tmb_cust_id) {
            this.toastMessage()
            return
        }
        if (!this.url) {
            this.isError = true
            await this.calloutInit()
            this.toastMessage()
        }

        let url = this.url
        if (!url) return;

        if (this._windowObjRef == null || this._windowObjRef.closed) {
            // Desktop environment
            if (this._formFactor === 'Large') {
                this._windowObjRef = window.open(url, uuid())
            }
            // Salesforce one app environment
            else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: { url }
                })
            }
        }
        else {
            this._windowObjRef?.focus()
        }

        this.dispatchEvent(new CustomEvent('close'))
    }

    toastMessage() {
        this.dispatchEvent(new ShowToastEvent({
            variant: 'error',
            // title: ,
            message: `${label.BA_View}: ${this._msgError}`,
        }));
    }

    connectedCallback() {
        this._class = `${this._formFactor === 'Large' ? 'slds-m-horizontal_small' : 'd-flex slds-m-vertical_small'}`
        this.dispatchEvent(new CustomEvent('init'))
    }

    async calloutInit() {
        try {
            this.isLoading = true

            let result = await calloutPopup({ tmb_cust_id: this._tmb_cust_id })
            this.url = result?.Data?.ValidateUrl || result?.data?.validateUrl

            if (this.url) {
                this.isError = false
            } else {
                // this.isError = true
                let _msgErr = result?.statusdesc.split('{0}')
                this._msgError = _msgErr[0]
                this._msgError_opt = _msgErr[1] || null
            }

            this.isLoading = false
        } catch (e) {
            console.error(e);
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: e.body?.exceptionType,
                message: e.body?.message,
            }));
        }
    }

}