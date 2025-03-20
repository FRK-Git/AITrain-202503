public with sharing class ROIDetailCtrl {
    public ROIDetailCtrl() {
        
    }

    /**
     * [search Lookup查找]
     * @param  searchTerm      [description]
     * @param  selectedIds     [description]
     * @param  anOptionalParam [description]
     * @param  objType         [description]
     * @return                 [description]
     */
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds, String placeStr,
        String anOptionalParam, String objType) {
        System.debug(LoggingLevel.INFO, '*** searchTerm: ' + searchTerm);
        System.debug(LoggingLevel.INFO, '*** selectedIds: ' + selectedIds);
        System.debug(LoggingLevel.INFO, '*** anOptionalParam: ' + anOptionalParam);
        System.debug(LoggingLevel.INFO, '*** objType: ' + objType);
        System.debug(LoggingLevel.INFO, '*** placeStr: ' + placeStr);

        List<LookupSearchResult> results = new List<LookupSearchResult>();
        if (searchTerm.length() == 1) {
            results.add(new LookupSearchResult(null, objType, '', '', 'searchTerm equal 1 String'));
            return results;
        }

        
        List<List<SObject>> searchResults = new List<List<SObject>>();
        if(objType == 'Product__c'){
            searchTerm += '*';
            searchResults = [FIND :searchTerm 
                             IN ALL 
                             FIELDS RETURNING Product__c 
                             (Id, Name, ProductName__c WHERE Id NOT IN :selectedIds LIMIT 20)];
            String oppIcon = 'custom:custom33';
            System.debug(LoggingLevel.INFO, '*** searchResults: ' + searchResults);
            Product__c [] dataList = ((List<Product__c>) searchResults[0]);
            for (Product__c item : dataList) {
                results.add(new LookupSearchResult(item.Id, objType, oppIcon, item.Name + '-' + item.ProductName__c, ''));
            }
        }

        if (results.isEmpty()) {
            results.add(new LookupSearchResult(null, objType, '', '','results is Emtpy!'));
        }
        return results;
    }


}