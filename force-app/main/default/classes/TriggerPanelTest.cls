@isTest
public class TriggerPanelTest {

    @TestSetup
    static void prepData(){
        Trigger_Settings__c settings = new Trigger_Settings__c();
        settings.Trigger_Configuration__c = 'TestConfiguration';
        settings.SetupOwnerId = UserInfo.getUserId();
        insert settings;
    }

    /**
     * Testing the 'GetAllPanels' function when no records are currently in database
     *
     * Expected behavior: When requested a map is always returned (even if empty)
     */
    @isTest
    public static void testGetAllNoRecords(){
        System.assertEquals(null, TriggerPanel.panelMap);
        System.assertNotEquals(null, TriggerPanel.getAllPanels());
        System.assertNotEquals(null, TriggerPanel.panelMap);
        System.assertEquals(1, TriggerPanel.panelMap.size());
    }

    /**
     * Testing the get 'GetAllPanels' function when records are currently in database
     *
     * Expected behavior: When requested a map is returned and contains a
     * static copy of the database (that can be updated) with the transaction
     */
    @isTest
    public static void testGetAllWithRecords(){
        Test.startTest();
        System.assertEquals(null, TriggerPanel.panelMap);
        System.assertNotEquals(null, TriggerPanel.getAllPanels());
        System.assertNotEquals(null, TriggerPanel.panelMap);
        System.assertEquals(1, TriggerPanel.panelMap.size());
        TriggerPanel.getAllPanels().clear();
        System.assertEquals(0, TriggerPanel.panelMap.size());
        Test.stopTest();
    }

    /**
     * Testing the 'GetPanel' function when no records are currently in database
     *
     * Expected behavior: When requested and no matching record is found,
     * the default is created and returned.  It is also saved in the map for
     * future reference.
     */
    @isTest
    public static void testGetRecordNoRecords(){
        System.assertEquals(1, TriggerPanel.getAllPanels().size());

        Test.startTest();
        Trigger_Panel__mdt panel = TriggerPanel.getPanel('Account');
        Test.stopTest();

        System.assertEquals(2, TriggerPanel.getAllPanels().size());
        System.assertEquals(true, panel.Breaker__c);
        System.assertEquals(true, panel.Before_Insert__c);
        System.assertEquals(true, panel.After_Insert__c);
        System.assertEquals(true, panel.Before_Update__c);
        System.assertEquals(true, panel.After_Update__c);
        System.assertEquals(true, panel.Before_Delete__c);
        System.assertEquals(true, panel.After_Delete__c);
        System.assertEquals(true, panel.After_Undelete__c);
    }

    /**
     * Testing the 'GetPanel' function when records are currently in database
     *
     * Expected behavior: When requested and a matching record is found,
     * the record is return.
     */
    @isTest
    public static void testGetRecordWithRecords(){
        System.assertEquals(1, TriggerPanel.getAllPanels().size());

        Test.startTest();
        Trigger_Panel__mdt panel = TriggerPanel.getPanel('Account');
        Test.stopTest();

        System.assertEquals(2, TriggerPanel.getAllPanels().size());
        System.assertEquals(true, panel.Breaker__c);
        
    }

    /**
     * Testing the 'GetBreaker' function with no record in the database
     *
     * Expected behavior: When requested, the default record will be 
     * generated and return the default value of 'true'.
     */
    @isTest
    public static void testGetBreakerNull(){
        System.assert(TriggerPanel.getBreaker('Account'));
    }
    
    /**
     * Testing the 'GetBreaker' function with a record in the database
     *
     * Expected behavior: When requested, the value will be returned.
     */
    @isTest
    public static void testGetBreakerValid(){        
        Test.startTest();
        System.assertEquals(false, TriggerPanel.getBreaker('EBEDUTriggerSettingsc'));
        Test.stopTest();
    }
    
