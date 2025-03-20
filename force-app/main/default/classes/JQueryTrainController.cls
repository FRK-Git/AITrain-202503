global with sharing class JQueryTrainController {
    public JQueryTrainController() {
        
    }

     WebService static Goods__c getGoodsInfoByName(String name) {
        List<Goods__c> goods = [SELECT Name,
                                       Id,
                                       ProductUpperCategory__c,
                                       ProductLowerCategory__c,
                                       BasePrice__c,
                                       CurrentStock__c 
                                FROM Goods__c 
                                WHERE Name = :name];

        System.debug(LoggingLevel.INFO, '*** goods[0]: ' + goods[0]);
        return goods[0];
    }
}