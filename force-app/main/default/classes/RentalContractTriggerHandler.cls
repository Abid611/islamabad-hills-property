public with sharing class RentalContractTriggerHandler {
    
    public static void validateContract(List<Rental_Contract__c> newContracts){
    
        Set<Id> propertiesIds = new Set<Id>();
        Set<Id> tenantsIds = new Set<Id>();

        for(Rental_Contract__c rc: newContracts){
            propertiesIds.add(rc.Property__c);
            tenantsIds.add(rc.Tenant__c);
        }
        Map<Id,Property__c> propertyMap = new Map<Id,Property__c>(
            [SELECT Id, Status__c FROM Property__c WHERE Id IN :propertiesIds]
        );

        //fetch exsiting contracts for same tenant + property
        List<Rental_Contract__c> existingContracts = [SELECT Id, Name, Tenant__c, Property__c
                                                      FROM Rental_Contract__c
                                                      WHERE Tenant__c IN : tenantsIds
                                                      AND Property__c IN : propertiesIds];

        //validation before saving contract
        for(Rental_Contract__c rc: newContracts){
            Property__c relatedProperty = propertyMap.get(rc.Property__c);
            //check if existing tenant have same properties rented
            for(Rental_Contract__c ex: existingContracts){
                if(ex.Tenant__c == rc.Tenant__c && ex.Property__c == rc.Property__c){
                    rc.addError('This tenant already has a contract for this property. Contract Number: ' + ex.Name);
                }
            }
            //check if properties is already occupied
            if(relatedProperty != null && relatedProperty.Status__c == 'Occupied'){
                rc.addError('Property is already rented out! Please check another property');
            }
            // date validation
            if(rc.Start_Date__c != null && rc.End_Date__c != null && rc.Start_Date__c > rc.End_Date__c){
                rc.addError('Ejari dates are incorrects. Please check');
            }
            
        }
    }
    public static void updateRelatedRecordAfterContractCreation(List<Rental_Contract__c> newContracts){
        Set<Id> propertiesIds = new Set<Id>();
        //muji ab related properties kai status ko update karna hai 
        for(Rental_Contract__c rc: newContracts){
            if(rc.Property__c != null){
                propertiesIds.add(rc.Property__c);
            }      
        }

        List<Property__c> propertiesToUpdate = new List<Property__c>();
        for(Property__c pr: [SELECT Id,Status__c
                             FROM Property__c
                             WHERE Id IN : propertiesIds])
                             {
                                pr.Status__c = 'Occupied';
                                propertiesToUpdate.add(pr);
                             }
        //system.debug('this is to be updated'+ propertiesToUpdate);
        if(propertiesToUpdate.size() > 0){
            update propertiesToUpdate;
        }   
    }          
    @future(callout=true)
    public static void sendToEjariSystem(List<Id> contractIds){

        List<Rental_Contract__c> newContracts = [
            SELECT Id, Tenant__c, Property__c, Start_Date__c, End_Date__c
            FROM Rental_Contract__c
            WHERE Id IN :contractIds
        ];

        List<Rental_Contract__c> contractsToUpdate = new List<Rental_Contract__c>();

        Set<Id> tenantIds = new Set<Id>();
        Set<Id> propertyIds = new Set<Id>();

        for(Rental_Contract__c rc: newContracts){
            if(rc.Tenant__c != null) tenantIds.add(rc.Tenant__c);
            if(rc.Property__c != null) propertyIds.add(rc.Property__c);
        }

        Map<Id,Tenant__c> tenantMap = new Map<Id,Tenant__c>(
            [SELECT Name,Email__c,Phone_Number__c FROM Tenant__c WHERE ID IN: tenantIds]
        );
        Map<Id,Property__c> propertyMap = new Map<Id,Property__c>(
            [SELECT Unique_Id__c FROM Property__c WHERE ID IN: propertyIds]
        );

        for(Rental_Contract__c rc: newContracts){
            try{
                Tenant__c tenant = tenantMap.get(rc.Tenant__c);
                Property__c prop = propertyMap.get(rc.Property__c);

                if(tenant == null || prop == null) continue;

                Map<string,object> payload = new Map<string,object>{
                    'tenantName' => tenant.Name,
                    'tenantEmail' => tenant.Email__c,
                    'tenantMobile' => tenant.Phone_Number__c,
                    'propertyUniqueId' => prop.Unique_Id__c,
                    'contractStartDate' => String.valueOf(rc.Start_Date__c),
                    'contractEndDate' => String.valueOf(rc.End_Date__c)
                };

                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:Ejari_Verify_OAuth/services/apexrest/createTenancyContract');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setBody(JSON.serialize(payload));

                Http http = new Http();
                HttpResponse res = http.send(req);

                if(res.getStatusCode() == 200){
                    Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    String ejariNumber = (String) result.get('ejariNumber');
                    contractsToUpdate.add(new Rental_Contract__c(
                        Id = rc.Id,
                        Ejari_Number__c = ejariNumber,
                        Ejari_Verification_Status__c = 'Verified',
                        Verification_Date__c = system.Today(),
                        Contract_Status__c	= 'Active'
                    ));
                } else {
                    system.debug('callout failed for contract: '+ rc.Id + ' Status: '+ res.getStatusCode());
                }

            } catch(Exception ex){
                system.debug('Exception for Contract '+ rc.Id+ 'Message: '+ ex.getMessage());
                ErrorLogger.logError('Callout',ex.getMessage(),'500', rc.Id,'RentalContractTriggerHandler.sendToEjariSystem');
            }
        }
        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
        }
    } 
    public static void handlePostUpdate(List<Rental_Contract__c> newContracts, Map<Id, Rental_Contract__c> oldContracts) {
        // Collect IDs to query tenant emails
        Set<Id> contractIdsWithEjariUpdate = new Set<Id>();
    
        for (Rental_Contract__c rc : newContracts) {
            Rental_Contract__c oldRc = oldContracts.get(rc.Id);
            if (String.isBlank(oldRc.Ejari_Number__c) && !String.isBlank(rc.Ejari_Number__c)) {
                contractIdsWithEjariUpdate.add(rc.Id);
            }
        }
    
        if (contractIdsWithEjariUpdate.isEmpty()) return;
    
        // Query contracts with related tenant emails
        List<Rental_Contract__c> contractsWithTenantInfo = [
            SELECT Id, Ejari_Number__c, Tenant__r.Email__c, Tenant__r.Name 
            FROM Rental_Contract__c 
            WHERE Id IN :contractIdsWithEjariUpdate
        ];
    
        List<Messaging.SingleEmailMessage> customerEmailsForNotification = new List<Messaging.SingleEmailMessage>();
    
        for (Rental_Contract__c rc : contractsWithTenantInfo) {
            if (rc.Tenant__r != null && !String.isBlank(rc.Tenant__r.Email__c)) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { rc.Tenant__r.Email__c });
                mail.setSubject('Welcome to your New Home - Islamabad Hills Property');
                mail.setPlainTextBody('Dear ' + rc.Tenant__r.Name + ',\n\n' +
                    'Your Ejari number has been successfully generated: ' + rc.Ejari_Number__c + '\n\n' +
                    'Welcome and thank you for choosing our property!\n\n' +
                    'Regards,\nIslamabad Hills Property Management');
                customerEmailsForNotification.add(mail);
            }
        }
    
        if (!customerEmailsForNotification.isEmpty()) {
            Messaging.sendEmail(customerEmailsForNotification);
        }
    }
    public static void handleExpiryContract(List<Rental_Contract__c> newContracts, Map<Id,Rental_Contract__c> oldContracts){
        Set<Id> contractIds = new Set<Id>();
        for(Rental_Contract__c rc: newContracts){
            if(rc.Contract_Status__c == 'Expired' && oldContracts.get(rc.Id).Contract_Status__c != 'Expired'){
                contractIds.add(rc.Id);
            }
        }
        if(!contractIds.isEmpty()){
                System.enqueueJob(new ContractExpiryEmailJob(new List<Id> (contractIds)));
        }
    }
       

}