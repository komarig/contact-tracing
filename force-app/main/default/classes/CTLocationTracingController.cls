public with sharing class CTLocationTracingController {
    
    //get location tracing records that matching location ID
    public static List<Location_Tracing__c> getVisitors(String locationId){
        return [SELECT Id, Name, Person__c, Location__c, Visit_Date__c, Person__r.Token__c, Person__r.Health_Status__c 
                FROM Location_Tracing__c 
                WHERE Id=:locationId
                ORDER BY Visit_Date__c DESC];
    }

    //get location tracing records by person ID
    public static List<Location_Tracing__c> getLocationByPersonIds (Set<Id> personIds){
        return [SELECT Id, Person__c, Location__c 
                FROM Location_Tracing__c 
                WHERE Person__c IN :personIds
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    //get location tracing records by location ID and person health
    public static List<Location_Tracing__c> getLocationsByLocationIds (Set<Id> locationIds){
        return [SELECT Id, Person__c, Location__c 
                FROM Location_Tracing__c 
                WHERE Location__c IN :locationIds
                AND Person__r.Health_Status__c ='Green'
                AND Visit_Date__c = LAST_N_DAYS:10];
    }

    //get duplicate location tracing records 
    public static List<Location_Tracing__c> checkDuplicates(List<Location_Tracing__c> newLocationTraces){
        //store location IDs
        Set<Id> locationIds=new Set<Id>();
        //store person IDs
        Set<Id> personIds=new Set<Id>();
        
        for (Location_Tracing__c trace : newLocationTraces) {
            locationIds.add(trace.Location__c);
            personIds.add(trace.Person__c);
        }

        //map of location id, set of person id
        // location1, [person1, person2]
        Map<Id, Set<Id>> mapOfExistingRecords=new Map<Id, Set<Id>>();

        //list of existing tracing records
        List<Location_Tracing__c> existingRecords=[SELECT Id, Person__c, Location__c 
                                                        FROM Location_Tracing__c 
                                                        WHERE Location__c IN :locationIds
                                                        AND Person__c IN :personIds];
        
        //list of duplicate records
        List<Location_Tracing__c> duplicates=new List<Location_Tracing__c>();

        if (existingRecords !=null && existingRecords.size() >0) {
            for (Location_Tracing__c trace : existingRecords) {
                if (!mapOfexistingRecords.containsKey(trace.Location__c)) {
                    mapOfExistingRecords.put(trace.Location__c, new Set<Id>());
                }
                mapOfExistingRecords.get(trace.Location__c).add(trace.Person__c);

                /*
                    Set<Id> personIds=mapOfExistingRecords.get(locationId);
                    personIds.add(personId);
                    mapOfExistingRecords.put(locationId, personId);
                */
            }

            //loop over new location tracing records
            for (Location_Tracing__c trace : newLocationTraces) {
                //first check for location id
                //if item found in map, then check for person id in set
                if (mapOfExistingRecords.containsKey(trace.Location__c) 
                    && mapOfExistingRecords.get(trace.Location__c).contains(trace.Person__c)) {
                    duplicates.add(trace);
                }
            }
        }
        return duplicates;
    }
}
