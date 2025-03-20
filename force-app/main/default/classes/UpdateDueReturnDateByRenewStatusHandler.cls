/**
    className: UpdateDueReturnDateByRenewStatusHandler
    Purpose：通过应还日期和借阅日期的差值判断是否已经续借过，
    ··       通过续借状态值改变应还日期，
             对已经超时的书籍进行数据校验，只能在应还日期到期前可以续借，
             一旦续借状态为true，则后面的续借状态都为true
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/20
    Modify Description: null
*/
public with sharing class UpdateDueReturnDateByRenewStatusHandler implements Triggers.Handler {
    public void handle() {
        

         if (Trigger.isUpdate && Trigger.isBefore) {
            
            Map<Id,BookBorrowingInfo__c> oldBorrowInfoMap = (Map<Id,BookBorrowingInfo__c>)Trigger.oldMap;

            // Set<Id> newInfoId = new Set<Id>();
            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                BookBorrowingInfo__c oldSingle = oldBorrowInfoMap.get(bbi.Id);
                
                //无论是学生还是教职工，只要没有续借图书，那么应还-借阅差值一定小于50，续借后则一定大于50
                if ((bbi.BorrowDate__c.daysBetween(bbi.DueReturnDate__c) < 50) && 
                    oldSingle.RenewStatus__c == false && 
                    bbi.RenewStatus__c != oldSingle.RenewStatus__c) {
                    if (oldSingle.DueReturnDate__c.daysBetween(System.today()) > 0) {
                        bbi.addError('只能在应还日期前续借');
                    }
                    bbi.DueReturnDate__c = bbi.DueReturnDate__c + 30;
                    // newInfoId.add(bbi.Id);
                } else if (oldSingle.RenewStatus__c) {
                    bbi.RenewStatus__c = true;
                }
            }
        }
    }
}