/*******************************************************************************************************
 *  ClassName:          BookInfoEditExtension.cls
 *  TestClassName:      null
 *  Purpose:            处理图书信息编辑问题
 *  Refer Object:       BookInfo__c
 *  Author:             fangruikai(bluelinksys.com)
 *  Create Date:        2022-12-27
 *  Modify Description:      
*********************************************************************************************************/
global without sharing class BookInfoEditExtension {
    
	// 工单Id
    global static String bookInfoId {get;set;}

    //学科类型的选项列表字符串
    global static String subjectTypeStr {get;set;}

    //所有人的选项列表字符串
    global static String ownerStr {get;set;}

    //图书信息字符串
    global static String bookInfoStr {get;set;}

    //图书详细信息字符串
    global static String bookDetailListStr {get;set;}

    //图书详情信息图书状态选项列表
    global static String bookDetailStatusStr {get;set;}

    global BookInfoEditExtension(ApexPages.StandardController con) {
    	Map<String,String> argsMap = ApexPages.currentPage().getParameters();

    	bookInfoId = argsMap.get('Id');
    	System.debug(LoggingLevel.INFO, '*** bookInfoId: ' + bookInfoId);

    	List<Map<String,String>> subjectTypeList = getPicklistLabelAndValue('BookInfo__c','SubjectType__c',false);
    	subjectTypeStr = JSON.serialize(subjectTypeList);

        List<Map<String,String>> bookDetailStatus = getPicklistLabelAndValue('BookDetailInfo__c','BookStatus__c',false);
        bookDetailStatusStr = JSON.serialize(bookDetailStatus);

    	//查询图书信息
    	BookInfo__c bookInfo = [SELECT Id,OwnerId,Owner.Name,Price__c,Author__c,PublishDate__c,Publisher__c,
    								   BookName__c,SubjectType__c,Introduction__c,
                                       (SELECT Id,Name,BookName__c,BookStatus__c,Author__c,Price__c,IsSelected__c
                                        FROM BookDetailInfo__r
                                        ORDER BY Name DESC) 
    							FROM BookInfo__c 
    							WHERE Id =: bookInfoId];

    	List<Map<String,String>> ownerList = new List<Map<String,String>>();
    	Map<String,String> ownerMap = new Map<String,String>();
    	ownerMap.put('label', bookInfo.Owner.Name);
    	ownerMap.put('value', bookInfo.OwnerId);
    	ownerList.add(ownerMap);
    	ownerStr = JSON.serialize(ownerList);

    	BookInfoEntity bookEntity = new BookInfoEntity();
    	bookEntity.id = bookInfo.Id;
    	bookEntity.bookName = bookInfo.BookName__c ;
		bookEntity.subjectType = bookInfo.SubjectType__c ;
		bookEntity.publisher = bookInfo.Publisher__c ;
		bookEntity.publishDate = String.valueOf(bookInfo.PublishDate__c) ;
		bookEntity.author = bookInfo.Author__c ;
		bookEntity.price = bookInfo.Price__c ;
		bookEntity.ownerId = bookInfo.OwnerId ;
		bookEntity.introduction = bookInfo.Introduction__c ;
		bookInfoStr = JSON.serialize(bookEntity);

        List<BookDetailEntity> detailList = new List<BookDetailEntity>();
        for (BookDetailInfo__c detail: bookInfo.BookDetailInfo__r) {
            BookDetailEntity detailEntity = new BookDetailEntity();
            detailEntity.id = detail.Id;
            detailEntity.name = detail.Name;
            detailEntity.bookName = detail.BookName__c;
            detailEntity.bookStatus = detail.BookStatus__c;
            detailEntity.author = detail.Author__c;
            detailEntity.price = detail.Price__c;
            detailEntity.isSelected = detail.IsSelected__c;
            detailList.add(detailEntity);
        }
        bookDetailListStr = JSON.serialize(detailList);
    }


    /********************************************************************
    * Purpose:   根据所有人名称查找类似的所有人
    * Param:     ownName：所有人名称
    * Return:    List<Map<String, String>> 返回所有人名称查找类似的所有人列表
    * Create By: fangruikai(bluelinksys.com) 2022-12-28
    * Modify By: 
    ********************************************************************/
    @RemoteAction
    global static List<Map<String, String>> getOwnerInfoByName(String ownName) {
    	List<Map<String, String>> retList = new List<Map<String, String>>();
    	String ownNameStr = ownName.trim();
    	if (ownNameStr.length() < 1) return retList;
    	ownNameStr = '%' + ownNameStr + '%';
    	for (User info: [SELECT Id,Name FROM User WHERE IsActive=true AND Name LIKE :ownNameStr]) {
    		Map<String,String> ownerMap = new Map<String,String>();
    		ownerMap.put('label', info.Name);
    		ownerMap.put('value', info.Id);
    		retList.add(ownerMap);
    	}
    	return retList;
    }


    /********************************************************************
    * Purpose:   保存图书信息
    * Param:     bookStr：图书信息的字符串
    * Return:    Map<String,Object> 返回状态信息
    * Create By: fangruikai(bluelinksys.com) 2022-12-28
    * Modify By: 
    ********************************************************************/
    @RemoteAction
    global static Map<String,Object> saveBookInfo(String bookStr) {
    	Map<String,Object> retMap = new Map<String,Object>();
    	retMap.put('status', 'error');
    	System.debug(LoggingLevel.INFO, '*** bookStr: ' + bookStr);
    	try{
    		BookInfoEntity bookInfo = (BookInfoEntity)JSON.deserialize(bookStr, BookInfoEntity.class);
	    	BookInfo__c info = new BookInfo__c();
	    	info.Id = bookInfo.id;
	    	info.OwnerId = bookInfo.ownerId;
	    	info.Price__c = bookInfo.price;
	    	info.Author__c = bookInfo.author;
	    	info.PublishDate__c = Date.valueOf(bookInfo.publishDate);
	    	info.Publisher__c = bookInfo.publisher;
	    	info.BookName__c = bookInfo.bookName;
	    	info.SubjectType__c = bookInfo.subjectType;
	    	info.Introduction__c = bookInfo.introduction;
	    	UPDATE info;
	    	retMap.put('status', 'success');
	    	retMap.put('bookInfoId', info.Id);
	    	return retMap;
    	}catch(Exception e) {
    		System.debug(LoggingLevel.INFO, '*** e.getCause(): ' + e.getCause());
    		System.debug(LoggingLevel.INFO, '*** e.getMessage(): ' + e.getMessage());
    		retMap.put('errorInfo', e.getMessage());
    		return retMap;
    	}
    	
    }



    /********************************************************************
    * Purpose:   获取对象字段的pickList
    * Param:     objectName：对象API名称
    * Param:     field_apiname：对象字段API名称
    * Param:     nullRequired：是否加头信息
    * Return:    List<Map<String, String>> 返回对象中字段需要用到的pickList
    * Create By: fangruikai(bluelinksys.com) 2022-12-28
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


    //图书信息实体类
    public class BookInfoEntity {
    	public String id {get;set;}					//图书信息Id
    	public String bookName {get;set;}			//图书名称
    	public String subjectType {get;set;}		//学科类型
    	public String publisher {get;set;}			//出版社
    	public String publishDate {get;set;}		//出版日期
    	public String author {get;set;}				//作者
    	public Decimal price {get;set;}				//价格
    	public String ownerId {get;set;}			//所有人
    	public String introduction {get;set;}		//简介
    }

    //图书详情实体类
    public class BookDetailEntity {
        public String id {get;set;}                 //图书详情Id
        public String name {get;set;}               //图书详情编号
        public String bookName {get;set;}           //图书名称
        public String bookStatus {get;set;}         //图书状态
        public String author {get;set;}             //作者
        public Decimal price {get;set;}             //价格
        public Boolean isSelected {get;set;}        //是否选中
        public Boolean isEdit {get;set;}            //是否编辑
    }
}