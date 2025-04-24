@isTest
private class RentalContractControllerTest {

    @isTest
    static void createRentalContractTest() {
        //create a property
        Property__c pro = new Property__c(
            Name = 'Test Property',
            Type__c = 'Apartment',
            Address__c = 'abc street',
            Rent_Amount__c  = 2500,
            Unique_Id__c = '124'
        );
        insert pro;
        //create a tenant record
        Tenant__c tn = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'abc@gmail.com',
            Phone_Number__c = '0501234567',
            Emirates_ID_Number__c = '784-677787-7'
        );
        insert tn;

        Rental_Contract__c rc = RentalContractController.createRenatlContract(pro.Id,tn.Id,Date.today(),Date.today().addMonths(12),2500);
        System.assertEquals(2500,rc.Monthly_Rent__c);
        System.assertNotEquals(null, rc.Id);
    }
    @isTest 
    static void validateEjariTestPositive(){
        MockResponseGenerator.mockScenario = 'success';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.EjariDataWrapper result = RentalContractController.validateEjari('12345');
        system.assertEquals(true, result.isValid);
        system.assertEquals('Ejari is valid', result.message);
        system.assertEquals('Ali Khan', result.tenantName);
    }
    @isTest 
    static void validateEjariTestWithException(){
        MockResponseGenerator.mockScenario = 'exception';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.EjariDataWrapper result = RentalContractController.validateEjari('12345');
        system.assertEquals(false, result.isValid);
    }
    @isTest 
    static void validateEjariTestWithInvalidEjari(){
        MockResponseGenerator.mockScenario = 'invalid_ejari';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.EjariDataWrapper result = RentalContractController.validateEjari('12345');
        system.assertEquals(false, result.isValid);
    }
    @isTest
    static void checkAvailabilityTestPositive(){
         MockResponseGenerator.mockScenario = 'success';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.CheckAvailabilityWrapper result = RentalContractController.checkAvailability('12346');
        system.assertEquals(true,result.isAvailable);
    }
    @isTest
    static void checkAvailabilityTestWithException(){
        MockResponseGenerator.mockScenario = 'exception';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.CheckAvailabilityWrapper result = RentalContractController.checkAvailability('12346');
        system.assertEquals(false,result.isAvailable);
    }
    @isTest
    static void checkAvailabilityTestNotAvailable(){
         MockResponseGenerator.mockScenario = 'not_available';
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        RentalContractController.CheckAvailabilityWrapper result = RentalContractController.checkAvailability('12346');
        system.assertEquals(false,result.isAvailable);
    }
}