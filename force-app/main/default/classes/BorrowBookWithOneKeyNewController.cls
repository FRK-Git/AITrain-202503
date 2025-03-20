public with sharing class BorrowBookWithOneKeyNewController {
    public BorrowBookWithOneKeyNewController() {
        
    }

    @AuraEnabled
    public static List<BookDetailInfo__c> getAllDetailBookHasStatusAndIsSelect () {
        List<BookDetailInfo__c> bdiList = [SELECT Id,Name,BookNo__c,BookName__c,Author__c,Price__c,BookStatus__c,IsSelected__c
                                           FROM BookDetailInfo__c
                                           WHERE BookStatus__c='可借阅'
                                           AND IsSelected__c=true];
        return bdiList;
    }

    @AuraEnabled
    public static List<BookDetailInfo__c> updateIsSelectByIdAndReturn(String bookDetailId) {
        BookDetailInfo__c bdi = [SELECT Id,Name,BookNo__c,BookName__c,Author__c,Price__c,BookStatus__c,IsSelected__c
                                 FROM BookDetailInfo__c
                                 WHERE Id= :bookDetailId];

        bdi.IsSelected__c = true;
        try {
            UPDATE bdi;
            return getAllDetailBookHasStatusAndIsSelect();
        } catch(Exception e) {
            System.debug(LoggingLevel.INFO, '*** e: ' + e);
            return null;
        }

    }

    @AuraEnabled
    public static List<BookDetailInfo__c> clearAllDetailBookHasStatusAndIsSelect() {
        List<BookDetailInfo__c> bdiList = [SELECT Id,Name,BookNo__c,BookName__c,Author__c,Price__c,BookStatus__c,IsSelected__c
                                           FROM BookDetailInfo__c
                                           WHERE BookStatus__c='可借阅'
                                           AND IsSelected__c=true];
        for (BookDetailInfo__c bdi : bdiList ) {
            bdi.IsSelected__c = false;
        }

        UPDATE bdiList;
        return getAllDetailBookHasStatusAndIsSelect();
    }

    @AuraEnabled
    public static List<BookDetailInfo__c> borrowBookByOnekeyNewOperation(String readerId) {
        List<BookDetailInfo__c> bdiList = getAllDetailBookHasStatusAndIsSelect();
        List<BookBorrowingInfo__c> borrowList  = new List<BookBorrowingInfo__c> ();
        for (BookDetailInfo__c bdi : bdiList ) {
            BookBorrowingInfo__c bbi = new BookBorrowingInfo__c();
            bbi.BookDetailNo__c = bdi.Id;
            bbi.ReaderNo__c = readerId;
            bbi.BorrowDate__c = System.today();
            borrowList.add(bbi);
        }
        INSERT borrowList;

        // for (BookDetailInfo__c bdi : bdiList ) {
        //     bdi.IsSelected__c = false;
        // }
        // UPDATE bdiList;

        return getAllDetailBookHasStatusAndIsSelect();
    }
}