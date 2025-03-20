/**********************************************************************
*Name：调用外部接口的执行类
*Description：
将公共逻辑放到统一的地方处理，减少整体代码复杂度，方便后续维护
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR          DATE            DETAIL                    
1.0      lijun        2020-02-17         Created

***********************************************************************/ 
public with sharing class IntfOutboundExecutor 
{
    //将接口的各种参数配置在OutboundDefine__mdt中，方便修改
    public OutboundDefine__mdt theDefine {get;set;}
    public String dataStr {get;set;}
    public IntegratedLog__c theLog {get;set;}
    public IntfOutboundData param {get;set;}

    public IntfOutboundExecutor(String interfaceName, IntfOutboundData param)
    {
        theDefine = IntfUtility.getOutboundDefineByName(interfaceName);
        if (theDefine == null) {
            throw new IntfException('The Interface name is not exist.');
        }

        theLog = new IntegratedLog__c();
        theLog.InterfaceName__c = theDefine.MasterLabel;
        theLog.ExecuteClass__c = theDefine.ExecuteClass__c;
        theLog.Type__c = IntfUtility.INTEGRATEDLOG_TYPE_CALL_OUT; // '出站';
        theLog.GeneratedTime__c = System.now();
        theLog.OutboundDefineName__c = theDefine.Label;
        theLog.SystemName__c = theDefine.ExternalSystemName__c;
        theLog.ErrorContent__c = '';
        theLog.ExecuteLog__c = '';

        if(theDefine.LogExpiryDate__c!=null)
        {
          theLog.LogExpiryDate__c = Date.today().addDays(Integer.valueOf(theDefine.LogExpiryDate__c)); 
        }
        
       
        param.theDefine = theDefine;

        // 是否重试，默认配置的重试设置
        param.needRetry = theDefine.IsNeedRetry__c;
        // theLog.SendContent__c = dataStr;
        this.param = param;

    }

    public Object execute(Boolean saveLog) {

        String clsName = theDefine.ExecuteClass__c;
        System.debug('clsName : ' + clsName);
        System.debug('theDefine:::'+theDefine);
        System.debug('param:::'+param);
        Type t = Type.forName(clsName);
        IntfOutboundBase outBase = (IntfOutboundBase)t.newInstance();

        if(theDefine.InterfaceType__c == 'REST'){
            String url = theDefine.Url__c;
            Integer timeout = 120000;   // 2min
            String contentType = 'application/json;charset=utf-8';

            if (theDefine.CalloutContentType__c != null) {
                contentType = theDefine.CalloutContentType__c;
            }

            if (theDefine.CalloutTimeout__c != null) {
                timeout = theDefine.CalloutTimeout__c.intValue();
            }
            

            try {
                Http http = new Http();
                HttpRequest req = new HttpRequest();

                req.setMethod(theDefine.CalloutMethod__c);
                req.setTimeout(timeout);

                req.setEndpoint(url);
                req.setHeader('Content-Type', contentType);
                req.setHeader('charset', 'utf-8');

                // 初始化数据
                outBase.http = http;
                outBase.request = req;
                outBase.response = null;

                param.requestHeader.put('Content-Type', contentType);
                param.requestHeader.put('charset', 'utf-8');
                param.calloutLog = theLog;

                // 执行具体类的callout操作，保存callout结果
                param.calloutResult = outBase.callout(param);

            } catch (Exception e) {
                String message = '(' + e.getLineNumber() +')' + e.getMessage() + '\n' +  e.getStackTraceString();
                System.debug('error:::::' + message);

                theLog.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_FAIL; //'失败';
                param.isSuccess = false;
                theLog.ErrorContent__c += message;
            }

            // 保存http基本信息
            theLog.HeaderContent__c = Json.serialize(param.requestHeader);
            theLog.ReturnsContent__c = param.responseBody;
            theLog.URI__c = outBase.request.getEndpoint();
            theLog.SendContent__c = param.requestBody;
            theLog.ExecuteLog__c += '【sourcedata】: ' + param.sourceData + '\n\n';
                                  // + '【requestBody】: ' + param.requestBody + '\n\n';

            // 如果是需要有加密需求
            if (param.theDefine.NeedEncode__c) {
                String reqBody = outBase.request.getBody();
                theLog.ReqBodyBeforeDecrypt__c = reqBody;
            }

            // 保存response信息
            if (outBase.response != null) {
                // 如果是需要有加密需求
                if (param.theDefine.NeedEncode__c) {
                    String resBody = outBase.response.getBody();
                    theLog.RespBodyAfterEncrypt__c = resBody;
                }
            }

        }else if(theDefine.InterfaceType__c == 'SOAP'){
            

            try {
                param.calloutLog = theLog;

                // 执行具体类的callout操作，保存callout结果
                param.calloutResult = outBase.callout(param);

            } catch (Exception e) {
                String message = '(' + e.getLineNumber() +')' + e.getMessage() + '\n' +  e.getStackTraceString();
                System.debug('error:::::' + message);

                theLog.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_FAIL; //'失败';
                param.isSuccess = false;
                theLog.ErrorContent__c += message;
            }

            // 保存http基本信息
            theLog.ReturnsContent__c = param.responseBody;
            theLog.SendContent__c = param.requestBody;  
        }

        
        
        

        // 判断成功失败
        if (param.isSuccess) {
            theLog.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_SUCCESS; //'成功';
        } else {
             if (String.isNotBlank(theDefine.SucessFlag__c)
                && String.isNotBlank(param.responseBody)
                && param.responseBody.contains(theDefine.SucessFlag__c)
            ) {
                theLog.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_SUCCESS; //'成功';
                param.isSuccess = true;
            } else {
                theLog.Results__c = IntfUtility.INTEGRATEDLOG_RESULTS_FAIL; //'失败';
            }
        }

        // 是否需要重试, 需要就新建调用计划
        System.debug('需要重试 theDefine.IsNeedRetry__c::::' + param.needRetry);
        if (param.needRetry) {
            // 处理错误数据，将其处理成请求内容的格式，保存至重试计划调用中, 默认返回JSON.serialize(param.data);
            String contentobj = '';
            if (theLog.Results__c == IntfUtility.INTEGRATEDLOG_RESULTS_FAIL) {
                contentobj = outBase.errorResultHandle(param);
            }

            setIntegratedExecute(theDefine, param, contentobj);
        }

        // System.debug('本次日志:::'+theLog);
        param.logList.add(theLog);

        // if (doAfter) {
        //     param.calloutResult = outBase.afterCallOut(param);
        // }

        if (saveLog) {
            if (!param.intfExecuteList.isEmpty()) {
                System.debug(LoggingLevel.INFO, '*** param.intfExecuteList: ' + param.intfExecuteList);
                upsert param.intfExecuteList;

                // 保存调用计划和日志的关联关系
                theLog.IntegratedExecute__c = param.intfExecuteList[0].Id;
            }

            if (!param.logList.isEmpty()) {
                IntfUtility.insertLog(param.logList);
            }
        }

        // System.debug(LoggingLevel.INFO, '*** param.calloutResult: ' + param.calloutResult);
        return param.calloutResult;
    }

    // 生成重试调用计划
    public void setIntegratedExecute(OutboundDefine__mdt theDefine, IntfOutboundData param, String nextContent) {
        // 当参数里面没有执行计划时，新建
        System.debug(LoggingLevel.INFO, '*** param.intfExecuteList.size(): ' + param.intfExecuteList.size());

        // 失败，且没有重试计划，需要新建重试
        if (param.calloutLog.Results__c == IntfUtility.INTEGRATEDLOG_RESULTS_FAIL 
            && param.intfExecuteList.isEmpty()) {
            List<String> contents = new List<String>{nextContent};

            List<IntegratedExecute__c> errorIEs = IntfUtility.saveErrorIntegratedExecutes(theDefine, contents, false);
            param.intfExecuteList.addAll(errorIEs);

            param.calloutLog.HasIntegratedExecute__c = TRUE;
        } else if (!param.intfExecuteList.isEmpty()) {
            // 参数中有执行计划调用时，表示是由计划触发的，只需要改变计数以及更新下次计划时间
            IntegratedExecute__c ie = param.intfExecuteList[0];
            ie.ExecutedCount__c += 1;
            ie.CalloutStatus__c = param.calloutLog.Results__c;

            if (param.calloutLog.Results__c == IntfUtility.INTEGRATEDLOG_RESULTS_SUCCESS) {
                ie.Status__c = IntfUtility.INTEGRATEDEXECUTE_STATUS_FINISHED; //'完成';
            } else {
                // 失败，判断执行次数是否已经达标， 达标且最后执行依旧失败就发送邮件通知管理员
                if (ie.ExecutedCount__c >= ie.PlanExecuteCount__c) {
                    /*需要邮件通知管理员*/
                    System.debug(LoggingLevel.INFO, '*** 需要邮件通知管理员！ ');
                    ie.AlertAdmin__c = true;
                    ie.Status__c = IntfUtility.INTEGRATEDEXECUTE_STATUS_FINISHED; //'完成';

                    String body = 'IntegratedExecute: ' +  URL.getSalesforceBaseUrl().toExternalForm() + '/' + ie.Id
                                + '\n\n'
                                + '【报错内容】：' + param.calloutLog.ErrorContent__c;

                    Utility4Email.sendEmailToAdmin('The retry planning failed', body,IntfUtility.ADMIN_REMINDER_EMAIL);
                } else {
                    // 执行次数未达标， 按执行频率设置下一次执行时间
                    if (theDefine != null && theDefine.RetryInterval__c != null) {
                        Integer minute = (Integer)theDefine.RetryInterval__c;
                        ie.PlanExecuteTime__c = System.now().addMinutes(minute);
                    } else {
                        ie.PlanExecuteTime__c = System.now().addMinutes(5);
                    }

                    ie.Status__c = IntfUtility.INTEGRATEDEXECUTE_STATUS_EXECUTED; // '执行结束';
                }
            }

            System.debug(LoggingLevel.INFO, '***调用结果 ie: ' + ie);
        }
    }
}