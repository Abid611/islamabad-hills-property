@isTest
private class ErrorLoggerTest {

    @isTest
    static void testLogError_InsertsRecordSuccessfully() {
        Test.startTest();
        ErrorLogger.logError(
            'Callout',
            'This is test error message',
            '500',
            '32533 dummy id',
            'ErrorLoggerTest.testLogError_InsertsRecordSuccessfully'
        );

        Test.stopTest();

        List<Integration_Error__c> logs = [
            SELECT Id, Error_Type__c, Error_Message__c, Context_Info__c
            FROM Integration_Error__c
            WHERE Context_Info__c = 'ErrorLoggerTest.testLogError_InsertsRecordSuccessfully'
        ];
        System.assertEquals(1,logs.size(),'Expected one error');
        System.assertEquals('Callout', logs[0].Error_Type__c);
    }
}