({
    helperMethod : function() {
    
    },

    showWantToBorrowByAddBook : function(component) {
        var bookDetailId = component.get('v.bookDeatilId');
        var action = component.get('c.updateIsSelectByIdAndReturn');
        action.setParams({
            'bookDetailId' : bookDetailId
        });
        action.setCallback(this,function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
                var returnValue = res.getReturnValue();
                if (returnValue != null) {
                    component.set('v.bookDetailColumns', [
                        {label: '图书详情编号', fieldName: 'Name', type: 'text'},
                        {label: '图书编号', fieldName: 'BookNo__c', type: 'text'},
                        {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
                        {label: '作者', fieldName: 'Author__c', type: 'text'},
                        {label: '价格', fieldName: 'Price__c', type: 'currency'},
                        {label: '图书状态', fieldName: 'BookStatus__c', type: 'text'},
                    ]);
                    component.set('v.bookDetailData', returnValue);
                } else {
                    
                }
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
                var showE = $A.get('e.force:showToast');
                    showE.setParams({
                        'title': '读者您好',
                        'message': '图书详细信息id号有误',
                        'type' : 'error',
                        'duration' : 2000
                    });
                showE.fire();
            }
        });

        $A.enqueueAction(action);
    },

    showClearIsSelectedBookByChange : function(component) {
        var action = component.get('c.clearAllDetailBookHasStatusAndIsSelect');
        action.setCallback(this, function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
                component.set('v.bookDetailColumns', [
                        {label: '图书详情编号', fieldName: 'Name', type: 'text'},
                        {label: '图书编号', fieldName: 'BookNo__c', type: 'text'},
                        {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
                        {label: '作者', fieldName: 'Author__c', type: 'text'},
                        {label: '价格', fieldName: 'Price__c', type: 'currency'},
                        {label: '图书状态', fieldName: 'BookStatus__c', type: 'text'},
                ]);
                component.set('v.bookDetailData', res.getReturnValue());
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });

         $A.enqueueAction(action);
    },

    borrowBookWithOnekeyNewOperation : function(component) {
        console.log('enen');
        var readerId = component.find('readerId').get('v.value');
        console.log('readerId'+ readerId);
        var action  = component.get('c.borrowBookByOnekeyNewOperation');
        action.setParams({
            'readerId' : readerId
        });
        action.setCallback(this, function(res) {
            console.log('返回值'+ res);
            var status = res.getState();
            if (status === 'SUCCESS') {
                component.set('v.bookDetailColumns', [
                        {label: '图书详情编号', fieldName: 'Name', type: 'text'},
                        {label: '图书编号', fieldName: 'BookNo__c', type: 'text'},
                        {label: '图书名称', fieldName: 'BookName__c', type: 'text'},
                        {label: '作者', fieldName: 'Author__c', type: 'text'},
                        {label: '价格', fieldName: 'Price__c', type: 'currency'},
                        {label: '图书状态', fieldName: 'BookStatus__c', type: 'text'},
                ]);
                component.set('v.bookDetailData', res.getReturnValue());
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
                var showE = $A.get('e.force:showToast');
                    showE.setParams({
                        'title': '读者您好',
                        'message': '图书借阅失败，原因是插入借阅信息有误',
                        'type' : 'error',
                        'duration' : 2000
                    });
                showE.fire();
            }
        });

        $A.enqueueAction(action);
    },
})