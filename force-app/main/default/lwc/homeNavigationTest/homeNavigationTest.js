import { LightningElement } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class NavigateFromLWC extends NavigationMixin(LightningElement) {
    navigateWithoutAura(event) {
        let cmpDef = {
            componentDef: "c:navBTest",
            attributes: {
                ids: event.target.dataset.ids
            }
    
        };

        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef
            }
        });
    }
}