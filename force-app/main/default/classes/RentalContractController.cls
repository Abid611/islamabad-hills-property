public with sharing class RentalContractController {
    
    @auraEnabled
    public static Rental_Contract__c createRenatlContract(Id propertyId, Id tenantId, Date startDate, Date endDate, decimal rentAmount, string ejariNumber){
        Rental_Contract__c contract = new Rental_Contract__c();
        contract.Property__c = propertyId;
        contract.Tenant__c = tenantId;
        contract.Start_Date__c = startDate;
        contract.End_Date__c = endDate;
        contract.Monthly_Rent__c = rentAmount;
        contract.Ejari_Number__c = ejariNumber;
        insert contract;

        return contract;
    }
}