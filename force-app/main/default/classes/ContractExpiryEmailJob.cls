public class ContractExpiryEmailJob implements Queueable{

    private List<Id> contractIds;
    public ContractExpiryEmailJob(LIst<Id> contractIds){
        this.contractIds = contractIds;
    }
    public void execute(QueueableContext context){
        List<Rental_Contract__c> contracts = [
        SELECT Id, Tenant__r.Email__c, Tenant__r.Name,Property__r.Name
        FROM Rental_Contract__c 
        WHERE Id IN :contractIds
        ];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Rental_Contract__c rc: contracts){
            if(!String.isBlank(rc.Tenant__r.Email__c)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new string[] {rc.Tenant__r.Email__c});
                mail.setSubject('Your Rental Contract is Expired - ISLAMABAD HILL PROPERTY MANAGEMENT');
                mail.setPlainTextBody('Dear ' + rc.Tenant__r.Name + ',\n\n' +
                    'Your contract for property ' + rc.Property__r.Name + ' has expired. Please contact us for renewal or closure.\n\n' +
                    'Regards,\nIHPM Team');
                emails.add(mail);
            }  
        }
        
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }      
    }
}