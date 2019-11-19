@isTest
public class SObjectDispatcherTest {

    /**
     * Testing the 'Init' method with a generic value
     *
     * Expected behavior: The init will run and the handler will
     * have a typeName of 'SObject'.  Note that for testing we do not have
     * any actual object handlers, so the generic is used.
     */
    @isTest
    public static void testInit_Valid(){
        Test.startTest();
        SObjectHandler handler = SObjectDispatcher.init('SObject');
        Test.stopTest();

        System.assertEquals('SObject', handler.typeName);
    }

    /**
     * Testing the 'Init' method with a invalid value
     *
     * Expected behavior: The init will run and the handler returned
     * will be null.
     */
    @isTest
    public static void testInit_Invalid(){
        Test.startTest();
        SObjectHandler handler = SObjectDispatcher.init('InvalidTypeName');
        Test.stopTest();

        System.assertEquals(null, handler);
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
        Exception ex;

        Test.startTest();
        try{
            SObjectHandler handler = SObjectDispatcher.init('Exception');
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
            SObjectHandler handler = SObjectDispatcher.init('Exception');
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

}