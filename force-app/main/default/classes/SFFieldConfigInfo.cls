/**********************************************************************
 名    称： SFFieldConfigInfo
 目    的： 接口或导入时的字段配置信息类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-01-30
 备    注：
 **********************************************************************/
public with sharing class SFFieldConfigInfo {

    // 导入时对应的Excel列名，如(A,B,C....)
    public String MappingColumn {GET; SET;}

    // 导入时对应的Excel列标头文本
    public String HeaderText {GET; SET;}

    // 字段Api名称
    public String ApiName {GET; SET;}

    // 数据类型为（Lookup,String,Decimal,Date,Datetime,Mapping,Boolean,RecordType,Picklist,MultiPicklist)
    public String DataType {GET; SET;}

    // Lookup数据类型时，原对象中的关系名称
    public String RelationName {GET; SET;}

    // Lookup数据类型时的查找对象
    public String SObjectName {GET; SET;}

    // Lookup数据类型时,接收数据指向的SObjectName中的字段Api名称
    public String ForeignKey {GET; SET;}

    // Lookup数据类型时,接收数据指向的SObjectName中的字段的数据类型
    public String FKDataType {GET; SET;}

    // 字段是否需要格式化(导入或接收数据时表示是否需要对数据进行转换)
    public Boolean NeedFormatted {GET; SET;}

    // 格式字符串(NeedFormatted=true)
    public String FormatString {GET; SET;}

    // 默认值
    public String DefaultValue {GET; SET;}

    // 是否必填
    public Boolean IsRequired {GET; SET;}

    // 必填依赖字段名称(接口时为字段api名称，导入时为字段对应的Excel列名:A,B,C...)
    public String IsRequiredFor {GET; SET;}

    // 当依赖字段为下列值时,此字段必须有值,不同的值用分号(;)分开
    public String IsRequiredForValues {GET; SET;}
}

/*
{
    "Opportunity":
    {
        "Name":
        {
            "MappingColumn":"A",
            "HeaderText":"姓名",
            "ApiName":"Name",
            "DataType":"String",
            "RelationName":"Account",
            "SObjectName":"Opportunity",
            "ForeignKey":"",
            "NeedFormatted":false,
            "FormatString":"yyyy-MM-dd",
            "DefaultValue":"false",
            "IsRequired":"true"
        }
    }
}
*/