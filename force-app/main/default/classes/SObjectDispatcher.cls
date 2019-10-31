global virtual class SObjectDispatcher {
    
    global String typeName                {get;set;}
    global List<SObject> newList          {get;set;}
    global Map<Id, SObject> oldMap        {get;set;}

    /**
     * Initialize the data data type and object collections.
     *
     * @param typeName   The string value of the object type with all '_' characters removed.
     * @param newList    A list of SObjects typically the Trigger.newList values.
     * @param oldMap     A map of SObjects typically equivalent to the Trigger.oldMap values.
     */
    private void initData(String typeName, List<SObject> newList, Map<Id, SObject> oldMap){
        this.typeName = typeName;
        this.newList = newList;
        this.oldMap = oldMap;
    }
    
    /**
     * This method runs prior to any 'before' context methods.  Usually used for data preparation.
     */
    global virtual void prepBefore(){

    }

    /**
     * This method runs prior to any 'after' context methods.  Usually used for data preparation.
     */
    global virtual void prepAfter(){

    }

    /**
     * The before insert functionality placeholder for a generic sObject type.
     */
    global virtual void beforeInsert(){

    }

    /**
     * The after insert functionality placeholder for a generic sObject type.
     */
    global virtual void afterInsert(){
        
    }
    
    /**
     * The before update functionality placeholder for a generic sObject type.
     */
    global virtual void beforeUpdate(){
        
    }

    /**
     * The after update functionality placeholder for a generic sObject type.
     */
    global virtual void afterUpdate(){
        
    }
    
    /**
     * The before delete functionality placeholder for a generic sObject type.
     */
    global virtual void beforeDelete(){

    }
    
    /**
     * The after delete functionality placeholder for a generic sObject type.
     */
    global virtual void afterDelete(){

    }
    
    /**
     * The after undelete functionality placeholder for a generic sObject type.
     */
    global virtual void afterUndelete(){
        
    }

    /**
     * This method runs after to all context methods.  Please not that this will run twice for any DML 
     * action (once on the before context and once on the after context).
     */
    global virtual void andFinally(){

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
    global virtual void execute(TriggerOperation context){
        if(TriggerPanel.getMainBreaker() == false){
            System.debug('Main breaker set to false. Skipping all trigger executions.');
            return;
        }
        
        if(TriggerPanel.getBreaker(typeName) == false){
            System.debug('Breaker for ' + typeName + ' set to false. Skipping execution of ' + context.name() + '.');
            return;
        }
        
        System.debug('Beginning execution of ' + context.name() + ' handler.');
        try{

            if(context.name().contains('BEFORE')){
                this.prepBefore();
            }else if(context.name().contains('AFTER')){
                this.prepAfter();
            }

            if(TriggerPanel.getSwitch(typeName, context.name())){
                switch on context{
                    when BEFORE_INSERT  { this.beforeInsert(); }
                    when BEFORE_UPDATE  { this.beforeUpdate(); }
                    when BEFORE_DELETE  { this.beforeDelete(); }
                    when AFTER_INSERT   { this.afterInsert();  }
                    when AFTER_UPDATE   { this.afterUpdate();  }
                    when AFTER_DELETE   { this.afterDelete();  }
                    when AFTER_UNDELETE { this.afterInsert();  }
                }
            }else{
                System.debug('Switch for ' + typeName + ':' + context.name() + ' set to false. Skipping execution.');
            }

            this.andFinally();

        }catch(Exception ex){
            if(context.name().contains('_DELETE')){
                SObjectDispatcher.handleException(typeName, ex, oldMap.values());
            }else{
                SObjectDispatcher.handleException(typeName, ex, newList);
            }
        }
    }

    /**
     * This method constructs and initializes the proper sObject dispatcher based upon the 
     * data input (newList and oldMap).  The dispatcher is chosen by formula by finding the 
     * sObject type name, removing all '_' characters, prepending 'EB_', and appending 
     * 'Dispatcher'.  For example: My_Custom_Object__c => EB_MyCustomObjectcDispatcher'
     *
     * @param  newList List of sObjects, typically equivalent to Trigger.newList
     * @param  oldMap  Map of sObjects, typically equivalent to Trigger.oldMap
     * @return         
     */
    global static SObjectDispatcher init(List<SObject> newList, Map<Id, SObject> oldMap){
        String typeName = getTypeName(newList, oldMap);

        try{
            System.Type t = Type.forName(getNamespacePrefix() + typeName + 'Dispatcher');
            if(t == null){
                if(typeName == 'EBEDUTriggerSettingsc'){
                    throw new SObjectException('Triggers are not supported on EBEDUTriggerSettingsc object');
                }
                t = Type.forName('SObjectDispatcher');
            }

            SObjectDispatcher dispatch = (SObjectDispatcher) t.newInstance();
            dispatch.initData(typeName, newList, oldMap);
            return dispatch;
        }catch(Exception ex){
            if(getMaskExceptions()){
                EBEDU_Exception ebex = new EBEDU_Exception(); 
                ebex.setMessage(System.Label.EBEDU_Init_Error_Message);
                throw ebex;
            }

            throw ex;
        }
    }

    private static String getTypeName(List<SObject> newList, Map<Id, SObject> oldMap){
        String typeName;

        if(newList != null){
            typeName = newList.getSObjectType().getDescribe().getName();
        }else if(oldMap != null){
            typeName = oldMap.getSObjectType().getDescribe().getName();
        }else{
            typeName = '';
        }

        typeName = typeName.remove('_');

        System.debug('Type Name = ' + typeName);
        
        return typeName;
    }

    private static String getNamespacePrefix(){
        String configurationName = Trigger_Settings__c.getInstance().Trigger_Configuration__c;
        if(configurationName == null){
            configurationName = 'Default';
        }

        Trigger_Configuration__mdt config = [ SELECT  Id, DeveloperName, Namespace_Prefix__c 
                                            FROM    Trigger_Configuration__mdt 
                                            WHERE   DeveloperName = :configurationName];

        String prefix = config.Namespace_Prefix__c == null ? '' : config.Namespace_Prefix__c;

        System.debug('Namespace Prefix = ' + prefix);

        return prefix;
    }

    public static Boolean getMaskExceptions(){
        return Trigger_Settings__c.getInstance().Mask_Detailed_Exceptions__c;
    }

    /**
     * This method handles how exceptions are displayed to the user, whether they are 
     * simplified or fully displayed.
     *
     * @param  typeName The type of object the DML was acting on when the exception was thrown.
     * @param  ex  The exception thrown by the code.
     * @param  objects  The list of sObjects, typically the newList. If in delete context, the old list.
     * @return
     **/
    private static void handleException(String typeName, Exception ex, List<SObject> objects){
        if(getMaskExceptions()){
            if(ex.getTypeName() == 'System.DmlException'){
                DmlException dmlEx = (DmlException) ex;
                for(Integer i = 0; i < ex.getNumDml(); i ++){
                    Integer index = ex.getDmlIndex(i);
                    String errorString = '';
                    errorString += ex.getDmlType(i) + ':';
                    errorString += ex.getDmlMessage(i);
                    if(ex.getDmlFieldNames(i).isEmpty() == false){
                        errorString += ' [' + typeName + '.' + String.join(ex.getDmlFieldNames(i),',') + ']. ';
                    }
                    errorString += System.Label.EBEDU_Generic_DML_Error_Message;
                    if(Test.isRunningTest() == false){
                        objects[index].addError(errorString);
                    }
                }
            }else{
                for(SObject obj:objects){
                    if(Test.isRunningTest() == false){
                        obj.addError(System.Label.EBEDU_Generic_Error_Message);
                    }
                }
            }
        }
        
        throw ex;
    }

    public class EBEDU_Exception extends Exception{

    }
}