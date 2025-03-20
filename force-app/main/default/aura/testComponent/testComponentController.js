({
    doInit : function(component, event, helper) {
        

    },

    getSelectOnchange: function(component, event, helper) {

    }

    // showInfo : function(component, event, helper) {
    //     var show = component.get('v.test');
    //     var data = component.get('c.printInfo');
    //     data.setParams({
    //         "name": show
    //     });
    //     data.setCallback(this,function(res) {
    //         if (res.getState() == 'SUCCESS') {
    //             var ret = res.getReturnValue();
    //             var showE = $A.get('e.force:showToast');
    //             showE.setParams({
    //                 'title': 'Welcome',
    //                 'mode': 'sticky',
    //                 'message': ret,
    //                 'type' : 'success',
    //                 'duration' : 2000
    //             });
    //             showE.fire();
    //         }
    //     });

    //     $A.enqueueAction(data);
    // },

    // showQueryGoodsInfoByNo : function(component, event, helper) {
    //     var goodsNo = component.get('v.goodsNo');
       
    //     var queryDataByNo = component.get('c.queryGoodsInfoByNo');
    //     queryDataByNo.setParams({
    //         "goodsNo" : goodsNo
    //     });

    //     queryDataByNo.setCallback(this,function(res) {
    //         if (res.getState() == 'SUCCESS') {
    //             var ret = res.getReturnValue();
    //             var showName = $A.get('e.force:showToast');
    //             if(ret.status ) {
    //                 showName.setParams({
    //                     "title" : 'SUCCESS',
    //                     'mode' : 'sticky',
    //                     'message' : ret.goodsName,
    //                     'type' : 'success',
    //                     'duration' : 2000
    //                 });
    //             } else {
    //                  showName.setParams({
    //                     "title" : 'ERROR',
    //                     'mode' : 'sticky',
    //                     'message' : ret.goodsName,
    //                     'type' : 'error',
    //                     'duration' : 2000
    //                 });
    //             }
    //             showName.fire();
    //         }
    //     });

    //     $A.enqueueAction(queryDataByNo);
    // }
})