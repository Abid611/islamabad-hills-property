@isTest
public class TestDataFactory {

    public static Property__c createProperty() {
        Property__c property = new Property__c(
            Name = 'Test Property',
            Type__c = 'Apartment',
            Address__c = 'Somewhere Street',
            Rent_Amount__c = 1000,
            Unique_Id__c = 'TEST-' + String.valueOf(Crypto.getRandomInteger()).left(6),
            Status__c = 'Available'
        );
        insert property;
        return property;
    }

    public static Tenant__c createTenant() {
        Tenant__c tenant = new Tenant__c(
            Name = 'Test Tenant',
            Email__c = 'test_' + DateTime.now().getTime() + '@example.com', 
            Phone_Number__c = '050' + String.valueOf(Math.mod(Crypto.getRandomInteger(), 10000000)).left(7), 
            Emirates_ID_Number__c = '784-777567-9'
        );
        insert tenant;
        return tenant;
    }

    public static Rental_Contract__c createContract() {
        Property__c property = createProperty();
        Tenant__c tenant = createTenant();

        Rental_Contract__c contract = new Rental_Contract__c(
            Property__c = property.Id,
            Tenant__c = tenant.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12),
            Monthly_Rent__c = 2500,
            Ejari_Number__c = 'EJ' + String.valueOf(Math.random()).replace('.', '').left(10),
            Ejari_Verification_Status__c = 'Verified',
            Contract_Status__c = 'Active'
        );
        insert contract;
        return contract;
    }
}