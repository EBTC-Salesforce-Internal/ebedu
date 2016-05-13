@isTest
public class TriggerPanelTest {

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
        System.assertEquals(0, TriggerPanel.panelMap.size());
    }

    /**
     * Testing the get 'GetAllPanels' function when records are currently in database
     *
     * Expected behavior: When requested a map is returned and contains a
     * static copy of the database (that can be updated) with the transaction
     */
    @isTest
    public static void testGetAllWithRecords(){
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        panel.Breaker__c = false;
        insert panel;

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
        System.assertEquals(0, TriggerPanel.getAllPanels().size());

        Test.startTest();
        Trigger_Panel__c panel = TriggerPanel.getPanel('Account');
        Test.stopTest();

        System.assertEquals(1, TriggerPanel.getAllPanels().size());
        System.assertEquals(true, panel.Breaker__c);
        System.assertEquals(true, panel.BeforeInsert__c);
        System.assertEquals(true, panel.AfterInsert__c);
        System.assertEquals(true, panel.BeforeUpdate__c);
        System.assertEquals(true, panel.AfterUpdate__c);
        System.assertEquals(true, panel.BeforeDelete__c);
        System.assertEquals(true, panel.AfterDelete__c);
        System.assertEquals(true, panel.AfterUndelete__c);
    }

    /**
     * Testing the 'GetPanel' function when records are currently in database
     *
     * Expected behavior: When requested and a matching record is found,
     * the record is return.
     */
    @isTest
    public static void testGetRecordWithRecords(){
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        panel.Breaker__c = false;
        insert panel;

        System.assertEquals(1, TriggerPanel.getAllPanels().size());

        Test.startTest();
        panel = TriggerPanel.getPanel('Account');
        Test.stopTest();

        System.assertEquals(1, TriggerPanel.getAllPanels().size());
        System.assertEquals(false, panel.Breaker__c);
        
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
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        panel.Breaker__c = false;
        insert panel;
        
        Test.startTest();
        System.assertEquals(false, TriggerPanel.getBreaker('Account'));
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
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        panel.Breaker__c = false;
        insert panel;
        
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
        System.assert(TriggerPanel.getSwitch('Account', 'afterInsert'));
    }
    
    /**
     * Testing the 'GetSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the value will be returned.
     */
    @isTest
    public static void testGetSwitchValid(){
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        panel.afterInsert__c = false;
        insert panel;
        
        Test.startTest();
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterInsert'));
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
        TriggerPanel.setSwitch('Account', 'afterInsert', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterInsert'));
    }
    
    /**
     * Testing the 'SetSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the record will be returned and
     * the value is updated for this transaction only.
     */
    @isTest
    public static void testSetSwitchValid(){
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        insert panel;
        
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'afterInsert'));
        
        Test.startTest();
        TriggerPanel.setSwitch('Account', 'afterInsert', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterInsert'));
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
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeInsert'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterInsert'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeUpdate'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterUpdate'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeDelete'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterDelete'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterUndelete'));
    }
    
    /**
     * Testing the 'SetAllSwitch' function with a record in the database
     *
     * Expected behavior: When requested, the record will be returned and
     * the value is saved to all contexts for this transaction only.
     */
    @isTest
    public static void testSetAllSwitchesValid(){
        Trigger_Panel__c panel = new Trigger_Panel__c();
        panel.Name = 'Account';
        insert panel;
        
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'beforeInsert'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'afterInsert'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'beforeUpdate'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'afterUpdate'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'beforeDelete'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'afterDelete'));
        System.assertEquals(true, TriggerPanel.getSwitch('Account', 'afterUndelete'));
        
        Test.startTest();
        TriggerPanel.setAllSwitches('Account', false);
        Test.stopTest();
        
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeInsert'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterInsert'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeUpdate'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterUpdate'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'beforeDelete'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterDelete'));
        System.assertEquals(false, TriggerPanel.getSwitch('Account', 'afterUndelete'));
    }
}