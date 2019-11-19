global virtual class SObjectDispatcher {

    private static Map<String, SObjectHandler> handlerMap;

    static {
        handlerMap = new Map<String, SObjectHandler>();
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
    global static SObjectHandler init(String typeName){
        try{
            if(handlerMap.containsKey(typeName) == false){
                System.Type t = Type.forName(typeName + 'Handler');

                if(t == null){
                    if(typeName == 'Exception'){
                        throw new SObjectException('Triggers are not supported on Exception object');
                    }
                    return null;
                }

                handlerMap.put(typeName, (SObjectHandler) t.newInstance());
            }

            return handlerMap.get(typeName);
        }catch(Exception ex){
            if(getMaskExceptions()){
                EBEDU_Exception ebex = new EBEDU_Exception();
                ebex.setMessage(System.Label.EBEDU_Init_Error_Message);
                throw ebex;
            }

            throw ex;
        }
    }

    @testVisible
    private static Boolean getMaskExceptions(){
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
    public static void handleException(String typeName, Exception ex, List<SObject> objects){
        if(getMaskExceptions()){
            if(ex.getTypeName() == 'System.DmlException'){
                DmlException dmlEx = (DmlException) ex;
                for(Integer i = 0; i < ex.getNumDml(); i ++){
                    Integer index = ex.getDmlIndex(i);
                    String errorString = ex.getTypeName() + '.';
                    errorString += ex.getDmlType(i) + ': ';
                    errorString += ex.getDmlMessage(i) + ' ';
                    if(ex.getDmlFieldNames(i).isEmpty() == false){
                        errorString += '[' + typeName + '.' + String.join(ex.getDmlFieldNames(i),',') + ']. ';
                    }
                    errorString += System.Label.EBEDU_Generic_DML_Error_Message;

                    objects[index].addError(errorString);
                }
            }else{
                for(SObject obj:objects){
                    obj.addError(System.Label.EBEDU_Generic_Error_Message);
                }
            }
            return;
        }

        throw ex;
    }

    public class EBEDU_Exception extends Exception{

    }
}