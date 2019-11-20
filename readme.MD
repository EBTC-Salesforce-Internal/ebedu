# EDHU Trigger Framework

## Overview ##
The EDHU Trigger Framework is an object-oriented trigger framework for simplifying and controlling trigger execution. EDHU stands for Event-Dispatch-Handler-Utility and is heavily influenced by Andy Fawcett (FinancialForce) and Robert Nunemaker (Citrix) during their 2014 Dreamforce presentations on Enterprise Apex Patterns and the Event-Dispatch-Action framework respectively. Thanks also goes to Ken Draper for additional feedback on standard enterprise patterns and their application within Salesforce.com.

Simply put, the layers translate as follows:

* **Event** :The capture of the event.
* **Dispatcher**:The identification and handoff to the proper handler.
* **Handler**:The handling of the event and coordination of multiple actions required to properly handle the event.
* **Utility**:The re-usable actions that are required to properly handle the event.

Robert Nunemaker described it with the 'Parable of the Plumber' (notes added):

A pipe in your house bursts (event). You call the plumbing company (dispatcher), who sends out a plumber (hander). The plumber assess the situation (business logic in handler) and uses a set of parts, tools, and processes (utilities) to resolve the issue.

When looked at this way, it becomes easier to view the logic and identify what elements belong in which locations. This layered logic can be applied in many situations, but specifically here to triggers.

## Installation ##

### Managed Package ###

