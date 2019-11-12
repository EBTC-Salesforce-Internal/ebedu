@isTest
public class SObjectDispatcherTest {

    /**
     * Testing the 'Init' method with a newList value
     *
     * Expected behavior: The init will run and the dispatcher will
     * have a typeName of 'Account'.  Note that for testing we do not have
     * any actual object dispatchers, so the generic is used.
     */
    @isTest
    public static void testNewListInit(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());

        Test.startTest();
        SObjectDispatcher dispatch = SObjectDispatcher.init(accounts, null);
        Test.stopTest();

        System.assertEquals('Account', dispatch.typeName);
    }

    /**
     * Testing the 'Init' method with a oldMap value
     *
     * Expected behavior: The init will run and the dispatcher will
     * have a typeName of 'Account'.  Note that for testing we do not have
     * any actual object dispatchers, so the generic is used.
     */
    @isTest
    public static void testOldMapInit(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(accounts);

        Test.startTest();
        SObjectDispatcher dispatch = SObjectDispatcher.init(null, accountMap);
        Test.stopTest();

        System.assertEquals('Account', dispatch.typeName);
    }

    /**
     * Testing the 'Init' method with a null values
     *
     * Expected behavior: In practice, this would return a null value for the
     * dispatcher.  However for testing we are forcing the SObject dispatcher,
     * hence we anticipate an '' typeName that would cause a null during runtime.
     */
    @isTest
    public static void testNullInit(){
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(accounts);

        Test.startTest();
        SObjectDispatcher dispatch = SObjectDispatcher.init(null, null);
        Test.stopTest();

        System.assertEquals('', dispatch.typeName);
    }

    /**
     * Test the init exception process
     *
     * Expected behavior: Triggers are not allowed on custom settings, and this is
     * only in Test behavior, so the added code to force a break on a trigger of this
     * type will not impact destination organizations.  Highlights the error process
     * if any where to occur.
     */
    @isTest
    public static void testInitException(){
        Map<Id, Trigger_Settings__c> panelMap = new Map<Id, Trigger_Settings__c>();

        Exception ex;

        Test.startTest();
        try{
            SObjectDispatcher dispatch = SObjectDispatcher.init(panelMap.values(), null);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, ex);
        System.assertEquals('System.SObjectException', ex.getTypeName());
        System.assert(ex.getMessage().contains('Triggers are not supported'));
    }

    /**
     * Test the init exception process when masking is enabled
     *
     * Expected behavior: The error is thrown, but masked by a generic error message
     * with an EBEDU exception type.
     */
    @isTest
    public static void testInitException_Masked(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        settings.Mask_Detailed_Exceptions__c = true;
        insert settings;

        Map<Id, Trigger_Settings__c> panelMap = new Map<Id, Trigger_Settings__c>();

        Exception ex;

        Test.startTest();
        try{
            SObjectDispatcher dispatch = SObjectDispatcher.init(panelMap.values(), null);
        }catch(Exception e){
            ex = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, ex);
        System.assertEquals('EBEDU.SObjectDispatcher.EBEDU_Exception', ex.getTypeName());
        System.assert(ex.getMessage().contains('Triggers are not supported') == false);
    }

    /**
     * Testing the exception process when no masking is enabled
     *
     * Expected behavior: The same error that was originally encountered should be re-thrown
     */
    @isTest
    public static void testHandleException_Standard(){
        Exception excep;

        try{
            Integer value = 1 / 0;
        }catch(Exception ex){
            excep = ex;
        }

        Test.startTest();

        try{
            SObjectDispatcher.handleException(null, excep, null);
            //Handler is expected to re-throw the same exception
            System.assert(false);
        }catch(Exception ex){
            System.assertEquals(excep.getTypeName(), ex.getTypeName());
        }
    }

    /**
     * Testing the exception process when masking is enabled
     *
     * Expected behavior: The same error that was originally encountered should be re-thrown
     */
    @isTest
    public static void testHandleException_Masked(){
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

        List<Account> accs = new List<Account>();
        Account a = new Account();
        a.Name = 'Test Account';
        accs.add(a);

        Test.startTest();

        SObjectDispatcher.handleException(null, excep, accs);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assertEquals(System.Label.EBEDU_Generic_Error_Message, ApexPages.getMessages()[0].getSummary());
    }

    /**
     * Testing the exception process when masking is enabled and a DML operation
     *
     * Expected behavior: The same error that was originally encountered should be re-thrown
     */
    @isTest
    public static void testHandleException_MaskedDML(){
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

        Test.startTest();

        SObjectDispatcher.handleException('Account', excep, accs);

        Test.stopTest();

        System.assertEquals(true, ApexPages.hasMessages());
        System.assert(ApexPages.getMessages()[1].getSummary().contains(System.Label.EBEDU_Generic_DML_Error_Message));
    }

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
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());
        SObjectDispatcher dispatch = SObjectDispatcher.init(accounts, null);

        Test.startTest();
        dispatch.execute(TriggerOperation.BEFORE_INSERT);
        dispatch.execute(TriggerOperation.AFTER_INSERT);
        dispatch.execute(TriggerOperation.BEFORE_UPDATE);
        dispatch.execute(TriggerOperation.AFTER_UPDATE);
        dispatch.execute(TriggerOperation.BEFORE_DELETE);
        dispatch.execute(TriggerOperation.AFTER_DELETE);
        dispatch.execute(TriggerOperation.AFTER_UNDELETE);
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
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(accounts);
        SObjectDispatcher dispatch = SObjectDispatcher.init(accounts, null);
        TriggerPanel.setBreaker('Account', false);

        Test.startTest();
        dispatch.execute(TriggerOperation.BEFORE_INSERT);
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
        List<Account> accounts = new List<Account>();
        accounts.add(new Account());
        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.putAll(accounts);
        SObjectDispatcher dispatch = SObjectDispatcher.init(accounts, null);
        TriggerPanel.setSwitch('Account', 'BEFORE_INSERT', false);

        Test.startTest();
        dispatch.execute(TriggerOperation.BEFORE_INSERT);
        Test.stopTest();
    }
}