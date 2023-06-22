import {LightningElement,api, track, wire} from 'lwc';

// importing apex class methods
import getAccountList from '@salesforce/apex/reassignBRCCustomerCTL.getBRCCustomerList';
import recordReassignBRC from '@salesforce/apex/reassignBRCCustomerCTL.recordReassign';
import findBRCuser from "@salesforce/apex/reassignBRCCustomerCTL.findBRCUserRecords";

// importing to show toast notifictions
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

// importing to refresh the apex after delete the records.
import {refreshApex} from '@salesforce/apex';

//import custom label field culumn header
import TMB_Customer_ID from '@salesforce/label/c.BRC_Field_TMB_Customer_ID';
import Customer_Title from '@salesforce/label/c.BRC_Field_Customer_Title';
import Customer_Name from '@salesforce/label/c.BRC_Field_Customer_Name';
import Segment from '@salesforce/label/c.BRC_Field_Segment';
import Sub_Segment from '@salesforce/label/c.BRC_Field_Sub_Segment';
import Suitability from '@salesforce/label/c.BRC_Field_Suitability';
import aum from '@salesforce/label/c.BRC_Field_AUM';
import Last_Cal_AUM from '@salesforce/label/c.BRC_Field_Last_Cal_AUM';
import Most_Oper_Branch from '@salesforce/label/c.BRC_Field_Most_Oper_Branch';
import Assign_BRC_User from '@salesforce/label/c.BRC_Field_Assign_BRC_User';
import Wealth_RM_BM from '@salesforce/label/c.BRC_Field_Wealth_RM_BM';
import asignBRCButton from '@salesforce/label/c.BRC_Button_AssignBRC';
import selectDataButton from '@salesforce/label/c.BRC_Button_Select_Data';


//import custom label messege
import errorSelectRecord from '@salesforce/label/c.BRC_Error_Select_Record';
import errorSelectuser from '@salesforce/label/c.BRC_Error_Select_User';
//import customerAssigned from '@salesforce/label/c.BRC_Sussess_Customer_Assigned';
import errorUpdateRecord from '@salesforce/label/c.BRC_Error_Update_Record';
import Error_Page_Less_Than1 from '@salesforce/label/c.BRC_Error_Page_Less_Than1';
import Error_Page_More_Than from '@salesforce/label/c.BRC_Error_Page_More_Than';

// datatable columns
    const columns = [{
        label: TMB_Customer_ID,
        fieldName: 'TMB_Customer_ID_PE__c',
        type: 'text',
        sortable: true
    },
    {
        label: Customer_Title,
        fieldName: 'RTL_Customer_Title__c',
        type: 'text',
        sortable: true
    },
    {
        label: Customer_Name,
        fieldName: 'CustomerNameLink',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'},
        sortable: true
    },
    {
        label: Segment,
        fieldName: 'Core_Banking_Suggested_Segment__c',
        type: 'text',
        sortable: true
    },
    {
        label: Sub_Segment,
        fieldName: 'Sub_segment__c',
        type: 'text',
        sortable: true
    },
    {
        label: Suitability,
        fieldName: 'RTL_Suitability__c',      
        type: 'text',
        sortable: true
    },
    {
        label: aum,
        fieldName: 'RTL_AUM__c',
        type: 'Currency',
        sortable: true
    },
    {
        label: Last_Cal_AUM,
        fieldName: 'RTL_AUM_Last_Calculated_Date__c',
        type: 'date',
        sortable: true
    },
    {
        label: Most_Oper_Branch,
        fieldName: 'BranchBRCLink',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Most_Operating_Branch_Name__c' }, target: '_blank'},
        sortable: true
    },
    {
        label: Assign_BRC_User,
        fieldName: 'BRCuserLink',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Assigned_BRC_User_Name__c' }, target: '_blank'},
        sortable: true
    },
    {
        label: Wealth_RM_BM,
        fieldName: 'WealthUserLink',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Wealth_RM_BM_Name__c' }, target: '_blank'},
        sortable: true
        }
    ]; 

    const DELAY = 300;
    const pageNumber = 1; //default page number
    const limitRecordPerPage = 500;


