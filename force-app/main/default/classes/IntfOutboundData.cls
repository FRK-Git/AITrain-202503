/**********************************************************************
*Name：调用外部系统接口的基础参数类
*Description：

======================================================
History                                                            
-------                                                            
    VERSION  AUTHOR          DATE            DETAIL                    
    1.0      lijun        2020-02-17         Created

***********************************************************************/ 
global virtual class IntfOutboundData 
{
   
    public String interfaceName;    // 定义的接口名
    public OutboundDefine__mdt theDefine;    // 接口定义

    public String soapAction;     // SOAP 操作类型
    public String queryType;      // SOAP 查询类型
    public String sqlType;        // SOAP SQL类型
    public Integer timeOut;        // SOAP SQL类型
    
    public String sourceData;     // 需要处理的数据源Json
    public Object requestBodyObj; // 实际请求数据(非加密前)
    public String requestBody;    // 实际请求数据(非加密前)Json
    public Map<String, String> requestHeader = new Map<String, String>(); // 实际请求头文件

    public String responseBody; // 返回结果(实际请求的结果，如果需要解密，就保存解密后的结果)
    public Integer responseHttpCode; // 返回HttpCode
    public Boolean isSuccess = false;

    // 是否重试：默认接口元数据定义
    public Boolean needRetry = false;
    public Object calloutResult;    // callout方法的返回的业务逻辑
    public String method; //请求方式

    public String pageSize;//每页数据大小
    public String pageNum;//第几页
    public String keyword;//关键词
   


    public List<IntegratedLog__c> logList = new List<IntegratedLog__c>();    //所有需要保存的日志

    public List<IntegratedExecute__c> intfExecuteList = new List<IntegratedExecute__c>();

    public IntegratedLog__c calloutLog;    // 当前callout的日志

}