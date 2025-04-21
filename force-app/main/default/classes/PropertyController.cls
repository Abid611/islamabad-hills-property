public with sharing class PropertyController {
    
    @AuraEnabled(cacheable= true)
    public static List<Property__c> getAllProperties(string propertyType, decimal rentAmount){
        string query = 'SELECT Id, Name, Type__c, Address__c, Rent_Amount__c, Status__c, Unique_Id__c FROM Property__c WHERE Status__c = \'Available\'';
        if(!String.isBlank(propertyType)){
            query+= ' AND Type__c =: propertyType';
        }
        if(rentAmount != null){
            query+= ' AND Rent_Amount__c <= :rentAmount';
        }
        return Database.query(query);
    }

}