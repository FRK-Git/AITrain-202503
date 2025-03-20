({
    updateSearchTerm : function(component, searchTerm) {
        component.set('v.searchTerm', searchTerm);
        
        const cleanSearchTerm = component.set('v.cleanSearchTerm');
        const newCleanSearchTerm = searchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        component.set('v.cleanSearchTerm', newCleanSearchTerm);

        // if (newCleanSearchTerm.length < 2) {
        //     component.set('v.searchResults', []);
        //     return;
        // }

        let searchTimeout = component.get('v.searchThrottlingTimeout');
        if (searchTimeout) {
            clearTimeout(searchTimeout);
        }
        searchTimeout = window.setTimeout(
            $A.getCallback(function() {
                // Send search event if it long enougth
                const searchTerm = component.get('v.searchTerm');
                // if (searchTerm.length >= 2) {
                    const searchEvent = component.getEvent('onSearch');
                    searchEvent.fire();
                // }
                component.set('v.searchThrottlingTimeout', null);
            }),
            300
        );
        component.set('v.searchThrottlingTimeout', searchTimeout);
    },

    selectResult : function(component, recordId) {
        const searchResults = component.get('v.searchResults');
        const selectedResult = searchResults.filter(function(result) { return result.id === recordId; });
        if (selectedResult.length > 0) {
            const selection = component.get('v.selection');
            const selectValues = $A.util.isUndefinedOrNull(selection) ? [] : JSON.parse(JSON.stringify(selection));
            selectValues.push(selectedResult[0]);
            component.set('v.selection', selectValues);
        }
        component.set('v.searchTerm', '');
        component.set('v.searchResults', []);
    },

    getSelectedIds : function(component) {
        const selection = component.get('v.selection');
        if($A.util.isUndefinedOrNull(selection)){return [];}
        return selection.map(function(element) { return element.id; });
    },

    removeSelectedItem : function(component, removedItemId) {
        const selection = component.get('v.selection');
        const isNotEdit = component.get('v.isEdit');
        const updatedSelection = isNotEdit ? selection : selection.filter(function(item) { return item.id !== removedItemId; });
        component.set('v.selection', updatedSelection);
        var event = component.getEvent('onRemove');
        if (event) {
            event.fire();
        }
    },

    clearSelection : function(component, itemId) {
        component.set('v.selection', []);
        var event = component.getEvent('onSelection');
        if (event) {
            event.fire();
        }
    },

    isSelectionAllowed : function(component) {
        return component.get('v.isMultiEntry') || component.get('v.selection').length === 0;
    },

    toggleSearchSpinner : function(component) {
        const spinner = component.find('spinner');
        const searchIcon = component.find('search-icon');

        $A.util.toggleClass(spinner, 'slds-hide');
        $A.util.toggleClass(searchIcon, 'slds-hide');
    }
})