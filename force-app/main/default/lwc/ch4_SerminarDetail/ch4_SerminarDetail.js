import { LightningElement, api, track } from "lwc";
import getRecordDataFromId from '@salesforce/apex/CH4_SerminarController.getRecordDataFromId';


export default class Ch4_SerminarDetail extends LightningElement {
    
    @api serminarId;
    @api isBookingShown;
    @track serminarInfo;
    @track shownSections;
    @track sections;
    errors;
    isShow = false;
    isExpandable = false;

    get isSerminarDetailShown(){
        return !this.isBookingShown;
    } 

    connectedCallback(){
        getRecordDataFromId({recordId: this.serminarId})
            .then((result) => {
                console.log(result);
                this.serminarInfo = result;
                if(result.Section__r){
                    this.sections = result.Section__r;
                    this.shownSections = this.getShownSection(result.Section__r);
                    this.isExpandable = this.sections.length > this.shownSections.length;
                }
                this.errors = undefined;
            })
            .catch((error) => {
                console.log('error');
                this.serminarInfo = undefined;
                this.errors = error;
            })
    }

    getShownSection(data){
        return data.filter((sec) => {
            return sec.Status__c === 'Shown';
        })
    }

    handleSectionToggle(event){
        console.log(event.detail.openSections);
    }

    handleToggleExpandation(event){
        this.shownSections = this.isShow ? 
            this.getShownSection(this.sections) : this.sections;
        this.isShow = !this.isShow;
    }

    handleReturnHomepage(event) {
        this.dispatchEvent(new CustomEvent('back'));
    }

    handleRegister (event) {
        this.isBookingShown = true;
    }

}