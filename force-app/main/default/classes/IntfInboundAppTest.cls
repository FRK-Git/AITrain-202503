/********************************************************************
* class Name         :  IntfInboundAppTest
* Purpose            :  测试接口联通性
* Author             :  yuhanxiang（yuhanxiang@bluelinksys.com）
* Created Date       :  2021-09-01
* Modify Description : 
* 
********************************************************************/
public without sharing class IntfInboundAppTest extends IntfInboundBase{
    public Override IntfInboundResult execute(IntfInboundData inboundData) {

        IntfInboundResult resultRes = new IntfInboundResult();
        System.debug(LoggingLevel.INFO, '***inboundData : ' + inboundData);
        System.debug(LoggingLevel.INFO, '***inboundData.allData : ' + inboundData.allData);
        System.debug(LoggingLevel.INFO, '***inboundData.invalidData : ' + inboundData.invalidData);
        System.debug(LoggingLevel.INFO, '***inboundData.errorMap : ' + inboundData.errorMap);
        //打开测试失败
        /*inboundData.errorMap.put('1','1');*/
       

        if (inboundData.errorMap == null || inboundData.errorMap.isEmpty()) {
            System.debug(LoggingLevel.INFO, '*** errorMap: ' + inboundData.errorMap);
            resultRes.code = 200;
            resultRes.msg = 'Success';
            return resultRes;
        }
        resultRes.msg = 'Error';
        resultRes.code = 400;
        return resultRes;
    }
}