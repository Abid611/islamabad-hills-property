@isTest
global with sharing class MockResponseGenerator implements HttpCalloutMock {
    public static String mockScenario = 'success'; 
    global HttpResponse respond(HttpRequest request){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (mockScenario == 'exception') {
            throw new CalloutException('Simulated callout failure');
        }
        

        if(request.getEndpoint().contains('VerifyEjari')){
            if (mockScenario == 'invalid_ejari') {
                res.setStatusCode(404);
                return res;
            }
            res.setStatusCode(200);
            res.setBody('{"Tenant_Name__c": "Ali Khan","Contract_Start__c": "2025-01-01","Contract_End__c": "2026-01-01"}');
        }else if(request.getEndpoint().contains('CheckAvailability')){
            if (mockScenario == 'not_available') {
                res.setStatusCode(404);
                return res;
            }
            res.setStatusCode(200);
            res.setBody('{"status":"available"}');
        }else if(request.getEndPoint().contains('createTenancyContract')){
            res.setStatusCode(200);
            res.setBody('{"ejariNumber":"6759874565657865"}');
        }else{
            res.setStatusCode(404);
        }
        return res;
    }
}