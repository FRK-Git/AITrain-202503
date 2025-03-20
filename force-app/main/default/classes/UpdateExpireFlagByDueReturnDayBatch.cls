/**
    className: UpdateExpireFlagByDueReturnDayBatch
    Purpose: 如果应还日期和系统当前日期差值为1（即明天就是过期时间）则做出批量更新
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/21
    Modify Description: null
*/
global class UpdateExpireFlagByDueReturnDayBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdateExpireFlagByDueReturnDayBatch() {
        this.query = 'SELECT Id,Name,DueReturnDate__c,ReturnedDate__c,ExpireFlag__c FROM BookBorrowingInfo__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<BookBorrowingInfo__c> bbiList) {
        
        List<BookBorrowingInfo__c> mybbiList = new List<BookBorrowingInfo__c>();

        for (BookBorrowingInfo__c bbi : bbiList ) {
            BookBorrowingInfo__c updateInfo = new BookBorrowingInfo__c();
             updateInfo.Id = bbi.Id;
             //如果为未还并且隔天过期，则设置过期标记字段为true
            if (bbi.ReturnedDate__c == null && (System.today().daysBetween(bbi.DueReturnDate__c) == 1)) {
                updateInfo.ExpireFlag__c = true;
            } else {
                updateInfo.ExpireFlag__c = false;
            }
            mybbiList.add(updateInfo);
        }

        UPDATE mybbiList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}