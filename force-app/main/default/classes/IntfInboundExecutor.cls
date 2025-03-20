/**********************************************************************
*Name：提供外部调用接口执行类
*Description：
将公共逻辑放到统一的地方处理，减少整体代码复杂度，方便后续维护
======================================================
History                                                            
-------                                                            
    VERSION  AUTHOR          DATE            DETAIL                
    1.0      lijun        2020-02-17         Created

***********************************************************************/ 
public with sharing class IntfInboundExecutor {

    public IntfInboundData theData {get;set;}
    public IntfInboundBase baseClass {get;set;}
    public InboundDefine__mdt theDefine {get;set;}
    public IntegratedLog__c theLog {get;set;}


    public IntfInboundExecutor(String intfName, String bodyStr, IntegratedLog__c log) {

        if (intfName == null) {
            throw new IntfException('The Interface name is not exist.');
        }

        theLog = log;
        
        theDefine = IntfUtility.getInboundDefineByName(intfName);
        System.debug(LoggingLevel.INFO, '*** bodyStr: ' + bodyStr);
        Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(bodyStr);

        if(String.isNotBlank(theDefine.DataListName__c)
            && !jsonMap.containsKey(theDefine.DataListName__c)){
            throw new IntfException('Data structure error.'); 
        }
        
        IntfInboundData inboundData = initInboundData(bodyStr,theDefine.DataListName__c);
        

        if (theDefine == null) {
            throw new IntfException('The Interface name is not exist.');
        }

        if ((theDefine.NoNeedLogin__c == null || !theDefine.NoNeedLogin__c)
            && theLog.InvokeSession__c == null ) {
            throw new IntfException('Please login first.');
        }

        inboundData.theDefine = theDefine;
        inboundData.theIntfName = intfName;
        theData = inboundData;
    }

    public IntfInboundResult execute(){

        theLog.InterfaceName__c = theDefine.MasterLabel;
        theLog.ExecuteClass__c = theDefine.ExecuteClass__c;
        theLog.ExecuteLog__c = '';
        theLog.SystemName__c = theDefine.ExternalSystemName__c;
        if (theDefine.LogExpiryDate__c != null) {
            theLog.LogExpiryDate__c = Date.today().addDays(Integer.valueOf(theDefine.LogExpiryDate__c)); 
        }
        System.debug('theDefine::::' + theDefine);

        // 是否自动对象
        // if (theDefine.IsAutoBuildObject__c
        //     && String.isNotBlank(theDefine.MapConfigName__c)
        //     && String.isNotBlank(theDefine.MapConfigObjectName__c)
        // ) {
        //     IntfFieldMappingUtil fieldMapUtil = new IntfFieldMappingUtil(theDefine.IntfFieldMapping__c);

        //     // 'Order__c', 'OAS_Orders'
        //     fieldMapUtil.toSobject(theData.DATA, theDefine.MapConfigName__c, theDefine.MapConfigObjectName__c);
        //     theData.errorMap = fieldMapUtil.allResult.errorMap;
        //     theData.allData = fieldMapUtil.allResult.allData;
        //     theData.invalidData = fieldMapUtil.allResult.invalidData;

        //     theData.fieldMap = fieldMapUtil.fieldMap;

        //     theLog.ExecuteLog__c += '自动构建对象结果集： \n';
        //     theLog.ExecuteLog__c += ' invalidData : ' + JSON.serialize(theData.invalidData);
        //     theLog.ExecuteLog__c += ' allData : ' + JSON.serialize(theData.allData);
        //     theLog.ExecuteLog__c += ' errorMap : ' + JSON.serialize(theData.errorMap); 
        // }


        // 执行业务逻辑
        String clsName = theDefine.ExecuteClass__c;
        if (String.isBlank(clsName)){
            theLog.ExecuteLog__c += '【无可执行类】\n' + JSON.serialize(theDefine);

            throw new IntfException('not matching the api define.');
        }

        System.debug(LoggingLevel.INFO, '*** clsName: ' + clsName);

        Type t = Type.forName(clsName);
        baseClass =  (IntfInboundBase)t.newInstance();

        System.debug(LoggingLevel.INFO, '*** theData: ' + theData);
        IntfInboundResult result = baseClass.execute(theData);

        //TODO 如果内容过大，则用附件来保存
        // theLog.ReturnsContent__c = JSON.serialize(result);
        theLog.ExecuteLog__c += baseClass.debugLog;

        if (result.code != 200) {
            setErrorResponse(result);
        }
        return result;
    }




    // 获取业务请求信息
    public IntfInboundData initInboundData (String bodyStr, String  dataListName) {
        IntfInboundData inboundData = new IntfInboundData();
            

 
        try{
            Map<String,Object> jsonMap = (Map<String,Object>)JSON.deserializeUntyped(bodyStr);

            // 判断是否需要解密
            if (theDefine.NeedEncode__c 
                && String.isNotBlank(theDefine.EncodeType__c) 
                && String.isNotBlank(theDefine.EncodeKey__c)) {
                
                if(jsonMap.containsKey(dataListName)){
                    String encryStr = String.valueOf(jsonMap.get(dataListName));
                    String decryBodyStr = IntfUtility.decryptByType(theDefine.EncodeType__c, encryStr, theDefine.EncodeKey__c);

                    // 日志中保存解密结果
                    theLog.ReqBodyBeforeDecrypt__c = bodyStr;
                    theLog.SendContent__c = decryBodyStr;
                    bodyStr = decryBodyStr;
                }  
            }
            
            // initCommonLogField(jsonMap, log);
            System.debug(LoggingLevel.INFO, '***initInboundData jsonMap: ' + jsonMap);
            
            if (jsonMap.containsKey(dataListName)) {
                Object value = jsonMap.get(dataListName);
                String dataJson = JSON.serialize(value);
                inboundData.dataStr = dataJson;
                inboundData.DATA = value;
            }

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, '*** (' + e.getLineNumber() + '): ' + e.getMessage());

            //该json 没有head 和 data 信息
            inboundData.dataStr = bodyStr;
            // inboundData.DATA = JSON.deserializeUntyped(bodyStr);
        }
        return inboundData;
    }


    public void setErrorResponse (IntfInboundResult result) {
        if (theData.errorMap == null || theData.errorMap.keySet().isEmpty()) {
            return;
        }

        List<Map<String, String>> errorList = new List<Map<String, String>>();
        for (String key : theData.errorMap.keySet()) {
            String error = theData.errorMap.get(key);
            Map<String, String> aItem = new Map<String, String>();
            aItem.put('key', key);
            aItem.put('msg', error);
            errorList.add(aItem);
        }

        result.data = errorList;
        result.msg = IntfUtility.INTEGRATEDLOG_RESULTS_FAIL; //'失败';
        result.code = 400;
    }

    // save upsert error
    public static void saveUpsertErrorResult (List<Database.UpsertResult> upsertResults,  String keyFieldValue, List<Sobject> invalidList, IntfInboundData inboundData) {
        // 保存错误结果
        Integer index = 0;
        for (Database.UpsertResult areslut : upsertResults) {
            if (areslut.isSuccess()) {
                continue;
            }

            Sobject aItem = invalidList[index];
            String keyValue = String.valueOf(aItem.get(keyFieldValue));
            System.debug(LoggingLevel.INFO, '*** areslut.getErrors(): ' + areslut.getErrors());

            String errorMsg = areslut.getErrors()[0].getMessage();
            if (inboundData.errorMap.containsKey(keyValue)) {
                errorMsg += inboundData.errorMap.get(keyValue);
            }

            inboundData.errorMap.put(keyValue, errorMsg);
            index++;
        }
    }
}