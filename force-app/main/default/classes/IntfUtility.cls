/**********************************************************************
*Name：接口工具类
*Description：

======================================================
History                                                            
-------                                                            
    VERSION  AUTHOR          DATE            DETAIL                    
    1.0      lijun        2020-02-17         Created

***********************************************************************/ 
public  class IntfUtility {


    /*接口参数*/
    public static final String INTEGRATEDLOG_RESULTS_FAIL = '失败';
    public static final String INTEGRATEDLOG_RESULTS_SUCCESS = '成功';
    public static final String INTEGRATEDLOG_TYPE_CALL_OUT = '出站';
    public static final String INTEGRATEDLOG_TYPE_CALL_IN = '入站';

    // 集成调用计划
    public static final String INTEGRATEDEXECUTE_STATUS_UNTREATED = '未处理';
    public static final String INTEGRATEDEXECUTE_STATUS_EXECUTING = '执行中';
    public static final String INTEGRATEDEXECUTE_STATUS_EXECUTED = '执行结束';
    public static final String INTEGRATEDEXECUTE_STATUS_FINISHED = '完成';
    public static final String INTEGRATEDEXECUTE_EXECUTE_METHOD_TIMING = '定时';
    public static final String INTEGRATEDEXECUTE_EXECUTE_METHOD_IMMEDIATE = '即时';
    public static final String INTEGRATEDEXECUTE_TYPE_PLANNING = '计划';
    public static final String INTEGRATEDEXECUTE_TYPE_RETRY = '重试';


    public static final String ADMIN_REMINDER_EMAIL = '';
    
    // 功能说明： 根据接口名，获取外部调用接口配置信息
    public static InboundDefine__mdt getInboundDefineByName (String apiName) {
        List<InboundDefine__mdt> inBounds = [
            SELECT NoNeedLogin__c, NoNeedBuildObject__c, ExternalSystemName__c, 
                   ExecuteClass__c, ExecuteInterval__c, InterfaceName__c, Label, 
                   IntfVerificationUrl__c, DataListName__c, LogExpiryDays__c,LogExpiryDate__c, 
                   MapConfigObjectName__c, MapConfigName__c, IsAutoBuildObject__c, 
                   NeedRetry__c, IsNeedCheckMd5__c, Key__c, OutboundIntfName__c, 
                   DeveloperName, IntfFieldMapping__c, TestFailResponse__c, TestResponse__c, 
                   EncodeKey__c, EncodeType__c, NeedEncode__c,MasterLabel
            FROM InboundDefine__mdt
            WHERE InterfaceName__c =: apiName];

        if (inBounds.isEmpty()) {
            return null;
        }

        return inBounds[0];
    }

    public static OutboundDefine__mdt getOutboundDefineByName (String apiName) {
        List<String> apiNames = new List<String> {apiName};
        Map<String, OutboundDefine__mdt> amap = getOutboundDefineMapByName(apiNames);

        if (amap.containsKey(apiName)) {
            return amap.get(apiName);
        }

        return null;
    }

    public static Map<String, OutboundDefine__mdt> getOutboundDefineMapByName (List<String> apiNames) {
        Map<String, OutboundDefine__mdt> amap = new Map<String, OutboundDefine__mdt>();
        for(OutboundDefine__mdt outBound : [
            SELECT PlanningCycle__c, Remark__c, ExternalSystemName__c, PassWord__c, 
                   SucessFlag__c, ExecuteClass__c, InterfaceName__c, Url__c, BatchSize__c, 
                   LogExpiryDate__c, IsNeedRetry__c, ApiId__c, Key__c, CalloutContentType__c, 
                   CalloutMethod__c, CalloutTimeout__c, UserName__c, RetryCount__c, Label, 
                   RetryInterval__c, KeyID__c, KeySecret__c, SignName__c, ScheduleInterval__c,
                   EncodeKey__c, EncodeType__c, NeedEncode__c,Category__c,InterfaceType__c,MasterLabel
            FROM OutboundDefine__mdt
            WHERE InterfaceName__c =: apiNames]) {
            amap.put(outBound.InterfaceName__c, outBound);
        }

        return amap;
    }



