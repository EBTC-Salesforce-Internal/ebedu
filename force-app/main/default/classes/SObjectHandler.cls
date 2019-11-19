global virtual class SObjectHandler {
    global String typeName = 'SObject';

    /**
     * The before insert functionality placeholder for a generic sObject type.
     */
    global virtual void beforeInsert(List<SObject> newList){

    }

    /**
     * The after insert functionality placeholder for a generic sObject type.
     */
    global virtual void afterInsert(List<SObject> newList){

    }

    /**
     * The before update functionality placeholder for a generic sObject type.
     */
    global virtual void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap){

    }

    /**
     * The after update functionality placeholder for a generic sObject type.
     */
    global virtual void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap){

    }

    /**
     * The before delete functionality placeholder for a generic sObject type.
     */
    global virtual void beforeDelete(Map<Id, SObject> oldMap){

    }

    /**
     * The after delete functionality placeholder for a generic sObject type.
     */
    global virtual void afterDelete(Map<Id, SObject> oldMap){

    }

    /**
     * The after undelete functionality placeholder for a generic sObject type.
     */
    global virtual void afterUndelete(List<SObject> newList){

    }

    /**
     * Generic execute method accepts the 'context' parameter and processes the required methods accordingly.
     * Control of the methods can be modified by using the EB_TriggerPanel custom setting values.
     *
     * If no record is found in the setting for the given sObject, the default behavior is 'true' or run
     * all methods. Any call to a 'set' function will return false and have no effect.
     *
     * @param  context The context for which to execute the function.
     * @return
     */
    global virtual void execute(TriggerOperation context, List<SObject> newList, Map<Id, SObject> oldMap){
        if(TriggerPanel.getMainBreaker() == false || TriggerPanel.getBreaker(this.typeName) == false){
            return;
        }

        System.debug('Beginning execution of ' + context.name() + ' handler.');
        try{

            if(TriggerPanel.getSwitch(this.typeName, context.name())){
                switch on context{
                    when BEFORE_INSERT  { this.beforeInsert(newList); }
                    when BEFORE_UPDATE  { this.beforeUpdate(newList, oldMap); }
                    when BEFORE_DELETE  { this.beforeDelete(oldMap); }
                    when AFTER_INSERT   { this.afterInsert(newList);  }
                    when AFTER_UPDATE   { this.afterUpdate(newList, oldMap);  }
                    when AFTER_DELETE   { this.afterDelete(oldMap);  }
                    when AFTER_UNDELETE { this.afterUndelete(newList);  }
                }
            }else{
                System.debug('Switch for ' + this.typeName + ':' + context.name() + ' set to false. Skipping execution.');
            }

        }catch(Exception ex){
            this.handleException(context, ex, newList, oldMap);
        }
    }

    global virtual void handleException(TriggerOperation context, Exception ex, List<SObject> newList, Map<Id, SObject> oldMap){
        if(context.name().contains('_DELETE')){
            SObjectDispatcher.handleException(typeName, ex, oldMap.values());
        }else{
            SObjectDispatcher.handleException(typeName, ex, newList);
        }
    }
}
