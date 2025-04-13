public with sharing class PropertyTriggerHandler {
    public static void validateProperty(List<Property__c> newProperty){

        if(newProperty.size()> 0 ){
            for(Property__c p: newProperty){
                if(p.Name == null || p.Name == ''){
                    p.addError('Please fill out the property Name!');
                }
                if(p.Rent_Amount__c > 100000){
                    p.addError('Rent amount cannot be more than 100000 USD per month.');
                }
                if(p.Rent_Amount__c != 0 && p.Rent_Amount__c < 1000){
                    p.addError('Rent for this property cannot be less than 1000 USD per month. Please correct the value.');
                }
            }
        }
    }
}