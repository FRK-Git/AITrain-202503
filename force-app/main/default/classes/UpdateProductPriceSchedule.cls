global class UpdateProductPriceSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        String queryGoods = 'SELECT BasePrice__c,' + 
                                   'ProductNo__c ' + 
                            'FROM Goods__c';
        // List<Goods__c> goods =  Database.query(queryGoods);
        // System.debug(LoggingLevel.INFO, '*** goods: ' + JSON.serialize(goods));

        UpdateProductPriceBatch up = new UpdateProductPriceBatch(queryGoods,1.88);
        Database.executeBatch(up);

        //批处理成功发送邮件通知
        EmailManager.sendMail('1612017127@qq.com','价格更新批处理操作','success');
    }

    public static void runSchedule() {

        //实例化产品价格计划任务
        UpdateProductPriceSchedule sc = new UpdateProductPriceSchedule();

        //设置时间格式
        String fmt = '30 49 14 8 1 ? 2021';
        String scheduleName = '产品价格更新提醒' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.schedule(scheduleName, fmt, sc);
    }

}