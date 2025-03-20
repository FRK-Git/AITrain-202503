/********************************************************************
* ClassName:          EditReaderExtension.cls
* TestClassName:      EditReaderExtensionTest.cls
* Purpose:            处理编辑读者信息的页面
* Refer Object:       ReaderInfo__c
* Author:             fangruikai(bluelinksys.com)
* Create Date:        2023-02-06
* Modify Description: 
********************************************************************/
public without sharing class EditReaderExtension {
    

    /********************************************************************
    * Purpose:   初始化编辑读者信息页面
    * Param:     recordId: 读者信息Id
    * Return:    Map<String,Object> 返回读者信息和读者类型的选项列表
    * Create By: fangruikai(bluelinksys.com) 2023-02-06
    * Modify By: 
    ********************************************************************/
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> initReaderInfo(String recordId) {
        Map<String,Object> retMap = new Map<String,Object>();
    	retMap.put('status', 'error');
        try {
            //获取读者信息对象
            ReaderInfo__c readInfo = [SELECT Id,Name,ReaderName__c,Phone__c,Email__c,ReaderType__c,BorrowingQuantity__c,
                                            (SELECT Id,Name,BorrowDate__c,BookDetailNo__c,DueReturnDate__c,
                                                    RenewStatus__c 
                                             FROM BookBorrowingInfo__r) 
                                      FROM ReaderInfo__c 
                                      WHERE Id =: recordId];
            retMap.put('readInfo',readInfo);

            List<BookBorrowEntity> bookBoInfoList = new List<BookBorrowEntity>();
            for (BookBorrowingInfo__c bbInfo : readInfo.BookBorrowingInfo__r) {
                BookBorrowEntity bb = new BookBorrowEntity();
                bb.Id = bbInfo.Id;
                bb.Name = bbInfo.Name;
                bb.BookDetailNo = bbInfo.BookDetailNo__c;
                bb.BorrowDate = String.valueOf(bbInfo.BorrowDate__c);
                bb.DueReturnDate = String.valueOf(bbInfo.DueReturnDate__c);
                bb.RenewStatus = bbInfo.RenewStatus__c;
                bookBoInfoList.add(bb);
            }
            retMap.put('bookBoInfoList',bookBoInfoList);

            //获取读者类型选项列表
            List<Map<String, String>> readerType = Utility.getPicklistLabelAndValue('ReaderInfo__c','ReaderType__c',false);
            retMap.put('readType',readerType);
            retMap.put('status', 'success');
            return retMap;
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
            System.debug(LoggingLevel.INFO, '*** e.getLineNumber(): ' + e.getLineNumber());
            retMap.put('errorInfo', Utility.formatException(e.getMessage()));
            return retMap;
        }
    }

    //图书借阅信息对象
    public class BookBorrowEntity{
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String BookDetailNo;
        @AuraEnabled public String BorrowDate;
        @AuraEnabled public String DueReturnDate;
        @AuraEnabled public Boolean RenewStatus; 
    }
}