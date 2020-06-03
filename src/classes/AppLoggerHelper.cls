/**
 * Created by Tim.Peterson on 8/23/2019.
 */

public without sharing class AppLoggerHelper {

    public static void storeApplicationLogEntry(List<AppLog__e> logList){
        List<ApplicationLog__c> logsToInsert = new List<ApplicationLog__c>();
        for(AppLog__e log : logList)
        {
            ApplicationLog__c appLog = new ApplicationLog__c(
                    LogType__c = log.LogType__c
                    ,Message__c = log.Message__c
                    ,ApexClass__c = log.ApexClass__c
                    ,ApexMethod__c = log.ApexMethod__c
                    ,ApplicationArea__c = log.ApplicationArea__c
                    ,ExceptionType__c = log.ExceptionType__c
                    ,TransactionId__c = log.TransactionId__c
                    ,Contact__c = log.Contact__c
            );


            logsToInsert.add(appLog);
        }


        insert logsToInsert;
    }
}