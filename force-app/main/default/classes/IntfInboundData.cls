/**********************************************************************
*Name：外部调用的基础参数类
*Description：

======================================================
History                                                            
-------                                                            
	VERSION  AUTHOR          DATE            DETAIL                    
	1.0      lijun        2020-02-17         Created

***********************************************************************/ 
global virtual class IntfInboundData 
{
    public String theIntfName;
    public InboundDefine__mdt theDefine;

    public List<Sobject> dataList;
    public Map<String, List<List<Sobject>>> dataMap;
    public String dataStr; //具体业务数据Json, 值与DATA一致

    public Object DATA; //具体业务数据
    public Map<String, String> errorMap = new Map<String, String>();  // 错误集合

    // 使用自动构建
    public Map<String, List<Sobject>> allData = new Map<String, List<Sobject>>();  //自动构建结果集
    public Map<String, List<Sobject>> invalidData = new Map<String, List<Sobject>>();  //自动构建的有效结果集
    // public IntfFieldMappingUtil.InterfaceFeildModel fieldMap;

    
}