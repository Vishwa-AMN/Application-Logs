/**
 * Created by Tim.Peterson on 8/23/2019.
 */

trigger AppLogEventHandler on AppLog__e (after insert) {
    AppLoggerHelper.storeApplicationLogEntry((List<AppLog__e>)Trigger.new);

}