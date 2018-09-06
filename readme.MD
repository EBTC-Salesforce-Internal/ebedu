# EDU Trigger Framework

## Overview ##
The EDU Trigger Framework is an object-oriented trigger framework for simplifying and controlling trigger execution. EDU stands for Event-Dispatcher-Utility and is heavily influenced by Andy Fawcett (FinancialForce) and Robert Nunemaker (Citrix) during their 2014 Dreamforce presentations on Enterprise Apex Patterns and the Event-Dispatch-Action framework respectively.

Simply put, the layers translate as follows:

* **Event** :The capture of the event and hand-off to the dispatcher.
* **Dispatcher**:The handling of the event and coordination of multiple actions required to properly handle the event.
* **Utility**:The re-usable actions that are required to properly handle the event.

Robert Nunemaker described it with the 'Parable of the Plumber' (notes added):

A pipe in your house bursts (event). You call the plumbing company (hand-off to dispatcher), who sends out a plumber (dispatcher). The plumber assess the situation (business logic in dispatcher) and uses a set of parts, tools, and processes (utilities) to resolve the issue.

When looked at this way, it becomes easier to view the logic and identify what elements belong in which locations. This layered logic can be applied in many situations, but specifically here to triggers.

## Installation ##

### Managed Package ###

A managed package version is available at the following url [https://login.salesforce.com/packaging/installPackage.apexp?p0=04t36000000H66s]. To install via Salesforce DX, run the following command

```
#!Command Line
sfdx force:package:install -i 04t36000000H66s -u <alias or username>
```

This installs both the SObjectDispatcher and the TriggerPanel with their supporting settings. These are in the EBEDU namespace. 

Once installed, configure the EBEDU.Settings__c org-wide default record. On this record, set your dispatcher prefix. This is a way to help organize your code in a more usable way. Internally, your default is 'EB_'. You may also want to configure a record for your user or profile to view detailed error messages. This passes through the actual error thrown directly to the user, rather than presenting a simplified message to the user (see Error Handling).

Note: All documentation assumes the installation of the managed version. Of special note, is that any overrides to the SObjectDispatcher methods must be *global*. This grants the managed methods on the SObjectDispatcher to interact appropriately with your code.

### Unmanaged Code ###

Cloning this repository and uploading into your own org will give you full/unrestricted access to the source code. However the framework was designed with flexibility in mind, all methods are virtual and can be overridden in order to completely customize a given trigger's behavior. It is highly recommended that you utilize the managed package version.

# Usage #

## Triggers ##

In the EDU framework, triggers only handle enough logic in order to 'hand-off' to the correct dispatcher. The SObjectDispatcher.init method detects the data type of the newList or oldMap and instantiates the correct dispatcher class. Triggers themselves do not have any particular naming convention (I recommend just the object name for simplicity). Copy and paste the code below, replacing the SObject type name in the appropriate places.

```
#!Apex

trigger {{ trigger_name }} on {{ object_name }} (before insert, before update,  before delete,
                                                 after insert,  after update,   after delete,   after undelete) {

    //Initialize the dispatcher
    EBEDU.SObjectDispatcher dispatch = EBEDU.SObjectDispatcher.init(Trigger.new, Trigger.oldMap);

    //Execute the appropriate dispatch method.
    if (dispatch != null) {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) { dispatch.execute('beforeInsert'); }
            if (Trigger.isUpdate) { dispatch.execute('beforeUpdate'); }
            if (Trigger.isDelete) { dispatch.execute('beforeDelete'); }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert) { dispatch.execute('afterInsert'); }
            if (Trigger.isUpdate) { dispatch.execute('afterUpdate'); }
            if (Trigger.isDelete) { dispatch.execute('afterDelete'); }
            if (Trigger.isUndelete) { dispatch.execute('afterUndelete'); }
        }
    } else {
        System.debug('No dispatcher found.');
    }
}
```

## Dispatchers ##

The dispatcher is where all logic is controlled. Included in the package is a single 'SObjectDispatcher' class which defines the base operations of the framework. Object-specific dispatchers extend this class, inheriting the standard logic, but allowing for any piece to be overridden and customized.

### Naming Convention ###

When creating your dispatcher, please make sure to following the following naming convention:

<DispatcherPrefix> + <SObjectAPINameWithoutUnderscores> + 'Dispatcher'.

The commonly missed item here is that the name must meet this criteria extactly. As an example of the above, if my dispatcher prefix is 'EB_',

* Account --> EB_AccountDispatcher
* Contact --> EB_ContactDispatcher
* Project_Milestone__c --> EB_ProjectMilestonecDispatcher (don't forget the 'c'!)

### SObjectDispatcher ###

Only one global static method exists in the standard SObjectDispatcher class. This *init* method accepts the newList and oldMap variables from the trigger context, identify the proper dispatcher to utilize (based on the object type), and return the initialized dispatcher. This method should be referenced only by the trigger.

The *execute* instance method controls the actual flow of logic within the trigger. It executes checks to the Trigger Panel to determine if specific functions should be run (see Trigger Panel). It also provides global error handling for logic within an object-specific dispatcher (see Error Handling). The execute method references other instance methods in the following order for each run:

1. **Preparation Methods**:The *prepBefore* and *prepAfter* methods are run based on the context and the status of the object's breaker. The purpose of these methods is to promote bulkification by providing a location to run any queries for dependent data, etc.
2. **Context Methods**:The context methods (*beforeInsert*, *afterUpdate*, etc.) run based on the current context and switch for the object. These methods provide the actual logic for each context.
3. **Finally Method**:The *andFinally* method runs at the end of each context, providing a location for any wrap-up work that needs to be done.

Each of these methods are defined as virtual (allowing them to be overridden) and contain no logic in the default implementation.

Also available on the SObjectDispatcher are three member variables: the object typeName (with underscores removed), the newList from the trigger context, and the oldMap from the trigger context.

### Object-Specific Dispatchers ###

Each object-specific dispatcher extends the standard SObjectDispatcher class, inheriting all methods from the default implementation. Adding override methods allows the customization of any of these methods. *Please note that all overridden methods must have the 'global' access modifier on them in order to function properly.*

Also included are some common helper methods that access and cast the new and old records for easy access in the org. These methods are included on each object-specific dispatcher as there are limitations to dynamically casting records to a specific type in Salesforce. Below are the template object-specific dispatcher and test class.

```
#!apex
global class {{ dispatcher_name }} extends EBEDU.SObjectDispatcher {
    
    /**
     * The before insert functionality on the {{ object_name }} object
     *
     * @return 
     */
    global override void beforeInsert(){
        System.debug('Overriden');
    }

    /**
     * Utility method to transform the Trigger.newList to the appropriate SObject type.
     *
     * @return A list containing the new {{ object_name }} objects.
     */
    public List<{{ object_name }}> getNewList(){
        if(newList != null){
            return (List<{{ object_name }}>) newList;
        }
        return null;
    }

    /**
     * Utility method to transform the Trigger.oldMap into the appropriate SObject type.
     *
     * @return A map containing the old {{ object_name }} objects by Id.
     */
    public Map<Id, {{ object_name }}> getOldMap(){
        if(oldMap != null){
            Map<Id, {{ object_name }}> oMap = new Map<Id, {{ object_name }}>();
            oMap.putAll( (List<{{ object_name }}>) oldMap.values());
            return oMap;
        }
        return null;
    }

    /**
     * Utility method to transform the Trigger.newList to a map of the appropriate SObject type.
     *
     * @return A map containing the new {{ object_name }} objects by Id.
     */
    public Map<Id, {{ object_name }}> getNewMap(){
        if(newList != null){
            Map<Id, {{ object_name }}> newMap = new Map<Id, {{ object_name }}>();
            newMap.putAll(getNewList()); 
            return  newMap;
        }
        return null;
    }

}
```


```
#!apex
@isTest
public class {{ test_class_name }} {

    @isTest
    public static void testUtilityMethodsValid(){
        {{ dispatcher_name }} dispatch = new {{ dispatcher_name }}();
        dispatch.newList = new List<{{ object_name }}>();
        dispatch.oldMap = new Map<Id, {{ object_name }}>();

        dispatch.getNewList();
        dispatch.getNewMap();
        dispatch.getOldMap();
    }

    @isTest
    public static void testUtilityMethodsNull(){
        {{ dispatcher_name }} dispatch = new {{ dispatcher_name }}();

        dispatch.getNewList();
        dispatch.getNewMap();
        dispatch.getOldMap();
    }

}

```

### Error Handling ###

A level of default error handling is built into the framework by default. This handling captures errors from within the instance method invocations and masks the error before presenting it to the user. This prevents users from seeing excessively long error messages and instead provide them with actionable instructions. This can be overridden on the 'Settings' custom setting, passing the raw errors to users for debugging purposes. These settings can be configured on an org-wide, profile, or per-user basis. For example, System Administrator profiles can be configured to always see raw errors.

## Trigger Panel ##

The trigger panel provides admin-configurable control of trigger execution. There are hooks to control all triggers simultaneously, each trigger individually, or each context individually. These are the Main Breaker, Breaker, and Switch elements individually. Each of these elements have three methods: set, get, and revert. There is also the ability to reset panels back to their original state. If no specific definition is found for the state of a panel, all values are assumed to be true.

### Admin Configuration ###

An administrator is able to configure the initial state of the breakers and switches by editing the EBEDU.TriggerPanel custom setting. The name of the custom setting record should be the sObject name following the same naming convention as the dispatcher (removing all '_' characters). There is no way to set the main breaker as an admin.

### Main Breaker ###

The main breaker is only editable via apex.

Turning off the main breaker disables all triggers.

```
#!Apex
//Turn off main breaker
EBEDU.TriggerPanel.setMainBreaker(false);

```

The main breaker can also be turned back on

```
#!Apex
//Turn on main breaker
EBEDU.TriggerPanel.setMainBreaker(true);

```

And reverted

```
#!Apex
//Revert main breaker
EBEDU.TriggerPanel.revertMainBreaker(true);

```

### Breakers ###
### Switches ###
### Revert Functions ###

Revert function return the status of a switch or breaker back to the *immediate* prior status. It does not keep a history stack in any way.

### Reset Functions ###

The reset function returns a value to its initial state. If an initial state is undefined, it defaults to true.