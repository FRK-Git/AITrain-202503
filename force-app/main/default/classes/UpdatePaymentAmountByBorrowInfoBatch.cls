/**
    className: UpdatePaymentAmountByBorrowInfoBatch
    Purpose: 对图书借阅信息表的缴费金额字段做出批处理操作：用系统当前时间和应还日期做出比较
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Create Date: 2021/01/21
    Modify Description: null
*/
global class UpdatePaymentAmountByBorrowInfoBatch implements Database.Batchable<sObject> {
    public String query;

    global UpdatePaymentAmountByBorrowInfoBatch() {
        this.query = 'SELECT Id,Name,DueReturnDate__c,PaymentAmount__c,ReturnedDate__c,BookPrice__c,RenewStatus__c FROM BookBorrowingInfo__c';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<BookBorrowingInfo__c> borrowList) {
        
        List<BookBorrowingInfo__c> myBorrowList = new List<BookBorrowingInfo__c>();
        for (BookBorrowingInfo__c bbi : borrowList ) {
            //当已还日期为空并且系统当前时间大于应还日期
            if (bbi.ReturnedDate__c == null && (bbi.DueReturnDate__c.daysBetween(System.today()) > 0)) {
                BookBorrowingInfo__c myInfo = new BookBorrowingInfo__c();
                myInfo.Id = bbi.Id;
                //如果系统当前时间和应还日期的差值大于图书的价格，则把缴费金额设置为图书价格，否则则为差值
                if (bbi.DueReturnDate__c.daysBetween(System.today()) > bbi.BookPrice__c) {
                    myInfo.PaymentAmount__c = bbi.BookPrice__c;
                } else {
                    myInfo.PaymentAmount__c = bbi.DueReturnDate__c.daysBetween(System.today());
                }
                myBorrowList.add(myInfo);
            }
        }
        UPDATE myBorrowList;
    }

    global void finish(Database.BatchableContext BC) {

    }
}