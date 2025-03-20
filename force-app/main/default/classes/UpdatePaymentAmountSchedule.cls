/**
    className: UpdatePaymentAmountSchedule
    Purpose: 于每天凌晨5：00对执行更新缴费金额的批处理操作
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Create Date: 2021/01/21
    Modify Description: null
*/
global class UpdatePaymentAmountSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        

        UpdatePaymentAmountByBorrowInfoBatch ub = new UpdatePaymentAmountByBorrowInfoBatch();
        Database.executeBatch(ub);

    }


    public static void runSchedule() {

        UpdatePaymentAmountSchedule uc = new UpdatePaymentAmountSchedule();

         String fmt = '00 00 05 1-31 1-12 ? 2021';
        // String fmt = '00 45 09 19 1 ? 2021';
        String scheduleName = '缴费金额更新提醒' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.schedule(scheduleName, fmt, uc);
    }
}