export default class ReassignBRCCustomer extends LightningElement {
    // reactive variable
    @api allDataList = [];
    @track columns = columns;
    @track recordsCount = 0;

    @track showTableData = false;
    @track isNoData = false;
    @track showSelectData = false;

    // non-reactive variables
    @track selectedRecords = [];
    @track refreshTable = [];
    error;

    @track recordsToDisplay = []; //Records to be displayed on the page
    @track numberRecordDisplay; //Show number of record display
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @track tempData = [];

    @track totalRecords; //Total no.of records; valid type is Integer
    @track pageSize = limitRecordPerPage; //No.of records to be displayed per page
    @track pageNumber = pageNumber; //Page number
    @track totalPages; //Total no.of pages

    @track selectRecordsDisplay = [];

    @track showReassignBox = true;
    @track showAssignBRCBox = false;    
    
    @track controlPagination = false;
    @track controlPrevious = false; //Controls the visibility of Previous page button
    @track controlNext = false; //Controls the visibility of Next page button

    //Search user for assign
    @track recordsList;  
    @track searchBRCKey = "";  
    @api selectedValue;  
    @api selectedRecordId;  
    @api objectApiName = 'User';  
    @api iconName;   
    @track messageSearch;  

    @api LoadingState = false;

    @track rowNumberOffset;
    @track selectRowNumberOffset;

    //Column name
    @track Col_TMB_Customer_ID = TMB_Customer_ID;
    @track Col_Customer_Title = Customer_Title;
    @track Col_Customer_Name = Customer_Name;
    @track Col_Segment = Segment;
    @track Col_Sub_Segment = Sub_Segment;
    @track Col_Suitability = Suitability;
    @track Col_aum = aum;
    @track Col_Last_Cal_AUM = Last_Cal_AUM;
    @track Col_Most_Oper_Branch = Most_Oper_Branch;
    @track Col_Assign_BRC_User = Assign_BRC_User;
    @track Col_Wealth_RM_BM = Wealth_RM_BM;

    @track asignBRC = asignBRCButton;
    @track selectData = selectDataButton;

    //popup
    @track popupMessege;
    @track popupHeader;
    @track showPopup = false;
    @track isError = false;

    // retrieving the data using wire service
    @wire(getAccountList)
    getAccountList(result){
        this.LoadingState = true;
        this.refreshTable = result;
        this.showSearchBox = true;
        this.showTableData = true; 
        if(result.data){  

            this.allDataList = result.data;
            this.tempData = result.data;
           // this.showTableData = true;   
            this.LoadingState = false;  
            this.setRecordsToDisplay();      

        }else{
            this.error = result.error;

        }
        
    }    
   
    // Getting selected rows 
    getSelectedRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;        
        this.recordsCount = event.detail.selectedRows.length;

