import { 
    LightningElement,
    track,
    wire, api
     } from 'lwc';

import fetchOppAppStatus from '@salesforce/apex/newDealSummaryCtl.fetchOppAppStatus';
import getNewDealForecast from '@salesforce/apex/newDealSummaryCtl.getNewDealForecast';
import getCurrentFYYear from '@salesforce/apex/newDealSummaryCtl.getCurrentFYYear';
import getmonthHeader from '@salesforce/apex/newDealSummaryCtl.monthHeader';

export default class NewDealSummary extends LightningElement {

    @api searchKey = '';
    @track LoadingState = false;
    //--Status list for filter---------------
    @track statusList = [];
    @track error;
    @wire(fetchOppAppStatus)
    wiredStatus({ error, data }) {
        if (data) {
            this.statusList = data;
        } else if (error) {
            console.log(error);
            this.error = error;
        }
    }

    handleClick(event) {
        this.searchKey = this.selectedOption;
        getNewDealForecast( {appStatusKey: '$searchKey'});

    }

    // @track next11Month = false;
    // runNext11Month(event) {
    //     this.next11Month = true;
    //     getNewDealForecast( {appStatusKey: '$searchKey', next11month: '$next11Month'});

    // }

    @track selectedOption;
    changeHandler(event) {
        const field = event.target.name;
        if (field === 'optionSelect') {
            this.selectedOption = event.target.value;
            } 
    }
    //--End Status list for filter---------------

    handleResize(event) {
        const sizes = event.detail.columnWidths;
    }   
    
    @wire(getCurrentFYYear) currentYear;
    get year(){
        return this.currentYear.data;
    } 

    @track monthHeaderTable = {};
    @wire(getmonthHeader)
    wiredmonthHeader({ error, data }) {
        if (data) {
            this.monthHeaderTable = data;
        } else if (error) {
            this.error = error;
        }
    }

    @track isNoData = false;

    get dealForeCastArray() {
        
        let dealForeCastList = this.newdealList;  
        this.isNoData = false;

        let groupedDataMap = new Map();
        dealForeCastList.forEach(forcastI => {
            if (groupedDataMap.has(forcastI.rmTeamname)) {
                groupedDataMap.get(forcastI.rmTeamname).dealForeCs.push(forcastI);
            } else {
                let newDealF = {};
                newDealF.rmTeamname = forcastI.rmTeamname;
                newDealF.dealForeCs = [forcastI];
                groupedDataMap.set(forcastI.rmTeamname, newDealF);
            }
        });    
        let itr = groupedDataMap.values();
        let dealForeCastArray = [];
        let result = itr.next();
        while (!result.done) {
            result.value.rowspan = result.value.dealForeCs.length + 1;
            dealForeCastArray.push(result.value);
            result = itr.next();
        }
        this.LoadingState = false;

        if(dealForeCastArray.length <= 0){
            this.isNoData = true;
        }
        return dealForeCastArray;

    }   

    get totalNI(){
        let totalNI = {};
        if(this.newdealList.length > 0){
            let ni = this.newdealList;
            var i = ni.length -1;            
            totalNI = ni[i].sumTotalNI;           
        }
        return totalNI;
        
    }

    //--------- pagination -----*/

    @track page = 1; //this will initialize 1st page
    @track items = []; //it contains all the records.
    @track startingRecord = 1; //start record position per page
    @track endingRecord = 0; //end record position per page
    @track pageSize = 200; //default value we are assigning
    @track totalRecountCount = 0; //total record count received from all retrieved records
    @track totalPage = 0; //total number of page is needed to display all records

    @track isShowPrevious = true;
    @track isShownext = true;

    @track isShowFirstPage = true;
    @track isShowEndPage = true;

    @track newdealList = [];
    @wire(getNewDealForecast, { appStatusKey: '$searchKey'})
        dealForecastData({ error, data }) {
        this.LoadingState = false;
        if (data) {

            this.items = data;
            this.totalRecountCount = data.length; //here it is length
            if(this.totalRecountCount > this.pageSize){
                this.isShownext = false;
                this.isShowEndPage = false;
            }
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is pageSize
            this.newdealList = this.items.slice(0,this.pageSize); 
            if(this.totalRecountCount <= this.pageSize){
                this.endingRecord = this.totalRecountCount;
                this.page = this.totalPage;
                this.startingRecord = 1;
                this.isShowPrevious = true;
                this.isShownext = true;

                this.isShowFirstPage = true;
                this.isShowEndPage = true;

                if(this.totalRecountCount === 0){
                    this.startingRecord = 0;
                }

            }else{
                this.endingRecord = this.pageSize;
            }
            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.newdealList = undefined;
        }
        this.LoadingState = true;
    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            //this.LoadingState = false;
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            //this.LoadingState = false;
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }             
    }

    endPage() {
        if (this.page >= 1) {
            //this.LoadingState = false;
            this.page = this.totalPage;
            this.displayRecordPerPage(this.page);
        }
    }

    firstPage() {
        if (this.page >= 1) {  
            //this.LoadingState = false;         
            this.page = 1;
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 
        this.newdealList = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        
        if(this.totalRecountCount <= this.pageSize){
            this.isShowPrevious = true;
            this.isShownext = true;
            this.isShowFirstPage = true;
            this.isShowEndPage = true;
        }else{

            if(this.startingRecord <= this.pageSize){
                this.isShowPrevious = true;
                this.isShowFirstPage = true;
                this.isShownext = false;
                this.isShowEndPage = false;
            }else{
                this.isShowPrevious = false;
                this.isShowFirstPage = false;
                this.isShownext = false;
                this.isShowEndPage = false;
                if(this.pageSize > (this.totalRecountCount -this.startingRecord) ){
                    this.isShownext = true;
                    this.isShowEndPage = true;
                }

            }

        }
        this.LoadingState = true;
    
    } 
    

}