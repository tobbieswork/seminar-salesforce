import { LightningElement, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from 'lightning/navigation';
import getRecordDataFromId from '@salesforce/apex/CH4_SerminarController.getRecordDataFromId';


export default class Ch4_SerminarDetail extends NavigationMixin(LightningElement) {
    
    @track serminarInfo;
    @track shownSections = [];
    @track sections = [];
    serminarId;
    errors;
    isShow = false;
    isExpandable;

    
    @wire(CurrentPageReference)
    getPageReference(currentPageRef){
        if(currentPageRef){
            this.serminarId = currentPageRef.attributes.attributes.recordId;
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
    }

    getShownSection(data){
        return data.filter((sec) => {
            return sec.Status__c === 'Shown';
        })
    }

    handleToggleExpandation(event){
        this.shownSections = this.isShow ? 
            this.getShownSection(this.sections) : this.sections;
        this.isShow = !this.isShow;
    }

    handleReturnHomepage(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "Booking_Serminar"
            }
        }); 
    }

}