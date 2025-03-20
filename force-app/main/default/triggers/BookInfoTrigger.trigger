trigger BookInfoTrigger on BookInfo__c(before insert,after update) {
    
    new Triggers()

        //插入出入库记录：通过图书信息表里的库存发生改变的之后
        .bind(Triggers.Evt.afterupdate,new InsertIOStockByBookInfoStockCountHandler())

        .manage();
}