@isTest
private class ContractExpiryEmailJobTest {

    @isTest
    static void expiredContractsEmailJobTest() {
        //insert test property
         Property__c property = new Property__c(
            Name = 'Test Property',
            Type__c = 'Apartment',
            Address__c = 'Somewhere Street',
            Rent_Amount__c = 2500,
            Unique_Id__c = 'TEST-001'
        );
        insert property;

        // Insert test Tenant
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'test@example.com',
            Phone_Number__c = '0501234567',
            Emirates_ID_Number__c = '784-777567-9'
        );
        insert tenant;

        // Insert expired contract
        Rental_Contract__c contract = new Rental_Contract__c(
            Property__c = property.Id,
            Tenant__c = tenant.Id,
            Start_Date__c = Date.today().addMonths(-12),
            End_Date__c = Date.today().addDays(-1),
            Monthly_Rent__c = 2500,
            Ejari_Number__c = 'EJ1234567890',
            Ejari_Verification_Status__c = 'Verified',
            Contract_Status__c = 'Active'
        );
        insert contract;
        //suppose our batch job updated the status from active to expired.
        contract.Contract_Status__c = 'Expired';
        update contract;
        
        Test.startTest();
		System.enqueueJob(new ContractExpiryEmailJob(new List<Id>{contract.Id}));
        Test.stopTest();
        
        Rental_Contract__c updatedContract = [
            SELECT Contract_Status__c FROM Rental_Contract__c WHERE Id = :contract.Id
        ];
        
        system.assertEquals('Expired',updatedContract.Contract_Status__c);
    }
}