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
     * Test the exception process
     *
     * Expected behavior: Triggers are not allowed on custom settings, and this is 
     * only in Test behavior, so the added code to force a break on a trigger of this
     * type will not impact destination organizations.  Highlights the error process
     * if any where to occur.
     */
    @isTest
    public static void testException(){
        TriggerPanel.getBreaker('Account');
        Map<Id, Trigger_Panel__c> panelMap = new Map<Id, Trigger_Panel__c>();
        panelMap.putAll(TriggerPanel.getAllPanels().values());

        Test.startTest();
        SObjectDispatcher dispatch = SObjectDispatcher.init(panelMap.values(), null);
        Test.stopTest();

        System.assertEquals(null, dispatch);
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
        dispatch.execute('beforeInsert');
        dispatch.execute('afterInsert');
        dispatch.execute('beforeUpdate');
        dispatch.execute('afterUpdate');
        dispatch.execute('beforeDelete');
        dispatch.execute('afterDelete');
        dispatch.execute('afterUndelete');
        dispatch.execute('beforeUndelete'); //Invalid context
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
        dispatch.execute('beforeInsert');
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
        TriggerPanel.setSwitch('Account', 'beforeInsert', false);

        Test.startTest();
        dispatch.execute('beforeInsert');
        Test.stopTest();
    }
}