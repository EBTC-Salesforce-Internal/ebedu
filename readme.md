# Eide Bailly EDU Trigger Framework


## Trigger Template

trigger Opportunity on Opportunity (before insert, 	before update, 	before delete,
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