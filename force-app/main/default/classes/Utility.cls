/********************************************************************
* ClassName:          Utility.cls
* TestClassName:      null
* Purpose:            工具类
* Refer Object:       all
* Author:             fangruikai(bluelinksys.com)
* Create Date:        2023-02-06
* Modify Description: 
********************************************************************/
public without sharing class Utility {
    
    /********************************************************************
    * Purpose:   格式化异常，使之不要越界
    * Param:     pMSG: 报错信息
    * Return:    String 格式化后的报错信息
    * Create By: fangruikai(bluelinksys.com) 2023-02-06
    * Modify By: 
    ********************************************************************/
    public static String formatException(String pMSG) {

        System.debug(LoggingLevel.INFO, '*** pMSG: ' + pMSG);

        if(pMSG.contains('_EXCEPTION')) {
            pMSG = pMSG.substringBetween('_EXCEPTION, ', ': [');
        }
        
        if(pMSG.contains('NO_APPLICABLE_PROCESS')) {
            pMSG = pMSG.substringBetween('NO_APPLICABLE_PROCESS, ', ': [');
        }
        
        if(pMSG.contains('DUPLICATE_VALUE')) {
            pMSG = pMSG.substringBetween('DUPLICATE_VALUE, duplicate value found:', ': [');
        }
        
        if(pMSG.contains('REQUIRED_FIELD_MISSING')) {
            pMSG = pMSG.substringBetween('REQUIRED_FIELD_MISSING, ', ': [');
        }
        
        if(pMSG.contains('MANAGER_NOT_DEFINED')) {
            pMSG = pMSG.substringBetween('MANAGER_NOT_DEFINED, ', ': [');
        }
        
        if(pMSG.contains('ALREADY_IN_PROCESS')) {
            pMSG = pMSG.substringBetween('ALREADY_IN_PROCESS, ', ': [');
        }

        if(pMSG.contains('ENTITY_IS_LOCKED')) {
            pMSG = pMSG.substringBetween('ENTITY_IS_LOCKED, ', ': [');
        }

        if(pMSG.contains('INSUFFICIENT_ACCESS_OR_READONLY')) {
            pMSG = pMSG.substringBetween('INSUFFICIENT_ACCESS_OR_READONLY, ', ': [');
        }

        if(pMSG.contains('insufficient access rights on object id')) {
            pMSG = '没有操作权限。';
        }
         
        return pMSG;
    }

    /********************************************************************
    * Purpose:   获取对象字段的pickList
    * Param:     objectName: 对象api名称
    * Param:     field_apiname: 字段api名称
    * Param:     nullRequired: 是否加入‘请选择’或者‘none’提示
    * Return:    List<Map<String, String>> 返回字段的pickList列表
    * Create By: fangruikai(bluelinksys.com) 2023-02-06
    * Modify By: 
    ********************************************************************/
    public static List<Map<String, String>> getPicklistLabelAndValue(String objectName, String field_apiname, Boolean nullRequired){
        List<Map<String, String>> optionList = new List<Map<String, String>>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        if(nullRequired) {
            optionList.add(new Map<String, String>{'label'=>'--None--','value'=>''});
        }
        for (Schema.PicklistEntry pe : picklistValues) {
            optionList.add(new Map<String, String>{'label'=>pe.getLabel(),'value'=>pe.getValue()});
        }
        return optionList;
    }
}