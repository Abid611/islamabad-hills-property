public with sharing class RentalContractTriggerHandler {
    
    public static void validateContract(List<Rental_Contract__c> newContracts){
    
        Set<Id> propertiesIds = new Set<Id>();
        Set<Id> tenantsIds = new Set<Id>();

        for(Rental_Contract__c rc: newContracts){
            propertiesIds.add(rc.Property__c);
            tenantsIds.add(rc.Tenant__c);
        }
        Map<Id,Property__c> propertyMap = new Map<Id,Property__c>(
            [SELECT Id, Status__c FROM Property__c WHERE Id IN :propertiesIds]
        );

        //fetch exsiting contracts for same tenant + property
        List<Rental_Contract__c> existingContracts = [SELECT Id, Name, Tenant__c, Property__c
                                                      FROM Rental_Contract__c
                                                      WHERE Tenant__c IN : tenantsIds
                                                      AND Property__c IN : propertiesIds];

        //validation before saving contract
        for(Rental_Contract__c rc: newContracts){
            Property__c relatedProperty = propertyMap.get(rc.Property__c);
            //check if existing tenant have same properties rented
            for(Rental_Contract__c ex: existingContracts){
                if(ex.Tenant__c == rc.Tenant__c && ex.Property__c == rc.Property__c){
                    rc.addError('This tenant already has a contract for this property. Contract Number: ' + ex.Name);
                }
            }
            //check if properties is already occupied
            if(relatedProperty != null && relatedProperty.Status__c == 'Occupied'){
                rc.addError('Property is already rented out! Please check another property');
            }
            // date validation
            if(rc.Start_Date__c != null && rc.End_Date__c != null && rc.Start_Date__c > rc.End_Date__c){
                rc.addError('Ejari dates are incorrects. Please check');
            }
            
        }
    }
    public static void updateRelatedRecordAfterContractCreation(List<Rental_Contract__c> newContracts){
        Set<Id> propertiesIds = new Set<Id>();
        //muji ab related properties kai status ko update karna hai 
        for(Rental_Contract__c rc: newContracts){
            if(rc.Property__c != null){
                propertiesIds.add(rc.Property__c);
            }      
        }

        List<Property__c> propertiesToUpdate = new List<Property__c>();
        for(Property__c pr: [SELECT Id,Status__c
                             FROM Property__c
                             WHERE Id IN : propertiesIds])
                             {
                                pr.Status__c = 'Occupied';
                                propertiesToUpdate.add(pr);
                             }
        system.debug('this is to be updated'+ propertiesToUpdate);
        if(propertiesToUpdate.size() > 0){
            update propertiesToUpdate;
        }   
    }               
        

}