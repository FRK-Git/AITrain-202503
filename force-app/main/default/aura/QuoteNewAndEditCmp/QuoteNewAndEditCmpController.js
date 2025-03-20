({
    init : function(component, event, helper) {
        let type = component.get("v.pageReference.state.c__type");
        if (type == 'new') {

        }else {
            let recordId = component.get("v.pageReference.state.c__recordId");
            console.log('QuoteNewAndEditCmp recordId: ' + recordId);
            component.set('v.recordId', recordId);
        }
        component.set('v.type', type);
    }
})