public with sharing class TestLightningComponentController {
    public TestLightningComponentController() {
        
    }

    @AuraEnabled
    public static List<Goods__c> getAllGoods() {
        List<Goods__c> goodses = [SELECT Name,
                                         Id,
                                         ProductUpperCategory__c,
                                         ProductLowerCategory__c,
                                         ProductCode__c,
                                         BasePrice__c,
                                         CurrentStock__c,
                                         MaxStock__c,
                                         MinStock__c 
                                   FROM Goods__c];
        return goodses;
    }


    @AuraEnabled
    public static Map<String,Object> queryGoodsByName(String name) {
        Map<String,Object> retData = new Map<String,Object>();
        List<Goods__c> goodses = [SELECT Name,Id 
                                  FROM Goods__c 
                                  WHERE Name = :name];
        if (goodses != null && goodses.size() > 0) {
            retData.put('goodsId',goodses[0].Id);
            retData.put('goodsName',goodses[0].Name);
        } else {
            retData.put('goodsId','a0C5g000000wvTxEAI');
            retData.put('goodsName','产品1');
        }

        return retData;
    }
}