trigger ReaderInfoTrigger on ReaderInfo__c(before insert,after insert,before update,after update,before delete,after delete) {
    new Triggers()

        //在ReaderInfo对象数据插入之后触发，将读者类型和可借阅数量绑定
        .bind(Triggers.Evt.beforeinsert,new UpdateBorrowQuantityByTypeHandler())

        //在ReaderInfo对象更新之后，如果缴费金额大于0并且发生改变时发送邮件给读者
        .bind(Triggers.Evt.afterupdate,new SendEmailToReaderByPaymentHandler())

        .manage();
}