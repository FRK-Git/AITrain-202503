trigger AccountTrigger on Account(before insert,after insert,before update,after update) {
    new Triggers()

        //设置标准客户编号为自定义客户编号
        .bind(Triggers.Evt.beforeinsert,new SetAccountNumberHander())

        //检查客户名称和编号是否存在
        .bind(Triggers.Evt.beforeinsert,new CheckAccountNameAndCodeHandler())

        //生成联系人
        .bind(Triggers.Evt.afterinsert,new CreateAccountContactHandler())

        .manage();
}