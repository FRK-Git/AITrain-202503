/**********************************************************************
 名    称：SFImportConvertor
 目    的：导入映射类
 作    者：kit.liu(liuwenjun@bluelinksys.com)
 创建日期：2019-03-22
 备    注：
**********************************************************************/
public without sharing class SFImportConvertor {

    // 自定义设置对象
    public Excel_Import_Config__mdt ImportConfig {GET; SET;}

    // 字段配置信息
    public Map<String, SFFieldConfigInfo> FieldConfigMap {GET; SET;}

    //导入输出结构
    public SFImportInfo ExportInfo {GET; SET;}

    // 基础配置信息
    public SFImportBaseConfig BaseConfig {GET; SET;}

    // 下载模板URL
    public String TemplateURL {GET; SET;}

    // 表头
    public List<SFFieldConfigInfo> HeaderList {GET; SET;}

    // 页面显示标题头
    public String PageTitle {GET; SET;}

    //获得下拉列表字段以及对应值(Sobject-FieldApiName-OptionLabel-OptionApi)
    Map<String, Map<String, Map<String, String>>> pickValuesMap;

    //导入配置API名称
    String sourceName;

    // 用于记录已进入执行DML操作的sobject，在Excel中对应行数的错误信息
    Map<Integer, String> errinfoMap;

    // 列映射对象字段映射关系
    Map<String, Set<String>> importSobjectColumnMap;

    // 数据保存顺序
    Set<String> importSaveOrderSet;

    // 记录类型Map，key-对象名称，value-记录类型DeveloperName
    Map<String, String> recordTypeMap;

    // 自定义验证类名
    List<String> validateClassNameList;

    // 数据保存前的预处理类名
    List<String> preProcessClassNameList;

    // 对象查找关系
    Map<String, Map<String, String>> importLookupRelationalMap;

    /*
        构造函数
        功能说明: 通过配置API名称获取配置信息
        参数说明: sourceName - 导入配置API名称
    */
    public SFImportConvertor(String sourceName) {

        this.sourceName = sourceName;
        this.ExportInfo = new SFImportInfo();
        this.errinfoMap = new Map<Integer, String>();
        this.validateClassNameList = new List<String>();
        this.preProcessClassNameList = new List<String>();

        // 获取导入表对应的元数据设置
        this.ImportConfig =  SFUtility.getImportConfig(sourceName);

        // 记录类型将集合
        this.recordTypeMap = new Map<String, String>();

        // 基础设置
        this.BaseConfig = (SFImportBaseConfig)JSON.deserialize(this.ImportConfig.BaseConfig__c, SFImportBaseConfig.class);
        //System.debug(LoggingLevel.INFO, '*** spacial - BaseConfig: ' + this.BaseConfig);

        // 下载模板URL
        this.TemplateURL = PageReference.forResource(this.ImportConfig.TemplateName__c, '').getUrl();

        // 页面显示标题头
        this.PageTitle = this.ImportConfig.PageTitle__c;

        // 对象查找关系设置
        this.importLookupRelationalMap = new Map<String, Map<String, String>>();
        if (!String.isBlank(this.ImportConfig.RelationalConfig__c)) {
            this.importLookupRelationalMap = (Map<String, Map<String, String>>)JSON.deserialize(this.ImportConfig.RelationalConfig__c, Map<String, Map<String, String>>.class);
        }

        // 自定义验证类名
        if (!String.isBlank(this.ImportConfig.validateClass__c)) {
            this.validateClassNameList = this.ImportConfig.validateClass__c.split(';');
        }

        // 数据预处理类名
        if (!String.isBlank(this.ImportConfig.PreProcessClass__c)) {
            this.preProcessClassNameList = this.ImportConfig.PreProcessClass__c.split(';');
        }

        // 如果有记录类型配置，先取到并保存记录类型ID，供后面使用
        if (this.BaseConfig != null && this.BaseConfig.RecordType != null && this.BaseConfig.RecordType.size() > 0) {
            for (String sobjectName : this.BaseConfig.RecordType.keySet()) {
                String recordDevName = this.BaseConfig.RecordType.get(sobjectName);
                String recordId = SFUtility.getRecordTypeId(recordDevName, sobjectName);
                this.recordTypeMap.put(sobjectName, recordId);
            }
        }

        // 字段配置信息
        this.FieldConfigMap = (Map<String, SFFieldConfigInfo>)JSON.deserialize(this.ImportConfig.FieldConfig__c, Map<String, SFFieldConfigInfo>.class);

        // 对象和列对应关系
        this.importSobjectColumnMap = (Map<String, Set<String>>)JSON.deserialize(this.ImportConfig.SobjectColumns__c, Map<String, Set<String>>.class);

        // 对象保存顺序
        this.importSaveOrderSet = (Set<String>)JSON.deserialize(this.ImportConfig.SaveOrdering__c, Set<String>.class);

        // 表头
        this.HeaderList = this.FieldConfigMap.values();

        /*
            记录哪些对象有选项列表字段，并得到对象及对应的Picklist字段集合
            Picklist字段集合Map<key-对象名API名称,value-List<选项列表字段API名称>>
        */
        Map<String, List<String>> picklistMap = new Map<String, List<String>>();
        for (String sobjectApiName : this.importSobjectColumnMap.keySet()) {
            for (SFFieldConfigInfo fc : this.HeaderList) {
                if (this.importSobjectColumnMap.get(sobjectApiName).contains(fc.HeaderText) &&
                   (fc.DataType.toLowerCase() == 'picklist' || 
                    fc.DataType.toLowerCase() == 'multipicklist')) {

                    if (picklistMap.containsKey(sobjectApiName)) {
                        picklistMap.get(sobjectApiName).add(fc.ApiName);
                    } else {
                        picklistMap.put(sobjectApiName, new List<String>{fc.ApiName});
                    }

                }
            }
        }

        // 通过Schema获取选项列表值
        this.pickValuesMap = SFUtility.getSchemaPickValuesMap(picklistMap);
    }

     /*
        方 法 名: Convert
        功能说明: 导入文件解析并进行逻辑处理后，输出程序验证的错误结果，并把正确的部分获得出来，进行第二轮的数据库校验。
        参数说明：jsonList - Excel数据行集合
        返 回 值：SFImportInfo
     */
    public SFImportInfo Convert(List<Object> jsonList) {

        Map<Integer, Map<String, String>> kmiDataMap = new Map<Integer, Map<String, String>> ();

        System.debug(LoggingLevel.INFO, '*** 要导入的源数据: ' + JSON.serializePretty(jsonList));

        /*
            保存转化后的数据
            Map<key-对象名, valueMap<key-行数,value-对象实例数据>>
        */
        Map<String, Map<Integer, SObject>> excelDataMap = new Map<String, Map<Integer, SObject>>();
        for (String sobjectApiName : this.importSobjectColumnMap.keySet()) {
            excelDataMap.put(sobjectApiName, new Map<Integer, SObject>());
        }

        // 对要导入的数据进行数据有效性和完整性检测
        List<SFImportRow> rowsList = this.dataIntegrityCheck(jsonList);

        for (SFImportRow rowInfo : rowsList) {

            // 对检验正确的数据行创建对象实例
            if (!rowInfo.IsError) {
                this.ExportInfo.addToSuccess(rowInfo);
                for (String sobjectApiName : this.importSobjectColumnMap.keySet()) {
                    Schema.SObjectType convertType = Schema.getGlobalDescribe().get(sobjectApiName);
                    Sobject sObj = convertType.newSObject();
                    if (this.recordTypeMap.containsKey(sobjectApiName)) {
                        sObj.put('RecordTypeId', this.recordTypeMap.get(sobjectApiName));
                    }

                    for (SFFieldConfigInfo fc : this.HeaderList) {
                        if (this.importSobjectColumnMap.get(sobjectApiName).contains(fc.HeaderText)) {
                            String fieldValue = rowInfo.RowData.get(fc.MappingColumn);

                            // 如果是选项列表值，则需要从Label更换为API
                            if(fc.DataType.toLowerCase() == 'picklist' || fc.DataType.toLowerCase() == 'multipicklist') {
                                fieldValue = getPicklistValue(sobjectApiName, fc.ApiName, fieldValue);
                            }

                            SFUtility.setFieldValue(fc, fieldValue, sObj);
                        }
                    }
                    excelDataMap.get(sobjectApiName).put(rowInfo.RowIndex, sObj);
                }
            } else {
                this.ExportInfo.addToError(rowInfo);
            }
        }

        this.ExportInfo.addToSObject(excelDataMap);

        // 调用自定义验证类验证数据的正确性
        if (this.validateClassNameList.size() > 0) {
            Map<Integer, SFImportRow> validateResultMap = this.validate(this.validateClassNameList, excelDataMap);
            if (validateResultMap != null && validateResultMap.size() > 0) {
                this.ExportInfo.addToError(validateResultMap.values());
                this.ExportInfo.removeFromSuccess(validateResultMap.values());
            }
        }

        return this.ExportInfo;
    }

    // 数据有效性和完整性检测
    private List<SFImportRow> dataIntegrityCheck(List<Object> jsonList) {

        List<SFImportRow> rowsList = new List<SFImportRow>();

        // 用来保存每一个Lookup字段在Excel中的值，Map<MappingColumn, 字段值集合>
        Map<String, Set<String>> lookupValueList = new Map<String, Set<String>>();

        // 读取数据并根据配置文件检测数据完整性
        for (Integer i = this.BaseConfig.StartRow; i < jsonList.size(); i++) {

            // 读取一行
            Map<String, String> rowDataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(jsonList[i]), Map<String, String>.class);
            SFImportRow rowInfo = new SFImportRow(i + 1, rowDataMap);

            /*
                数据校验
                1、检查必填字段是否有值
                2、检查下拉列表值是否有效
                3、检查其它类型字段值是否是有效的数据类型
                4、检查lookup字段值，在数据库中是否存在
            */
            for (SFFieldConfigInfo fc : this.HeaderList) {
                String fieldValue = rowDataMap.get(fc.MappingColumn);
                if (String.isBlank(fieldValue)) {
                    fieldValue = '';
                } else {
                    fieldValue = fieldValue.trim();
                }

                // Lookup字段，先保留值，然后查询一次数据库，再判断值是否有效
                if (fc.DataType == 'lookup') {
                    if (fieldValue != '') {
                        if (lookupValueList.containsKey(fc.MappingColumn)) {
                            lookupValueList.get(fc.MappingColumn).add(fieldValue);
                        } else {
                            lookupValueList.put(fc.MappingColumn, new Set<String>{fieldValue});
                        }
                    }
                    continue;
                }

                // 非Lookup字段，直接判断值是否有效
                if (fieldValue != '') {
                    String err = this.checkFieldInfo(fc, fieldValue);
                    if (String.isNotBlank(err)) {
                        rowInfo.IsError = true;
                        rowInfo.ErrorField += fc.HeaderText + '; ';
                        rowInfo.ErrorMessage += err;
                    }
                } else {
                    if (fc.IsRequired != null && fc.IsRequired) {

                        // 未设置依赖字段, 直接报错
                        if (String.isBlank(fc.IsRequiredFor)) {
                            rowInfo.IsError = true;
                            rowInfo.ErrorField += fc.HeaderText + '; ';
                            rowInfo.ErrorMessage += String.format(Label.NEED_REQURIED_INFO, new List<String>{fc.HeaderText}) + '; ';

                        // 设置了依赖字段，判断依赖字段值是否在指定范围内
                        } else {

                            // 读取依赖字段的值
                            String dependValue = rowDataMap.get(fc.IsRequiredFor);
                            if (String.isBlank(dependValue)) {
                                dependValue = '';
                            } else {
                                dependValue = dependValue.trim();
                            }

                            // 读取依赖字段的范围值
                            String dependScope = String.isBlank(fc.IsRequiredForValues) ? '' : fc.IsRequiredForValues.trim();

                            // 如果依赖字段的值在依赖范围值内，报错
                            if (dependScope.indexOf(dependValue) >= 0) {
                                rowInfo.IsError = true;
                                rowInfo.ErrorField += fc.HeaderText + '; ';
                                rowInfo.ErrorMessage += String.format(Label.NEED_REQURIED_INFO, new List<String>{fc.HeaderText}) + '; ';
                            }
                        }
                    }
                }
            }

            rowsList.add(rowInfo);
        }

        // 有lookup字段，检测提供的值是否在系统中存在
        if (lookupValueList.size() > 0) {
            Map<String, SFFieldConfigInfo> headMap = new Map<String, SFFieldConfigInfo>();
            for (SFFieldConfigInfo fc : this.HeaderList) {
                headMap.put(fc.MappingColumn, fc);
            }

            // 查询指定值的数据
            for (String mappingName : lookupValueList.keySet()) {
                SFFieldConfigInfo fc = headMap.get(mappingName);
                List<Object> valueList = SFUtility.convertValue(fc, lookupValueList.get(mappingName));
                String sql = 'SELECT ' + fc.ForeignKey + ' ' +
                             'FROM ' + fc.SObjectName + ' ' + 
                             'WHERE ' + fc.ForeignKey + ' IN :valueList';
                List<SObject> objList = Database.query(sql);
                Set<String> existValueSet = new Set<String>();
                for (SObject obj : objList) {
                    existValueSet.add(String.valueOf(obj.get(fc.ForeignKey)));
                }

                // 判断值是否存在
                for (SFImportRow rowInfo : rowsList) {
                    String fieldValue = rowInfo.RowData.get(mappingName);
                    if (!String.isBlank(fieldValue) && !existValueSet.contains(fieldValue)) {
                        rowInfo.IsError = true;
                        rowInfo.ErrorField += fc.HeaderText + '; ';
                        rowInfo.ErrorMessage += String.format(Label.IMPORT_VALUE_NOT_EXIST, new List<String>{fieldValue}) + '; ';
                    }
                }
            }
        }
        return rowsList;
    }

    /*
        目的： 通过下拉列表选项值的标签名称取对应选项值的API值
        参数： sObjectApiName - 对象API名称
               fieldApiName - 字段API名称
               fieldValue - 选项列表值集(标签)
        返回： 选项列表值集(API值)
    */
    private String getPicklistValue(String sObjectApiName, String fieldApiName, String fieldValue) {
        String[] fieldValueSet = fieldValue.split(';');
        String value = '';
        for (String fieldLabel : fieldValueSet) {
            value += (String.isBlank(value) ? '' : ';') + this.pickValuesMap.get(sObjectApiName).get(fieldApiName).get(fieldLabel);
        }
        return value;
    }

    /*
        目的： 字段数据完整性检测
        参数： fieldName - 字段名称（Label）
               fieldValue - 字段值 
        返回： 无错误返回空('')，否则返回错误信息
    */
    private String checkFieldInfo(SFFieldConfigInfo fieldConfig, String fieldValue) {
        String errorMessage = '';
        for (String sObjectApiName : this.importSaveOrderSet) {
            if (this.importSobjectColumnMap.get(sObjectApiName).contains(fieldConfig.HeaderText)){

                // 字段数据检验
                switch on fieldConfig.DataType.toLowerCase() {
                    when 'picklist' {
                        errorMessage = SFUtility.checkPicklist(fieldConfig.HeaderText, fieldValue, this.pickValuesMap.get(sObjectApiName).get(fieldConfig.ApiName));
                    }

                    when 'multipicklist' {
                        errorMessage = SFUtility.checkMultiPicklist(fieldConfig.HeaderText, fieldValue, this.pickValuesMap.get(sObjectApiName).get(fieldConfig.ApiName));
                    }

                    when 'date' {
                        errorMessage = SFUtility.checkDate(fieldConfig.HeaderText, fieldValue);
                    }

                    when 'time' {
                        errorMessage = SFUtility.checkTime(fieldConfig.HeaderText, fieldValue);
                    }

                    when 'datetime' {
                        errorMessage = SFUtility.checkDatetime(fieldConfig.HeaderText, fieldValue);
                    }

                    when 'integer','decimal','numeric' {
                        errorMessage = SFUtility.checkNumber(fieldConfig.HeaderText, fieldValue);
                    }

                    when 'email' {
                        errorMessage = SFUtility.checkEmailFormat(fieldConfig.HeaderText, fieldValue);
                    }

                    when 'boolean' {
                        errorMessage = SFUtility.checkBoolean(fieldConfig.HeaderText, fieldValue);
                    }

                    when else {
                        errorMessage = '';
                    }
                }
            }
        }

        return errorMessage;
    }

    /*
      方法名: KMI_DML
      功能说明: 将数据插入/更新至数据库中，并获取插入/更新失败列表
      参数说明：DMLOption - Map<Integer, Sobject>>
               excelDatas - List<SFImportRow>
      返回值：SFImportInfo
     */
    public SFImportInfo ImportDML(Map<String, Map<Integer, Sobject>> DMLOption, List<SFImportRow> excelDatas) {

        SavePoint sp = Database.setSavepoint();

        // 获取成功数据的行号
        List<Integer> indexList = new List<Integer>();
        indexList.addAll(DMLOption.values()[0].keySet());
        System.debug(LoggingLevel.INFO, '*** DMLOption第一个值: ' + DMLOption.values()[0]);

        //用于记录已进入执行DML操作的sobject，在Excel中对应行数
        Map<Integer, Integer> indexMap = new Map<Integer, Integer>();

        System.debug(LoggingLevel.INFO, '*** ImportDML - indexList: ' + JSON.serializePretty(indexList));
        System.debug(LoggingLevel.INFO, '*** ImportDML - DMLOption: ' + JSON.serializePretty(DMLOption));
        System.debug(LoggingLevel.INFO, '*** ImportDML - excelDatas: ' + JSON.serializePretty(excelDatas));

        for (Integer i = 0; i < indexList.size(); i++) {
            indexMap.put(i, indexList.get(i));
            this.errinfoMap.put(indexList.get(i), '');
        }

        Boolean isRollBack = false;

        GlobalSetting__c originalSetting;
        List<GlobalSetting__c> gsList = [SELECT Id, 
                                            SetupOwnerId, 
                                            IgnoreValidation__c, 
                                            IgnoreInterface__c, 
                                            IgnoreTrigger__c, 
                                            IgnoreWorkflow__c 
                                     FROM GlobalSetting__c 
                                     WHERE SetupOwnerId = :UserInfo.getUserId()];
        GlobalSetting__c gs;
        if (gsList.size() > 0) {
            gs = gsList[0];
        } else {
            gs = new GlobalSetting__c();
        }
        gs.SetupOwnerId = UserInfo.getUserId();
        originalSetting = gs.clone();

        gs.IgnoreValidation__c = this.BaseConfig.IgnoreValidation;
        gs.IgnoreInterface__c = this.BaseConfig.IgnoreInterface;
        gs.IgnoreTrigger__c = this.BaseConfig.IgnoreTrigger;
        gs.IgnoreWorkflow__c = this.BaseConfig.IgnoreWorkflow;
        UPSERT gs;

        // 设置要还原设置的ID
        originalSetting.Id = gs.Id;

        try {

            Integer insIndex = 0;

            for (String sObjectApiName : this.importSaveOrderSet) {

                List<Database.SaveResult> saveResult;

                System.debug(LoggingLevel.INFO, '*** this.AllowPartialUpdate: ' + this.BaseConfig.AllowPartialUpdate);

                if (!DMLOption.containsKey(sObjectApiName)) {
                    continue;
                }

                // 保存数据前进行数据的预处理
                List<Sobject> saveSobjectList = DMLOption.get(sObjectApiName).values();
                this.preProcess(this.preProcessClassNameList, sObjectApiName, saveSobjectList);

                // 对象插入顺序,第一个直接插入，后面的对象中的查找字段根据对象查找配置来设置查找的Id
                if (insIndex == 0) {
                    saveResult = Database.insert(saveSobjectList, !this.BaseConfig.AllowPartialUpdate);
                } else {
                    for (Integer index : DMLOption.get(sObjectApiName).keySet()) {
                        Sobject childSobject = DMLOption.get(sObjectApiName).get(index);
                        for (String lookupFieldName : this.importLookupRelationalMap.get(sObjectApiName).keySet()) {
                            Sobject parentSobject = DMLOption.get(this.importLookupRelationalMap.get(sObjectApiName).get(lookupFieldName)).get(index);
                            childSobject.put(lookupFieldName, parentSobject.get('Id'));
                        }
                    }
                    saveResult = Database.insert(saveSobjectList, !this.BaseConfig.AllowPartialUpdate);
                }

                System.debug(LoggingLevel.INFO, '*** saveResult: ' + saveResult);

                // 解析DML操作结果
                Integer index  = 0;
                for (Database.SaveResult sr : saveResult) {
                    if (!sr.isSuccess()) {
                        String errStr = '';
                        for (Database.Error err : sr.getErrors()) {
                            errStr += err.getMessage() + ':' + err.getFields() + ':' + err.getStatusCode() + '; ';
                        }

                        this.errinfoMap.put(indexMap.get(index), errStr);

                        if (!this.BaseConfig.AllowPartialUpdate) {
                            isRollBack = true;
                        }
                    }
                    index++;
                }

                insIndex++;
            }

            System.debug(LoggingLevel.INFO, '*** this.errinfoMap: ' + this.errinfoMap);

            // 整理错误数据
            for (SFImportRow info : excelDatas) {
                if (this.errinfoMap.containsKey(info.RowIndex)){
                    if (String.isNotBlank(this.errinfoMap.get(info.RowIndex))) {
                        info.IsError = true;
                        info.ErrorMessage = this.errinfoMap.get(info.RowIndex);
                        this.ExportInfo.addToError(info);
                    } else {
                        info.IsError = false;
                        this.ExportInfo.addToSuccess(info);
                    }
                }
            }

            if (isRollBack) {
                Database.rollback(sp);
            }

        } catch (Exception ex) {
            this.ExportInfo.ErrorMessage = Label.SAVE_FAILED + '\n' + ex.getMessage() + '\n' + ex.getStackTraceString();
            Database.rollback(sp);

        } finally {

            // 还原用户设置
            UPDATE originalSetting;
        }

        if (this.ExportInfo.ErrorList != null && this.ExportInfo.ErrorList.size() > 0) {
            if (!this.BaseConfig.AllowPartialUpdate) {
                this.ExportInfo.ErrorMessage = Label.SAVE_FAILED;
            }
        }

        return this.ExportInfo;
    }

    /*
        目的：自定义验证数据的正确性
        返回：如果有错，则返回错误信息数组，否则，返回空数组
    */
    private Map<Integer, SFImportRow> validate(List<String> classNameList, Map<String, Map<Integer,Sobject>> sourceDataMap) {

        Map<Integer, SFImportRow> validateResultMap = new Map<Integer, SFImportRow>();
        for (String className : classNameList) {
            Type t = Type.forName(className);
            SFInterface.SFImportValidateInterface ivif = (SFInterface.SFImportValidateInterface)t.newInstance();
            for (String sobjectName : sourceDataMap.keySet()) {
                Map<Integer, SFImportRow> tmpMap = ivif.validate(sobjectName, sourceDataMap.get(sobjectName));
                if (tmpMap.size() > 0) {
                    validateResultMap.putAll(tmpMap);
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** validateResultMap: ' + JSON.serializePretty(validateResultMap));

        return validateResultMap;
    }

    /*
        目的：在保存前对要导入的数据进行预处理
        返回：void
    */
    private void preProcess(List<String> classNameList, String sobjectName, List<SObject> sourceDataList) {
        for (String className : classNameList) {
            Type t = Type.forName(className);
            SFInterface.SFImportFixedInterface ivif = (SFInterface.SFImportFixedInterface)t.newInstance();
            ivif.preProcess(sobjectName, sourceDataList);
        }
    }
}