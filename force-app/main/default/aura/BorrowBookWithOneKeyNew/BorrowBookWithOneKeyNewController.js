({
    myAction : function(component, event, helper) {
    
    },

    addDetailBookId : function(component, event, helper) {
        helper.showWantToBorrowByAddBook(component);
    },

    updateIsSelected : function(component, event, helper) {
        helper.showClearIsSelectedBookByChange(component);
    },

    borrowBookWithOneKeyNew : function(component, event, helper) {
        helper.borrowBookWithOnekeyNewOperation(component);
    },
})