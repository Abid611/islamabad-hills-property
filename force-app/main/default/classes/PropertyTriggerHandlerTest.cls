@isTest
private class PropertyTriggerHandlerTest {

    @isTest
    static void validatePropertyTest() {
        //we aren't using test data factory here because it's on before insert and we need to insert different data on each record.
        
        List<Property__c> invalidProperties = new List<Property__c>();

        // 1. Rent too high
        Property__c highRent = new Property__c(
            Name = 'High Rent Property',
            Type__c = 'Apartment',
            Address__c = 'Street A',
            Rent_Amount__c = 200000,
            Unique_Id__c = 'TEST-1111',
            Status__c = 'Available'
        );
        invalidProperties.add(highRent);

        // 2. Name missing
        Property__c noName = new Property__c(
            Name = '',
            Type__c = 'Apartment',
            Address__c = 'Street B',
            Rent_Amount__c = 5000,
            Unique_Id__c = 'TEST-2222',
            Status__c = 'Available'
        );
        invalidProperties.add(noName);

        // 3. Rent too low
        Property__c lowRent = new Property__c(
            Name = 'Low Rent Property',
            Type__c = 'Apartment',
            Address__c = 'Street C',
            Rent_Amount__c = 500,
            Unique_Id__c = 'TEST-3333',
            Status__c = 'Available'
        );
        invalidProperties.add(lowRent);

        Test.startTest();
        try {
            insert invalidProperties;
            System.assert(false, 'Insert should have failed due to validation errors');
        } catch (DmlException e) {
            System.debug('Expected DML exception: ' + e.getMessage());
            System.assert(e.getMessage().contains('Rent amount cannot be more than'), 'Expected rent validation error');
        }
        Test.stopTest();
    }
}