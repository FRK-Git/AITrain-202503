/********************************************************************
* class Name:   UpdateProductPriceBatch
* Test Class:   GoodsTest
* Purpose:  更新产品价格的批量操作
* Author: king frk(1612017127@qq.com)
* Created Date: 2021/1/4
* Modify Description: 
* 1. 修改逻辑 (Joe 2020-7-27）
********************************************************************/
global class UpdateProductPriceBatch implements Database.Batchable<sObject> {
    public String query;
    public Decimal addPrice ;

    global UpdateProductPriceBatch(String query,Decimal addPrice) {
        this.query = query;
        this.addPrice = addPrice;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Goods__c> goodsList) {

        List<Goods__c> mygoods = new List<Goods__c>();

        for (Goods__c goods : goodsList ) {
            Goods__c good = new Goods__c();
            good.Id = goods.Id;
            if (null == goods.BasePrice__c) {
                 good.BasePrice__c = addPrice;
            } else {
                good.BasePrice__c = goods.BasePrice__c + addPrice;
            }
            mygoods.add(good);
        }

        UPDATE mygoods;
    }

    global void finish(Database.BatchableContext BC) {

    }
}