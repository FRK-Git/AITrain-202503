@isTest(SeeAllData = true)
private class TestAccount {
    static testMethod void testMethod1() {

    	List<Account> accList1 = [SELECT Id,Name FROM Account WHERE Name LIKE 'test%'];
    	System.assert(accList1.size() > 0);

        Account acc = new Account(Name = 'test acc 4');
        insert acc;

        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name LIKE 'test%'];

        System.assert(accList.size() > 0);

        delete accList;

        accList = [SELECT Id,Name FROM Account WHERE Name LIKE 'test%'];

        System.assert(accList.size() == 0);
    }
}