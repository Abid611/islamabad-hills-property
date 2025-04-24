@isTest
private class RentalContractExpirySchedulerTest {

    @isTest
    static void schedulerRunsBatchJobTest() {
        Test.startTest();
        string jobId = System.schedule('Test contract expiry schedule','0 0 0 * * ?',new RentalContractExpiryScheduler());
        Test.stopTest();
        system.assertNotEquals(null,jobId);
    }
}