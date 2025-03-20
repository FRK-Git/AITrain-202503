({
    myAction : function(component, event, helper) {
    
    },

    init: function(component, event, helper) {

        component.set('v.readerColumns',[
            {label: '读者编号', fieldName: 'Name', type: 'text'},
            {label: '读者姓名', fieldName: 'ReaderName__c', type: 'text'},
            {label: '读者类型', fieldName: 'ReaderType__c', type: 'text'},
            {label: '联系电话', fieldName: 'Phone__c', type: 'phone'},
            {label: '邮箱', fieldName: 'Email__c', type: 'email'},
            {label: '可借阅数量', fieldName: 'BorrowingQuantity__c', type: 'number'},
            {label: '缴费金额', fieldName: 'PaymentAmount__c', type: 'currency'},
            {label: '操作', type: 'button', typeAttributes: {label: '一键还书', name: 'returnBookOneKey'}}
        ]);

        helper.getReaderInfo(component);
    },

    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log('点击那一行的Id:'+ row.Id);
        switch (action.name) {
            case 'returnBookOneKey':
                helper.updateBorrowInfoByReaderId(component,row.Id);
                break;
        }
    },

    // handlerSelectList : function(component, event, helper) {
    //     var selectedRows = event.getParam('selectedRows');
        
    // }
})