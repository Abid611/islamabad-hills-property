trigger RentalContractNotificationTrigger on Rental_Contract_Notification__e (after insert) {
    system.debug('Inside event ');
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for(Rental_Contract_Notification__e evt: Trigger.New){
        if(!String.isBlank(evt.Tenant_Email__c)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {evt.Tenant_Email__c});
            mail.setSubject('Welcome to your New Home - Islamabad Hills Property');
            mail.setPlainTextBody('Dear ' + evt.Tenant_Name__c + ',\n\n' +
                'Congratulation! You rented out property: '+evt.Property_Name__c+
                ' Successfully. Your Ejari number has been successfully generated and Ejari number is: ' + evt.Ejari_Number__c + '\n\n' +
                'Welcome and thank you for choosing our property!\n\n' +
                'Regards,\nIslamabad Hills Property Management');
            emails.add(mail);
        }
    }
    if(!emails.isEmpty()){
        system.debug('before sending email');
        Messaging.sendEmail(emails);
    }
}