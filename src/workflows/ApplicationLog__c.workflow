<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>WFR_Email_Devs_on_new_CRITICAL_log</fullName>
        <description>WFR: Email Devs on new CRITICAL log</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sfdc_Developers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/App_CRITICAL_Email_Html</template>
    </alerts>
    <alerts>
        <fullName>WFR_Email_Devs_when_new_error_log_created</fullName>
        <description>WFR: Email Devs when new error log created</description>
        <protected>false</protected>
        <recipients>
            <recipient>Sfdc_Developers</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/App_Error_Email_Html</template>
    </alerts>
    <rules>
        <fullName>Application Log%3A Created CRITICAL log type</fullName>
        <actions>
            <name>WFR_Email_Devs_on_new_CRITICAL_log</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ApplicationLog__c.LogType__c</field>
            <operation>equals</operation>
            <value>CRITICAL</value>
        </criteriaItems>
        <description>Fires when a new Application Log record is created with a log type of CRITICAL</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Application Log%3A Created as error log type</fullName>
        <actions>
            <name>WFR_Email_Devs_when_new_error_log_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ApplicationLog__c.LogType__c</field>
            <operation>equals</operation>
            <value>ERROR</value>
        </criteriaItems>
        <description>Fires when a new Application Log record is created with a log type of ERROR</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
