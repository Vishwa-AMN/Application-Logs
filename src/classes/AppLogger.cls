public without sharing class AppLogger {

    private AppLoggerSettings__c logSettings;

    private class AppLoggerDummyException extends Exception {}  // Used to generate a stack trace.

    public enum LogType { DEBUG, ERROR, AUDIT, SECURITY, CRITICAL }
    public String transactionId { get; set; }
    public String apexClass { get; set; }
    public String applicationArea { get; set; }

    public Boolean isDebugOn { 
        get { return !this.logSettings.DisableDebug__c; }
    }

    public Boolean isErrorOn {
        get { return !this.logSettings.DisableError__c; }
    }

    public Boolean isAuditOn {
        get { return !this.logSettings.DisableAudit__c; }
    }

    public Boolean isSecurityOn {
        get { return !this.logSettings.DisableSecurity__c; }
    }

    /*************** CONSTRUCTORS ********************************/

    public AppLogger(String apexClass) {
        this(getGuid(), apexClass, '');
    }

    public AppLogger(String transactionId, String apexClass) {
        this(transactionId, apexClass, '');
    }

    public AppLogger(String transactionId, String apexClass, String applicationArea) {
        if (String.isEmpty(transactionId)) transactionId = getGuid();
        if (applicationArea == null) applicationArea = '';
        this.logSettings = AppLoggerSettings__c.getInstance();
        this.transactionId = transactionId;
        this.apexClass = apexClass;
        this.applicationArea = applicationArea;
    }

    /*************** PUBLIC METHODS ********************************/

    public void log(Exception ex) {
        this.log(ex, '', '', null);
    }

    public void log(Exception ex, String apexMethod) {
        this.log(ex, apexMethod, '', null);
    }

    public void log(Exception ex, String apexMethod, String applicationArea, Id contactId) {        
        
        String message = '';

        if (ex instanceof DmlException) {
            DmlException dmlEx = (DmlException)ex;            
            for (Integer idx = 0; idx < dmlEx.getNumDml(); idx++) {                
                message += '\r\n------------ Dml Error (' + String.valueOf(idx) + ')--------------\r\n';
                message += 'Field Names: ' + String.join(dmlEx.getDmlFieldNames(idx), ',') + '\r\n';
                message += 'Failed Record ID: ' + dmlEx.getDmlId(idx) + '\r\n';
                message += 'Dml Message: ' + dmlEx.getDmlMessage(idx) + '\r\n';
                message += 'Dml Status: ' + dmlEx.getDmlStatusCode(idx) + '\r\n';
                message += 'Dml Type: ' + String.valueOf(dmlEx.getDmlType(idx)) + '\r\n';                
            }
            message += '\r\nStack Trace:\r\n' + ex.getMessage() + '\r\n\r\n' + ex.getStackTraceString();
        } else {
            message = ex.getMessage() + '\r\n\r\n' + ex.getStackTraceString();
        }

        this.log(message, apexMethod, applicationArea, LogType.ERROR, ex.getTypeName(), contactId);
    }

    public void log(String message, String apexMethod, LogType logType) {
        this.log(message, apexMethod, '', logType, '', null);
    }

    public void log(String message, String apexMethod, String applicationArea, LogType logType) {
        this.log(message, apexMethod, applicationArea, logType, '', null);
    }

    public void log(String message, String apexMethod, String applicationArea, LogType logType, String exceptionType, Id contactId) {
        
        // stop here if custom setting is configured to disable all logging or specific log type.
        if (this.isLogTypeDisabled(logType)) return;

        if (String.isEmpty(applicationArea) && String.isNotEmpty(this.applicationArea)) applicationArea = this.applicationArea;

        this.log(message, apexMethod, applicationArea, logType, exceptionType, contactId, null, null);



        //Temporary... until we get dedicated subscriber to write the applicationLog records
//        ApplicationLog__c appLog = new ApplicationLog__c(
//            LogType__c = String.valueOf(logType)
//            ,Message__c = message.abbreviate(131072)
//            ,ApexClass__c = this.apexClass.abbreviate(255)
//            ,ApexMethod__c = apexMethod.abbreviate(255)
//            ,ApplicationArea__c = applicationArea.abbreviate(255)
//            ,ExceptionType__c = exceptionType.abbreviate(255)
//            ,TransactionId__c = this.transactionId
//            ,Contact__c = contactId
//        );
//        this.insertLogRecord(appLog);




    }


    public void log(String message, String apexMethod, String applicationArea, LogType logType, String exceptionType, Id contactId, Id notifyId, String notifyMessage) {

        // stop here if custom setting is configured to disable all logging or specific log type.
        if (this.isLogTypeDisabled(logType)) return;

        if (String.isEmpty(applicationArea) && String.isNotEmpty(this.applicationArea)) applicationArea = this.applicationArea;

        AppLog__e appLog = new AppLog__e(
                LogType__c = String.valueOf(logType)
                ,Message__c = message.abbreviate(131072)
                ,ApexClass__c = this.apexClass.abbreviate(255)
                ,ApexMethod__c = apexMethod.abbreviate(255)
                ,ApplicationArea__c = applicationArea.abbreviate(255)
                ,ExceptionType__c = exceptionType.abbreviate(255)
                ,TransactionId__c = this.transactionId
                ,Contact__c = contactId
                ,NotifyId__c = notifyId //could be a group, user, contact.... may need more thought
                ,NotifyMessage__c = notifyMessage
        );

        EventBus.publish(appLog);

    }


    // create UUID for TransactionId__c
    public static String getGuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertToHex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        return guid;
    }

    public void logError(Exception ex) {
        if (!this.isErrorOn) return;
        this.log(ex, getExceptionMethodName(ex, 0), this.applicationArea, null);
    }

    public void logError(Exception ex, string contactId) {
        if (!this.isErrorOn) return;
        this.log(ex, getExceptionMethodName(ex, 0), this.applicationArea, contactId);
    }

    public void logDebug(string message) {
        if (!this.isDebugOn) return;
        this.log(message, this.getCallerMethodName(), this.applicationArea, LogType.DEBUG);
    }

    public void logDebug(string message, string contactId) {
        if (!this.isDebugOn) return;
        this.log(message, this.getCallerMethodName(), this.applicationArea, LogType.DEBUG, '', contactId);
    }

    /*************** PRIVATE METHODS ********************************/

    // method to handle whether or not to insert via future method
