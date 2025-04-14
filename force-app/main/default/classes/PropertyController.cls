public with sharing class PropertyController {
    
    @AuraEnabled(cacheable= true)
    public static List<Property__c> getAllProperties(){
        List<Property__c> AllProperties = [SELECT Id, Name, Type__c, Address__c, Rent_Amount__c, Status__c 
                                             FROM Property__c 
                                             WHERE Status__c = 'Available'
                                             ORDER BY Rent_Amount__c ASC];
        return AllProperties;
    }

}