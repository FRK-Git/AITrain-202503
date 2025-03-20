({
    helperMethod : function() {
    
    },

    getReaderInfo : function(component) {
        var action = component.get('c.getReaderInfoByUnReturn');
        action.setCallback(this, $A.getCallback(function (response) {
            var status = response.getState();
            if (status === 'SUCCESS') {
                component.set('v.readerData', response.getReturnValue());
            } else if (status === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }

        }));
        $A.enqueueAction(action);
    },

    updateBorrowInfoByReaderId : function(component,id) {
        var action = component.get('c.setReturnDateInBorrowInfoByReaderId');
        console.log('测试'+id);
        action.setParams({
            'id': id
        });
        action.setCallback(this, $A.getCallback(function (res) {
            console.log('return++++'+JSON.stringify(res));
            var status = res.getState();
            if (status === 'SUCCESS') {
                if (res.getReturnValue()) {
                    location.reload();
                }
            } else if (status === 'ERROR') {
                var errors = res.getError();
                console.error(errors);
            }
        }));

         $A.enqueueAction(action);
    }
})