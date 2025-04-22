global  class RentalContractExpiryScheduler implements schedulable{
    global void execute(SchedulableContext sc){
        RentalContractExpiryBatch batch = new RentalContractExpiryBatch();
        Database.executeBatch(batch, 100);
    }
}