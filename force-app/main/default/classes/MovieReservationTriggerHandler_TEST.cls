@isTest
public class MovieReservationTriggerHandler_TEST {
    static Movie__c movie;
    static Theater__c theater;
    static Seat__c seat;
    static MovieSchedule__c ms;
    static Reservation__c res;

    static {
        movie = new Movie__c(
            Name = 'testName',
            ReservationRate__c = 12
        );
        insert movie;

        theater = new Theater__c(
            Name = 'Test 극장'
        );
        insert theater;

        seat = new Seat__c(
            md_Theater__c = theater.Id

        );
        insert seat;

        ms = new MovieSchedule__c(
            md_Movie__c = movie.Id,
            md_Theater__c = theater.Id

        );
        insert ms;

        res = new Reservation__c(
            md_Movie__c = movie.Id,
            md_Theater__c = theater.Id,
            l_Seat__c = seat.Id,
            l_MovieSchedule__c = ms.Id
        );
        insert res;

    }

    @isTest
    static void testOnAfterInsert(){
        Test.startTest();
        List<Reservation__c> rList = [SELECT Id, Name, md_Movie__c FROM Reservation__c];
        // MovieReservationTriggerHandler.onAfterInsert(rList);
        MovieReservationTriggerHandler handler = new MovieReservationTriggerHandler(true, 1);
        handler.onAfterInsert(rList);
        Test.stopTest();
    }
}