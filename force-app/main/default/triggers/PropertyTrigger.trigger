trigger PropertyTrigger on Property__c (before insert,before update,before delete,after insert,after update,after delete,after undelete) {

    if(Trigger.isBefore){
        
        if(Trigger.isInsert){
            
            PropertyTriggerHandler.validateRent(Trigger.new);
        }
        if(Trigger.isUpdate){
            
            PropertyTriggerHandler.validateRent(Trigger.new);
        }
    }
    if(Trigger.isAfter){

    }
}