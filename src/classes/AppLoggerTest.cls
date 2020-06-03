@isTest
private class AppLoggerTest {
    
    @isTest 
    static void testLogger() {
        
        AppLogger logger = new AppLogger('AppLoggerTest');
        try {
            List<Contact> users = new List<Contact>();
            Contact u1 = new Contact(FirstName='test@loggertest.com');
            Contact u2 = new Contact(FirstName='test2@loggertest.com');
            users.add(u1);
            users.add(u2);
            insert users;
        } catch (Exception ex) {
            logger.log(ex);
        }

        try {
            Integer i = 10 / 0;
        } catch (Exception ex) {
            logger.log(ex);
            logger.log(ex, 'testLogger');
        }

        if (logger.isDebugOn)
            logger.log('debug message', 'testLogger', AppLogger.LogType.DEBUG);

        if (logger.isAuditOn)
            logger.log('audit message', 'testLogger', 'Unit Test', AppLogger.LogType.AUDIT);
        
        if (logger.isErrorOn)
            logger.log('error message', 'testLogger', 'Unit Test', AppLogger.LogType.ERROR);

        if (logger.isSecurityOn)
            logger.log('security message', 'testLogger', 'Unit Test', AppLogger.LogType.SECURITY);

        AppLoggerSettings__c settings = AppLoggerSettings__c.getOrgDefaults();
        settings.DisableAll__c = true;
        upsert settings;

        logger = new AppLogger('AppLoggerTest');
        if (logger.isDebugOn)
            logger.log('debug message', 'testLogger', AppLogger.LogType.DEBUG);
    }   

    @isTest
    static void testFailedLogInsert() {
        // exceed 255 character limit for transactionid to force DML error inserting log record
        String longInvalidTransactionId = '................................................................................................................................................................................................................................................................';
        AppLogger logger = new AppLogger(longInvalidTransactionId, 'AppLoggerTest');
        logger.log('debug message', 'testFuture', AppLogger.LogType.DEBUG);
    }

    @isTest
    static void testLoggerFromFuture() {
        testFuture();
    }

    @future
    static void testFuture() {
        AppLogger logger = new AppLogger('AppLoggerTest');
        logger.log('debug message', 'testFuture', AppLogger.LogType.DEBUG);
    }
}