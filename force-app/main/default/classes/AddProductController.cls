/********************************************************************
* class Name:	AddProductController
* Test Class:	GoodsTest
* Purpose:	为产品页创建一个控制器
* Author: king frk(1612017127@qq.com)
* Created Date:	2021/1/4
* Modify Description: 
* 1. 修改逻辑 (Joe 2020-7-27）
********************************************************************/
public without sharing class AddProductController {


    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getRecordInfo(String recordId) {
        system.debug('record: ' + recordId);
        Map<String,Object> retMap = new Map<String,Object>();
        retMap.put('status', 'error');
        try {
            Product__c prod = [SELECT Id,ProductName__c,Description__c,ProductStatus__c,
                                      ProductType__c,StockCount__c 
                               FROM Product__c 
                               WHERE Id = :recordId];
            retMap.put('recordId',prod.Id);
            retMap.put('productInfo',prod);
            retMap.put('status','success');
            return retMap;
        }catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            retMap.put('errorInfo', e.getMessage());
            return retMap;
        }
    }


}