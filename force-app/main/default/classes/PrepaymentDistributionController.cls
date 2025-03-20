/*******************************************************************************
* class Name:			PrepaymentDistributionController.cls
* Purpose:			   	
* TestClassName:		 
* Author:				hao(longhao@bluelinksys.com)
* Created Date:		  	2025-01-22
* Refer Object:		  	
* Version History
* Date				   	Developer                  		 	Comments
* ---------------		--------------------       		 	---------------
* 2025-01-22			hao(longhao@bluelinksys.com)        创建类
* 
********************************************************************************/
public without sharing class PrepaymentDistributionController {
    

    @AuraEnabled
    public static Map<String,Object> initDistribution(String recordId) {

    	Map<String,Object> result = new Map<String,Object>();

    	Id myRecordId = Id.valueOf(recordId);

		String sObjName = myRecordId.getSObjectType().getDescribe().getName();
		//初始化pd对象
		Prepayment_Distribution__c pd = new Prepayment_Distribution__c();

		if (sObjName == 'Prepayment__c') {
			Prepayment__c pre = [SELECT Id,Account__c FROM Prepayment__c WHERE Id =: recordId];
			pd.Account__c = pre.Account__c;
			pd.Prepayment__c = pre.Id;
			// pd.CurrencyIsoCode = pre.CurrencyIsoCode;
		}else if (sObjName == 'Prepayment_Distribution__c') {
			pd = [SELECT Id,Account__c,Prepayment__c,Order__c,Order__r.OrderNumber,
						 Order_ERP_Number__c,Order_Amount__c,Order_Status__c,
						 Prepayment_Distribution_Amount__c,Remarks__c
				  FROM Prepayment_Distribution__c
				  WHERE Id =: recordId];
		}

		result.put('preObj',pd);
		result.put('sObjName',sObjName);

    	return result;
    }

    /********************************************************************
    * Purpose: 根据不同条件查询信息(可包括不同对象)
    * Param:   searchTerm：需要搜索的名称
    * Param:   selectedIds：排除已选中的记录
    * Param:   placeStr：
    * Param:   anOptionalParam：
    * Param:   objType：对象类型
    * Return:  List<LookupSearchResult> 返回查找信息
    ********************************************************************/
    @AuraEnabled
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String objType, String anOptionalParam ) {

        User currentUser = [SELECT Id,Name,Alias,Email,ProfileId,Profile.Name,Address,Department,UserRole.DeveloperName,
        UserRole.Name,ManagerId,LanguageLocaleKey
        From User 
        WHERE Id =: UserInfo.getUserId()];

        System.debug(LoggingLevel.INFO, '*** searchTerm: ' + searchTerm);
        System.debug(LoggingLevel.INFO, '*** selectedIds: ' + selectedIds);
        System.debug(LoggingLevel.INFO, '*** objType: ' + objType);
        System.debug(LoggingLevel.INFO, '*** anOptionalParam: ' + anOptionalParam);

        searchTerm = searchTerm.trim();
        // 查询结果
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // if (searchTerm.length() < 5 && String.isBlank(anOptionalParam)) {
        //     results.add(new LookupSearchResult(null, objType, '', '', '查询内容长度不能少于5'));
        //     return results;
        // }

        // List<LookupSearchResult> lookupSearchResultList = new List<LookupSearchResult>();

        //查询订单
        if(objType == 'Order'){
        	String searchCon = '%' + searchTerm + '%';
            System.debug(LoggingLevel.INFO, '*** searchCon: ' + searchCon);

            String iconStr = 'standard:record';

            String sql = 'SELECT Id,OrderNumber,ExternalID__c,TotalAmount,Status '+ 
                         'FROM Order ';
            if (String.isBlank(searchTerm)) {
            	sql += 'WHERE Id NOT IN :selectedIds AND AccountId =:anOptionalParam LIMIT 10';
            }else{
            	sql += 'WHERE (OrderNumber LIKE :searchCon OR ExternalID__c LIKE :searchCon)'+
                       'AND Id NOT IN :selectedIds AND AccountId =:anOptionalParam LIMIT 5';
            }

            List<Order> ordList = Database.query(sql);
            for (Order ord : ordList){
            	results.add(new LookupSearchResult(ord.Id, objType, iconStr, ord.OrderNumber, ord.ExternalID__c,ord));
            }
        }

        return results;
    }

    @AuraEnabled
    public static Map<String,Object> getOrderInfo(String orderId,String recordId) {

        Map<String,Object> result = new Map<String,Object>();

        List<AggregateResult> resultList = [SELECT Order__c,SUM(Prepayment_Distribution_Amount__c) orderDistributedAmount
                                            FROM Prepayment_Distribution__c
                                            WHERE Order__c =: orderId AND Id !=: recordId
                                            GROUP BY Order__c];
        result.put('resultList',resultList);

        return result;
    }


    /*******************************************************************
    * @description  : 保存方法
    * @date         : 2025-01-22
    * @author       : hao(longhao@bluelinksys.com) 
    * @param        : pdStr 记录对象JSON序列化Str
    * @return       : 
    ********************************************************************/
    @AuraEnabled
    public static Map<String,Object> saveDistribution(String pdStr) {

    	System.debug(LoggingLevel.DEBUG, '*** 111: ');

    	Map<String,Object> result = new Map<String,Object>();

    	try{
    		Prepayment_Distribution__c pd = (Prepayment_Distribution__c)JSON.deserialize(pdStr, Prepayment_Distribution__c.class);
    		UPSERT pd;

            List<AggregateResult> resultList = [SELECT Order__c,SUM(Prepayment_Distribution_Amount__c) orderDistributedAmount
                                                FROM Prepayment_Distribution__c
                                                WHERE Order__c =: pd.Order__c
                                                GROUP BY Order__c];
            Order orderObj = [SELECT Id,TotalAmount FROM Order WHERE Id =: pd.Order__c];

            Order ord = new Order();
            ord.Id = pd.Order__c;
            ord.Order_Distributed_Amount__c = (Decimal)resultList[0].get('orderDistributedAmount');
            ord.Order_Balanced_Amount__c = orderObj.TotalAmount - ord.Order_Distributed_Amount__c;
            UPDATE ord;
    	}catch (Exception e) {
    		System.debug(LoggingLevel.DEBUG, '*** e.getMessage(): ' + e.getMessage());
    		System.debug(LoggingLevel.DEBUG, '*** e.getStackTraceString(): ' + e.getStackTraceString());
    		String errStr = e.getMessage();
            result.put('message', errStr);
    	}

    	return result;
    }
}