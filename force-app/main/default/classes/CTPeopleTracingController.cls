public with sharing class CTPeopleTracingController {
    
    //find all the traces a people by ID
    public static List<People_Tracing__c> getTraces(String personId){
        return [SELECT Id, Contact_Date__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c, Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c 
                FROM People_Tracing__c 
                WHERE Person_1__c =: personId 
                OR Person_2__c =: personId 
                ORDER BY Contact_Date__c DESC];
    }

    //look for duplicates
    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){
        //store unique person ids
        Set<Id> personIds=new Set<Id>();
        for (People_Tracing__c trace : newPeopleTraces) {
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }

        //list for duplicate records
        List<People_Tracing__c> duplicates=new List<People_Tracing__c>();

        //map id and set of id
        Map<Id, Set<Id>> mapOfExistingRecords=new Map<Id, Set<Id>>();
        
        //query existing records
        List<People_Tracing__c> existingRecords=[SELECT Id, Person_1__c, Person_2__c 
                                                FROM People_Tracing__c 
                                                WHERE Person_1__c IN: personIds 
                                                OR Person_2__c IN: personIds];

        if (existingRecords != null && existingRecords.size()>0) {
            for (People_Tracing__c trace : existingRecords) {
                //check person1
                if (mapOfExistingRecords.containsKey(trace.Person_1__c)) {
                    mapOfExistingRecords.put(trace.Person_1__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);

                //check person2
                if (mapOfExistingRecords.containsKey(trace.Person_2__c)) {
                    mapOfExistingRecords.put(trace.Person_2__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);
            }            
        }

        //loop over existing records to find duplicates
        for(People_Tracing__c trace : newPeopleTraces){
            //check for duplicates
            if ((mapOfExistingRecords.containsKey(trace.Person_1__c)&& mapOfExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c))
                || (mapOfExistingRecords.containsKey(trace.Person_2__c)&& mapOfExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))) 
            {
                duplicates.add(trace);
            }
        }
        return duplicates;
    }  
    
}
