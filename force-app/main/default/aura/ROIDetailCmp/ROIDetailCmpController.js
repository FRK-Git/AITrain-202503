({
    saveROI: function(component, event, helper) {

    },

    cancelROI: function(component, event, helper) {

    },

    selectAcc: function(component, event, helper) {
        var val = component.find('select2').get('v.value');
        if (val == '全部') {
            component.set('v.isShowAcc', false);
        }else if (val == '部分') {
            component.set('v.isShowAcc', true);
        }
    },

    selectMethod: function(component, event, helper) {
        var val = component.find('select3').get('v.value');
        if (val == '全系列') {
            component.set('v.isShowMethod', false);
        }else if (val == '部分产品') {
            component.set('v.isShowMethod', true);
        }
    },

    selectMethodDetail: function(component, event, helper) {
        var val = component.find('select4').get('v.value');
        if (val == '百分比') {
            component.set('v.isShowMethidDetail', true);
        }else if (val == '金额') {
            component.set('v.isShowMethidDetail', false);
        }
    },

    //查找
    lookupSearch : function(component, event, helper) {
        //获取引发搜索事件的查找组件
        const lookupComponent = event.getSource();
        // 获取SampleLookupController.search服务器端操作
        const serverSearchAction = component.get('c.search');
        //可以将可选参数传递给搜索操作
        //只能使用setParam，而不能使用setParams
        serverSearchAction.setParam('anOptionalParam', 'not used');
        // 通过调用搜索方法将操作传递给查找组件
        lookupComponent.search(serverSearchAction);
    },

    lookupOnChange : function(component, event, helper) {
        console.log('1');
        var selection = event.getSource().get("v.selection");
        var objType = event.getSource().get("v.objType");
        console.log("selection::"+JSON.stringify(selection));

        var selectProdList = component.get('v.selectProdList');
        console.log('selectProdList:: ' + JSON.stringify(selectProdList));
        var prodDetailList = component.get('v.prodDetailList');
        prodDetailList.splice(0,prodDetailList.length);
        for(var i = 0; i < selectProdList.length; i++) {
            var planObj = new Object();
            planObj.id = selectProdList[i].id;
            planObj.prodMethod = '采购目标金额，返利百分比';
            planObj.name = selectProdList[i].title;
            prodDetailList.push(planObj);
        }
        console.log('prodDetailList: ' + JSON.stringify(prodDetailList));
        component.set('v.prodDetailList', prodDetailList);
        component.set('v.prodDetailListLength', prodDetailList.length);
    },

    lookupOnRemove: function(component, event, helper) {
        console.log('2');
        var selection = event.getSource().get("v.selection");
        console.log("selection::"+JSON.stringify(selection));
        var selectProdList = component.get('v.selectProdList');
        console.log('selectProdList:: ' + JSON.stringify(selectProdList));

        var prodDetailList = component.get('v.prodDetailList');
        prodDetailList.splice(0,prodDetailList.length);
        for(var i = 0; i < selectProdList.length; i++) {
            var planObj = new Object();
            planObj.id = selectProdList[i].id;
            planObj.prodMethod = '采购目标金额，返利百分比';
            planObj.name = selectProdList[i].title;
            prodDetailList.push(planObj);
        }
        console.log('prodDetailList: ' + JSON.stringify(prodDetailList));
        component.set('v.prodDetailList', prodDetailList);
        component.set('v.prodDetailListLength', prodDetailList.length);
    }
})