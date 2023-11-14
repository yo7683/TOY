trigger ContentVersionTrigger on ContentVersion (after insert, after delete) {

    ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.OperationType {
		when AFTER_INSERT {
			handler.onAfterInsert(Trigger.new);
		}
		when AFTER_DELETE {
			handler.onAfterDelete(Trigger.old);
		}
    }
}