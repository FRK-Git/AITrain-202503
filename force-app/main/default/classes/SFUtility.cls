/*******************************************************************************************************
 *  名    称： SFUtility
 *  目    的： 接口类通用函数
 *  创 建 人： kit.liu(liuwenjun@bluelinksyc.com)
 *  创建时间： 2019-01-17
 *  备注说明： 
 *********************************************************************************************************/

public with sharing class SFUtility {

    // 接口异常
    public class SFInterfaceConfigException extends Exception {}

    // 导入异常
    public class SFImportException extends Exception {}

    /*
        目的：得到导入配置信息
        参数：导入配置开发名
        返回：Excel_Import_Config__mdt对象
    */
    public static Excel_Import_Config__mdt getImportConfig(String developerName) {

        List<String> fields = getSObjectField(Schema.Excel_Import_Config__mdt.SObjectType);
        String sql = 'SELECT ' + String.join(fields, ',') + ' ' +
                     'FROM Excel_Import_Config__mdt ' +
                     'WHERE DeveloperName = :developerName';

        List<Excel_Import_Config__mdt> configList = Database.query(sql);
        if(configList.size() > 0) {
            return configList[0];
        } else {
            throw new SFImportException(String.format(Label.IMPORT_CONFIG_NOT_EXIST, new List<String>{DeveloperName}));
        }
    }

    // 取对象的所有字段集合
    private static List<String> getSObjectField(Schema.SObjectType sobjectType) {
        List<String> fields = new List<String>();
        Map<String, Schema.SobjectField> fieldMap = sobjectType.getDescribe().fields.getMap();

        for (String fieldName : fieldMap.keySet()) {
            fields.add(fieldMap.get(fieldName).getDescribe().getName());
        }
        return fields;
    }

    /*
        目的：发达Chatter信息
        参数：
             ownerId - 信息接收人Id
             subjectId - 记录Id
             message - 信息内容
        返回值：N/A
    */
    public static List<ConnectApi.BatchResult> sendChatterMessage(Id ownerId, Id subjectId, String message) {

        System.debug(LoggingLevel.INFO, '*** 发送Chatter给: ' + ownerId);

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();

        mentionSegmentInput.id = ownerId;
        textSegmentInput.text = message;
        feedItemInput.subjectId = subjectId;

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        batchInputs.add(new ConnectApi.BatchInput(feedItemInput));

        List<ConnectApi.BatchResult> results;
        if(!Test.isRunningTest()) {
            results = ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }

        return results;
    }

    /*
        目的：得到SObject对象指定字段值(包含关系字段)
        参数：source - 数据源(SObject)
              config - 字段配置信息，
        返回：字段值
    */
    public static String getSobjectFieldValue(SObject source, SFFieldConfigInfo config) {

        //System.debug(LoggingLevel.INFO, '*** source: ' + source);
        //System.debug(LoggingLevel.INFO, '*** fieldName: ' + config);

        if (source == null || String.isBlank(config.ApiName) || config.ApiName == 'DML') {
            return '';
        }

        String val;
        SObject obj = source;

        // 如果字段为查找对象中的字段值，先找出查找对象
        List<String> fields = config.ApiName.split('\\.');
        Integer count = fields.size();
        for (Integer i = 0; i < count - 1; i++) {
            String relationName = fields[i].trim();
            obj = obj.getSObject(relationName);
            if (obj == null) {
                break;
            }
        }

        if (obj != null) {
            if (config.NeedFormatted != null && config.NeedFormatted) {
                val = formatFieldValue(config, obj.get(fields[count - 1]));
            } else {
                val = String.valueOf(obj.get(fields[count - 1]));
            }
        }

        if (String.isBlank(val)) {
            val = '';
        }

        return val;
    }

    /*
        目的：格式化字段的值
        参数：config - 字段配置信息
              value - 需要格式的值
        返回：字段值
    */
    public static String formatFieldValue(SFFieldConfigInfo config, Object value) {

        if (value == null) {
            return '';
        }

        // 无需格式化
        if (config.NeedFormatted == null || !config.NeedFormatted) {
            return String.valueOf(value);
        }

        String val;
        switch on config.DataType.toLowerCase() {
            when 'date','time','datetime' {

                Datetime dt;
                if (value instanceof Date) {
                    dt = Datetime.newInstance((Date)value, Time.newInstance(0, 0, 0, 0));
                } else if (value instanceof Time) {
                    dt = Datetime.newInstance(Date.newInstance(2000, 1, 1), (Time)value);
                } else if (value instanceof Datetime) {
                    dt = (Datetime)value;
                }

                val = dt.format(config.FormatString);
            }

            when 'string' {
                Integer len = config.FormatString.trim().length();
                String formatChar = config.FormatString.trim().substring(0, 1);
                val = String.valueOf(value).leftPad(len, formatChar);
            }

            when 'decimal', 'double', 'integer' {
                Integer scale = Integer.valueOf(config.FormatString);
                val = String.valueOf(Decimal.valueOf(String.valueOf(value)).setscale(scale));
            }

            // 格式字符串中的每一个值为True
            when 'boolean' {
                List<String> tfValue = config.FormatString.split('-');
                if(Boolean.valueOf(value)) {
                    val = tfValue[0];
                } else {
                    val = tfValue[1];
                }
            }

            // 如果一个值要映射为另一个值时
            when 'mapping' {
                String mapping = config.FormatString.replace('\'', '"');
                Map<String, String> mapValues = (Map<String,String>)JSON.deserialize(mapping, Map<String,String>.class);
                String key = String.valueOf(value);
                if (mapValues.containsKey(key)) {
                    val = mapValues.get(key);
                } else {
                    val = String.valueOf(value);
                }
            }

            when else {
                val = String.valueOf(value);
            }
        }

        return val;
    }

    /*
        目的：取对象指定名称的记录类型ID
        参数：developerNameOrName - 记录类型开发API名称或记录类型名称
              sObjectName - 对象API名称
        返回：不存在为空，否则为取到的记录类型ID
    */
    public static String getRecordTypeId(String developerNameOrName, String sObjectName) {
        String rtID = null;
        Map<String, Schema.RecordTypeInfo> rtInfoMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName();
        if (rtInfoMap != null && rtInfoMap.size() > 0) {
            for (String key : rtInfoMap.keySet()) {
                Schema.RecordTypeInfo rtInfo = rtInfoMap.get(key);
                if (rtInfo.DeveloperName == developerNameOrName || rtInfo.Name == developerNameOrName) {
                    rtID = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }

        System.debug(LoggingLevel.INFO, '*** 记录类型ID: ' + sObjectName + ' - ' + rtID);

        return rtID;
    }

    /*
        目的：转化为字段类型所需要值
        参数：config - 字段配置信息
              value - 需要格式的值
              obj - 需要设置值的对象
        返回：字段值
    */
    public static void setFieldValue(SFFieldConfigInfo config, String value, SObject obj) {

        if (config.ApiName == 'DML') {
            return;
        }

        // System.debug(LoggingLevel.INFO, '*** config: ' + config);
        // System.debug(LoggingLevel.INFO, '*** value: ' + value);

        if (config.IsRequired != null && 
            config.IsRequired && 
            String.isBlank(value) && 
            String.isBlank(config.IsRequiredFor)) {
            throw new SFInterfaceConfigException(String.format(Label.IF_FIELD_VALUE_EMPTY, new List<String>{config.ApiName}));
        }

        switch on config.DataType.toLowerCase() {

            // 通过记录类型名称设置记录类型ID
            when 'recordtype' {
                if (String.isBlank(value)) {
                    obj.put(config.ApiName, null);
                } else {
                    if (String.isBlank(config.SObjectName)) {
                        throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'SObjectName'}));
                    }

                    // 判断是否需要先进行记录类型名称的转换
                    String val = value;
                    if (config.NeedFormatted != null && config.NeedFormatted) {
                        if (String.isBlank(config.FormatString)) {
                            throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'FormatString'}));
                        }
                        String mapping = config.FormatString.replace('\'', '"');
                        Map<String, String> mapValues = (Map<String,String>)JSON.deserialize(mapping, Map<String,String>.class);
                        val = mapValues.get(value);
                    }

                    String rtID = getRecordTypeId(val, config.SObjectName);
                    if (String.isBlank(rtID)) {
                        throw new SFInterfaceConfigException(String.format(Label.IF_RECORDTYPE_NOT_EXIST, new List<String>{value}));
                    } else {
                        obj.put(config.ApiName, rtID);
                    }
                }
            }

            // 设置字段为主表中的数据
            when 'lookup' {
                if (String.isBlank(config.RelationName)) {
                    throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'RelationName'}));
                }

                if (String.isBlank(config.SObjectName)) {
                    throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'SObjectName'}));
                }

                if (String.isBlank(config.ForeignKey)) {
                    throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'ForeignKey'}));
                }

                if (String.isBlank(config.FKDataType)) {
                    throw new SFInterfaceConfigException(String.format(Label.IF_PARAMETER_NOT_SETTING, new List<String>{'FKDataType'}));
                }

                if (String.isBlank(value)) {
                    obj.putSObject(config.RelationName, null);
                    return;
                }

                // 得到主从关系类型
                SObject sub = (SObject)Type.forName(config.SObjectName).newInstance();

                // 转化值类型
                Object keyValue = convertValue(config, value);
                sub.put(config.ForeignKey, keyValue);
                obj.putSObject(config.RelationName, sub);
            }

            when else {
                obj.put(config.ApiName, convertValue(config, String.isBlank(value) ? config.DefaultValue : value));
            }
        }
    }

    /*
        目的：转化字符串为指定类型数据返回
        参数：config - 字段配置信息
              values - 值列表
        返回：List<Object>
    */
    public static List<Object> convertValue(SFFieldConfigInfo config, Set<String> values) {
        List<String> valueList = new List<String>();
        valueList.addAll(values);
        return convertValue(config, valueList);
    }

    /*
        目的：转化字符串为指定类型数据返回
        参数：config - 字段配置信息
              values - 值列表
        返回：List<Object>
    */
    public static List<Object> convertValue(SFFieldConfigInfo config, List<String> values) {
        String dataType = config.DataType.toLowerCase();
        if (dataType == 'lookup') {
            dataType = config.FKDataType.toLowerCase();
        }
        List<Object> valueList = getObjectList(dataType);
        for (String val : values) {
            valueList.add(convertValue(config, val));
        }
        return valueList;
    }

    /*
        目的：转化字符串为指定类型数据返回
        参数：config - 字段配置信息
              value - 值
        返回：Object
    */
    public static Object convertValue(SFFieldConfigInfo config, String value) {
        Object val;

        String dataType = config.DataType.toLowerCase();
        if (dataType == 'lookup') {
            dataType = config.FKDataType.toLowerCase();
        }

        switch on dataType {
            when 'boolean' {
                if (String.isBlank(value)) {
                    val = false;
                } else {
                    if (config.NeedFormatted != null && 
                        config.NeedFormatted && 
                        config.FormatString.contains('-')) {

                        List<String> conTypes = config.FormatString.split('-');
                        if (value == conTypes[0]) {
                            val = true;
                        } else {
                            val = false;
                        }
                    } else {
                        val = Boolean.valueOf(value.trim());
                    }
                }
            }

            when 'mapping' {
                String mapping = config.FormatString.replace('\'', '"');
                Map<String, String> mapValues = (Map<String,String>)JSON.deserialize(mapping, Map<String,String>.class);
                val = mapValues.get(value);
            }

            when 'decimal' {
                val = String.isBlank(value) ? 0 : Decimal.valueOf(value.trim().replace(',', '').replace(' ',''));
            }

            when 'integer' {
                val = String.isBlank(value) ? 0 : Integer.valueOf(value.trim());
            }

            when 'date' {
                val = String.isBlank(value) ? null : Date.valueOf(value.trim().replace('/', '-'));
            }

            when 'time' {
                if (String.isBlank(value)) {
                    val = null;
                } else {
                    List<String> times = value.trim().replace('：',':').split(':');
                    Integer HH = Integer.valueOf(times[0]);
                    Integer mm = times.size() > 1 ? Integer.valueOf(times[1]) : 0;
                    Integer ss = times.size() > 2 ? Integer.valueOf(times[2]) : 0;
                    val = Time.newInstance(HH, mm, ss, 0);
                }
            }

            when 'datetime' {
                if (String.isBlank(value)) {
                    val = null;
                } else {
                    TimeZone tz = UserInfo.getTimeZone();
                    String str = value.trim().replace('：',':');
                    if (str.indexOf(':') <= 0) {
                        str = str + ' 00:00:00';
                    } else if(str.split(':').size() == 2) {
                        str = str + ':00';
                    }

                    str = str.replace('T', ' ');
                    Datetime dt = Datetime.valueOf(str);
                    Integer offset = tz.getOffset(dt);
                    Integer h = offset / (1000 * 60 * 60);
                    val = dt.addHours(h);
                }
            }

            when else {
                val = value;
            }
        }

        return val;
    }

    public static List<Object> getObjectList(String typeName) {
        List<Object> objList;
        switch on typeName.toLowerCase() {
            when 'boolean' {
                objList = new List<Boolean>();
            }

            when 'decimal' {
                objList = new List<Decimal>();
            }

            when 'integer' {
                objList = new List<Integer>();
            }

            when 'date' {
                objList = new List<Date>();
            }

            when 'time' {
                objList = new List<Time>();
            }

            when 'datetime' {
                objList = new List<Datetime>();
            }

            when else {
                objList = new List<String>();
            }
        }

        return objList;
    }

    /*
        方法名: checkMultiPicklist
        功能说明: 检验MultiPicklist值并输出错误
        参数说明：fieldName - 字段名
                 pickStr - 选项列表值
                 vMap - 值集合
        返 回 值：如果字段值包含在值集合中，则返回空，否则返回错误信息
    */
    public static String checkMultiPicklist(String fieldName, String pickStr, Map<String, String> vMap) {
        if (String.isBlank(pickStr) || vMap == null) {
            return '';
        }

        List<String> pickStrList = new List<String>();
        pickStrList.addAll(pickStr.split(';'));

        for (String pickLabel : pickStrList) {
            if (!vMap.containsKey(pickLabel)) {
                return String.format(Label.INVALID_PICKLIST, new List<String>{fieldName, pickLabel});
            }
        }

        return '';
    }

    /*
        方法名: checkNumber
        功能说明: 检验数字值并输出错误
        参数说明：fieldName - 字段名
                 numberStr - 数字字符串
        返 回 值：如果是数字，则返回空，否则返回错误信息
    */
    public static String checkNumber(String fieldName, String numberStr) {
        try {
            Decimal d = Decimal.valueOf(numberStr.replace(',', '').replace(' ',''));
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_NUMERIC, new List<String>{fieldName, numberStr});
        }
    }

    /*
        方法名: checkDatetime
        功能说明: 检验日期时间值并输出错误
        参数说明：fieldName - 字段名
                 datetimeStr - 选项列表值
        返 回 值：如果字段值是日期时间，则返回空，否则返回错误信息
    */
    public static String checkDatetime(String fieldName, String datetimeStr) {
        try {
            datetimeStr = datetimeStr.replace('：', ':');
            if (datetimeStr.indexOf(':') <= 0) {
                datetimeStr = datetimeStr + ' 00:00:00';
            }
            Datetime d = Datetime.valueOf(datetimeStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_DATETIME, new List<String>{fieldName, datetimeStr});
        }
    }

    /*
        方法名: checkBoolean
        功能说明: 检验布尔值并输出错误
        参数说明：fieldName - 字段名
                 boolStr - 字符串
        返 回 值：如果字段值可以转换为布尔值，则返回空，否则返回错误信息
    */
    public static String checkBoolean(String fieldName, String boolStr) {
        try {
            Boolean bl = Boolean.valueOf(boolStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_BOOLEAN, new List<String>{fieldName, boolStr});
        }
    }

    /*
        方 法 名: checkEmailFormat
        功能说明: 检验邮箱格式并输出错误
        参数说明：fieldName - 字段名
                 emlStr - Email格式字符串
        返 回 值：如果字段值不是正确的邮箱，则返回错误信息，否则返回空
    */
    public static String checkEmailFormat(String fieldName, String emlStr) {
        String emailFormat = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
        if (!Pattern.matches(emailFormat, emlStr)) {
            return String.format(Label.INVALID_EMAIL, new List<String>{fieldName, emlStr});
        } else {
            return '';
        }
    }

    /*
        方法名: checkPicklist
        功能说明: 检验Picklist值并输出错误
        参数说明：fieldName - 字段名
                 pickStr - 选项列表值
                 vMap - 值集合
        返 回 值：如果字段值包含在值集合中，则返回空，否则返回错误信息
    */
    public static String checkPicklist(String fieldName, String pickStr, Map<String, String> vMap) {
        if (vMap != null && vMap.containsKey(pickStr)) {
            return '';
        } else {
            return String.format(Label.INVALID_PICKLIST, new List<String>{fieldName, pickStr});
        }
    }

    /*
        方法名: checkDate
        功能说明: 检验日期值并输出错误
        参数说明：fieldName - 字段名
                 dateStr - 日期字符串
        返 回 值：如果字段值是日期，则返回空，否则返回错误信息
    */
    public static String checkDate(String fieldName, String dateStr) {
        try {
            Date d = Date.valueOf(dateStr);
            return '';
        } catch(Exception ex) {
            return String.format(Label.INVALID_DATE, new List<String>{fieldName, dateStr});
        }
    }

    /*
        方法名: checkTime
        功能说明: 检验时间值并输出错误
        参数说明：fieldName - 字段名
                 dateStr - 日期字符串
        返 回 值：如果字段值是日期，则返回空，否则返回错误信息
    */
    public static String checkTime(String fieldName, String timeStr) {
        try {
            List<String> timeList = timeStr.replace('：', ':').split(':');
            if (timeList.size() > 2) {
                Time t = Time.newInstance(Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2]), 0);
                return '';
            } else if (timeList.size() == 2) {
                Time t = Time.newInstance(Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), 0, 0);
                return '';
            } else {
                return String.format(Label.IMPORT_INVALID_TIME, new List<String>{fieldName, timeStr});
            }
        } catch(Exception ex) {
            return String.format(Label.IMPORT_INVALID_TIME, new List<String>{fieldName, timeStr});
        }
    }

    /*
        方 法 名: requiredFormat
        功能说明: 必填校验并输出错误
        参数说明：fieldName - 字段名
                 valStr - 字段值
        返 回 值：如果字段值为空，则返回错误信息，否则返回空
    */
    public static String requiredFormat(String fieldName, String valStr){
        if (String.isBlank(valStr)) {
            return String.format(Label.NEED_REQURIED_INFO, new List<String>{fieldName});
        } else {
            return '';
        }
    }

    /*
        方 法 名: getSchemaPickValuesMap
        功能说明: 获取对象的Picklist字段及其对应值
        参数说明： picklistMap 
                      key - 对象名
                      value - 选项列表字段集合
        返 回 值： Map<String, Map<String, Map<String, String>>> 
                  例：Map<objectName, Map<filedName, Map<label, api>>>
                      key - 对象名
                      value - 字段的和它的选项列表值
                          key - 字段名
                          value - 字段选项列表值集合(Label + API)
    */
    public static Map<String, Map<String, Map<String, String>>> getSchemaPickValuesMap(Map<String, List<String>> picklistMap) {
        Map<String, Map<String, Map<String, String>>> pickValuesMap = new Map<String, Map<String, Map<String, String>>>();

        // 得到对象列表
        List<String> objectName = new List<String>();
        objectName.addAll(picklistMap.keySet());

        System.debug(LoggingLevel.INFO, '*** objectName: ' + objectName);

        // 得到对象描述结果
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(objectName);

        for (Schema.DescribeSobjectResult sobjectDescribe : results) {

            // 字段选项列表值MAP
            Map<String, Map<String, String>> fieldMap = new Map<String, Map<String, String>>();

            for(String fieldName : picklistMap.get(sobjectDescribe.getName())) {

                // 选项列表值MAP
                Map<String, String> fieldValuesMap = new Map<String, String>();

                for (Schema.PicklistEntry pe : sobjectDescribe.fields.getMap().get(fieldName).getDescribe().getPickListValues()) {
                    fieldValuesMap.put(pe.getLabel(), pe.getValue());
                }

                fieldMap.put(fieldName, fieldValuesMap);
            }

            pickValuesMap.put(sobjectDescribe.getName(), fieldMap);
        }

        return pickValuesMap;
    }

    /*
        方 法 名: joinTwoText
        功能说明: 连接二个文本值
        参数说明： originalText - 原文本值
        返 回 值： newText - 要连接（增加）的新文本值
    */
    public static String joinTwoText(String originalText, String newText) {
        if (String.isBlank(originalText)) {
            return newText;
        } else if (String.isBlank(newText)) {
            return originalText;
        } else {
            return originalText + newText;
        }
    }
}