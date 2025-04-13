public with sharing class PropertyTriggerHandler {
    public static void validateRent(List<Property__c> newProperty){

        if(newProperty.size()> 0 ){
            for(Property__c p: newProperty){
                if(p.Rent_Amount__c != 0 && p.Rent_Amount__c < 1000){
                    p.addError('Rent for this property cannot be less than 1000 USD per month. Please correct the value.');
                }
            }
        }
    }
}