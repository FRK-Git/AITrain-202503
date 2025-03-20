({
    helperMethod : function() {
        
    },

    getGoodsData : function(component) {
        var action = component.get('c.getAllGoods');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.myGoodsData', response.getReturnValue());
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.error(errors);
            }
        }));

        $A.enqueueAction(action);
    }
})