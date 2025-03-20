public with sharing class TestComponentController {
    public TestComponentController() {
        
    }

    @AuraEnabled
    public static String printInfo(String name) {
        return 'My name is '+name;
    }

    @AuraEnabled
    public static Map<String,Object> queryGoodsInfoByNo(Integer goodsNo) {
        Map<String,Object> retData = new Map<String,Object>();
        List<Goods__c> goodses = [SELECT Name,Id 
                                  FROM Goods__c 
                                  WHERE ProductNo__c= :goodsNo];

        if (goodses != null && goodses.size() > 0 ) {
            retData.put('status',true);
            retData.put('goodsName',goodses[0].Name);
            retData.put('goodsId',goodses[0].Id);
            return retData;
        } else {
            retData.put('status',false);
            retData.put('goodsName','不存在');
            return retData;
        }
    }
}