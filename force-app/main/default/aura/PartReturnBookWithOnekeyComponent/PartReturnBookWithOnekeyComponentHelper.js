({
    helperMethod : function() {
    
    },

    showAllUnReturnInfo : function(component) {
        var action = component.get('c.getAllUnReturnBorrowInfo');
        action.setCallback(this,function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
                component.set('v.borrowInfoData', res.getReturnValue());
            }else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });

        $A.enqueueAction(action);
    },

    showQueryBorrowInfoByReaderName : function(component, readerName) {
        console.log('readerName++'+ readerName);
        var action = component.get('c.getBorrowInfoByReaderName');
        action.setParams({
            'readerName': readerName
        });
        action.setCallback(this, function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
                component.set('v.borrowInfoData', res.getReturnValue());
            }else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });

        $A.enqueueAction(action);
    },

    returnBookOperation : function(component,selectList) {
        var action = component.get('c.setReturndateById');
        action.setParams({
            'selectList' : selectList
        });

        action.setCallback(this, function(res) {
            var status = res.getState();
            if (status === 'SUCCESS') {
               if (res.getReturnValue()) {
                    location.reload();
               }
            }else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        });

         $A.enqueueAction(action);
    },

})