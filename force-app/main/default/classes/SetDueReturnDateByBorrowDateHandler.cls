/**
    className: SetDueReturnDateByBorrowDateHandler
    Purpose：在插入借阅记录信息之前判断读者类型，然后通过读者类型设置相应的应还日期
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/19
    Modify Description: null
*/
public with sharing class SetDueReturnDateByBorrowDateHandler implements Triggers.Handler {
    public void handle() {
        
        if (Trigger.isInsert && Trigger.isBefore) {

            Set<Id> readerId = new Set<Id>();
            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                readerId.add(bbi.ReaderNo__c);
            }

            //从读者信息表中获取Id相应的记录
            Map<Id,ReaderInfo__c> readerMap = new Map<Id,ReaderInfo__c>([SELECT Id,Name,ReaderType__c FROM ReaderInfo__c WHERE Id IN :readerId]);
            
            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                if (readerMap.get(bbi.ReaderNo__c).ReaderType__c == '教职工') {
                    bbi.DueReturnDate__c = bbi.BorrowDate__c + 45;
                } else if(readerMap.get(bbi.ReaderNo__c).ReaderType__c == '学生') {
                    bbi.DueReturnDate__c = bbi.BorrowDate__c + 30;
                }
            }

            
        }
    }
}