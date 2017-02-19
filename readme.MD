# EDU Trigger Framework

## Overview ##
The EDU Trigger Framework is an object-oriented trigger framework for simplifying and controlling trigger execution. EDU stands for Event-Dispatcher-Utility and is heavily influenced by Andy Fawcett (FinancialForce) and Robert Nunemaker (Citrix) during their 2014 Dreamforce presentations. The former for his emphasis on service (utility) logic segregation and the latter for his delineation of the event and dispatch layers.

Simply put, the layers translate as follows:

* **Event** :The capture of the event and hand-off to the dispatcher.
* **Dispatcher**:The handling of the event and coordination of multiple actions required to properly handle the event.
* **Utility**:The re-usable actions that are required to properly handle the event.

Robert Nunemaker described it with the 'Parable of the Plumber' (notes added):

A pipe in your house bursts (event). You call the plumbing company (hand-off to dispatcher), who sends out a plumber (dispatcher). The plumber assess the situation (business logic in dispatcher) and uses a set of parts, tools, and processes (utilities) to resolve the issue.

When looked at this way, it becomes easier to view the logic and identify what elements belong in which locations. This layered logic can be applied in many situations, but specifically here to triggers.

## Installation ##

### Managed Package ###

A managed package version is available at the following url [https://login.salesforce.com/packaging/installPackage.apexp?p0=04t36000000H66s]. This installs both the SObjectDispatcher and the TriggerPanel with their supporting settings. These are in the EBEDU namespace. 

Once installed, configure the EBEDU.Settings__c org-wide default record. On this record, set your dispatcher prefix. This is a way to help organize your code in a more usable way. Internally, your default is 'EB_'. You may also want to configure a record for your user or profile to view detailed error messages. This passes through the actual error thrown directly to the user, rather than presenting a simplified message to the 

Note: All documentation assumes the installation of the managed version. Of special note, is that any overrides to the SObjectDispatcher methods must be *global*. This grants the managed methods on the SObjectDispatcher to interact appropriately with your code.

### Unmanaged Code ###

Cloning this repository and uploading into your own org will give you full/unrestricted access to the source code. However the framework was designed with flexibility in mind, all methods are virtual and can be overridden in order to completely customize a given trigger's behavior. It is highly recommended that you utilize the managed package version.

# Usage #

## Triggers ##

In the EDU framework, triggers only handle enough logic in order to 'hand-off' to the correct dispatcher. The SObjectDispatcher.init method detects the data type of the newList or oldMap and instantiates the correct dispatcher class. Triggers themselves do not have any particular naming convention (I recommend just the object name for simplicity). Copy and paste the code below, replacing the SObject type name in the appropriate places.

### Trigger Template ###

```
#!Apex

trigger <sObject> on <sObject> (before insert, 	before update, 	before delete,
                                after insert, 	after update, 	after delete, 	after undelete) {

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
The dispatcher is where all logic is controlled. When creating your dispatcher, please make sure to following the following naming convention:

<DispatcherPrefix> + <SObjectAPINameWithoutUnderscores> + 'Dispatcher'.

The commonly missed item here is that the name must meet this criteria extactly. As an example of the above, if my dispatcher prefix is 'EB_',

Account --> EB_AccountDispatcher
Contact --> EB_ContactDispatcher
Project__Milestone__c --> EB_ProjectMilestonecDispatcher (don't forget the 'c'!)

Also, please note that all overridden methods must have the 'global' access modifier on them in order to function properly.

## Trigger Panel ##
The trigger panel provides an admin-configurable method to control the trigger execution.