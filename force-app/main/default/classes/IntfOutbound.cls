public with sharing class IntfOutbound {
     public static Object call(String interfaceName, IntfOutboundData param, Boolean saveLog) {
        IntfOutboundExecutor exe = new IntfOutboundExecutor(interfaceName, param);
        long startDatetime = Datetime.now().getTime();
        Object result = exe.execute(saveLog);
        long endDatetime = Datetime.now().getTime();
        system.debug('时间差::'+(endDatetime - startDatetime));
        return result;
    }
}