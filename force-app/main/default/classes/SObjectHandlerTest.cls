@isTest
public class SObjectHandlerTest {

    /**
     * Test all contexts of the execute method
     *
     * Expected behavior: Each of the context methods run.
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
     * Expected Behavior: The methods should not run.
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
        handler.execute(TriggerOperation.AFTER_INSERT, null, null);
        Test.stopTest();
    }


    /**
     * Test the execute method when a TriggerPanel switch is false
     *
     * Expected Behavior: The method should not run.
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

    /**
     * Test the exception handling when only a new list is present.
     *
     * Expected Behavior: The exception method should process normally.
     *
     */
    @isTest
    public static void testHandleException_NewList(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Mask_Detailed_Exceptions__c = true;
        insert settings;

        Exception excep;

        List<Account> accs = new List<Account>();
        try{
            Account a1 = new Account();
            a1.Name = 'Test Account 1';
            accs.add(a1);

            Account a2 = new Account();
            a2.Name = 'Test Account 1';
            a2.AccountNumber = '12345678901234567890123456789012345678901';
            accs.add(a2);

            insert accs;
            //This throws a DML error due to the field size limit of 40 on AccountNumber.
        }catch(Exception ex){
            excep = ex;
        }

        SObjectHandler handler = SObjectDispatcher.init('SObject');

        Test.startTest();

        handler.handleException(TriggerOperation.AFTER_INSERT, excep, accs, null);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assert(ApexPages.getMessages()[1].getSummary().contains(System.Label.EDHU_Generic_DML_Error_Message));
    }

    /**
     * Test the exception handling when only a old list is present.
     *
     * Expected Behavior: The exception method should process normally.
     *
     */
    @isTest
    public static void testHandleException_OldList(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Mask_Detailed_Exceptions__c = true;
        insert settings;

        Exception excep;

        List<Account> accs = new List<Account>();
        try{
            Account a1 = new Account();
            a1.Name = 'Test Account 1';
            accs.add(a1);

            Account a2 = new Account();
            a2.Name = 'Test Account 1';
            a2.AccountNumber = '12345678901234567890123456789012345678901';
            accs.add(a2);

            insert accs;
            //This throws a DML error due to the field size limit of 40 on AccountNumber.
        }catch(Exception ex){
            excep = ex;
        }

        SObjectHandler handler = SObjectDispatcher.init('SObject');

        Test.startTest();

        handler.handleException(TriggerOperation.AFTER_DELETE, excep, null, accs);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assert(ApexPages.getMessages()[1].getSummary().contains(System.Label.EDHU_Generic_DML_Error_Message));
    }
}
