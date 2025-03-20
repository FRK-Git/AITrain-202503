/**********************************************************************
*Name：提供外部调用的基础处理类，所有的接口类都应该实现此方法
*Description：
提供外部调用的基础处理类，所有的接口类都应该实现此方法
======================================================
History                                                            
-------                                                            
	VERSION  AUTHOR          DATE            DETAIL                    
	1.0      lijun        2020-02-17         Created

***********************************************************************/ 
public virtual class IntfInboundBase 
{
    public String debugLog = '';
    public virtual IntfInboundResult execute(IntfInboundData data) {
        return null;
    }

    public virtual Map<String, String> getCheckMap(IntfInboundData data)
    {
        return null;
    }

    // public virtual IntfInboundResult asyncCallExecute(IntfInboundData data)
    // {
    //     return null;
    // }

    public void recordLog(String log)
    {
        debugLog = debugLog + log + '\r\n';
    }

}