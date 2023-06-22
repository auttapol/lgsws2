import { LightningElement ,api,wire } from 'lwc';
import getSetupFormat from '@salesforce/apex/SetUpFormat.getSetupFormat';
import ThirdPartyAccountLinkKey from '@salesforce/schema/ThirdPartyAccountLink.ThirdPartyAccountLinkKey';

export default class SetupFormat extends LightningElement {
    @api param1;    
    @api param2;
    @api param3;
    @api param4;
    @api param5;
    @api param6;
    jsonConditionFormat;

    @wire(getSetupFormat, {formatname : '$param1'})
    wireSetupFormat({error,data}){
        if(data){
            console.log('--------------- formatName -----------------');
            this.jsonConditionFormat = JSON.parse(data);
            console.log( this.jsonConditionFormat );
            
            if( this.param1 == 'segment_coloring'){
                this.segmentColoring();
            }


        }else if(error){
            console.log('--------------- Error ----------------------');
        }
    }



    displayFormat;
    displayData;

    connectedCallback(){        
    }

    // param1 is naming of coloring condition
    // param2 is Segment Code
    // param3 is Privilege
    // param4 is Customer Type
    // param5 is Customer Segment
    // param6 is Customer SubSegment

    segmentColoring(){
        console.log('----------------------- segment coloring -----------------');
        console.log( this.jsonConditionFormat );
        //segmentInput = this.param2;
        console.log( 'P1 : '+this.param1 + ' : , P2 : '+this.param2+', P3 : '+this.param3+', P4 : '+this.param4+', P5 : '+this.param5+', P6 : '+this.param6);


        for(var i in this.jsonConditionFormat.Condition){
            //console.log( this.jsonConditionFormat.Condition[i] );
            if( this.jsonConditionFormat.Condition[i].Segment_crm__c == this.param2 ){
                if( this.jsonConditionFormat.Condition[i].RTL_Privilege1__c.length > 0 ){
                    if( this.jsonConditionFormat.Condition[i].RTL_Privilege1__c.indexOf( this.param3) >= 0 ){
                        this.displayFormat = this.jsonConditionFormat.Condition[i].style;
                        break;
                    }
                    // else do notting
                }else{ // there are not check Privilege1
                    //console.log('----------------------- setup displayFormat -------------- '+this.jsonConditionFormat.Condition[i].Segment_crm__c + ' : '+this.jsonConditionFormat.Condition[i].style);
                    this.displayFormat = this.jsonConditionFormat.Condition[i].style;
                    break;
                }
            }
        }
        this.displayData =   (this.param4 != '' && this.param4 != undefined  ?this.param4:'-')+'/'+(this.param5 != '' && this.param5 != undefined ?this.param5:'-')+'('+(this.param6 != '' && this.param6 != undefined ?this.param6:'-')+')';  
    }



}