    /**
     * Testing the 'SetBreaker' function with no record in the database
     *
     * Expected behavior: When requested, the default record will be 
     * generated and the value is saved to the record for access in this
     * transaction.
     */
    @isTest
    public static void testSetBreakerNull(){
        Test.startTest();
        TriggerPanel.setBreaker('Account', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getBreaker('Account'));
    }
    
    /**
     * Testing the 'SetBreaker' function with a record in the database
     *
     * Expected behavior: When requested, the record will be returned and
     * the value is updated for this transaction only.
     */
    @isTest
    public static void testSetBreakerValid(){

        
        Test.startTest();
        TriggerPanel.setBreaker('Account', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getBreaker('Account'));
        
    }
    
    /**
     * Testing the 'GetSwitch' function with no record in the database
     *
     * Expected behavior: When requested, the default record will be 
     * generated and return the default value of 'true'.
     */
    @isTest
    public static void testGetSwitchNull(){
        System.assert(TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
    }
    
    /**
     * Testing the 'GetSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the value will be returned.
     */
    @isTest
    public static void testGetSwitchValid(){
        Test.startTest();
        System.assertEquals(false, TriggerPanel.getSwitch('EBEDUTriggerSettingsc', 'AFTER_INSERT'));
        Test.stopTest();
    }
    
    /**
     * Testing the 'SetSwitch' function with no record in the database
     *
     * Expected behavior: When requested, the default record will be 
     * generated and the value is saved to the record for access in this
     * transaction.
     */
    @isTest
    public static void testSetSwitchNull(){
        Test.startTest();
        TriggerPanel.setSwitch('Account', 'AFTER_INSERT', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
    }
    
    /**
     * Testing the 'SetSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the record will be returned and
     * the value is updated for this transaction only.
     */
    @isTest
    public static void testSetSwitchValid(){

        
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
        
        Test.startTest();
        TriggerPanel.setSwitch('Account', 'AFTER_INSERT', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
    }
    
    /**
     * Testing the 'SetAllSwitch' function with no record in the database
     *
     * Expected behavior: When requested, the default record will be 
     * generated and the value is saved to the record for all contexts for access in 
     * this transaction.
     */
    @isTest
    public static void testSetAllSwitchesNull(){
        Test.startTest();
        TriggerPanel.setAllSwitches('Account', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_INSERT'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_UPDATE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_UPDATE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_DELETE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_DELETE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_UNDELETE'));
    }
    
    /**
     * Testing the 'SetAllSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the record will be returned and
     * the value is saved to all contexts for this transaction only.
     */
    @isTest
    public static void testSetAllSwitchesValid(){        
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_INSERT'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_UPDATE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_UPDATE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_DELETE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_DELETE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_UNDELETE'));
        
        Test.startTest();
        TriggerPanel.setAllSwitches('Account', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_INSERT'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_UPDATE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_UPDATE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'BEFORE_DELETE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_DELETE'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'AFTER_UNDELETE'));
    }
    
    /**
     * Testing the 'Reset' function with a single value in cache
     *
     * Expected behavior: All switches will be reset to the default true
     */
    @isTest
    public static void testReset(){
        TriggerPanel.setAllSwitches('Account', false);
        
        Test.startTest();
        TriggerPanel.reset('Account');
        Test.stopTest();
        
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_INSERT'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_INSERT'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_UPDATE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_UPDATE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'BEFORE_DELETE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_DELETE'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'AFTER_UNDELETE'));
    }
    
    /**
     * Testing the 'Reset' function with a no values in cache
     *
     * Expected behavior: No exception thrown
     */
    @isTest
    public static void testResetNull(){
        Test.startTest();
        TriggerPanel.reset('Account');
        Test.stopTest();
        
        //Successful if no error thrown
        System.assert(true);
    }
    
    /**
     * Testing the 'ResetAll' function with a value in cache
     *
     * Expected behavior: No exception thrown
     */
    @isTest
    public static void testResetAll(){
        TriggerPanel.setBreaker('Account', false);
        
        Test.startTest();
        TriggerPanel.resetAll();
        Test.stopTest();
        
        System.assertEquals(null, TriggerPanel.panelMap);
    }
}