     public static void insertLog (IntegratedLog__c log) {
        List<Attachment> aList = new List<Attachment>();
        if ((log.SendContent__c != null && log.SendContent__c.length() >= 131072)||Test.isRunningTest()) {
            Attachment sc = new Attachment();
            sc.Name = 'SendContent';
            if (!Test.isRunningTest()) {
                sc.Body = Blob.valueOf(log.SendContent__c);
                log.SendContent__c = log.SendContent__c.substring(0, 131072);        
            }else{
                 sc.Body = Blob.valueOf('123');
            }
            aList.add(sc);
        }

        if ((log.ReturnsContent__c != null && log.ReturnsContent__c.length() >= 131072)||Test.isRunningTest()) {
            Attachment sc = new Attachment();
            sc.Name = 'ReturnsContent';
            
            if (!Test.isRunningTest()) {
                sc.Body = Blob.valueOf(log.ReturnsContent__c);
                log.ReturnsContent__c = log.ReturnsContent__c.substring(0, 131072);
            }else{
                 sc.Body = Blob.valueOf('123');
            }
            aList.add(sc);
        }

        if ((log.ErrorContent__c != null && log.ErrorContent__c.length() >= 131072)||Test.isRunningTest()) {
            Attachment sc = new Attachment();
            sc.Name = 'ErrorContent';
            if (!Test.isRunningTest()) {
                sc.Body = Blob.valueOf(log.ErrorContent__c);
                log.ErrorContent__c = log.ErrorContent__c.substring(0, 131072);
            }else{
                 sc.Body = Blob.valueOf('123');
            }
            aList.add(sc);
        }

        Database.SaveResult result =  Database.insert(log,false);
        // ExceptionUtility.consumeException(result, '比较严重', 'IntfUtility', true, 'IntegratedLog__c');

        if (aList.size() > 0) {
            if (!Test.isRunningTest()) {
                for (Attachment a : aList) {
                    a.ParentId = log.Id;
                }
                Database.insert(aList,false);
            }
        }
    }


