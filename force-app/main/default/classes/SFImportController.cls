/**********************************************************************
 名    称：SFImportController
 目    的：导入页面控制类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-03-20
 备    注：
**********************************************************************/
global without sharing class SFImportController {

    //导入模板路径
    public String templateUrl {GET; SET;}

    // 上传的数据
    public String output {GET; SET;}

    // 成功的表头信息
    public String headerJson {GET; SET;}

    //上传文件对应的对象名
    public String sourceName {GET; SET;}

    // 导入模板名称
    public String importFile {GET; SET;}

    // 导入数量限制
    public String limitNumber {GET; SET;}

    // 导入的表头读取行数
    public Integer dataStartRow {GET; SET;}

    // 页面标头
    public String pageTitle {GET; SET;}

    // 允许部分更新
    public Boolean allowPartialUpdate {GET; SET;}

    // 成功数据集合
    public List<SObject> successList {GET; SET;}

    public SFImportController() {

        // 获得自定义数据设置名称
        this.sourceName = ApexPages.currentPage().getParameters().get('sourceName');

        if (String.isBlank(this.sourceName)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IMPORT_ERROR_PAGE_PARAMETER));
            return;
        }

        // 生成数据导入解析器
        SFImportConvertor convertor = new SFImportConvertor(this.sourceName);

        // 获得导入模板文件(Excel)URL
        this.templateURL = convertor.TemplateURL;

        // 表头信息
        this.headerJson = JSON.serialize(convertor.HeaderList);

        this.pageTitle = convertor.PageTitle;
        this.allowPartialUpdate = convertor.BaseConfig.AllowPartialUpdate;
        this.dataStartRow = Integer.valueOf(convertor.BaseConfig.StartRow);
        this.limitNumber = String.format(Label.IMPORT_LIMITNUMBER, new List<String>{String.valueOf(convertor.BaseConfig.LimitNumber)});

        System.debug(LoggingLevel.INFO, '*** convertor.dataStartRow: ' + convertor.BaseConfig.StartRow);
        System.debug(LoggingLevel.INFO, '*** this.headerJson: ' + this.headerJson);
    }

    /*
        方法名: upload
        功能说明:初步解析文件：判断导入表是否正确，以及数量是否超额
        参数说明：selected 选择的操作类型(更新，删除，导入); sourceName 对象名; importTable 上传文件名; PrentId 父对象Id; output 上传的数据;
        返回值：String
    */
    @RemoteAction 
    global static String upload(String sourceName, String importTable, String output) {

        System.debug(LoggingLevel.INFO, '*** output: ' + output);

        // 生成数据导入解析器
        SFImportConvertor convertor = new SFImportConvertor(sourceName);
        SFImportInfo importInfo  = new SFImportInfo();

        //初步解析文件：判断导入表是否正确，以及数量是否超额
        if (output == null) {
            importInfo.ErrorMessage = Label.FILE_NULL_DATA;
            return JSON.serialize(importInfo);
        }

        try {

            // Excel内容
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(output);

            // 保存Excel中第一个sheet的数据
            List<Object> jsonList;

            if (jsonMap.size() > 0) {

                jsonList = (List<Object>)jsonMap.values()[0];

            } else if (jsonMap == null || jsonMap.size() == 0) {

                importInfo.ErrorMessage = Label.FILE_NULL_DATA;
                return JSON.serialize(importInfo);

            } else {

                importInfo.ErrorMessage = String.format(Label.FIND_NOT_SHEET, new List<String>{importTable});
                return JSON.serialize(importInfo);

            }

            // 无数据
            if (jsonList == null || jsonList.size() < convertor.BaseConfig.StartRow) {
                importInfo.ErrorMessage = Label.SHEET_NOT_DATA;
                return JSON.serialize(importInfo);
            }

            // 超出单次导入数据最大值
            if (jsonList.size() >= convertor.BaseConfig.LimitNumber) {
                importInfo.ErrorMessage = String.format(Label.OVER_LINE_LIMIT, new List<String>{String.valueOf(convertor.BaseConfig.LimitNumber)});
                return JSON.serialize(importInfo);
            }

            // 导入文件解析并进行逻辑处理后，输出程序验证的错误结果，并把正确的部分获得出来
            importInfo = convertor.Convert(jsonList);

        } catch(Exception e) {

            System.debug(e.getMessage() + '\n【错误行号: ' + e.getLineNumber() + '】\n' + e.getStackTraceString());

            importInfo.ErrorMessage = String.format(Label.IMPORT_SYSTEM_ABNORMALITY, new List<String>{e.getMessage() + e.getStackTraceString(), String.valueOf(e.getLineNumber())});
        }

        return JSON.serialize(importInfo);
    }

    /*
        方法名: Save
        功能说明:调用保存方法
        参数说明：sourceName 资源名;
                 sucessData 成功的SObject对象数据; Map<String, Map<Integer, Sobject>>
                 originalData 原始数据信息; List<SFImportRow>
        返回值：String - SFImportInfo的序列化字符串
    */
    @RemoteAction 
    global static String Save(String sourceName, String sucessData, String originalData) {

        // 生成数据导入解析器
        SFImportConvertor convertor = new SFImportConvertor(sourceName);

        System.debug(LoggingLevel.INFO, '*** sucessData: ' + sucessData);
        System.debug(LoggingLevel.INFO, '*** originalData: ' + JSON.serializePretty(originalData));

        //记录成功的数据行
        List<SFImportRow> successList = (List<SFImportRow>)JSON.deserialize(sucessData, List<SFImportRow>.class);
        Set<Integer> successIndexSet = new Set<Integer>();
        for (SFImportRow row : successList) {
            successIndexSet.add(row.RowIndex);
        }

        // 对于不在成功行中的数据，移除它
        Map<String, Map<Integer, Sobject>> originalDataMap = (Map<String, Map<Integer, Sobject>>)JSON.deserialize(originalData, Map<String, Map<Integer, Sobject>>.class);
        for (String sobjectName : originalDataMap.keySet()) {
            Map<Integer, Sobject> tmpList = originalDataMap.get(sobjectName);
            for (Integer index : tmpList.keySet()) {
                if (!successIndexSet.contains(index)) {
                    tmpList.remove(index);
                }
            }
        }
        SFImportInfo importInfo = convertor.ImportDML(originalDataMap, successList);

        System.debug(LoggingLevel.INFO, '*** importInfo.ErrorList(Save): ' + importInfo.ErrorList);

        return JSON.serialize(importInfo);
    }
}