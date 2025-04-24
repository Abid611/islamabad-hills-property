@isTest
private class TenantControllerTest {

    @isTest
    static void searchTenantTest() {
        Tenant__c ten = TestDataFactory.createTenant();
        ten.Name = 'Ahmad';
        update ten;
        Test.startTest();
        TenantController.searchTenants(ten.Name);
        Test.stopTest();
        List<Tenant__c> tenantList = [SELECT Id, Name FROM Tenant__c WHERE Id =: ten.Id];
        system.assertNotEquals(null, tenantList.size());
        system.assertEquals('Ahmad', tenantList[0].Name);
        
    }
}