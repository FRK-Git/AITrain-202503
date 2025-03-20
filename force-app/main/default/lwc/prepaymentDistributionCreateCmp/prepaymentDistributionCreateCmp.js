import { LightningElement, track, wire, api } from 'lwc';
// import { label } from 'c/labelUtility';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import initMet from '@salesforce/apex/PrepaymentDistributionController.initDistribution';
import search from '@salesforce/apex/PrepaymentDistributionController.search';
import savePD from '@salesforce/apex/PrepaymentDistributionController.saveDistribution';
import getOrder from '@salesforce/apex/PrepaymentDistributionController.getOrderInfo';

export default class prepaymentDistributionCreateCmp extends NavigationMixin(LightningElement) {

	// @api recordId

	_recordId;

	@api set recordId(value) {
        this._recordId = value;
        console.log(value);
        // do your thing right here with this.recordId / value
        this.initJS();
    }

    get recordId() {
        return this._recordId;
    }

	// @track customlabel = label;
    @track distributionField;

    @wire(getObjectInfo, {
        objectApiName: 'Prepayment_Distribution__c'
    })
    distributionInfo({ data, error }) {
        console.log('aaaaaaaa');
        console.log(data);
        console.log('cccccccc');
        this.distributionField = data;
    }

    /**
     * 控制展示spinner
     */
    @track isShow = false;

    @track distributionObj = {}

    @track orderAmount;

    @track orderNumber;

    @track orderStatus;

    orderSelection = []
    errors = []

    @track anOptionalparam;

    sObjName;

    connectedCallback() {
    	// this.initJS();
    }

    initJS() {
    	console.log('recordId:::'+this.recordId) 
    	this.isShow = true;
    	initMet({ recordId: this.recordId})
    	.then((result) => {
            this.isShow = false;
            let data = result;
            console.log(11111111);
            console.log(data);
            console.log(22222222);
            if (result.message != null) {
                this.showToast('tips', data.message, 'warning');
                this.handleCancel();
            }else{
                this.sObjName = data.sObjName;
            	this.distributionObj = data.preObj;
            	this.anOptionalparam = data.preObj.Account__c;
                if (data.preObj.Order_Amount__c) {
                    this.orderAmount = data.preObj.Order_Amount__c;
                }
                if (data.preObj.Order_ERP_Number__c) {
                    this.orderNumber = data.preObj.Order_ERP_Number__c;
                }
                if (data.preObj.Order_Status__c) {
                    this.orderStatus = data.preObj.Order_Status__c;
                }
                if (data.preObj.Order__c) {
                    this.orderSelection = [{
                        "id":data.preObj.Order__c,
                        "objType":'Order',
                        "title":data.preObj.Order__r.OrderNumber,
                        "subtitle":data.preObj.Order__r.Order_ERP_Number__c,
                        "icon":"standard:record"
                    }];
                }

                this.getOrder(data.preObj.Order__c);
            }
        })
        .catch((error) => {
            this.isShow = false;
            console.log("execute error");
            console.log(error);
        });
    }

    handleCancel() {
        if (this.sObjName === 'Prepayment__c') {
            this.dispatchEvent(new CloseActionScreenEvent());
        }else{
            window.history.back();
        }
    	
    }

