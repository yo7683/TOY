trigger MovieTrigger on Movie__c (before delete) {

    MovieTriggerHandler handler = new MovieTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.OperationType {
        // when AFTER_INSERT {
        //     handler.onAfterInsert(Trigger.new);
		// }
        when BEFORE_DELETE {
            handler.onBeforeDelete(Trigger.old);
        }
    }

}