        // this set elements the duplicates if any
        let accIds = new Set();

        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
            accIds.add(selectedRows[i].Id);
        }

        // coverting to array
        this.selectedRecords = Array.from(accIds);
        window.console.log('selectedRecords ====> ' +this.selectedRecords);
    }

    // Select records function
    selectAccount() {
        if(this.selectedRecords.length <= 0){
            window.console.log('no select record');
            //alert(errorSelectRecord);

            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = errorSelectRecord;

        }else{
            if (this.selectedRecords) {
                this.selectRecordsDisplay = [];               
                for(let i = 0; i < this.recordsToDisplay.length; i++){
                    if(this.selectedRecords.includes(this.recordsToDisplay[i].Id )){
                        this.selectRecordsDisplay.push(this.recordsToDisplay[i]);                   
                    }               
                }

                //Set hide view section
                this.showTableData = false;
                this.showSelectData = true;
                this.controlPagination = false;
                this.showSearchBox = false;               
                this.showReassignBox = false;
                this.showAssignBRCBox = true;
            }
        }
       
    }

    //Assign new BRC staff to customer
    reassignBRCuser() {  
        if(this.selectedRecordId == null){
           // alert(errorSelectuser); 
            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = errorSelectuser;
        }else{
            this.LoadingState = true;           
            recordReassignBRC({lstAcc: this.selectRecordsDisplay, newBRCId: this.selectedRecordId})
            .then(result => {
                window.console.log('result ====> ' + result);
                //alert(result);
                this.showPopup = true;
                this.popupHeader = 'Result';
                this.isError = false;
                this.popupMessege = result; 
                   
                // Clearing selected row indexs 
               // this.template.querySelector('lightning-datatable').selectedRows = [];
                
               //reset data for display in screen
                this.showSelectData = false;
                this.showTableData = true;
                this.controlPagination = true;
                this.showSearchBox = true;

                this.recordsCount = 0;
                this.showReassignBox = true;
                this.showAssignBRCBox = false;
                this.selectedRecords = [];
                
                this.searchKey = "";  
                this.selectedValue = null;  
                this.selectedRecordId = null;  
                this.recordsList = null;  
                 
                this.LoadingState = false;
                // refreshing table data using refresh apex
                return refreshApex(this.refreshTable); 
                

            })
            .catch(error => {
                window.console.log(error);               
               // alert(errorUpdateRecord);
 
                this.showPopup = true;
                this.popupHeader = 'Error!';
                this.isError = true;
                this.popupMessege = errorUpdateRecord;


                //reset data for display in screen
                this.showSelectData = false;
                this.showTableData = true;
                this.controlPagination = true;
                this.showSearchBox = true;

                this.recordsCount = 0;
                this.showReassignBox = true;
                this.showAssignBRCBox = false;
                this.selectedRecords = [];
                
                this.searchKey = "";  
                this.selectedValue = null;  
                this.selectedRecordId = null;  
                this.recordsList = null;  
    
                
            });

            
            

        }
        
    }  

    //Serch data function
    searchData(event) {
        
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
       
        if(searchKey){
            
            this.delayTimeout = setTimeout(() => {
                
                this.tempData = this.allDataList.filter(rec => JSON.stringify(rec).toLowerCase().includes(searchKey.toLowerCase()));
                
                if(Array.isArray(this.tempData) && this.tempData.length > 0)
                    this.dispatchEvent(new CustomEvent('paginatorchange', {detail: this.tempData}));    //Send records to display on table to the parent component
            }, DELAY); 
        
        }else{
           
            this.tempData = this.allDataList;
            
        } 

        this.pageNumber = 1;
        this.setRecordsToDisplay();
     
    }

    setRecordsToDisplay(){
        
        this.recordsToDisplay = [];
        this.totalRecords = this.tempData.length;       
        if(!this.pageSize){
            this.pageSize = this.totalRecords;
        }
        this.totalPages = Math.ceil(this.totalRecords/this.pageSize);   
        if(this.tempData.length > 0){
            for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
                let acc = {};
                if(i === this.totalRecords) break;
                acc.CustomerNameLink = '/'+this.tempData[i].Id;
                if(this.tempData[i].RTL_Most_Operating_Branch__c != null){  acc.BranchBRCLink ='/'+ this.tempData[i].RTL_Most_Operating_Branch__c;  }      
                if(this.tempData[i].RTL_Assigned_BRC__c != null){acc.BRCuserLink = '/'+this.tempData[i].RTL_Assigned_BRC__c;}
                if(this.tempData[i].RTL_Wealth_RM__c != null){acc.WealthUserLink = '/'+this.tempData[i].RTL_Wealth_RM__c;}
                acc = Object.assign(acc, this.tempData[i]);
                this.recordsToDisplay.push(acc);               
            } 
        }

        this.numberRecordDisplay = this.recordsToDisplay.length;
        if(this.recordsToDisplay.length <= 0){
            this.isNoData = true;
           // this.showTableData = false;
        }else{
            this.isNoData = false;
           // this.showTableData = true;
            
        }
        this.LoadingState = false;

        //-------------for paginator
        if(this.totalRecords > this.pageSize){
            this.controlPagination = true;
        }
        this.rowNumberOffset = (this.pageNumber-1)*this.pageSize;
        this.setPaginationControls();
       
    }  

    setPaginationControls(){

        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.controlPrevious = false;
            this.controlNext = false;
        }else if(this.totalPages > 1){
           this.controlPrevious = true;
           this.controlNext = true;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
            this.controlPrevious = false;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
            this.controlNext = false;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        if(this.controlPagination === false){
            this.controlPrevious = false;
            this.controlNext = false;
        }
    }
   
    handlePageNumberChange(event){        
        if(event.keyCode === 13){
            this.pageNumber = event.target.value;           
            if(this.pageNumber <= 0){ 
               // alert(Error_Page_Less_Than1);          
     
                this.showPopup = true;
                this.popupHeader = 'Error!';
                this.isError = true;
                this.popupMessege = Error_Page_Less_Than1;

            }else if(this.pageNumber > this.totalPages){
               // alert(Error_Page_More_Than+' '+ this.totalPages);

                this.showPopup = true;
                this.popupHeader = 'Error!';
                this.isError = true;
                this.popupMessege = Error_Page_More_Than+' '+ this.totalPages;

            }else{

                this.recordsCount = 0;
                let selectedRows = this.template.querySelector('[data-id="maincheckbox"]');
                selectedRows.checked = false;

                this.setRecordsToDisplay();
            }
        }

       
    }

    previousPage(){     
        this.pageNumber = this.pageNumber - 1;        
        if(this.pageNumber <=0){
           // alert(Error_Page_Less_Than1);
            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = Error_Page_Less_Than1;
        }else if(this.pageNumber > this.totalPages){
           // alert(Error_Page_More_Than+' '+ this.totalPages);
            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = Error_Page_More_Than+' '+ this.totalPages;

        }else{

            this.recordsCount = 0;
            let selectedRows = this.template.querySelector('[data-id="maincheckbox"]');
            selectedRows.checked = false;

            this.setRecordsToDisplay();
        } 
        
        
    }

    nextPage(){      
        this.pageNumber = (this.pageNumber - 1) + 2;      
        if(this.pageNumber > this.totalPages){
            //alert(Error_Page_More_Than+' '+ this.totalPages);
            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = Error_Page_More_Than+' '+ this.totalPages;

        }else if(this.pageNumber <=0){
            //alert(Error_Page_Less_Than1);
            this.showPopup = true;
            this.popupHeader = 'Error!';
            this.isError = true;
            this.popupMessege = Error_Page_Less_Than1;

        }else{

            this.recordsCount = 0;
            let selectedRows = this.template.querySelector('[data-id="maincheckbox"]');
            selectedRows.checked = false;

            this.setRecordsToDisplay();
        }
        
       
        
    }

    cancelSelection(){
        this.showSelectData = false;
        this.showTableData = true;
        this.controlPagination = true;
        this.showSearchBox = true;

        this.recordsCount = 0;
        this.showReassignBox = true;
        this.showAssignBRCBox = false;
        this.selectedRecords = [];
        
        this.searchKey = "";  
        this.selectedValue = null;  
        this.selectedRecordId = null;  
        this.recordsList = null;  

        this.setRecordsToDisplay();

    }

    //------------------Search User function -------------
        
    onLeave(event) {  
        setTimeout(() => {  
            this.searchBRCKey = "";  
            this.recordsList = null;  
        }, 300);  
    }  
        
    onRecordSelection(event) {  
        this.selectedRecordId = event.target.dataset.key;  
        this.selectedValue = event.target.dataset.name;  
        this.searchBRCKey = "";  
        this.onSeletedRecordUpdate();  
    }  
   
    handleFindBRC(event) {  
        const searchKey = event.target.value;  
        this.searchBRCKey = searchKey;  
        this.getLookupResult();  
    }

    removeRecordOnLookup(event) {  
        this.searchKey = "";  
        this.selectedValue = null;  
        this.selectedRecordId = null;  
        this.recordsList = null;  
        this.onSeletedRecordUpdate();  
    } 

    getLookupResult() {  
        findBRCuser({ searchBRCKey: this.searchBRCKey, objectName : this.objectApiName })  
         .then((result) => {  
          if (result.length===0) {  
            this.recordsList = [];  
            this.messageSearch = "No Records Found";  
           } else {  
            this.recordsList = result;  
            this.messageSearch = "";  
           }  
           this.error = undefined;  
         })  
         .catch((error) => {  
          this.error = error;  
          this.recordsList = undefined;  
         });  
       } 
       
    onSeletedRecordUpdate(){  
        const passEventr = new CustomEvent('recordselection', {  
          detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
        });  
        this.dispatchEvent(passEventr);  
    }


    //-----------For select record-----------

    selectedAllRecords(event) {
        
        this.LoadingState = true;
        let selectedRows = [];
        let chackBoxvalue = event.target.checked;      
        new Promise(
            (resolve) => {
            setTimeout(()=> {   
               
            selectedRows = this.template.querySelectorAll('lightning-input');               
            this.recordsCount = 0;
            for(let i = 0; i < selectedRows.length; i++) {
                if(selectedRows[i].type === 'checkbox' && selectedRows[i].dataset.id != null && selectedRows[i].dataset.id != 'maincheckbox') {
                    selectedRows[i].checked = chackBoxvalue;
                    if(selectedRows[i].checked === true){
                        this.recordsCount = this.recordsCount + 1;
                    }                    
                    if(selectedRows[i].checked === false){
                        this.recordsCount = this.recordsCount - 1;

                    }
                }
                if(this.recordsCount < 0){
                    this.recordsCount = 0;
                }
            }            
            
            resolve();
                }, 0);
            }).then(
                () => this.LoadingState = false
                
            );  
            
    }

    selectRecord(event){

        let selectedRows = event.detail;

        selectedRows.checked = event.target.checked;
        if(this.recordsCount < 0){
            this.recordsCount = 0;
        }        
        if(selectedRows.checked == true){
            this.recordsCount = this.recordsCount + 1;
        }
        if(selectedRows.checked == false){
            this.recordsCount = this.recordsCount - 1;
        }

    }


    // Select records function
    selectDataForAssign() {
        this.LoadingState = true;
        new Promise(
            (resolve) => {
            setTimeout(()=> { 

            let selectedRows = this.template.querySelectorAll('lightning-input');
            this.selectRecordsDisplay = []; 
            // based on selected row getting values of the contact
            for(let i = 0; i < selectedRows.length; i++) {
                if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
                    this.selectedRecords.push(selectedRows[i].dataset.id)   
                }
            }

            if(this.selectedRecords.length <= 0){
                window.console.log('no select record');
                //alert(errorSelectRecord);               
                this.showPopup = true;
                this.popupHeader = 'Error!';
                this.isError = true;
                this.popupMessege = errorSelectRecord;

            }else{
                if (this.selectedRecords) {
                    this.selectRecordsDisplay = [];               
                    for(let i = 0; i < this.recordsToDisplay.length; i++){
                        if(this.selectedRecords.includes(this.recordsToDisplay[i].Id )){
                            this.selectRecordsDisplay.push(this.recordsToDisplay[i]);                   
                        }               
                    }           

                    //Set hide view section
                    this.showTableData = false;
                    this.showSelectData = true;
                    this.controlPagination = false;
                    this.showSearchBox = false;               
                    this.showReassignBox = false;
                    this.showAssignBRCBox = true;
                }
            }

        resolve();
                }, 0);
            }).then(
                () => this.LoadingState = false
                
            ); 
        
    }

    closedPopup(){
        this.showPopup = false;
    }
    
}