({
    helperMethod : function() {
    
    },

    showEnableBorrowInfo : function(component) {
        var action = component.get('c.getAllEnableBorrowBook');
        action.setCallback(this, function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
                var returnValue = res.getReturnValue();
                component.set('v.bookDetailData',returnValue);
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    },

    showEnableBorrowBookByOneKey : function(component) {
        var readerNo = component.find('readerId').get('v.value');
        console.log('readerNo=>'+readerNo);
        var bookDetailList = component.get('v.selectBookDetailRowId');
        console.log('bookDatailList' + bookDetailList);
        var action = component.get('c.getBookDetailInfoByAfterBorrow');
        action.setParams({
            'readerNo' : readerNo,
            'bookDetailList' : bookDetailList
        });
        action.setCallback(this,function(res) {
            var status = res.getState();
             if (status === 'SUCCESS') {
                if (res.getReturnValue() != null) {
                    var returnValue = res.getReturnValue();
                    component.set('v.bookDetailData',returnValue);
                }
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
    }

})