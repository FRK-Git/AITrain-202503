({
    search : function(component, event, helper) {
        // init(component,event);
        const action = event.getParam('arguments').serverAction;
        if (component.get('v.cleanSearchTerm') == null || component.get('v.cleanSearchTerm') == "") {
            component.set('v.searchResults', []);
            return;
        }
        helper.toggleSearchSpinner(component);

        action.setParams({
            "searchTerm" : component.get('v.cleanSearchTerm'),
            "selectedIds" :helper.getSelectedIds(component),
            "objType" : component.get("v.objType"),
            "anOptionalParam":component.get("v.anOptionalParam"),
            "placeStr": component.get("v.placeStr")
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                helper.toggleSearchSpinner(component);
                component.set('v.searchResults', response.getReturnValue());
            }
            else if (state === 'ERROR') {
                helper.toggleSearchSpinner(component);
                const errors = response.getError();
                let message = 'Unknown error'; 
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    const error = errors[0];
                    if (typeof error.message != 'undefined') {
                        console.log(error.message)
                        message = error.message;
                    } else if (typeof error.pageErrors != 'undefined' && Array.isArray(error.pageErrors) && error.pageErrors.length > 0) {
                        const pageError = error.pageErrors[0];
                        if (typeof pageError.message != 'undefined') {
                            message = pageError.message;
                        }
                    }
                }
                console.error('Error: '+ message);
                console.error(JSON.stringify(errors));
                const toastEvent = $A.get('e.force:showToast');
                if (typeof toastEvent !== 'undefined') {
                    toastEvent.setParams({
                        title : 'Server Error',
                        message : message,
                        type : 'error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
            }
        });

        action.setStorable();
        $A.enqueueAction(action);
    },

    onInput : function(component, event, helper) {

        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        const newSearchTerm = event.target.value;
        helper.updateSearchTerm(component, newSearchTerm);
    },

    onResultClick : function(component, event, helper) {
        const recordId = event.currentTarget.id;
        helper.selectResult(component, recordId);
        var event = component.getEvent('onSelection');

        if (event) {
            event.fire();
        }
    },

    onComboboxClick : function(component, event, helper) {
        const blurTimeout = component.get('v.blurTimeout');
        if (blurTimeout) {
            clearTimeout(blurTimeout);
        }
        component.set('v.hasFocus', false);
    },

    //聚焦后值不为空,调用search
    onFocus : function(component, event, helper) {

        if (!helper.isSelectionAllowed(component)) {
            return;
        }
        component.set('v.hasFocus', true);
    },

    onBlur : function(component, event, helper) {
        if (!helper.isSelectionAllowed(component)) {
            return;
        }

        const blurTimeout = window.setTimeout(
            $A.getCallback(function() {
                component.set('v.hasFocus', false);
                component.set('v.blurTimeout', null);
            }),
            300
        );
        component.set('v.blurTimeout', blurTimeout);
    },

    onRemoveSelectedItem : function(component, event, helper) {
        const itemId = event.getSource().get('v.name');
        helper.removeSelectedItem(component, itemId);
    },

    onClearSelection : function(component, event, helper) {
        helper.clearSelection(component);
    },
    init : function(component, event, helper){
        console.log("触发事件InitializationUserEvent");
    }
})