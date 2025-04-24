@isTest
public class RentalContractTriggerHandlerTest {

    @isTest
    static void validateContract_AllValidationsTest() {
        // Step 1: Create and insert Property (Occupied)
        Property__c occupiedProperty = new Property__c(
            Name = 'Occupied Property',
            Type__c = 'Apartment',
            Address__c = 'Test Address',
            Rent_Amount__c = 2000,
            Unique_Id__c = 'TEST-OCCUPIED',
            Status__c = 'Occupied' // Triggers the 'already rented out' error
        );
        insert occupiedProperty;

        // Step 2: Create and insert Property (Available)
        Property__c availableProperty = new Property__c(
            Name = 'Available Property',
            Type__c = 'Apartment',
            Address__c = 'Available Address',
            Rent_Amount__c = 3000,
            Unique_Id__c = 'TEST-AVAILABLE',
            Status__c = 'Available'
        );
        insert availableProperty;

        // Step 3: Create and insert Tenant
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'test@example.com',
            Phone_Number__c = '0500000000',
            Emirates_ID_Number__c = '784-1234567-1'
        );
        insert tenant;

        // Step 4: Create a contract for (Tenant + Available Property) to trigger duplicate contract
        Rental_Contract__c existingContract = new Rental_Contract__c(
            Tenant__c = tenant.Id,
            Property__c = availableProperty.Id,
            Start_Date__c = Date.today().addDays(-10),
            End_Date__c = Date.today().addDays(10),
            Monthly_Rent__c = 2500
        );
        insert existingContract;

        // Step 5: Test Contracts (will fail due to different validations)
        Test.startTest();

        List<Rental_Contract__c> testContracts = new List<Rental_Contract__c>();

        //  1. Duplicate Contract
        testContracts.add(new Rental_Contract__c(
            Tenant__c = tenant.Id,
            Property__c = availableProperty.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Monthly_Rent__c = 2500
        ));

        //  2. Property Already Occupied
        testContracts.add(new Rental_Contract__c(
            Tenant__c = tenant.Id,
            Property__c = occupiedProperty.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Monthly_Rent__c = 2500
        ));

        //  3. Invalid Dates
        testContracts.add(new Rental_Contract__c(
            Tenant__c = tenant.Id,
            Property__c = availableProperty.Id,
            Start_Date__c = Date.today().addDays(10),
            End_Date__c = Date.today(), // Start after End
            Monthly_Rent__c = 2500
        ));

        // Call method
        try {
            insert testContracts;
            System.assert(false, 'Expected validation errors but insert succeeded.');
        } catch (DmlException e) {
            System.assert(e.getDmlMessage(0).contains('already has a contract') ||
                          e.getDmlMessage(0).contains('already rented out') ||
                          e.getDmlMessage(0).contains('Ejari dates are incorrects'),
                          'Expected validation error not found: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @isTest
    static void updateRelatedRecordAfterContractCreationTest(){
        Property__c property = TestDataFactory.createProperty();
        Tenant__c tenant = TestDataFactory.createTenant();
        Rental_Contract__c contract = new Rental_Contract__c(
        	Tenant__c = tenant.Id,
            Property__c = property.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Monthly_Rent__c = 2500
        );

        Test.startTest();
        insert contract;
        Property__c updatedProperty = [SELECT Id, Status__c FROM Property__c WHERE Id = :property.Id];
        system.assertEquals('Occupied',updatedProperty.Status__c);
        Test.stopTest();
    }
    @isTest
    static void sendToEjariSystemTest(){
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        List<Id> contractList = new List<Id>();
        Rental_Contract__c contract = TestDataFactory.createContract();
        contractList.add(contract.Id);
        Test.startTest();
        RentalContractTriggerHandler.sendToEjariSystem(contractList); 
        Test.stopTest();
        Rental_Contract__c updated = [SELECT Id, Ejari_Number__c, Ejari_Verification_Status__c, Contract_Status__c
                                  FROM Rental_Contract__c
                                  WHERE Id = :contract.Id];

        System.assertEquals('Verified', updated.Ejari_Verification_Status__c);
        System.assertEquals('Active', updated.Contract_Status__c);
        System.assertNotEquals(null, updated.Ejari_Number__c);
    }
    @isTest
    static void handlePostUpdateTest(){
        Property__c property = TestDataFactory.createProperty();
        Tenant__c tenant = TestDataFactory.createTenant();
        Rental_Contract__c contract = new Rental_Contract__c();
        contract.Start_Date__c = Date.today();
        contract.End_Date__c = Date.today().addDays(360);
        contract.Monthly_Rent__c = 1500;
        contract.Property__c = property.Id;
        contract.Tenant__c = tenant.Id;
        insert contract;
        Test.startTest();
        contract.Ejari_Number__c = '28376489493393';
        update contract;
        Test.stopTest();
        Rental_Contract__c updatedContract = [SELECT Id,Ejari_Number__c FROM Rental_Contract__c WHERE Id =: contract.Id];
        system.assertEquals('28376489493393',updatedContract.Ejari_Number__c);
    }
    @isTest
    static void handleExpiryContractTest(){
        Rental_Contract__c contract = TestDataFactory.createContract();
        contract.Contract_Status__c = 'Expired';
        Test.startTest();
        update contract;
        Test.stopTest();
        Rental_Contract__c updatedContract = [SELECT Id, Contract_Status__c FROM Rental_Contract__c WHERE Id = :contract.Id];
        system.assertEquals('Expired',updatedContract.Contract_Status__c);
        system.assertNotEquals('null',updatedContract.Contract_Status__c);
    }
}