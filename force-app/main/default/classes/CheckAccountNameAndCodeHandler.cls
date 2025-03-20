public with sharing class CheckAccountNameAndCodeHandler implements Triggers.Handler {
    public void handle() {
        
        if (!(Trigger.isInsert && Trigger.isBefore)) {
            return;
        }

        Set<String> nameSet = new Set<String>();
        Set<String> codeSet = new Set<String>();

        for (Account acc : (List<Account>)Trigger.new ) {
            nameSet.add(acc.Name);
            codeSet.add(acc.AccountCode__c);
        }

        List<Account> accList = [SELECT Name,
                                        AccountCode__c 
                                 FROM Account 
                                 WHERE AccountCode__c IN :codeSet 
                                 OR Name IN :nameSet];

        Map<String,String> nameMap = new Map<String,String>();
        Map<String,String> codeMap = new Map<String,String>();

        for (Account acc : accList ) {
            nameMap.put(acc.Name,acc.Id);
            codeMap.put(acc.AccountCode__c,acc.Id);
        }

        for (Account acc : (List<Account>)Trigger.new ) {
            if (acc.Name != null && nameMap.containsKey(acc.Name)) {
                acc.addError('客户名称已经存在，客户Id为：' + nameMap.get(acc.Name));
            }
            if (acc.AccountCode__c !=null && codeMap.containsKey(acc.AccountCode__c)) {
                acc.addError('客户编号已经存在，客户Id为：' + codeMap.get(acc.AccountCode__c));
            }
        }
    }
}