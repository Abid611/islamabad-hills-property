public class ErrorLogger {
    public static void logError(String errorType, string errorMessage, string statusCode, string relatedRecordId, string contextInfo){
        try{
            Integration_Error__c err = new Integration_Error__c(
                Error_Type__c = errorType,
                Error_Message__c = errorMessage,
                Status_Code__c = statusCode,
                Related_Record_Id__c = relatedRecordId,
                Context_Info__c = contextInfo
            );
            insert err;   
        }catch (Exception ex){
            System.debug(' Logging failed: ' + ex.getMessage());
        }
    }
}