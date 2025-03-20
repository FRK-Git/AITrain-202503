public with sharing class BorrowBookWithOneKeyController {
    public BorrowBookWithOneKeyController() {
        
    }

    @AuraEnabled
    public static List<BookDetailInfo__c> getAllEnableBorrowBook() {
        String bookStatus = '可借阅';
        List<BookDetailInfo__c> enableBorrowList = [SELECT Id,Name,BookNo__c,BookName__c,Author__c,Price__c,BookStatus__c
                                                    FROM BookDetailInfo__c
                                                    WHERE BookStatus__c= :bookStatus];
        return enableBorrowList;
    }

    @AuraEnabled
    public static List<BookDetailInfo__c> getBookDetailInfoByAfterBorrow(String readerNo,List<String> bookDetailList) {
        List<BookBorrowingInfo__c> bbiList = new List<BookBorrowingInfo__c>();
        for (String bookDetailId: bookDetailList ) {
            BookBorrowingInfo__c bbi = new BookBorrowingInfo__c();
            bbi.ReaderNo__c = readerNo;
            bbi.BookDetailNo__c = bookDetailId;
            bbi.BorrowDate__c = System.today();
            bbiList.add(bbi);
        }
        try {
            INSERT bbiList;
            return getAllEnableBorrowBook();
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            return null;
        }
    }


}