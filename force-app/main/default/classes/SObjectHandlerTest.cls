@isTest
public class SObjectHandlerTest {

    /**
     * Test all contexts of the execute method (including invalid)
     *
     * Expected behavior: Each of the context methods run.  The invalid context will
     * not run as there is no switch for it in the TriggerPanel.
     *
     * Note: There is no good way I have found to make sure the methods actually run
     * except to see the code coverage.
     */
    @isTest
    public static void testExecuteAllContexts(){

        SObjectHandler handler = SObjectDispatcher.init('SObject');

        Test.startTest();
        handler.execute(TriggerOperation.BEFORE_INSERT, null, null);
        handler.execute(TriggerOperation.AFTER_INSERT, null, null);
        handler.execute(TriggerOperation.BEFORE_UPDATE, null, null);
        handler.execute(TriggerOperation.AFTER_UPDATE, null, null);
        handler.execute(TriggerOperation.BEFORE_DELETE, null, null);
        handler.execute(TriggerOperation.AFTER_DELETE, null, null);
        handler.execute(TriggerOperation.AFTER_UNDELETE, null, null);
        Test.stopTest();
    }

    /**
     * Test the execute method when a TriggerPanel breaker is false
     *
     * Expected Behavior: The prep, context, and finally methods are not run as the breaker short
     * circuits execution.
     *
     * Note: There is no good way I have found to make sure the methods actually run
     * except to see the code coverage.
     */
    @isTest
    public static void testExecuteBreakerFalse(){

        SObjectHandler handler = SObjectDispatcher.init('SObject');
        TriggerPanel.setBreaker('SObject', false);

        Test.startTest();
        handler.execute(TriggerOperation.BEFORE_INSERT, null, null);
        Test.stopTest();
    }


    /**
     * Test the execute method when a TriggerPanel switch is false
     *
     * Expected Behavior: The prep and finally methods are run but the context method
     * is not run as the switch short circuits execution.
     *
     * Note: There is no good way I have found to make sure the methods actually run
     * except to see the code coverage.
     */
    @isTest
    public static void testExecuteSwitchFalse(){

        SObjectHandler handler = SObjectDispatcher.init('SObject');
        TriggerPanel.setSwitch('Account', 'BEFORE_INSERT', false);

        Test.startTest();
        handler.execute(TriggerOperation.BEFORE_INSERT, null, null);
        Test.stopTest();
    }

    @isTest
    public static void testHandleException_NewList(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Mask_Detailed_Exceptions__c = true;
        insert settings;

        Exception excep;

        try{
            Integer value = 1 / 0;
        }catch(Exception ex){
            excep = ex;
        }

        List<SObject> objs = new List<SObject>();
        Account a = new Account();
        a.Name = 'Test Account';
        objs.add(a);

        Map<Id, SObject> objMap = new Map<Id, SObject>();
        objMap.putAll(objs);

        SObjectHandler handler = SObjectDispatcher.init('SObject');

        Test.startTest();

        handler.handleException(TriggerOperation.AFTER_INSERT, excep, objs, objMap);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assertEquals(System.Label.EBEDU_Generic_Error_Message, ApexPages.getMessages()[0].getSummary());
    }

    @isTest
    public static void testHandleException_OldMap(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Mask_Detailed_Exceptions__c = true;
        insert settings;

        Exception excep;

        try{
            Integer value = 1 / 0;
        }catch(Exception ex){
            excep = ex;
        }

        List<SObject> objs = new List<SObject>();
        Account a = new Account();
        a.Name = 'Test Account';
        objs.add(a);

        Map<Id, SObject> objMap = new Map<Id, SObject>();
        objMap.putAll(objs);

        SObjectHandler handler = SObjectDispatcher.init('SObject');

        Test.startTest();

        handler.handleException(TriggerOperation.AFTER_DELETE, excep, objs, objMap);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assertEquals(System.Label.EBEDU_Generic_Error_Message, ApexPages.getMessages()[0].getSummary());
    }
}
