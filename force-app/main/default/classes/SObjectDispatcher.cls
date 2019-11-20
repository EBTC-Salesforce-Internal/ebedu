global virtual class SObjectDispatcher {

    /**
     * Static map containing the singleton instances of the
     * handlers as they are created and used.
     */
    private static Map<String, SObjectHandler> handlerMap;

    /**
     * Static initialization of the dispatcher static members.
     */
    static {
        handlerMap = new Map<String, SObjectHandler>();
    }

    /**
     * This method constructs and initializes the proper sObject handler based upon the
     * typeName input.  The handler is chosen by formula by appending the type name with
     * 'Handler'.  For example: MyCustomObject => MyCustomObjectHandler'
     *
     * @param  typeName
     * @return SObjectHandler
     */
    global static SObjectHandler init(String typeName){
        try{
            if(handlerMap.containsKey(typeName) == false){
                System.Type t = Type.forName(typeName + 'Handler');

                if(t == null){
                    if(typeName == 'ExceptionValue'){
                        throw new SObjectException('Triggers are not supported on ExceptionValue object');
                    }
                    return null;
                }

                handlerMap.put(typeName, (SObjectHandler) t.newInstance());
            }

            return handlerMap.get(typeName);
        }catch(Exception ex){
            if(getMaskExceptions()){
                EDHU_Exception ebex = new EDHU_Exception();
                ebex.setMessage(System.Label.EDHU_Init_Error_Message);
                throw ebex;
            }

            throw ex;
        }
    }

    /**
     * Method returns the users configured setting of whether to override the error message (true)
     */
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
                    errorString += System.Label.EDHU_Generic_DML_Error_Message;

                    objects[index].addError(errorString);
                }
            }else{
                for(SObject obj:objects){
                    obj.addError(System.Label.EDHU_Generic_Error_Message);
                }
            }
            return;
        }

        throw ex;
    }

    global class EDHU_Exception extends Exception{

    }
}