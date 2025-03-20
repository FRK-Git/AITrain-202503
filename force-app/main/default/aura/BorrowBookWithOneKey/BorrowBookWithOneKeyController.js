({
    myAction : function(component, event, helper) {
    
    },

    init : function(component, event, helper) {
        component.set('v.bookDetailColumns', [
            {label: '图书详情编号', fieldName: 'Name', type: 'text'},
            {label: '图书编号', fieldName: 'BookNo__c', type: 'text'},
            {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
            {label: '作者', fieldName: 'Author__c', type: 'text'},
            {label: '价格', fieldName: 'Price__c', type: 'currency'},
            {label: '图书状态', fieldName: 'BookStatus__c', type: 'text'},

        ]);
        helper.showEnableBorrowInfo(component);
    },

    getSelectedBookDetail : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        var selectList = new Array();
        for(var i = 0; i<selectedRows.length; i++){
            selectList.push(selectedRows[i].Id);
        }
        component.set('v.selectBookDetailRowId', selectList);
    },

    borrowBookWithOneKey : function(component, event, helper) {
        helper.showEnableBorrowBookByOneKey(component);
    }

})