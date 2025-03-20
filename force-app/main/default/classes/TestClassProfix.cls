/********************************************************************
* ClassName:          TestClassProfix.cls
* TestClassName:      TestClassProfixTest.cls
* Purpose:            测试代码片段快捷方式
* Refer Object:       null
* Author:             fangruikai(bluelinksys.com)
* Create Date:        2023-02-03
* Modify Description: 
********************************************************************/
public with sharing class TestClassProfix {
    

    /********************************************************************
    * Purpose:   获取前10个客户
    * Param:     null
    * Return:    List<Account> 返回客户列表
    * Create By: fangruikai(bluelinksys.com) 2023-02-03
    * Modify By: 
    ********************************************************************/
    @AuraEnabled
    public static List<Account> getAccount(){
        List<Account> accList = [SELECT Id,Name FROM Account ORDER BY Name LIMIT 10];
        return accList;
    }
}