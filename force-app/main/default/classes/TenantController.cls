public with sharing class TenantController {
    @auraEnabled(cacheable=true)
    public static list<Tenant__c> searchTenants(string keyword) {
        List<Tenant__c> allTenants = [SELECT Id, Name 
                                        FROM Tenant__c
                                        WHERE Name LIKE: ('%' + keyword + '%')
                                        LIMIT 10];
        return allTenants;
    }
}