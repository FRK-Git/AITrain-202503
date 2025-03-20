/**********************************************************************
 名    称：SFImportBaseConfig
 目    的：导入基础配置信息类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-03-22
 备    注：
**********************************************************************/
public with sharing class SFImportBaseConfig {

    // Excel中数据总列数(从第A列开始，中间不可有空列)
    public Integer TotalColumns {GET; SET;}

    // Excel中数据开始行位置
    public Integer StartRow {GET; SET;}

    // Excel中表头所在行位置
    public Integer HeaderRow {GET; SET;}

    // 允许数据部分更新到数据库
    public Boolean AllowPartialUpdate {GET; SET;}

    // 导入数据时忽略验证规则
    public Boolean IgnoreValidation {GET; SET;}

    // 导入数据时忽略接口调用
    public Boolean IgnoreInterface {GET; SET;}

    // 导入数据时忽略工作流
    public Boolean IgnoreWorkflow {GET; SET;}

    // 导入数据时忽略触发器
    public Boolean IgnoreTrigger {GET; SET;}

    // 单次导入数量限制
    public Integer LimitNumber {GET; SET;}

    // 记录类型设置
    public Map<String, String> RecordType {GET; SET;}
}