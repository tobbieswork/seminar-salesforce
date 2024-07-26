import { LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CurrentPageReference } from 'lightning/navigation';


export default class NavBTest extends NavigationMixin(LightningElement) {
    
    valueee;


    @wire(CurrentPageReference)
    currentPageReference;

    connectedCallback() {  
        console.log('connected');
        console.log(`id = ${this.currentPageReference.attributes.attributes.ids}`);
        this.valueee = this.currentPageReference.attributes.attributes.ids
    }



    navigateHome() {
        // let cmpDef = {
        //   componentDef: "c:homeNavigationTest"
        // };
        // window.history.back();
        // let encodedDef = btoa(JSON.stringify(cmpDef));

        this[NavigationMixin.Navigate]({
            type: "standard__navItemPage",
            attributes: {
                apiName: "navigation_test"
                // appTarget: "navigation_test"
                // url: "/one/one.app#" + encodedDef
            },
            state: {
                idsi: 'asdasdasd'
            }
        }); 


    }

    // connectedCallback() {

    //     //Get the MDMID from the URL
    //     this.recordId = new URLSearchParams(window.location.search).get('c__Id');
    //     console.log(this.recordId);
    // }
}