global with sharing class GetProductInfoController {
    public GetProductInfoController() {
        goodsList = new List<Goods__c>();
    }

    public List<Goods__c> goodsList{get;set;}

    public List<SelectOption> goodsUpperCategory = new List<SelectOption>();

    public List<SelectOption> goodsLowerCategory = new List<SelectOption>();

    public Goods__c goods {get;set;}

    public String goodsName {get;set;}

    public Decimal goodsBasePrice {get;set;}

    public Decimal goodsProductNo {get;set;}

    public List<SelectOption> goodsUnit = new List<SelectOption>();

    public Decimal maxStock {get;set;}

    public Decimal minStock {get;set;}

    public Decimal goodsCurrentStock {get;set;}

    WebService static Goods__c getGoodsInfoByName(String name) {
         List<Goods__c> goods = [SELECT Name,
                                       Id,
                                       ProductUpperCategory__c,
                                       ProductLowerCategory__c,
                                       BasePrice__c,
                                       CurrentStock__c,
                                       ProductNo__c,
                                       Unit__c,
                                       MaxStock__c,
                                       MinStock__c
                                FROM Goods__c 
                                WHERE Name = :name];
        return goods[0];
    }

    public void queryGoodsInfoByName(String name) {
        goodsList = [SELECT Name,
                                       Id,
                                       ProductUpperCategory__c,
                                       ProductLowerCategory__c,
                                       BasePrice__c,
                                       CurrentStock__c,
                                       ProductNo__c,
                                       Unit__c,
                                       MaxStock__c,
                                       MinStock__c
                                FROM Goods__c 
                                WHERE Name = :name];
        goodsName = goodsList[0].Name;
        goodsBasePrice = goodsList[0].BasePrice__c;
        // goodsUpperCategory = goodsList[0].ProductUpperCategory__c;
        // goodsLowerCategory = goodsList[0].ProductLowerCategory__c;
        goodsProductNo = goodsList[0].ProductNo__c;
        goodsCurrentStock = goodsList[0].CurrentStock__c;
    }

}