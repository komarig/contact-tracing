trigger CTPersonTrigger on Person__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            //update health status to green and generate unique token for the person record
            for (Person__c person : Trigger.new) {
                person.Health_Status__c='Green';
                person.Token__c=CTPersonController.getToken(person.Mobile__c);
            }
        }
        when else {
            
        }
    }
}