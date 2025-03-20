/**
    className: InsertIOStockByBookInfoStockCountHandler
    Purpose：通过图书信息表里的库存发生改变之后在出入库信息表里面插入相应的记录
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/20
    Modify Description: null
*/
public with sharing class InsertIOStockByBookInfoStockCountHandler implements Triggers.Handler {
    public void handle() {
        

        if (Trigger.isUpdate && Trigger.isAfter) {
            
            Map<Id,BookInfo__c> oldBookInfoMap = (Map<Id,BookInfo__c>)Trigger.oldMap;
            List<IOStockInfo__c> needInsertBookInfo = new List<IOStockInfo__c>();

            for (BookInfo__c bi : (List<BookInfo__c>)Trigger.new ) {
                BookInfo__c oldBookInfo = oldBookInfoMap.get(bi.Id);

                if (oldBookInfo.StockCount__c != bi.StockCount__c) {
                    IOStockInfo__c ioStock = new IOStockInfo__c();
                    ioStock.BookNo__c = bi.Id;
                    //判断新旧值大小做出相应处理，当改变后的现有库存大于改变前的现有库存的时候则做入库操作，否则做出库操作
                    if (oldBookInfo.StockCount__c < bi.StockCount__c) {
                        ioStock.IOStatus__c = '入库';
                        ioStock.IOCount__c = bi.StockCount__c - oldBookInfo.StockCount__c;
                    } else if (oldBookInfo.StockCount__c > bi.StockCount__c) {
                        ioStock.IOStatus__c = '出库';
                        ioStock.IOCount__c = oldBookInfo.StockCount__c - bi.StockCount__c;
                    }
                    ioStock.IOTime__c = System.now();
                    ioStock.CurrentStockCount__c = bi.StockCount__c;
                    needInsertBookInfo.add(ioStock);
                }
            }
            INSERT needInsertBookInfo;
        }
    }
}