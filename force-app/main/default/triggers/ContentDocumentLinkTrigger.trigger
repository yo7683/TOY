trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {

    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.OperationType {
		when AFTER_INSERT {
			// handler.onAfterInsert(Trigger.old, Trigger.new);
		}
        when AFTER_UPDATE {
            
        }
		when AFTER_DELETE {
			// handler.onAfterDelete(Trigger.old);
		}
    }
}