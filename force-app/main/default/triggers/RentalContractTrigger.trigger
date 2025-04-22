trigger RentalContractTrigger on Rental_Contract__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            RentalContractTriggerHandler.validateContract(Trigger.New);
        }
        if(Trigger.isUpdate){

        }
        if(Trigger.isDelete){

        }
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            RentalContractTriggerHandler.updateRelatedRecordAfterContractCreation(Trigger.New);
            List<Id> contractIds = new List<Id>();
            for (Rental_Contract__c rc : Trigger.new) {
                contractIds.add(rc.Id);
            }
            RentalContractTriggerHandler.sendToEjariSystem(contractIds);
        }
        if(Trigger.isUpdate){
            RentalContractTriggerHandler.handlePostUpdate(Trigger.New,Trigger.oldMap);
            RentalContractTriggerHandler.handleExpiryContract(Trigger.New,Trigger.oldMap);
        }
        if(Trigger.isDelete){

        }
        if(Trigger.isUndelete){

        }
    }
}