@isTest
private class PropertyControllerTest {

    @isTest
    static void getAllPropertiesTest() {
          // Step 1: Insert test Property__c records
        Property__c testProperty = TestDataFactory.createProperty();
        string propertyType = 'Apartment';
        decimal rentAmount = 2000;
        Test.startTest();
        List<Property__c> allProperties = PropertyController.getAllProperties(propertyType, rentAmount);
        Test.stopTest();
        system.assertEquals(true,!allProperties.isEmpty());
        System.assertEquals('Apartment', allProperties[0].Type__c);
    }
}