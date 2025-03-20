/********************************************************************
* Trigger Name: GoodsTrigger
* Test Class:   null
* Purpose:  为产品创建一个触发器
* Author: king frk(1612017127@qq.com)
* Created Date: 2021/1/4
* Modify Description: 
* 1. 修改逻辑 (Joe 2020-7-27）
********************************************************************/
trigger GoodsTrigger on Goods__c(before insert,before update,after insert, after update) {

    System.debug(LoggingLevel.INFO, '*** : 触发器调用了');

    List<String> newAndOldPriceAndStockList = new List<String>();

    if (Trigger.isUpdate && Trigger.isAfter) {
         Map<Id,Goods__c> oldGoodsMap = (Map<Id,Goods__c>) Trigger.oldMap;
        for (Goods__c goods : (List<Goods__c>)Trigger.new ) {
            if (goods.BasePrice__c != oldGoodsMap.get(goods.Id).BasePrice__c || 
                goods.CurrentStock__c != oldGoodsMap.get(goods.Id).CurrentStock__c) {
                
                newAndOldPriceAndStockList.add(goods.Id +'-->' + goods.Name +
                                              '产品的基本价格从' + oldGoodsMap.get(goods.Id).BasePrice__c + '（元）变成了' + goods.BasePrice__c + '（元）,' + 
                                              '当前库存从' + oldGoodsMap.get(goods.Id).CurrentStock__c + oldGoodsMap.get(goods.Id).Unit__c + 
                                              '变成' + goods.CurrentStock__c + goods.Unit__c);
                
            }
        }

        EmailManager.sendMail('1612017127@qq.com','基本价格或当前库存改变触发器',JSON.serialize(newAndOldPriceAndStockList));

        // 发送邮件给管理员
        //         发送邮件给管理员
        //         EmailManager.sendMail('1612017127@qq.com', 
        //                               '基本价格或当前库存改变触发器', 
        //                               '基本价格从' + oldGoodsMap.get(goods.Id).BasePrice__c + '（元）变成了' + goods.BasePrice__c + '（元）,' + 
        //                               '当前库存从' + oldGoodsMap.get(goods.Id).CurrentStock__c + oldGoodsMap.get(goods.Id).Unit__c + 
        //                               '变成' + goods.CurrentStock__c + goods.Unit__c);
    }
        
       

    // Integer i = 0;
    // if (Trigger.isInsert) {
        
    //     if(Trigger.isBefore) {
    //         List<Goods__c> oldGoods = [SELECT Name,
    //                                           ProductCode__c 
    //                                    FROM Goods__c ];
    //         List<String> oldGoodsProductCode = new List<String>();
    //         List<String> oldGoodsProductName = new List<String>();
    //         for (Goods__c oldGood: oldGoods) {
    //             oldGoodsProductCode.add(oldGood.ProductCode__c);
    //             oldGoodsProductName.add(oldGood.Name);
    //         }
    //         Boolean flagCode,flagName;
    //         for (Goods__c goods: Trigger.new) {
    //             flagCode = false;
    //             flagName = false;
    //             goods.ProductCode__c += 'frk';
    //             if (oldGoodsProductName.contains(goods.Name)) {
    //                 flagName = true;
    //             }
    //             if (oldGoodsProductCode.contains(goods.ProductCode__c)) {
    //                 flagCode = true;
    //             }
                
    //             if (flagName == true) {
    //                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'产品名称不能重复'));
    //                 goods.Name += 'error' + i;
    //                 i++;
    //             }  
    //             if (flagCode == true) {
    //                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'产品编码不能重复'));
    //                 goods.ProductCode__c += 'error';
    //             } else {

    //             }
    //         }
    //     }
    // }

    // if (Trigger.isUpdate) {
    //     if (Trigger.isBefore) {
            
    //     }
    // }

    
    
}