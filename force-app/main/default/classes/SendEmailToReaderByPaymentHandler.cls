/**
    className: SendEmailToReaderByPaymentHandler
    Purpose：当缴费金额大于0并且发生变化的时候为给一个读者发送邮件
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/20
    Modify Description: null
    功能：
*/
public with sharing class SendEmailToReaderByPaymentHandler implements Triggers.Handler {
    public void handle() {
        
        if (Trigger.isUpdate && Trigger.isAfter) {
            Map<Id,ReaderInfo__c> readers = (Map<Id,ReaderInfo__c>)Trigger.oldMap;

            //从读者信息表里找到所有缴费金额大于0的读者Id
            Set<Id> readId = new Set<Id>();
            for (ReaderInfo__c reader : (List<ReaderInfo__c>)Trigger.new ) {
                ReaderInfo__c oldreader = readers.get(reader.Id);
                if ((oldreader.PaymentAmount__c != reader.PaymentAmount__c) && (reader.PaymentAmount__c > 0)) {
                    readId.add(reader.Id);
                }
            }
            //根据读者Id从借阅表里面找到缴费金额大于0的读者借阅图书信息
            List<BookBorrowingInfo__c> bbiList = [SELECT Id,Name,BookName__c,ReaderNo__c,ReaderName__c,PaymentAmount__c
                                                  FROM BookBorrowingInfo__c 
                                                  WHERE ReaderNo__c IN :readId AND PaymentAmount__c > 0];


            for (ReaderInfo__c reader : (List<ReaderInfo__c>)Trigger.new) {
                ReaderInfo__c oldreader = readers.get(reader.Id);
                if ((oldreader.PaymentAmount__c != reader.PaymentAmount__c) && (reader.PaymentAmount__c > 0)) {
                    String bookName = '';
                    //遍历符合条件的所有借阅图书信息并根据读者Id进行筛选
                    for (BookBorrowingInfo__c bbi : bbiList ) {
                        if (bbi.ReaderNo__c == reader.Id) {
                            bookName += bbi.BookName__c + ' ';
                        }
                    }
                    String reademail = reader.Email__c;
                    String title = '图书馆缴费金额通知';
                    String info = reader.ReaderName__c +reader.ReaderType__c+'，您所借阅是书籍('+bookName+')已经超时，请尽快还书并还清欠费！欠费金额为：'+reader.PaymentAmount__c;
                    EmailManager.sendMail(reademail,title,info);
                }
            }
        }
    }
}