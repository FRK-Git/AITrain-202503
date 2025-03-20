public with sharing class SetAccountNumberHander implements Triggers.Handler {
    public void handle() {

        if (!(Trigger.isInsert && Trigger.isBefore)) {
            return;
        }

        for (Account acc : (List<Account>)Trigger.new ) {
            acc.AccountNumber = acc.AccountCode__c;
        }
    }
}