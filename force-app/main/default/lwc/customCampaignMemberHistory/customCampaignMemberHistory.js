import { LightningElement, api, track, wire } from 'lwc';
import getHistoryDetailsWithLimit from '@salesforce/apex/customCampaignMemberHistoryCtrl.getHistoryDetailsWithLimit';

import label_title from '@salesforce/label/c.RTL_Campaign_Member_History_Section_Title';
import label_date from '@salesforce/label/c.RTL_Campaign_Member_History_Header_Date';
import label_field from '@salesforce/label/c.RTL_Campaign_Member_History_Header_Field';
import label_modby from '@salesforce/label/c.RTL_Campaign_Member_History_Header_ModBy';
import label_old from '@salesforce/label/c.RTL_Campaign_Member_Updated_Text';
import label_new from '@salesforce/label/c.RTL_Campaign_Member_To_Text';

import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';

import { NavigationMixin } from 'lightning/navigation';

export default class CustomCampaignMemberHistory extends NavigationMixin(LightningElement) {

    @track label = {
        label_title,
        label_date,
        label_field,
        label_modby,
        label_old,
        label_new
    }

    @track wiredResult;
    @api recordId;
    @api displayRows = 2;
    @api displayData;
    @track emptyResult = false;

    async handler() {
        getRecordNotifyChange([{recordId: this.recordId}]);
        // this.dispatchEvent(new CustomEvent('recordChange'));
      }

    // connectedCallBack(){
    //     console.log('connectedCallBack');
    //     this.getHistoryDetailsWithLimit(this.recordId,this.displayRows);
    // }

    // getHistoryDetailsWithLimit(){
    //     getHistoryDetailsWithLimit({
    //         recordId: this.recordId,
    //         numOfElement : this.displayRows
    //     })
    //     .then((result) => {
    //         console.log('result', result);
    //         let data = result.data;
    //         let error = result.error;
    //         // this.wiredResult = result;
    //         if(result){
    //             console.log('fetched', JSON.stringify(result));
    //             // console.log(!data.length)
    //             if(!result.length){
    //                 this.emptyResult = true;
    //             }
    //             this.displayData = result;
    //         }
    //         else if(error){
    //             console.log(error);
    //         }
    //     })
    // }


    @wire(getHistoryDetailsWithLimit, {
        recordId: '$recordId',
        numOfElement: '$displayRows'
    })
    fetchedHistory(result){
        let data = result.data;
        let error = result.error;
        this.wiredResult = result;
        if(this.wiredResult.data){
            console.log('fetched', JSON.stringify(this.wiredResult.data));
            // console.log(!data.length)
            if(!this.wiredResult.data.length){
                this.emptyResult = true;
            }
            this.displayData = this.wiredResult.data;
        }
        else if(error){
            console.log(error);
        }
    }

    // @wire(getRecord, {
    //     recordId: '$recordId',
    //     fields: ['CampaignMember.RTL_Contact_Status__c']
    // })
    // getCampaignHisRecord({data,error})
    // {
    //     console.log('data:', data);
    //     console.log('error:', error);
    //     if(data)
    //     {
    //         console.log('getCampaignHisRecord:', data);
    //         this.getHistoryDetailsWithLimit(this.recordId,this.displayRows);
    //     }
    // }


    @api 
    refreshView()
    {
        // console.log('lwc!!');
        // getRecordNotifyChange([{recordId: this.recordId}]);
        //this.displayRows = 1;
        // return getHistoryDetailsWithLimit(this.recordId,this.displayRows);
        // getHistoryDetailsWithLimit([{recordId: this.recordId,numOfElement: this.displayRows}]);
    }

    handleViewAll(){

        this[NavigationMixin.Navigate]({
            "type": "standard__component",
            "attributes": {
                "componentName":"c__customAllCMH_Main"
            },
            "state": {
                "c__recordId": this.recordId
            }
        });
    }

    handleClickUser(event){

        this[NavigationMixin.Navigate]({
            "type" : "standard__recordPage",
            "attributes": {
                "recordId"      : event.target.dataset.id,
                "actionName"    : "view"
            }
        });
    }

}