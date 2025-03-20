/**
    className: UpdateBookStatusByReturnDateHandler
    Purpose：当已还日期为空时，修改图书详细信息表里的图书状态为'已借阅'
         当已还日期不为空时，修改图书详细信息表里的图书状态为'可借阅'
         对插入之后的数据进行检验：当插入之后，判断已还日期是否为空，如果不为空提示报错信息；当当状态为true时提示报错信息
         当发生已还日期发生更新：插入借阅记录后对相应的读者信息表的可借阅数量进行减操作
                               更新之后如果已还日期不为空则对读者信息表里的可借阅数量进行增操作
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/19
    Modify Description: null
*/
public with sharing class UpdateBookStatusByReturnDateHandler implements Triggers.Handler {
    public void handle() {

        /**
            改变借阅状态
            改变读者可借阅数量
        */
        if (Trigger.isInsert && Trigger.isAfter) {
            Set<Id> detailNos = new Set<Id>();//存储图书详细信息Id
            Set<Id> readerNos = new Set<Id>();//存储读者非重复Id
            List<Id> readerList = new List<Id>();//存储读者Id（包括重复）
            Map<Id,Integer> theSameNoCount = new Map<Id,Integer>();//存储读者Id相同的记录数

            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
               if (bbi.ReturnedDate__c == null) {
                   detailNos.add(bbi.BookDetailNo__c);
                   readerNos.add(bbi.ReaderNo__c);
                   readerList.add(bbi.ReaderNo__c);
               } else if (bbi.ReturnedDate__c != null) {
                    bbi.addError('归还日期必须为空');
               }

               if (bbi.RenewStatus__c == true) {
                   bbi.addError('当前续借状态不能勾选');
               }
            }

            //筛选相同Id的记录数
            for (Id setId : readerNos ) {
                Integer count = 0;
                for (Id listId : readerList ) {
                    if (setId == listId) {
                        count++;
                    }
                }
                theSameNoCount.put(setId,count);
            }

            List<BookDetailInfo__c> detailInfo = [SELECT Id,Name,BookStatus__c,IsSelected__c FROM BookDetailInfo__c WHERE Id IN :detailNos];
            for (BookDetailInfo__c bdi : detailInfo ) {
                bdi.BookStatus__c = '已借阅';
                bdi.IsSelected__c = false;
            }

            UPDATE detailInfo;

            List<ReaderInfo__c> readers = [SELECT Id,Name,BorrowingQuantity__c FROM ReaderInfo__c WHERE Id IN :readerNos];
            for (ReaderInfo__c read : readers) {
                read.BorrowingQuantity__c = read.BorrowingQuantity__c - theSameNoCount.get(read.Id);
            }

            UPDATE readers;

        }

       
        if (Trigger.isUpdate && Trigger.isAfter) {
            
            Map<Id,BookBorrowingInfo__c> oldMap =  (Map<Id,BookBorrowingInfo__c>)Trigger.oldMap;
            Set<Id> bookIdSet = new Set<Id>();
            Set<Id> readerIdSet = new Set<Id>();
            Map<Id,Integer> theSameReaderNoCount = new Map<Id,Integer>();
            List<Id> readerIdList = new List<Id>();
            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                BookBorrowingInfo__c oldbbi =  oldMap.get(bbi.Id);
                if (oldbbi.ReturnedDate__c == null && bbi.ReturnedDate__c != oldbbi.ReturnedDate__c) {
                    bookIdSet.add(bbi.BookDetailNo__c);
                    readerIdSet.add(bbi.ReaderNo__c);
                    readerIdList.add(bbi.ReaderNo__c);
                }
            }

            for (Id setId : readerIdSet ) {
                Integer count = 0;
                for (Id listId : readerIdList) {
                    if (setId == listId) {
                        count++;
                    }
                }
                theSameReaderNoCount.put(setId,count);
                System.debug(LoggingLevel.INFO, '*** theSameReaderNoCount: ' + theSameReaderNoCount);
            }

            //根据Id集合获取相应对象的记录数
            Map<Id,BookDetailInfo__c> bookDeteilMap = new Map<Id,BookDetailInfo__c>([SELECT Id, BookStatus__c FROM BookDetailInfo__c WHERE Id IN :bookIdSet]);
            List<ReaderInfo__c> readerList = new List<ReaderInfo__c>([SELECT Id,Name,BorrowingQuantity__c FROM ReaderInfo__c WHERE Id IN :readerIdSet]);

            List<BookDetailInfo__c> updateStatusList = new List<BookDetailInfo__c>();

            for (BookBorrowingInfo__c bbi : (List<BookBorrowingInfo__c>)Trigger.new ) {
                    BookBorrowingInfo__c oldbbi =  oldMap.get(bbi.Id);
                    if (oldbbi.ReturnedDate__c == null && bbi.ReturnedDate__c != oldbbi.ReturnedDate__c) {
                        BookDetailInfo__c bdi = bookDeteilMap.get(bbi.BookDetailNo__c);
                        bdi.BookStatus__c = '可借阅';
                        updateStatusList.add(bdi);
                    }
            }

            for (ReaderInfo__c ri : readerList ) {
                ri.BorrowingQuantity__c += theSameReaderNoCount.get(ri.Id);
            }
            
            UPDATE updateStatusList;
            UPDATE readerList;
        }

       
    }
}