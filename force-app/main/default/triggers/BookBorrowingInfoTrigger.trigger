trigger BookBorrowingInfoTrigger on BookBorrowingInfo__c(before insert,after insert,before update,after update) {
    new Triggers()

    /**插入之后：对图书详情表里面的图书状态设置为‘已借阅’；
                对读者信息表里面的可借阅数量进行减操作；
                并做出部分字段的检验
       更新之后（即是已还日期不为空）：对图书详情表里面的图书状态设置为‘可借阅’；
                                    对读者信息表里面的可借阅数量进行增操作
    */
    .bind(Triggers.Evt.afterupdate,new UpdateBookStatusByReturnDateHandler())
    .bind(Triggers.Evt.afterinsert,new UpdateBookStatusByReturnDateHandler())

    //设置应还日期：通过判断插入之前的借阅日期和读者类型来设置应还日期
    .bind(Triggers.Evt.beforeinsert,new SetDueReturnDateByBorrowDateHandler())

    //通过续借状态确定应归还日期，并且设置一旦续借状态为true，往后都为true
    .bind(Triggers.Evt.beforeupdate,new UpdateDueReturnDateByRenewStatusHandler())

    //当已还日期不为空时，将付款金额和过期提醒清空
    .bind(Triggers.Evt.beforeupdate,new UpdatePaymentAmountByReturnedDateHandler())

    .manage();
}