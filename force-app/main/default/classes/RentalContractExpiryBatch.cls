global  class RentalContractExpiryBatch implements Database.Batchable<SObject>, Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([
            SELECT Id, End_Date__c, Contract_Status__c 
            FROM Rental_Contract__c 
            WHERE End_Date__c < :Date.today()
            AND Contract_Status__c != 'Expired'
            AND Ejari_Verification_Status__c = 'Verified'
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Rental_Contract__c> scope){
        for(Rental_Contract__c rc: scope){
            rc.Contract_Status__c = 'Expired';
        }
        update scope;
    }

    global void finish(Database.BatchableContext bc){

    }
    
}