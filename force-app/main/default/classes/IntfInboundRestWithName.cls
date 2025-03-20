/**********************************************************************
 * 
 *
 * @url: /services/apexrest/rest
 * @data:
 *  {
        
    }
*************************************************************************/
@RestResource(urlMapping='/rest/*')
global with sharing class IntfInboundRestWithName 
{
    @HttpPost
    global static void doPost() 
    {
        String respBody = doExecute(RestContext.request);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.statusCode = 200;
        RestContext.response.responseBody = Blob.valueOf(respBody);
    }

    // @HttpGet
    // global static void doGet() 
    // {
    //     RestContext.response.responseBody = Blob.valueOf('success.');
    // }

    public static String doExecute (RestRequest req) {
        IntegratedLog__c log = new IntegratedLog__c();
        IntfInboundResult result;
        String respBody = '';


        String bodystr = req.requestBody.tostring();
        String intfName = getIntfNameFromUrl(req.requestURI, req.httpMethod);

        log.GeneratedTime__c = System.now();
        log.InvokeUser__c = UserInfo.getUserId();
        log.InvokeSession__c = UserInfo.getSessionId();

        log.SendContent__c = bodystr;
        log.HeaderContent__c = String.valueOf(req.headers);
        log.IP__c = req.remoteAddress;
        log.URI__c = req.requestURI;
        log.Type__c = IntfUtility.INTEGRATEDLOG_TYPE_CALL_IN; //'入站';

        IntfInboundExecutor executor;
        try{
            // if (!IntfUtility.isTheValidIp(intfName, log.IP__c)) {
            //     throw new IntfException('The ip is not valid.');
            // }
            executor = new IntfInboundExecutor(intfName, bodystr, log);
            result = executor.execute();

            if (result == null) {
                throw new IntfException('Apex_Error: IntfInboundResult is null.');
            }

            
        } catch (Exception e) {
            String message = e.getMessage();
            result = new IntfInboundResult();
            result.code = 400;
            result.msg = message;

            log.ErrorContent__c = Json.serialize('(' + e.getLineNumber() 
                                + ') : ' + message 
                                + '\n' + e.getStackTraceString());

            System.debug(LoggingLevel.INFO, '*** log.ErrorContent__c: ' + log.ErrorContent__c);
        }

        respBody = JSON.serialize(result, true);
        log.ReturnsContent__c = respBody;
        if (result.code == 200) {
            log.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_SUCCESS; //'成功';
        } else {
            log.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_FAIL;  //'失败';
        }

        //判断返回结果是否加密
        if (executor != null
             && executor.theDefine != null
             && executor.theDefine.NeedEncode__c
             && String.isNotBlank(executor.theDefine.EncodeType__c)
             && String.isNotBlank(executor.theDefine.EncodeKey__c)
        ) {

            String respBodyStr = IntfUtility.encryptByType(executor.theDefine.EncodeType__c, respBody, executor.theDefine.EncodeKey__c);
            System.debug(LoggingLevel.INFO, '*** respBodyStr: ' + respBodyStr);

            Map<String, String> amap = new Map<String, String>{'DATA' => respBodyStr};
            String respJson = JSON.serialize(amap);

            log.RespBodyAfterEncrypt__c = respJson; //respBodyStr;
            respBody = respJson;
        }

        // 保存日志
        IntfUtility.insertLog(log);
        return respBody;
    }

    public static String getIntfNameFromUrl (String requestUrl, String method) {
        String theURI = requestUrl;
        if ('GET' == method) {
            theURI = theURI.substringBefore('?');
        }

        System.debug(LoggingLevel.INFO, '*** theURI: ' + theURI);
        String intfName = theURI.substringAfter('/rest/');

        System.debug(LoggingLevel.INFO, '*** intfName: ' + intfName);
        return intfName;
    }
}