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
        }
        if(Trigger.isUpdate){

        }
        if(Trigger.isDelete){

        }
        if(Trigger.isUndelete){

        }
    }
}