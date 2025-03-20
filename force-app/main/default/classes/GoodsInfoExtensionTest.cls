@isTest
private class GoodsInfoExtensionTest {
    static testMethod void testMethod1() {
        //产品1号

        PageReference pr = new PageReference('apex/CreateProduct');
        Test.setCurrentPage(pr);

        Goods__c goods1 = new Goods__c();
        goods1.Name = '产品1号';
        goods1.ProductCode__c = '1265382';
        goods1.ProductUpperCategory__c = '保健';
        goods1.ProductLowerCategory__c = '保健1';
        goods1.CurrentStock__c = 1000;
        goods1.MaxStock__c = 1500;
        goods1.MinStock__c = 30;
        goods1.Unit__c = '箱';
        goods1.ProductDescription__c = '这是一种保健类的产品';

        ApexPages.StandardController con = new ApexPages.StandardController(goods1);
        GoodsInfoExtension exc = new GoodsInfoExtension(con);

        exc.next();
        exc.goods = goods1;
        exc.saveAction();

        String name = '产品1';
        Goods__c g =  exc.queryGoodsInfoByName(name);
        System.assert(g != null);
    }
}