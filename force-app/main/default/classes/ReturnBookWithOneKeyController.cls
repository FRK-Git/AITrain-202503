/**
    className: ReturnBookWithOneKeyController
    Purpose: 自定义控制器，作用于自定义组件ReturnBookWithOneKeyComponent
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Create Date: 2021/01/20
    Modify Description: null
*/
public with sharing class ReturnBookWithOneKeyController {
    public ReturnBookWithOneKeyController() {
        
    }

    /**
        Purpose: 拿到所有还没还清图书的学生信息
        Params: null
        Return: 返回List<//ReaderInfo__c>的对象集合
    */
    @AuraEnabled
    public static List<ReaderInfo__c> getReaderInfoByUnReturn() {
        List<ReaderInfo__c> allReaderInfo = [SELECT Id,                     //读者Id
                                                    Name,                   //读者编号
                                                    ReaderName__c,          //读者姓名
                                                    ReaderType__c,          //读者类型
                                                    Phone__c,               //联系电话
                                                    Email__c,               //邮箱
                                                    BorrowingQuantity__c,   //可借阅数量
                                                    PaymentAmount__c        //缴费金额
                                             FROM ReaderInfo__c];           //读者信息表
        List<ReaderInfo__c> returnReader = new List<ReaderInfo__c>();
        for (ReaderInfo__c reader : allReaderInfo) {
            if (reader.ReaderType__c == '教职工' && (reader.BorrowingQuantity__c != 20)) {
                returnReader.add(reader);
            } else if (reader.ReaderType__c == '学生' && (reader.BorrowingQuantity__c != 10)) {
                returnReader.add(reader);
            }
        }

        return returnReader;
    }

    /**
        Purpose: 通过读者Id在借阅表里面拿到所有归还日期为空的记录并设置为当前日期
        Params: id(读者Id)
        Return: Boolean(更新成功为true)
    */
    @AuraEnabled
    public static Boolean setReturnDateInBorrowInfoByReaderId(String id) {
        System.debug(LoggingLevel.INFO, '*** id: ' + id);
        List<BookBorrowingInfo__c> bbiList = [SELECT Id,Name,ReaderNo__c,ReturnedDate__c FROM BookBorrowingInfo__c WHERE ReaderNo__c = :id AND ReturnedDate__c = null];
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