/***
    className: UpdateBorrowQuantityByTypeHandler
    Purpose：当插入读者信息之前，判断读者类型并为其设置借阅数量
             只有在插入时才触发，也即是一旦读者类型确定，借阅数量不能更改，因为读者类型不可能发生改变
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Created Date: 2021/01/20
    Modify Description: null
**/
public with sharing class UpdateBorrowQuantityByTypeHandler implements Triggers.Handler {
    public void handle() {
        
        if (!(Trigger.isBefore && Trigger.isInsert)) {
            return;
        }

        //根据读者类型改变读者可借阅数量
        for (ReaderInfo__c ri : (List<ReaderInfo__c>)Trigger.new ) {
            if (ri.ReaderType__c == '教职工') {
                ri.BorrowingQuantity__c = 20;
            } else {
                ri.BorrowingQuantity__c = 10;
            }
        }
    }
}