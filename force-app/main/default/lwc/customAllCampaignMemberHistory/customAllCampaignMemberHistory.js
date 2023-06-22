import { LightningElement, track, api, wire } from 'lwc';
import getHistoryDetails from '@salesforce/apex/customCampaignMemberHistoryCtrl.getHistoryDetails';

import { NavigationMixin } from 'lightning/navigation';

// Import custom labels
import haveNoRecord from '@salesforce/label/c.RTL_CampaignMemberHistory_HaveNoRecord';
import campHisTitile from '@salesforce/label/c.RTL_Campaign_Member_History_Title'; 
import campHisSubTitile from '@salesforce/label/c.RTL_Campaign_Member_History_Subtitle';  


export default class CustomAllCampaignMemberHistory extends NavigationMixin(LightningElement) {

    @api recordId;
    @track displayData;
    @track isDisplay = false;

    // Expose the labels to use in the template.
    label = {
        haveNoRecord,
        campHisTitile,
        campHisSubTitile
    };

    @wire(getHistoryDetails, {recordId: '$recordId'})
    fetchData({error, data}){
        if(data){
            this.displayData = data;
            if(data.length > 0)
            {
                this.isDisplay = true;
            }
        }
        else if(error){
            console.log(error);
        }
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