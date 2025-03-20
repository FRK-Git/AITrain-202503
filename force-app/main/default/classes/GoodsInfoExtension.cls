public with sharing class GoodsInfoExtension {
    public GoodsInfoExtension(ApexPages.StandardController con) {
        goods = new Goods__c();
    }

    public Goods__c goods {get;set;}

    public String codeUniqueMessage {get;set;}

    public Integer productNo {get;set;}


    public PageReference next() {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'这是下一页'));
        return null;
    }

    public PageReference saveAction() {
        try {
            INSERT goods;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'插入成功'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }

        return null;
    }

     public Goods__c queryGoodsInfoByName(String name) {
         List<Goods__c> goods1 = [SELECT Name,
                                       Id,
                                       ProductUpperCategory__c,
                                       ProductLowerCategory__c,
                                       BasePrice__c,
                                       CurrentStock__c,
                                       ProductNo__c,
                                       Unit__c,
                                       MaxStock__c,
                                       MinStock__c
                                FROM Goods__c 
                                WHERE Name = :name];
        return goods1[0];
    }

    public PageReference checkProductNoUnique() {

      codeUniqueMessage = '产品编号不能重复';
      // List<Goods__c> goods1 = [SELECT Name 
      //                          FROM Goods__c 
      //                          WHERE ProductNo__c = :productNo];
      // if (goods1.isEmpty() && goods1.size() == 0) {
      //     codeUniqueMessage = '产品编号可用';
      // } else {
      //     codeUniqueMessage = '产品编号不能重复';
      // }

      return null;
    }

    @RemoteAction
    public static Boolean checkProductNameUnique (String name) {
      List<Goods__c> goods1 = [SELECT Name 
                               FROM Goods__c 
                               WHERE Name = :name];
      if (goods1.isEmpty() && goods1.size() == 0) {
          return true;
      } else {
        return false;
      }
    }
}