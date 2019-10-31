global class TriggerPanel {

    /**
     * Private variable that controls global trigger execution.
     */
    @testVisible
    private static Boolean mainSwitch;
    
    
    /**
     * Private variable that maintains the panel settings during the execution context.
     */
    @testVisible
    private static Map<String, Trigger_Panel__mdt> panelMap;
    
    /*
     * Private variable that maintains the previous status of switches and breakers 
     * (caputred during set method call).
     */    
    @testVisible
    private static Map<String, Boolean> stateHistory= new Map<String, Boolean>();
    
    /**
     * Global accessor for the main switch. This controls the execution of all triggers collectively. 
     */
    global static Boolean getMainBreaker(){
        if(mainSwitch == null){
            mainSwitch = Trigger_Settings__c.getInstance().Bypass_Triggers__c == false;
        }
        return mainSwitch;
    }
    
    /*
     * Global settor for the main switch. This controls the execution of all triggers collectively.
     */
    global static void setMainBreaker(Boolean active){
        setPriorStatus('Main', null, getMainBreaker());
        mainSwitch = active;
    }
    
    /**
     * Global method for reverting the main switch the the immediately previous value. Defaults to true. 
     */
    global static void revertMainBreaker(){
        setMainBreaker(getPriorStatus('Main', null));
    }
    
    /**
     * Global accessor for single TriggerPanel records. If no record is found, a default
     * is created with breaker and switches set to true.
     */
    global static Trigger_Panel__mdt getPanel(String typeName){
        Map<String, Trigger_Panel__mdt> panels = getAllPanels();
        if(panels.containsKey(typeName) == false){
            Trigger_Panel__mdt panel = (Trigger_Panel__mdt) Trigger_Panel__mdt.sObjectType.newSObject(null, true);
            panel.DeveloperName = typeName;
            panels.put(typeName, panel);
        }
        return panels.get(typeName);
    }

    /**
     * Global accessor for TriggerPanel records.
     */
    global static Map<String, Trigger_Panel__mdt> getAllPanels(){
        String configurationName = Trigger_Settings__c.getInstance().Trigger_Configuration__c;
        if(configurationName == null){
            configurationName = 'Default';
        }

        if(panelMap == null){
            panelMap = new Map<String, Trigger_Panel__mdt>();
            for(Trigger_Panel__mdt panel:[  SELECT  Id, DeveloperName, Breaker__c, Before_Insert__c, After_Insert__c, 
                                                    Before_Update__c, After_Update__c, Before_Delete__c, After_Delete__c, 
                                                    After_Undelete__c 
                                            FROM    Trigger_Panel__mdt
                                            WHERE   Trigger_Configuration__r.DeveloperName = :configurationName]){
                panelMap.put(panel.DeveloperName, panel);
            }
        }
        return panelMap;
    }
    
    /**
     * Returns the related value of the EB_TriggerPanel record for the given context.  If there is
     * no record for the object type, and no sets are called previously in the code, the default
     * return is true.
     *
     * @param typeName The string value of the object type with all '_' characters removed.
     * @param context  The trigger context value with no spaces.  For example, 'beforeInsert'.
     * @return         The return value indicates whether the trigger switch is set to on or off.
     */
    global static Boolean getSwitch(String typeName, String context){
        return (Boolean) getPanel(typeName).get(context + '__c');
    }

    /**
     * Sets the related value of the EB_TriggerPanel record for the given context. If there is no
     * record in the database for this sObject type, a temporary record (all options set to true 
     * by default) will be created for this transaction only. The supplied value will then be set.
     *
     * @param  typeName The string value of the object type with all '_' characters removed.
     * @param  context  The trigger context value with no spaces.  For example, 'beforeInsert'.
     * @param  active   The desired value to set.
     * 
     * @return          The prior value of the switch.
     */
    global static void setSwitch(String typeName, String context, Boolean active){
        Boolean priorValue = (Boolean) getPanel(typeName).put(context + '__c', active);
        setPriorStatus(typeName, context, priorValue);
    }

    /*
     * Global method for reverting a context switch to the immediately previous value. Defaults to true.
     */
    global static void revertSwitch(String typeName, String context){
        setSwitch(typeName, context, getPriorStatus(typeName, context));
    }
    
    /**
     * Returns the breaker value of the EB_TriggerPanel record.
     *
     * @param typeName The string value of the object type with all '_' characters removed.
     * @return         The return value indicates whether the trigger breaker is set to on or off.
     */
    global static Boolean getBreaker(String typeName){
        return getPanel(typeName).Breaker__c;
    }

    /**
     * Sets the breaker value of the EB_TriggerPanel record.  If there is no record in the 
     * database for this sObject type, a temporary record (all options set to true by default) 
     * will be created for this transaction only. The supplied value will then be set.
     *
     * @param  typeName The string value of the object type with all '_' characters removed.
     * @param  active   The desired value to set.
     */
    global static void setBreaker(String typeName, Boolean active){
        Boolean priorValue = (Boolean) getPanel(typeName).put('Breaker__c', active);
        setPriorStatus(typeName, null, priorValue);
    }

    /*
     * Global method for reverting a breaker to the immediately previous value. Defaults to true.
     */
    global static void revertBreaker(String typeName){
        setBreaker(typeName, getPriorStatus(typeName, null));
    }
    
    /**
     * Sets the related value of the EB_TriggerPanel record for all contexts. If there is no 
     * record in the database for this sObject type, a temporary record (all options set to 
     * true by default) will be created for this transaction only. The supplied value will 
     * then be set.
     *
     * @param  typeName The string value of the object type with all '_' characters removed.
     * @param  active   The desired value to set.
     * @return          The return value indicates successful update (this transaction only).
     */
    global static void setAllSwitches(String typeName, Boolean active){
        setSwitch(typeName, 'BEFORE_INSERT', active);
        setSwitch(typeName, 'AFTER_INSERT', active);
        setSwitch(typeName, 'BEFORE_UPDATE', active);
        setSwitch(typeName, 'AFTER_UPDATE', active);
        setSwitch(typeName, 'BEFORE_DELETE', active);
        setSwitch(typeName, 'AFTER_DELETE', active);
        setSwitch(typeName, 'AFTER_UNDELETE', active);
    }
    
    /**
     * Global method for accessing the prior state of a switch. This method does not remove
     * or change the prior status recorded.
     */
    global static Boolean getPriorStatus(String typeName, String context){
        Boolean priorValue = stateHistory.get(buildKey(typeName, context));
        if(priorValue == null){
            //If null, then no change has occurred, get the raw value
            if(context == null){
                if(typeName == 'Main'){
                    priorValue = getMainBreaker();
                }else{
                    priorValue = getBreaker(typeName);
                }
            }else{
                getSwitch(typeName, context);
            }
        }
        return priorValue;
    }
    
    /**
     * Global method for saving the prior state of a switch or breaker.
     */
    global static void setPriorStatus(String typeName, String context, Boolean active){
        stateHistory.put(buildKey(typeName, context), active);
    }
    
    /*
     * Private method that converts the typeName and context into the history map key. 
     */
    private static String buildKey(String typeName, String context){
        if(context == null || context == ''){
            return typeName;
        }
        return typeName + '_' + context;
    }
    
    /**
     * Removes the EB_TriggerPanel record for the given typeName from the cached map of panels.
     *
     * @param  typeName The string value of the object type with all '_' characters removed.
     * @return
     */
    global static void reset(String typeName){
        getAllPanels().remove(typeName);
    }
    
    /**
     * Resets the map of EB_TriggerPanel records to only those found in the database.
     *
     * @param  typeName The string value of the object type with all '_' characters removed.
     * @return
     */
    global static void resetAll(){
        panelMap = null;
    }
}