import { api, LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class EditReader extends NavigationMixin(LightningElement) {

    @api recordId;

    @api invoke() {
        let cmpDef = {
            componentDef: "c:editReaderReal",
            state: {
                c__recordId: this.recordId,
            }
        };

        let encodedDef = btoa(JSON.stringify(cmpDef));
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/one/one.app#" + encodedDef,
            },

        });
        console.log(this.recordId);
    }
}