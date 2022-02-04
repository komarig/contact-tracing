public with sharing class CTPersonController {

    //generate hash out of mobile number
    public static String getToken(String mobileNo){
        Blob value= Blob.valueOf(mobileNo);
        Blob hash=Crypto.generateDigest('MD5', value);

        //get the string value of hash blob
        return EncodingUtil.base64Encode(hash);
    }

    //query person records limit to 100
    public static List<Person__c> getRecentHealthChanges(){
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                ORDER BY Status_Update_Date__c DESC 
                NULLS LAST 
                LIMIT 100];
    }

    //query person records thet matches the search term
    public static List<Person__c> searchPeople(String searchTerm){
        searchTerm=searchTerm+'%';
        return [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
        FROM Person__c 
        WHERE Name LIKE :searchTerm 
                OR Mobile__c LIKE :searchTerm 
                OR Token__c LIKE :searchTerm 
        ORDER BY Status_Update_Date__c DESC 
        NULLS LAST];
    }

    //get person by ID
    public static Person__c getPersonById(String personId){
        List<Person__c> people = [SELECT Id, Name, Health_Status__c, Mobile__c, Status_Update_Date__c, Token__c 
                FROM Person__c 
                WHERE Id=:personId];
        
        if (people!=null && people.size()>0) {
            return people[0];
        }
        return null;
    }

    //number of people in each health status
    public static Map<String, Integer> getHealthStatusCount(){

        Map<String, Integer> healthCountMap=new Map<String,Integer>();

        for (AggregateResult ar : [SELECT Health_Status__c, COUNT(Id) total FROM Person__c GROUP BY Health_Status__c]) {

            healthCountMap.put(String.valueOf(ar.get('Health_Status__c')), Integer.valueOf(ar.get('total')));
        }
        return healthCountMap;
    }

}
