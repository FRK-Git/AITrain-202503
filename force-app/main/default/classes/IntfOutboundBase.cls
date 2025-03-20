/**********************************************************************
*Name：调用外部接口的基础处理类，所有的接口类都应该实现此方法
*Description：
调用外部接口的基础处理类，所有的接口类都应该实现此方法
======================================================
History                                                            
-------                                                            
VERSION  AUTHOR          DATE            DETAIL                    
1.0      lijun        2020-02-17         Created

***********************************************************************/ 
public virtual class IntfOutboundBase 
{
    public Http http;
    public HttpRequest request;
    public HTTPResponse response;

    public virtual Object callout(IntfOutboundData param)
    {
        return null;
    }


    // 处理错误数据，将其处理成请求内容的格式，保存至重试计划调用中
    public virtual String errorResultHandle (IntfOutboundData param) {
        // 默认返回请求数据源
        return param.sourceData;
    }

    /**
    dml语句放在此方法中执行
    **/
    // public virtual Object afterCallOut(IntfOutboundData param)
    // {
    //     return null;
    // }

    // public virtual Object asyncCall(IntfOutboundData param)
    // {
    //     return null;
    // }
}