({
    myAction : function(component, event, helper) {
    
    },



    showQueryGoodsByName : function(component, event, helper) {
        var goodsName = component.get('v.goods_Name');
        var queryGoodsByName = component.get('c.queryGoodsByName');
        queryGoodsByName.setParams({
            'name': goodsName
        });

        queryGoodsByName.setCallback(this,function(res) {
            if (res.getState() == 'SUCCESS') {
                var ret = res.getReturnValue();
                console.log(ret.goodsId);
                component.set('v.goods_Id', ret.goodsId);
            }
        });

        $A.enqueueAction(queryGoodsByName);
    },

    init : function(component, event, helper) {
        component.set('v.myGoodsColumns', [
                {label: '产品名称',fieldName: 'Name',type: 'text'},
                {label: '产品大类',fieldName: 'ProductUpperCategory__c',type: 'text'},
                {label: '产品小类',fieldName: 'ProductLowerCategory__c',type: 'text'},
                {label: '产品编码',fieldName: 'ProductCode__c',type: 'text'},
                {label: '基本价格',fieldName: 'BasePrice__c',type: 'text'},
                {label: '当前库存',fieldName: 'CurrentStock__c',type: 'text'},
                {label: '最大库存',fieldName: 'MaxStock__c',type: 'text'},
                {label: '最小库存',fieldName: 'MinStock__c',type: 'text'}
            ]);
        helper.getGoodsData(component);
    }

})