import {
    LightningElement,
    api,
} from 'lwc';
import {
    replaceFormat
} from 'c/methodUtils';
import getReference from '@salesforce/apex/AbstractCoreClass.getReference';

export default class PillOutput extends LightningElement {
    @api
    get type() {
        return this._type;
    }
    set type(val) {
        this._type = `${val}`.toUpperCase();
    }
    @api value;
    @api valueAddon;
    /*
        String format replace
        {0...n} number
     */
    @api format;

    // private property
    _type;
    _label; // for link referrence
    _value; // for link referrence

    isRerender = false;
    _isRAW = false;
    _isPHONE = false;
    _isDATE = false;
    _isCURRENCY = false;
    _isNUMBER = false;
    _isNUMBER4 = false;
    _isINTEGER = false;
    _isPERCENT = false;
    _isPERCENT3 = false;
    _isSTRING = false;
    _isDOUBLE = false;
    _isLONG = false;
    _isTIME = false;
    _isTEXTAREA = false;
    _isTEXTAREA2READONLY = false;
    _isPICKLIST = false;
    _isBOOLEAN = false;
    _isEMAIL = false;
    _isLOOKUP = false;
    _isREFERENCE = false;
    _isPARSE = false;

    connectedCallback() {
        this._value = this.value;
        this.runInit();
    }

    renderedCallback() {
        // if (this.isRerender) return;
        // this.isRerender = true;
        this.runInit();
    }

    disconnectedCallback() {
        this.setDefault();
    }

    errorCallback(error, stack) {
        console.log({
            error: error,
            stack: stack,
        });
    }

    setDefault() {
        this._isRAW = false;
        this._isPHONE = false;
        this._isDATE = false;
        this._isCURRENCY = false;
        this._isNUMBER = false;
        this._isNUMBER4 = false;
        this._isINTEGER = false;
        this._isPERCENT = false;
        this._isPERCENT3 = false;
        this._isSTRING = false;
        this._isDOUBLE = false;
        this._isLONG = false;
        this._isTIME = false;
        this._isTEXTAREA = false;
        this._isTEXTAREA2READONLY = false;
        this._isPICKLIST = false;
        this._isBOOLEAN = false;
        this._isEMAIL = false;
        this._isLOOKUP = false;
        this._isREFERENCE = false;
        this._isPARSE = false;
    }

    runInit() {
        switch (this.type) {
            case 'RAW':
                this._isRAW = true;
                break;
            case 'PHONE':
                this._isPHONE = true;
                break;
            case 'DATE':
                this._isDATE = true;
                break;
            case 'CURRENCY':
                this._isCURRENCY = true;
                break;
            case 'NUMBER':
                this._isNUMBER = true;
                break;
            case 'NUMBER4':
                this._isNUMBER4 = true;
                break;
            case 'INTEGER':
                this._isINTEGER = true;
                break;
            case 'PERCENT':
                this._isPERCENT = true;
                this._isvalue = Number(this.value) / 100;
                break;
            case 'PERCENT3':
                this._isPERCENT3 = true;
                this._isvalue = Number(this.value) / 100;
                break;
            case 'STRING':
                this._isSTRING = true;
                break;
            case 'DOUBLE':
                this._isDOUBLE = true;
                break;
            case 'LONG':
                this._isLONG = true;
                break;
            case 'TIME':
                this._isTIME = true;
                break;
            case 'TEXTAREA':
                this._isTEXTAREA = true;
                break;
            case 'TEXTAREA2READONLY':
                this._isTEXTAREA2READONLY = true;
                break;
            case 'PICKLIST':
                this._isPICKLIST = true;
                break;
            case 'BOOLEAN':
                this._isBOOLEAN = true;
                break;
            case 'EMAIL':
                this._isEMAIL = true;
                break;
            case 'REFERENCE':
                getReference({
                    recordId: this.value
                }).then(data => {
                    this._isLOOKUP = false;
                    this._label = this.format ? replaceFormat(this.format, [data].concat(this.valueAddon ? this.valueAddon : '')) : data;
                    this._value = `/lightning/r/${this.value}/view`;
                }).catch(error => {
                    this._isLOOKUP = true;
                    this._value = this.value;
                }).finally(() => {
                    this._isREFERENCE = true;
                });
                break;
            case 'PARSE':
                this._isPARSE = true;
                this._isLOOKUP = this.value.length != 15 && this.value.length != 18;
                if (this._isLOOKUP) {
                    this._value = this.format ? replaceFormat(this.format, this.valueAddon) : this.value;
                } else {
                    this._label = this.format ? replaceFormat(this.format, this.valueAddon) : this.value;
                    this._value = `/lightning/r/${this.value}/view`;
                }
                break;
            default:
                break;
        }
    }
}