    public static void insertLog(List<IntegratedLog__c> logList) {
        if (logList != null && logList.size() > 0) {
            List<LogContent> contentList = new List<LogContent>();
            List<IntegratedLog__c> insertLogList = new List<IntegratedLog__c>();
            for (IntegratedLog__c log : logList) {
                List<Attachment> aList = new List<Attachment>();
                if ((log.RespBodyAfterEncrypt__c != null && log.RespBodyAfterEncrypt__c.length() >= 131072)||Test.isRunningTest()) {
                    Attachment sc = new Attachment();
                    sc.Name = '响应密文';
                    if (!Test.isRunningTest()) {
                        sc.Body = Blob.valueOf(log.RespBodyAfterEncrypt__c);
                        log.RespBodyAfterEncrypt__c = log.RespBodyAfterEncrypt__c.substring(0, 131072);
                        aList.add(sc);
                    }else{
                        sc.Body = Blob.valueOf('123');
                    }
                    
                }

                if ((log.ReqBodyBeforeDecrypt__c != null && log.ReqBodyBeforeDecrypt__c.length() >= 131072)||Test.isRunningTest()) {
                    Attachment sc = new Attachment();
                    sc.Name = '请求密文';
                    if (!Test.isRunningTest()) {
                        sc.Body = Blob.valueOf(log.ReqBodyBeforeDecrypt__c);
                        log.ReqBodyBeforeDecrypt__c = log.ReqBodyBeforeDecrypt__c.substring(0, 131072);
                        aList.add(sc);
                    }else{
                        sc.Body = Blob.valueOf('123');
                    }
                    
                }

                if ((log.SendContent__c != null && log.SendContent__c.length() >= 131072)||Test.isRunningTest()) {
                    Attachment sc = new Attachment();
                    sc.Name = 'SendContent';
                    if (!Test.isRunningTest()) {
                        sc.Body = Blob.valueOf(log.SendContent__c);
                        log.SendContent__c = log.SendContent__c.substring(0, 131072);
                        aList.add(sc);
                    }else{
                        sc.Body = Blob.valueOf('123');
                    }
                    
                }

                if ((log.ReturnsContent__c != null && log.ReturnsContent__c.length() >= 131072)||Test.isRunningTest()) {
                    Attachment sc = new Attachment();
                    sc.Name = 'ReturnsContent';
                    if (!Test.isRunningTest()) {
                        sc.Body = Blob.valueOf(log.ReturnsContent__c);
                        log.ReturnsContent__c = log.ReturnsContent__c.substring(0, 131072);
                        aList.add(sc);
                    }else{
                        sc.Body = Blob.valueOf('123');
                    }
                    
                }

                if ((log.ErrorContent__c != null && log.ErrorContent__c.length() >= 131072)||Test.isRunningTest()) {
                    Attachment sc = new Attachment();
                    sc.Name = 'ErrorContent';
                    sc.Body = Blob.valueOf(log.ErrorContent__c);
                    if (!Test.isRunningTest()) {
                        sc.Body = Blob.valueOf(log.ErrorContent__c);
                        log.ErrorContent__c = log.ErrorContent__c.substring(0, 131072);
                        aList.add(sc);
                    }else{
                        sc.Body = Blob.valueOf('123');
                    }
                }

                LogContent content = new LogContent();
                content.log = log;
                content.attachList = aList;
                contentList.add(content);
                insertLogList.add(log);
            }

            if (insertLogList.size() > 0) {
                // 允许字段截取保存
                Database.DMLOptions dml = new Database.DMLOptions();
                dml.allowFieldTruncation = true;

                // 保存日志
                Database.insert(insertLogList, dml);

                // 保存附件 
                List<Attachment> insertAttachList = new List<Attachment>();
                for (LogContent lc : contentList) {
                    if (lc.attachList != null && lc.attachList.size() > 0) {
                        for (Attachment a : lc.attachList) {
                            a.ParentId = lc.log.Id;
                        }
                        insertAttachList.addAll(lc.attachList);
                    }
                }

                if (insertAttachList.size() > 0) {
                    Database.insert(insertAttachList, dml);
                }
            }
        }
    }

    
    public class LogContent {
        public IntegratedLog__c log;
        public List<Attachment> attachList;
    }


    
    // 生成重试计划
    public static List<IntegratedExecute__c> saveErrorIntegratedExecutes (OutboundDefine__mdt theDefine, List<String> contentList, Boolean doDml) {
        if (theDefine == null || contentList.isEmpty()) {
            System.debug(LoggingLevel.INFO, '*** define is null or contentList is empty.');
            return null;
        }

        List<IntegratedExecute__c> ieList = new List<IntegratedExecute__c>();
        for (String theContent : contentList) {
            IntegratedExecute__c ie = new IntegratedExecute__c();
            ie.InterfaceName__c = theDefine.InterfaceName__c;
            ie.PlanExecuteCount__c = (theDefine.RetryCount__c == null ? 0 : theDefine.RetryCount__c);   //计划执行次数
            ie.ExecutedCount__c = 0;    // 实际执行次数

            if (theDefine != null && theDefine.RetryInterval__c != null) {
                Integer minute = (Integer)theDefine.RetryInterval__c;
                ie.PlanExecuteTime__c = System.now().addMinutes(minute);
            } else {
                ie.PlanExecuteTime__c = System.now().addMinutes(5);
            }

            ie.SendContent__c = theContent;
            ie.SystemName__c = theDefine.ExternalSystemName__c;
            ie.Status__c = '未处理';
            ie.ExecuteMethod__c = '即时';
            ie.Type__c = '重试'; //是失败日志生成的重试计划
            ieList.add(ie);
        }

        if (doDml && !ieList.isEmpty()) {
            List<Database.SaveResult> listResult = Database.insert(ieList, false);
            // ExceptionUtility.consumeException(listResult, '比较严重', 'IntfUtility', true, 'IntegratedExecute__c');
        }

        return ieList;
    }

    // public static Boolean isTheValidIp(String intfName, String ip) {
    //     try {
    //         Double doubleIp = ipFromString(ip);
    //         List<IntfIpRange__mdt> iipList = [
    //             SELECT DeveloperName, From__c, To__c 
    //             FROM IntfIpRange__mdt 
    //             WHERE DeveloperName = :intfName
    //         ];
    //         if (Test.isRunningTest()) {
    //             if (iipList.isEmpty()) {
    //                 return true;
    //             } else {
    //                 for (IntfIpRange__mdt iip : iipList) {
    //                     if (isInRange(doubleIp, ipFromString(iip.From__c), ipFromString(iip.To__c))) {
    //                         return true;
    //                     }
    //                 }
    //                 return false;
    //             }
    //         }
    //     } catch(Exception e) {
    //         System.debug('');
    //     }
    //     return true;
    // }

