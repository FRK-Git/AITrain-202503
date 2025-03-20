/**
  className: PartReturnBookWithOnekeyController
  Purpose: 自定义控制器，作用于PartReturnBookWithOneKeyComponent
  Author: Fangruikai(fangruikai@bluelinksys.com)
  Create Date: 2021/01/21
  Modify Description:null
*/
public with sharing class PartReturnBookWithOnekeyController {
    public PartReturnBookWithOnekeyController() {
        
    }

    /**
      Purpose: 获取所有未归还的图书借阅信息
      Params: null
      Return: 返回一个所有未归还图书借阅信息对象的List集合
    */
    @AuraEnabled
    public static List<BookBorrowingInfo__c> getAllUnReturnBorrowInfo() {
        List<BookBorrowingInfo__c> bbiList = [SELECT Id,                  //图书借阅信息Id
                                                     Name,                //借阅信息编号
                                                     BorrowDate__c,       //借阅日期
                                                     BookName__c,         //图书名称
                                                     BookDetailNo__c,     //图书详细编号
                                                     ReturnedDate__c,     //已还日期
                                                     DueReturnDate__c,    //应还日期
                                                     RenewStatus__c,      //续借状态
                                                     PaymentAmount__c,    //缴费金额
                                                     ReaderName__c,       //读者姓名
                                                     ReaderNo__c,         //读者编号
                                                     ExpireFlag__c        //过期提醒标记
                                              FROM BookBorrowingInfo__c   //图书借阅信息表
                                              WHERE ReturnedDate__c = null];
        return bbiList;
    }

    /**
      Purpose: 根据读者姓名获取所有未归还的图书借阅信息,如果readerName为空则查找所有
      Params: readerName(读者姓名)
      Return: List<//BookBorrowingInfo__c> 对象集合
    */
    @AuraEnabled
    public static List<BookBorrowingInfo__c> getBorrowInfoByReaderName(String readerName) {
        if (readerName != null && readerName != '') {
           List<BookBorrowingInfo__c> bbiList = [SELECT Id,Name,BorrowDate__c,BookName__c,BookDetailNo__c,ReturnedDate__c,
                                                     DueReturnDate__c,RenewStatus__c,PaymentAmount__c,ReaderName__c,
                                                     ReaderNo__c,ExpireFlag__c
                                                 FROM BookBorrowingInfo__c 
                                                 WHERE ReturnedDate__c = null 
                                                 AND ReaderName__c = :readerName];
           return bbiList;
        } else {
          return getAllUnReturnBorrowInfo();
        }
        
        
    }

    /**
      Purpose: 根据一个存放Id的List从借阅信息对象中设置对应的已还日期为当前时间并更新整个List
      Params: selectList(存放Id的List，为复选框选中的值)
      Return: Boolean(更新成功则返回true，否则返回false)
    */
    @AuraEnabled
    public static Boolean setReturndateById(List<String> selectList) {
        List<BookBorrowingInfo__c> bbiList = [SELECT Id,Name,BorrowDate__c,BookName__c,BookDetailNo__c,ReturnedDate__c,
                                                     DueReturnDate__c,RenewStatus__c,PaymentAmount__c,ReaderName__c,
                                                     ReaderNo__c,ExpireFlag__c
                                              FROM BookBorrowingInfo__c 
                                              WHERE Id IN :selectList];
        System.debug(LoggingLevel.INFO, '*** bbiList: ' + bbiList);
        for (BookBorrowingInfo__c bbi : bbiList ) {
          bbi.ReturnedDate__c = System.today();
        }

        try {
          UPDATE bbiList;
          return true;
        } catch(Exception e) {
          return false;
        }
    }
}