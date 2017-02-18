# EDU Trigger Framework

## Overview ##
The EDU Trigger Framework is an object-oriented trigger framework for simplifying and controlling trigger execution. EDU stands for Event-Dispatcher-Utility and is heavily influenced by Andy Fawcett (FinancialForce) and Robert Nunemaker (Citrix) during their 2014 Dreamforce presentations.

Simply put, the layers translate as follows:
* **Event**:The capture of the event and hand-off to the dispatcher.
* **Dispatcher**:The handling of the event and coordination of multiple actions required to properly handle the event.
* **Utility**:The re-usable actions that are required to properly handle the event.

Robert Nunemaker described it this way:

A pipe in your house bursts (event). You call the plumbing company (hand-off to dispatcher), who sends out a plumber (dispatcher). The plumber assess the situation (business logic in dispatcher) and uses a set of parts, tools, and processes (utilities) to resolve the issue.

When looked at this way, it becomes easier to view the logic and identify what elements belong in which locations. This set of descriptions can be applied in many situations, but specifically here to triggers.

## Trigger Template ##


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