//    private void insertLogRecord(ApplicationLog__c appLog) {
//        if (System.isFuture() || System.isBatch()) {
//            executeDml(appLog);
//        } else {
//            //if calling async, serialize and pass as String since future calls only support primitives
//            executeDmlAsync(JSON.serialize(appLog));
//        }
//    }
//
//    // future call to insert log record.  accepts serialized sobject since future calls can only accept primitive data types
//    @future
//    private static void executeDmlAsync(String serializedSObject) {
//        // change SObject to new ApplicationLog__c object
//        // deserialize sobject and call sync version
//        ApplicationLog__c appLog = (ApplicationLog__c)JSON.deserialize(serializedSObject, ApplicationLog__c.class);
//        executeDml(appLog);
//    }
//
//    // method to insert the log record. ignore any errors caused by this dml
//    private static void executeDml(ApplicationLog__c appLog) {
//        try {
//            insert appLog;
//        } catch (Exception ex) {
//            //swallow errors inserting log records
//            system.debug(ex);
//        }
//    }

    private Boolean isLogTypeDisabled(LogType logType) {
        if (this.logSettings.DisableAll__c) {
            return true;
        }

        if (logType == AppLogger.LogType.DEBUG) {
            return this.logSettings.DisableDebug__c;
        }
        else if (logType == AppLogger.LogType.ERROR) {
            return this.logSettings.DisableError__c;
        }
        else if (logType == AppLogger.LogType.AUDIT) {
            return this.logSettings.DisableAudit__c;
        }
        else if (logType == AppLogger.LogType.SECURITY) {
            return this.logSettings.DisableSecurity__c;
        }

        return false;
    }

    // Get my caller's callers's method name.
    public String getCallerMethodName() {
        return getExceptionMethodName(new AppLoggerDummyException(), 2);
    }

    // Return the method name from the exception stack at the specified level.
    public static String getExceptionMethodName(Exception ex, Integer stackLevel) {
        return getExceptionMethodName(ex, stackLevel, false);
    }

    public static String getExceptionMethodName(Exception ex, Integer stackLevel, Boolean getClass) {
        String stackTrace = ex.getStackTraceString();
        String[] stackLines = stackTrace.split('\\n', stackLevel + 1);
        if (stackLevel >= stackLines.size()) stackLevel = stackLines.size() - 1;
        String traceLine = stackLines[stackLevel];
        String subStr = (getClass ? 'Class.' :'.');
        String methodName = traceLine.substringBefore(':').substringAfterLast(subStr);
        return methodName;
    }

    public static void createExceptionAppLog(Exception ex, String appClass, String appArea, String logType){
        // Return the class and method name from the exception stack at the specified level.
        String method = AppLogger.getExceptionMethodName(ex, 2, true);
        if (String.isEmpty(method))
            method = AppLogger.getExceptionMethodName(ex, 1, true);

        String msg = ex.getStackTraceString();
        AppLog__e appLog = new AppLog__e(
                LogType__c = String.isNotEmpty(logType) ? logType.abbreviate(255) : ''
                ,Message__c = msg.abbreviate(131072)
                ,ApexClass__c =  String.isNotEmpty(appClass) ? appClass.abbreviate(255) : ''
                ,ApexMethod__c = String.isNotEmpty(method) ? method.abbreviate(255) : ''
                ,ApplicationArea__c = String.isNotEmpty(appArea) ? appArea.abbreviate(255) : ''
                ,ExceptionType__c = null
                ,TransactionId__c = null
                ,Contact__c = null
                ,NotifyId__c = null
                ,NotifyMessage__c = null
        );

        EventBus.publish(appLog);

//        ApplicationLog__c appLog = new ApplicationLog__c(ApexClass__c = String.isNotEmpty(appClass) ? appClass.abbreviate(255) : ''
//                , ApexMethod__c = String.isNotEmpty(method) ? method.abbreviate(255) : ''
//                , ApplicationArea__c = String.isNotEmpty(appArea) ? appArea.abbreviate(255) : ''
//                , LogType__c = String.isNotEmpty(logType) ? logType.abbreviate(255) : ''
//                , Message__c = msg.abbreviate(131072) //Abbreviating to Making sure message not bigger than field size
//        );
//        //if (System.isFuture() || System.isBatch()) {
//            executeDml(appLog);
//        //} else {
//        //    executeDmlAsync(JSON.serialize(appLog));
//        //}
    }
}