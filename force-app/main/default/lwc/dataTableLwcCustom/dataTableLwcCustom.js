import {
    LightningElement,
    api,
    track
} from 'lwc';

import {
    getValueReference,
    uuid,
    parseObj
} from 'c/methodUtils';

import {
    NavigationMixin
} from 'lightning/navigation';

export default class DataTableLwcCustom extends NavigationMixin(LightningElement) {
    isRerender = false;

    @api columns;
    @api items;
    @api offset = this.isPaginator ? 10 : 1000;
    @api isPaginator = this.offset == 1000;

    @track data = [];
    _data = [];
    _curentPage = 1;
    _totalPage = 1;

    // Run initial
    connectedCallback() {
        this.generateDataTable();
        this.offset = parseInt(this.offset)
        this._totalPage = Math.ceil(this._data.length / this.offset);

    }

    // Handle re-render
    renderedCallback() {
        if (this.isRerender) {
            return;
        }
        this.isRerender = true;
    }

    @api
    get isDisabledPrevious() {
        return this.currentPage == 1;
    }
    @api
    get isDisabledNext() {
        return this.currentPage == this.totalPage;
    }

    @api
    get totalPage() {
        return this._totalPage;
    }
    @api
    get currentPage() {
        return this._curentPage;
    }
    set currentPage(value) {
        this._curentPage = value >= this.totalPage ? this.totalPage : (value > 0 ? value : 1);
    }

    @api
    reload() {
        this.data = [];
        this.generateDataTable();
    }
    @api
    first() {
        this.currentPage = 1;
        this.data = [];
        for (let i = 0; i < this.offset && i < this._data.length; i++) {
            this.data.push(this._data[i]);
        }
    }
    @api
    next() {
        this.currentPage += 1;
        this.data = [];
        let startIndex = (this.currentPage - 1) * this.offset;
        let length = startIndex + this.offset;
        for (let i = startIndex; i < length && i < this._data.length; i++) {
            this.data.push(this._data[i]);
        }
    }
    @api
    previous() {
        this.currentPage -= 1;
        this.data = [];
        let startIndex = (this.currentPage - 1) * this.offset;
        let length = startIndex + this.offset;
        for (let i = startIndex; i < length && i < this._data.length; i++) {
            this.data.push(this._data[i]);
        }
    }
    @api
    last() {
        this.currentPage = this.totalPage;
        this.data = [];
        if (this.currentPage > 1) {
            let startIndex = parseInt(this._data.length / this.offset) * this.offset;
            let length = startIndex + (this._data.length % this.offset);
            for (let i = startIndex; i < length; i++) {
                this.data.push(this._data[i]);
            }
        }
    }

    generateDataTable() {
        try {
            this.items.forEach((item, index) => {
                let obj = {
                    key: item.Id,
                    fields: []
                };
                this.columns.forEach(column => {
                    let isAction = column.type.toUpperCase() == 'ACTION';
                    let isParse = column.type.toUpperCase() == 'PARSE';
                    obj.fields.push({
                        key: uuid(),
                        fieldName: column.fieldName,
                        isAction: isAction,
                        type: column.type.toUpperCase(),
                        value: isAction ? (item.action ? Object.keys(item.action).map(m => {
                            return {
                                type: m,
                                label: item.action[m],
                            };
                        }) : []) : getValueReference(column.fieldName, item),
                        format: column.format,
                        valueAddon: isParse ? column.valueAddon.map(m => getValueReference(m, item)) : column.valueAddon,
                    })
                });
                this._data.push(obj);

                if (index < this.offset) {
                    this.data.push(obj);
                }
            });
        } catch (error) {
            console.log(error);
        }
    }

    handleOnclickEvent(event) {
        event.preventDefault();
        var dataset = event.target.dataset;
        this.dispatchEvent(
            new CustomEvent(dataset.type, {
                detail: {
                    recordId: dataset.id,
                    type: dataset.type
                }
            })
        );
    }
}