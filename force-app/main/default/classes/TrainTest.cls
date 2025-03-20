@isTest(SeeAllData = true)
private class TrainTest {
    static testMethod void testMethod1() {
        Account acc = new Account(Name = 'test 1234');
        INSERT acc;

        List<Account> accList = [SELECT Id FROM Account WHERE Name LIKE 'test%'];
        System.assert(accList.size() > 0);

        DELETE accList;

        accList = [SELECT Id FROM Account WHERE Name LIKE 'test%'];
        System.assert(accList.size() == 0);
    }
}