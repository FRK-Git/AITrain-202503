import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getRecordInfo from '@salesforce/apex/Test1lwcExtension.getRecordInfo';

export default class Test1lwc extends NavigationMixin(LightningElement) {

    @api recordId;

    @wire(getRecordInfo,{recordId:'$recordId'})
    wireRecord({ error, data }) {
        // console.log('data.product: ' + JSON.stringify(data.productInfo));
        if (data) {
            console.log('data.product: ' + JSON.stringify(data));
        } else if (error) {
            
        }
    }
}