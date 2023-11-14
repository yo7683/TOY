@isTest
public class TP_MovieInfoController_TEST {
    
    static Movie__c movie;
    static Theater__c th;
    static MovieSchedule__c ms;
    static Seat__c seat;
    static Reservation__c res;

    static {
        movie = new Movie__c (
            Name = 'Test',
            Amounts__c = 15000
        );
        insert movie;

        th = new Theater__c (
            Name = 'Test Th'
        );
        insert th;

        ms = new MovieSchedule__c (
            md_Movie__c = movie.Id,
            md_Theater__c = th.Id,
            ShowDate__c = Date.newInstance(2016, 12, 9),
            StartTime__c = Time.newInstance(1, 2, 3, 4),
            ShowDateTime__c = DateTime.newInstance(1996, 3, 22)
        );
        insert ms;

        seat = new Seat__c (
            md_Theater__c = th.Id,
            SeatColumn__c = 'A',
            SeatRow__c = 10
        );
        insert seat;

        res = new Reservation__c(
            md_Movie__c = movie.Id,
            md_Theater__c = th.Id,
            l_Seat__c = seat.Id,
            l_MovieSchedule__c = ms.Id,
            ReservationNum__c = 100
        );
        insert res;

    }


    @isTest
    static void testMovieReservation(){
        Test.startTest();
        TP_MovieInfoController.movieReservation();
        Test.stopTest();
    }

    @isTest
    static void testTheaterName(){
        Test.startTest();
        TP_MovieInfoController.theaterName(movie.Id, th.Id);
        Test.stopTest();
    }

    @isTest
    static void testMovieDate(){
        Test.startTest();
        TP_MovieInfoController.movieDate(movie.Id, th.Id, String.valueOf(ms.ShowDate__c));
        Test.stopTest();
    }

    @isTest
    static void testSeatView(){
        Test.startTest();
        TP_MovieInfoController.seatView();
        Test.stopTest();
    }

    @isTest
    static void testDoReserve(){
        Test.startTest();
        List<Seat__c> sList = [SELECT Id, SeatColumn__c, SeatRow__c FROM Seat__c];
        List<String> strList = new List<String>();
        for(Seat__c seat : sList) {
            strList.add(seat.Id);
        }

        TP_MovieInfoController.doReserve(movie.Id, th.Id, ms.Id, strList);
        Test.stopTest();
    }

    @isTest
    static void testSelectMultiIds(){
        Test.startTest();
        List<Movie__c> mList = [SELECT Id, Name, Amounts__c FROM Movie__c];
        List<Theater__c> tList = [SELECT Id, Name FROM Theater__c];
        List<MovieSchedule__c> msList = [SELECT Id, ShowDate__c, StartTime__c, ShowDateTime__c FROM MovieSchedule__c] ;

        List<String> strList = new List<String>();
        for(Movie__c movie : mList) {
            strList.add(movie.Id);
        }
        
        List<String> thList = new List<String>();
        for(Theater__c th : tList) {
            thList.add(th.Id);
        }
        
        List<String> movieScList = new List<String>();
        for(MovieSchedule__c ms : msList) {
            movieScList.add(ms.Id);
        }

        TP_MovieInfoController.selectMultiIds(strList, thList, movieScList);
        Test.stopTest();
    }



}