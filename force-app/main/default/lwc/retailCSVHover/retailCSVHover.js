import { LightningElement, api ,track } from 'lwc';

export default class RetailCSVHover extends LightningElement {
    @track HoverID;
    @track top = 50; //position in page
    @track left = 50;


    @api
    get myId(){
        return this.HoverID;
    }
    set myId(value) {
        this.HoverID = value;
    }

    @api
    get topmargin(){
        return this.top;
    }
    set topmargin(value) {
        this.top = value;
    }

    @api
    get leftmargin(){
        return this.left;
    }
    set leftmargin(value) {
        this.left = value;
    }

    // get topHere() {
    //      return document.
    // }

    // get leftHere() {

    // }
    get boxClass() { 
        let styleText;
        styleText = `position:absolute; background-color:white; top: ${this.top}px; left: ${this.left}px; z-index: 99 !important;`;
        // console.log(styleText);
        // window.screen.height
        return styleText;
    }
}