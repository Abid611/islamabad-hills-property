@isTest
private class RentalContractExpiryBatchTest {

    @isTest
    static void batchMarksContractAsExpiredTest() {
        Rental_Contract__c contract = TestDataFactory.createContract();
        contract.End_Date__c = Date.today().addDays(-5);
        update contract;
        Test.startTest();
        RentalContractExpiryBatch batch = new RentalContractExpiryBatch();
        Database.executeBatch(batch,1);
        Test.stopTest();
        
        Rental_Contract__c updatedContract = [SELECT Id,Contract_Status__c FROM Rental_Contract__c WHERE Id = :contract.Id];
        system.assertEquals('Expired', updatedContract.Contract_Status__c);
    }
}