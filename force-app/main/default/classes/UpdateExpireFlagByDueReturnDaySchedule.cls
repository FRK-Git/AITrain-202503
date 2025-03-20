/**
    className: UpdateExpireFlagByDueReturnDaySchedule
    Purpose: 更新过期标记的计划表：对更新过期标记的批处理操作与每天23：00做出定时操作
    Author: Fangruikai(fangruikai@bluelinksys.com)
    Create Date: 2021/01/21
    Modify Description: null
*/
global class UpdateExpireFlagByDueReturnDaySchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        UpdateExpireFlagByDueReturnDayBatch ub = new UpdateExpireFlagByDueReturnDayBatch();
        Database.executeBatch(ub);
    }


    public static void runSchedule() {
        UpdateExpireFlagByDueReturnDaySchedule us = new UpdateExpireFlagByDueReturnDaySchedule();

        String fmt = '00 00 23 1-31 1-12 ? 2021';
        // String fmt = '00 38 16 19 1 ? 2021';
        String scheduleName = '借书过期更新提醒' + System.now().format('yyyyMMddHHmmss');
        Id sid = System.schedule(scheduleName, fmt, us);
    }
}