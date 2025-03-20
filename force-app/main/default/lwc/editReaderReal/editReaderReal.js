import { api, LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from 'lightning/navigation';
import LightningAlert from 'lightning/alert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initReaderInfo from '@salesforce/apex/EditReaderExtension.initReaderInfo';

export default class EditReaderReal extends NavigationMixin(LightningElement) {
    
    @api recordId;

    @track readerInfo = {
        Id: '',
        Name: '',
        ReaderName__c: '',
        Phone__c: '',
        Email__c: '',
        ReaderType__c: '',
        BorrowingQuantity__c: 0
    };
    @track readerType = [];
    @track bookBorrowList = [];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.c__recordId;
            console.log('readerReal: ' + this.recordId);
            this.getInit(this.recordId);
        }
    }

    getInit(recordId) {
        initReaderInfo({
            'recordId': recordId
        }).then(data => {
            if (data.status == 'error') {
                this.showToast('error','错误信息',data.errorInfo);
            } else {
                this.readerInfo = data.readInfo;
                this.readerType = data.readType;
                this.bookBorrowList = data.bookBoInfoList;
            }
        });
    }

    readerTypeChange(event) {
        this.readerInfo.ReaderType__c = event.detail.value;
    }

    AddNewRow() {
        let obj = new Object();
        obj.BookDetailNo = '';
        obj.BorrowDate = null;
        obj.DueReturnDate = null;
        obj.RenewStatus = false;
        this.bookBorrowList.push(obj);
    }

    removeRow(event) {
        let rowNo = event.currentTarget.dataset.index;//获得行号
        console.log('remove Row: ' + rowNo);
        this.bookBorrowList.splice(rowNo,1);
    }

    fieldChange(event) {
        let field = event.currentTarget.dataset.field;
        console.log(field);
        let value = event.target.value;
        console.log(value);
        switch(field) {
            case 'ReaderName__c':
                this.readerInfo.ReaderName__c = value;
                break;
            case 'Phone__c':
                this.readerInfo.Phone__c = value;
                break;
            case 'Email__c':
                this.readerInfo.Email__c = value;
                break;
            case 'BorrowingQuantity__c':
                this.readerInfo.BorrowingQuantity__c = value;
                break;
        }
    }

    itemFieldChange(event) {
        let field = event.currentTarget.dataset.field;
        console.log('field: ' + field);
        let row = event.currentTarget.dataset.index;
        console.log('row: ' + row);
        let value = event.detail.value;
        console.log('value: ' + value);
        switch(field) {
            case 'BookDetailNo':
                if (this.isEmpty(value) || value.length == 0) {
                    this.bookBorrowList[row].BookDetailNo = '';
                }else {
                    this.bookBorrowList[row].BookDetailNo = value[0];
                }
                break;
            case 'BorrowDate':
                this.bookBorrowList[row].BorrowDate = value;
                break;
            case 'DueReturnDate':
                this.bookBorrowList[row].DueReturnDate = value;
                break;
            case 'RenewStatus':
                this.bookBorrowList[row].RenewStatus = !this.bookBorrowList[row].RenewStatus;
                break; 
        }
        console.log(JSON.stringify(this.bookBorrowList));
    }

    saveClick() {
        console.log(JSON.stringify(this.readerInfo));
        if (this.isEmpty(this.readerInfo.Name)) {
            this.showToast('error','错误信息','读者编号不能为空');
            return;
        }
        if (this.isEmpty(this.readerInfo.ReaderName__c)) {
            this.showToast('error','错误信息','读者姓名不能为空');
            return;
        }
        if (this.isEmpty(this.readerInfo.Phone__c)) {
            this.showToast('error','错误信息','联系电话不能为空');
            return;
        }
        if (this.isEmpty(this.readerInfo.Email__c)) {
            this.showToast('error','错误信息','邮箱不能为空');
            return;
        }
        if (this.isEmpty(this.readerInfo.ReaderType__c)) {
            this.showToast('error','错误信息','读者类型不能为空');
            return;
        }
        if (this.isEmpty(this.readerInfo.BorrowingQuantity__c)) {
            this.showToast('error','错误信息','可借阅数量不能为空');
            return;
        }

        if (this.readerInfo.BorrowingQuantity__c  < 0) {
            this.showToast('error','错误信息','可借阅数量不能小于0');
            return;
        }
    }

    cancelClick() {
        //重定向
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ReaderInfo__c',
                actionName: 'view'
            },
        });
        //window.location.href = '/lightning/r/ReaderInfo__c/' + this.recordId + '/view';
    }

    /**
     * 提示消息弹框显示
     * @param {提示状态} theme 
     * @param {提示标题} label 
     * @param {提示内容} message 
     */
    showAlert(theme, label, message) {
        LightningAlert.open({theme, label, message});
    }

    /**
     * 消息提示
     * @param {提示状态：'info','success','warning','error'} variant 
     * @param {提示标题} title 
     * @param {提示内容} message 
     */
    showToast(variant, title, message) {
        const evt = new ShowToastEvent({variant, title, message});
        this.dispatchEvent(evt);
    }

    /**
     * 对象判空
     * @param {对象} obj 
     * @returns true/false
     */
    isEmpty(obj) {
        if (typeof obj === 'undefined' || obj == null || obj === '') {
            return true;
        } else {
            return false;
        }
    }
}