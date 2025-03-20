/**
    className: UpdatePaymentAmountByReturnedDateHandler
    Purpose：当已还日期不为空时，将付款金额和过期提醒清空
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/21
    Modify Description: null
*/
public with sharing class UpdatePaymentAmountByReturnedDateHandler implements Triggers.Handler {
    public void handle() {
        
        if (Trigger.isUpdate && Trigger.isBefore) {
            
            Map<Id,BookBorrowingInfo__c> oldbbiMap = (Map<Id,BookBorrowingInfo__c>)Trigger.oldMap;
            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                BookBorrowingInfo__c oldInfo = oldbbiMap.get(bbi.Id);
                if (oldInfo.ReturnedDate__c == null && bbi.ReturnedDate__c != oldInfo.ReturnedDate__c) {
                    bbi.PaymentAmount__c = 0;
                    bbi.ExpireFlag__c = false;
                }
            }
        }
    }
}