    save() {

        this.isShow = true;
        let validMsg = '';
        //标准input field check字段必填验证
        const allValid = [...this.template.querySelectorAll('lightning-input-field')]
        .reduce((validSoFar, inputCmp) => {
            // console.log(inputCmp);
            inputCmp.reportValidity();
            return validSoFar && inputCmp.reportValidity();
        }, true);
        //custom lookup 组件 check字段必填验证
        const allLookupValid = [...this.template.querySelectorAll('c-lookuplwc')]
        .reduce((validSoFar, inputCmp) => {
            // console.log(inputCmp);
            inputCmp.checkRequiredErrorValue(false);
            return validSoFar && inputCmp.checkRequiredErrorValue();
        }, true);

        if (!allValid || !allLookupValid) {
            this.showToast('Tips','Please fill required and update all invalid form entries','error');
            this.isShow = false;
        }else{
            savePD({ pdStr: JSON.stringify(this.distributionObj)})
            .then((result) => {
                this.isShow = false;
                if(result.message){
                    this.showToast('error', result.message, 'error');
                }else{
                    this.showToast('success', 'success', 'success');
                    setTimeout(()=>{
                        window.location.reload();
                    },200);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            actionName: 'view'
                        }
                    });
                }
            }).catch(error => {
                // console.log("出错::::"+error.errorCode+','+error.body.message);
                console.log(JSON.stringify(error))
            });
        }

    }

    showToast(title,message,variant,mode) {
        if(!mode){
            mode = 'dismissable';
        }
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }


    handleSectionToggle(event) {

    }


    /**
     * 处理查找搜索事件。
     * Calls the server to perform the search and returns the resuls to the lookup.
     * @param {event} event `search` event emmitted by the lookup
     */
    handleLookupSearch(event) {
        const lookupElement = event.target;
        event.detail['anOptionalParam'] = this.anOptionalparam;
        console.log("search::"+JSON.stringify(event.detail));
        // Call Apex endpoint to search for records and pass results to the lookup
        search(event.detail)
        .then((results) => {
            lookupElement.setSearchResults(results);
        })
        .catch((error) => {
            console.error('Lookup error', JSON.stringify(error));
            this.showToast('Query Error', JSON.stringify(error), 'error');
        });
    }

    handleLookupSelectionChange(event) {

    	const theLookup = event.detail;
        console.log("选中::"+JSON.stringify(theLookup));

        if (theLookup.selection.length > 0) {
        	let item = theLookup.selection[0];
        	this.distributionObj.Order__c = item.id;
        	this.orderAmount = item.sobj.TotalAmount;
            this.orderNumber = item.sobj.ExternalID__c;
            this.orderStatus = item.sobj.Status;
            this.getOrder(item.id);
        }else{
        	if (theLookup.objType == 'Order') {
        		this.distributionObj.Order__c = null;
        		this.orderAmount = null;
                this.orderStatus = null;
        	}
        }
    }


    /**
     * 字段变更事件
     */
    handleMasterFieldChange(event) {
        this.distributionObj = this.handleFieldChange(event,this.distributionObj);
    }

    /**
     * 为JS字段赋值
     */
    handleFieldChange(event,obj) {
        // Object.preventExtensions(obj);
        let newObj = {};
        if (event.target.tagName == 'LIGHTNING-INPUT-FIELD') {
            // var param = event.target.fieldName;
            var fieldsOjb = {};
            fieldsOjb[event.target.fieldName] = event.target.value;
            newObj = Object.assign({}, obj,fieldsOjb);
            // obj[event.target.fieldName] = event.target.value;
        } else if (event.target.tagName == 'LIGHTNING-INPUT') {
            var fieldsOjb = {};
            fieldsOjb[event.target.dataset.fieldName] = event.target.value;
            newObj = Object.assign({}, obj,fieldsOjb);
            // obj[event.target.dataset.fieldName] = event.target.value;
        }
        // console.log(JSON.stringify(newObj));
        return newObj;
    }

    getOrder(orderId) {

        getOrder({ orderId: orderId, recordId: this.distributionObj.Id})
        .then((result) => {
            this.isShow = false;
            if(result.message){
                this.showToast('error', result.message, 'error');
            }else{
                let results = result.resultList;
                if (results.length > 0) {
                    this.distributionObj.Order_Balanced_Amount__c = this.orderAmount - results[0].orderDistributedAmount;
                    this.distributionObj.Order_Distributed_Amount__c = results[0].orderDistributedAmount;
                }else{
                    this.distributionObj.Order_Balanced_Amount__c = this.orderAmount;
                    this.distributionObj.Order_Distributed_Amount__c = 0;
                }
            }
        }).catch(error => {
            // console.log("出错::::"+error.errorCode+','+error.body.message);
            console.log(JSON.stringify(error))
        });
    }
}