A managed package version is available at the following url [https://login.salesforce.com/packaging/installPackage.apexp?p0=04t36000000H66s]. To install via Salesforce DX, run the following command

```
#!Command Line
sfdx force:package:install -i 04t36000000H66s -u <alias or username>
```

This installs the SObjectDispatcher, the generic SObjectHandler, and the TriggerPanel with their supporting settings. These are in the EDHU namespace.

Once installed, configure the EDHU.Trigger_Settings__c org-wide custom setting record. These records can be overriden by profile and user to allow for fine-grained control of the system. On this record, there are settings to bypass all framework triggers (also known as the Main breaker), standard automation, and validation rules. These settings only function as you build conforming triggers, process builders, workflow rules, and validation rules. You can also configure the option to mask detailed error messages. This replaces the actual error thrown by the code and presents a simplified message to the user (see Error Handling).

On the EBHU.Trigger_Settings__c record, you can configure different Trigger Configuration values. These map to the Trigger_Configuration__mdt object by developer name. Each trigger configuration has its own set of Trigger_Panel__mdt records, allowing you to configure trigger status as granular as by sObject by person.

Note: All documentation assumes the installation of the managed version. Of special note, is that any overrides to the SObjectHandler methods must be *global*. This grants the managed methods on the SObjectDispatcher to interact appropriately with your instantiated handler.

### Unmanaged Code ###

Cloning this repository and uploading into your own org will give you full/unrestricted access to the source code. However the framework was designed with flexibility in mind, all methods are virtual and can be overridden in order to completely customize a given trigger's behavior. It is highly recommended that you utilize the managed package version.

# Usage #

## Triggers ##

In the EDHU framework, triggers only handle enough logic in order to pass the context information to the appropriate handler. The SObjectDispatcher.init method identifies the handler based on the naming convention 'typeName + "Handler". It then instantiates the class. The typeName value is recommended to be the sObject developer name with all '_' characters removed. Triggers themselves do not have any particular naming convention (I recommend just the object name for simplicity). Copy and paste the code below, replacing the SObject type name in the appropriate places.

```
#!Apex

trigger {{ type_name }} on {{ object_name }} (
        before insert, before update,  before delete,
        after insert,  after update,   after delete,   after undelete) {

    //Initialize the handler
    EDHU.SObjectHandler handler = EBEDU.SObjectDispatcher.init( {{ type_name }});

    //Execute the appropriate dispatch method.
    if(dispatch != null){ dispatch.execute(Trigger.operationType, Trigger.new, Trigger.oldMap); }
}
```

## Handlers ##

The handler is where all logic is controlled. Included in the package is a single 'SObjectHandler' class which defines the basic operations of a framework. Object-specific handlers extend this class, inheriting the standard logic, but allowing for any piece to be overridden and customized. Handlers are held in memory as a singleton value. This means that you should NOT hold any member variables on the handler that are data dependent. Anything requiring that level of complexity is best abstracted into a separate object oriented utility class.

### Naming Convention ###

When creating your handler, please make sure to following the following naming convention:

<TypeName> + 'Handler'.

The commonly missed item here is that the name must meet this criteria extactly. The type name is the value passed by the trigger during intialization. Technically, this would allow multiple objects to utilize the same handler, however this is not recommended.

* Account --> AccountHandler
* Contact --> ContactHandler
* Project_Milestone__c --> ProjectMilestonecHandler (don't forget the 'c'!)

### SObjectDispatcher ###

The first global static method in the standard SObjectDispatcher class is the *init* method. This method accepts the typeName variable, identifies the proper handler to utilize (based on the convention), and return the initialized handler. This method should be referenced only by the trigger.

The second global static method provides a standard method of error handling that supports masking of exception messages for end users.

### SObjectHandler ###

The *execute* instance method controls the actual flow of logic within the trigger. It executes checks to the Trigger Panel to determine if specific functions should be run (see Trigger Panel). It also provides global error handling for logic within an object-specific dispatcher (see Error Handling). The execute method references other instance methods for each context. Each of these methods are defined as virtual (allowing them to be overridden) and contain no logic in the default implementation.

Also available on the SObjectHandler is one member variable: the object typeName (with underscores removed).

### Object-Specific Handlers  ###

Each object-specific dispatcher extends the standard SObjectHandler class, inheriting all methods from the default implementation. Adding override methods allows the customization of any of these methods. *Please note that all overridden methods must have the 'global' access modifier on them in order to function properly.* Note that these methods should be treated as static and no additional member variables should typically be added directly to a handler.

```
#!apex
global class {{ handler_name }} extends EDHU.SObjectHandler {

    /**
     * The before insert functionality on the {{ object_name }} object
     */
    global override void beforeInsert(){
        System.debug('Overriden');
    }

}
```

### Error Handling ###

A level of default error handling is built into the framework by default. This handling can capture errors from within the instance method invocations and masks the error before presenting it to the user. This prevents users from seeing excessively long error messages and instead provide them with actionable instructions. This can be enabled on the 'Trigger Settings' custom setting, masking the raw errors to users except for debugging purposes. These settings can be configured on an org-wide, profile, or per-user basis. For example, System Administrator profiles can be configured to always see raw errors.

## Trigger Panel ##

The trigger panel provides admin-configurable control of trigger execution. There are hooks to control all triggers simultaneously, each trigger individually, or each context individually. These are the Main Breaker, Breaker, and Switch elements individually. Each of these elements have three methods: set, get, and revert. There is also the ability to reset panels back to their original state. If no specific definition is found for the state of a panel, all values are assumed to be true.

### Admin Configuration ###

An administrator is able to configure the initial state of the breakers and switches by editing the EDHU.Trigger_Panel__mdt custom metadata records. The name of the custom metadata record should be the same as the typeName on the handler (typically the sObject name following the same naming convention as the dispatcher a.k.a. removing all '_' characters). Trigger panels are grouped into Trigger Configurations, that can be assigned on a default, profile, or per-user basis. If not configuration is specified the 'Default' configuration is used. The main breaker is configured on the Trigger Settings record as 'Bypass Triggers'.

### Main Breaker, Object Breakers, and Switches ###

Turning off the main breaker programatically will disables all triggers for the duration of the execution context. If set via configuration, it is set for all execution contexts for the configured users.

```
#!Apex
//Turn off main breaker
EDHU.TriggerPanel.setMainBreaker(false);

```

The main breaker can also be turned back on

```
#!Apex
//Turn on main breaker
EDHU.TriggerPanel.setMainBreaker(true);

```

And reverted

```
#!Apex
//Revert main breaker
EDHU.TriggerPanel.revertMainBreaker();

```

### Revert Functions ###

Revert function return the status of a switch or breaker back to the *immediate* prior status. It does not keep a history stack in any way.

### Reset Functions ###

The reset function returns a value to its initial state. If an initial state is undefined, it defaults to true.