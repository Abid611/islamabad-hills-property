List<Property__c> properties = new List<Property__c>();

for (Integer i = 1; i <= 5; i++) {
    String typeVal = (Math.mod(i, 2) == 0) ? 'Apartment' : 'Villa';

    properties.add(new Property__c(
        Name = 'Property ' + i,
        Type__c = typeVal,
        Address__c = 'Block ' + i + ', Dubai',
        Rent_Amount__c = 2000 + (i * 500),
        Status__c = 'Available'
    ));
}

insert properties;
System.debug('✅ Dummy Property Records Inserted.');