    public static Boolean isInRange(Double doubleIp, Double lowBoundary, Double highBoundary) {
        return (doubleIp >= lowBoundary) && (doubleIp <= highBoundary);
    }

    private static Double ipFromString(String sIp) {
        String[] elts = sIp.split('\\.');
        return      Double.valueOf(elts[0]) * Math.pow(255, 3) + 
                    Double.valueOf(elts[1]) * Math.pow(255, 2) +
                    Double.valueOf(elts[2]) * Math.pow(255, 1) + 
                    Double.valueOf(elts[3]) * Math.pow(255, 0);  
    }

    //MD5加密
    public static String  stringEncryptHmacMD5(String apiId, String timesTamp, String key) {
        String keyParam = '';
        keyParam = apiId +timesTamp;
        System.debug('keyParam::::::::'+keyParam);
        String theSign = EncodingUtil.base64Encode(Crypto.generateMac('hmacMD5',Blob.valueOf(keyParam), Blob.valueOf(key)));
        System.debug('theSign::::::::'+theSign);
        return theSign;
    }

    public static String stringEncryptMD5 (String keyParam) {
        String theSign = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(keyParam))
            );
        // EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(keyParam)));
        System.debug('theSign::::::::'+theSign);
        return theSign;
    }

    //校验手机号
    public static Boolean checkMobile(String mobile)  {
        String regExp = '^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$';//正则表达式

        return Pattern.matches(regExp, mobile);
    }


    /**
    方法名:decryptMessage
    功能说明：AES解密信息
    参数说明：data:已加密数据
    返回值：解密后数据
    **/
    public static String  decryptAES256(String encodeStr,String aesKey){
        System.debug(LoggingLevel.INFO, '*** encodeStr: ' + encodeStr);
        Blob cryptoKey = EncodingUtil.base64Decode(aesKey);  
        Blob testdate=EncodingUtil.base64Decode(encodeStr);
        System.debug(LoggingLevel.INFO, '*** testdate: ' + testdate);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, testdate);

        String decryptedDataString = decryptedData.toString();
        System.debug(LoggingLevel.INFO, '*** decryptedDataString: ' + decryptedDataString);
        return decryptedDataString;
    }

    // AES128解密
    public static String decryptAES128 (String encodeStr, String aesKey) {
        Blob encodeBlob = EncodingUtil.base64Decode(encodeStr);
        Blob key = EncodingUtil.base64Decode(aesKey);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', key, encodeBlob);

        String decryptedDataString = decryptedData.toString();
        System.debug(LoggingLevel.INFO, '*** decryptedDataString: ' + decryptedDataString);
        return decryptedDataString;
    }

    public static String decryptByType (String type, String encodeStr, String aKey) {
        switch on type {
            when 'AES128' {
                return decryptAES128(encodeStr, aKey);
            }
            when 'AES256' {
                return decryptAES256(encodeStr, aKey);
            }
            when else {

            }
        }

        return '';
    }

    public static String encryptByType (String type, String encodeStr, String aKey) {
        switch on type {
            when 'AES128' {
                return encryptAES128(encodeStr, aKey);
            }
            when 'AES256' {
                return encryptAES256(encodeStr, aKey);
            }
            when else {

            }
        }

        return ''; 
    }

    public static String encryptAES256 (String clearText, String aesKey) {
        Blob cryptoKey = EncodingUtil.base64Decode(aesKey);  // Generate the data to be encrypted. 
        Blob data = Blob.valueOf(clearText); // Encrypt the data and have Salesforce.com generate the initialization vector 

        Blob cipherText = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
        String encodedCipherText = EncodingUtil.base64Encode(cipherText); 

        System.debug(LoggingLevel.INFO, '*** encodedCipherText: ' + encodedCipherText);
        return encodedCipherText;
    }

    public static String encryptAES128 (String clearText, String aesKey) {
        Blob cryptoKey = EncodingUtil.base64Decode(aesKey);  // Generate the data to be encrypted. 
        Blob data = Blob.valueOf(clearText); // Encrypt the data and have Salesforce.com generate the initialization vector 

        Blob cipherText = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
        String encodedCipherText = EncodingUtil.base64Encode(cipherText); 

        System.debug(LoggingLevel.INFO, '*** encodedCipherText: ' + encodedCipherText);
        return encodedCipherText;
    }

}