public with sharing class RentalContractController {

    public class EjariDataWrapper{
        @AuraEnabled public boolean isValid;
        @AuraEnabled public string message;
        @AuraEnabled public string tenantName;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
    }
    public class CheckAvailabilityWrapper{
        @AuraEnabled public boolean isAvailable;
        @AuraEnabled public string message;
    }
    
    @auraEnabled
    public static Rental_Contract__c createRenatlContract(Id propertyId, Id tenantId, Date startDate, Date endDate, decimal rentAmount){
        Rental_Contract__c contract = new Rental_Contract__c();
        contract.Property__c = propertyId;
        contract.Tenant__c = tenantId;
        contract.Start_Date__c = startDate;
        contract.End_Date__c = endDate;
        contract.Monthly_Rent__c = rentAmount;
        insert contract;

        return contract;
    }
    @AuraEnabled(cacheable = false)
    public static EjariDataWrapper validateEjari(string ejariNumber){
        EjariDataWrapper responseWrapper = new EjariDataWrapper();

        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            req.setEndpoint('callout:Ejari_Verify_OAuth/services/apexrest/VerifyEjari/'+ejariNumber);
            req.setMethod('GET');

            HttpResponse res = http.send(req);

            if(res.getStatusCode() ==  200){
                Map<String,Object> result = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
                responseWrapper.isValid = true;
                responseWrapper.message = 'Ejari is valid';
                responseWrapper.tenantName = (String) result.get('Tenant_Name__c');
                responseWrapper.startDate = Date.valueOf((String) result.get('Contract_Start__c'));
                responseWrapper.endDate = Date.valueOf((String) result.get('Contract_End__c'));
            }else{
                responseWrapper.isValid = false;
                responseWrapper.message = 'Ejari is invalid';
            }
        }catch (Exception ex){
                responseWrapper.isValid = false;
                responseWrapper.message = 'Error: '+ ex.getMessage();
                ErrorLogger.logError('Callout',ex.getMessage(),'500', '','RentalContractController.validateEjari');
        }
        return responseWrapper;
    }

    @AuraEnabled
    public static CheckAvailabilityWrapper checkAvailability(String uniqueId) {
        CheckAvailabilityWrapper responseWrapper = new CheckAvailabilityWrapper();
        //System.debug('inside checkAvailability method, and unique id is: '+ uniqueId);
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            //  Callout URL with encoded property name
            req.setEndpoint('callout:Ejari_Verify_OAuth/services/apexrest/CheckAvailability/' + EncodingUtil.urlEncode(uniqueId, 'UTF-8'));
            req.setMethod('GET');

            HttpResponse res = http.send(req);
           // System.debug('Response code is: '+ res.getStatusCode());
            if (res.getStatusCode() == 200) { 
                responseWrapper.isAvailable = true;
            } else if (res.getStatusCode() == 404) {
                responseWrapper.isAvailable = false;
            } else {
                responseWrapper.isAvailable = false;
                responseWrapper.message = 'Unexpected status code: ' + res.getStatusCode();
            }

        } catch (Exception ex) {
            responseWrapper.isAvailable = false;
            responseWrapper.message = 'Error: ' + ex.getMessage();
            ErrorLogger.logError('Callout',ex.getMessage(),'500', '','RentalContractController.checkAvailability');
        }

        return responseWrapper;
    }


}