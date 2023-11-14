trigger MovieReservationTrigger on Reservation__c (before insert, before update, before delete, after insert, after update, after delete) {
    
    MovieReservationTriggerHandler handler = new MovieReservationTriggerHandler(Trigger.isExecuting, Trigger.size);

    switch on Trigger.OperationType {
        // when BEFORE_INSERT {
            // handler.onAfterInsert(Trigger.new);
		// }
        when AFTER_INSERT {
            handler.onAfterInsert(Trigger.new);
        }
        // when BEFORE_UPDATE {
        //     // handler.onAfterInsert(Trigger.new);
		// }
        // when AFTER_UPDATE {
        //     // handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
        // }
        // when BEFORE_DELETE {
        //     // handler.onAfterInsert(Trigger.new);
		// }
        // when AFTER_DELETE {
        //     // handler.onAfterUpdate(Trigger.old);
        // }
    }

}