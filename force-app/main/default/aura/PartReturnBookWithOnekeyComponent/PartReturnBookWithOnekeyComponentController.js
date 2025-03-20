({
    myAction : function(component, event, helper) {
    
    },

    init : function(component, event, helper) {
        component.set('v.borrowInfoColumns',[
            {label: '借阅信息编号', fieldName: 'Name', type: 'text'},
            {label: '图书详细编号', fieldName: 'BookDetailNo__c', type: 'text'},
            {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
            {label: '读者姓名', fieldName: 'ReaderName__c', type: 'text'},
            {label: '借阅日期', fieldName: 'BorrowDate__c', type: 'date'},
            {label: '应还日期', fieldName: 'DueReturnDate__c', type: 'date'},
            {label: '已还日期', fieldName: 'ReturnedDate__c', type: 'date'},
        ]);

        helper.showAllUnReturnInfo(component);
    },

    queryBorrowInfoByReaderName : function(component, event, helper) {
        component.set('v.borrowInfoColumns',[
            {label: '借阅信息编号', fieldName: 'Name', type: 'text'},
            {label: '图书详细编号', fieldName: 'BookDetailNo__c', type: 'text'},
            {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
            {label: '读者姓名', fieldName: 'ReaderName__c', type: 'text'},
            {label: '借阅日期', fieldName: 'BorrowDate__c', type: 'date'},
            {label: '应还日期', fieldName: 'DueReturnDate__c', type: 'date'},
            {label: '已还日期', fieldName: 'ReturnedDate__c', type: 'date'},
        ]);
        var readerName = component.get('v.readerName');
        console.log('readerName' + readerName);
        helper.showQueryBorrowInfoByReaderName(component,readerName);
    },

    handlerBorrowInfoRowData : function(component,event) {
        var selectedRows = event.getParam('selectedRows');
        var selectList = new Array();
        for(var i = 0; i<selectedRows.length; i++){
            selectList.push(selectedRows[i].Id);
        }
        component.set('v.selectBorrowInfoRowId', selectList);
        
    },

    partReturnBookOnclick : function(component, event, helper) {
        var selectList = component.get('v.selectBorrowInfoRowId');
        console.log(selectList);
        helper.returnBookOperation(component,selectList);
    },

})