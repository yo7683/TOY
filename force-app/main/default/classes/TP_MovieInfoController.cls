public without sharing class TP_MovieInfoController {
    
    @AuraEnabled
    public static Map<String,Object> movieReservation(){
        try {

            List<Movie__c> msList = [SELECT Id, Name, Amounts__c FROM Movie__c ORDER BY Name];

            List<Theater__c> theaterList = [SELECT Id, Name FROM Theater__c ORDER BY Name];

            Map<String,Object> returnMap = new Map<String,Object>();
            returnMap.put('movieSchedule', msList);
            returnMap.put('theater', theaterList);

            return returnMap;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<MovieSchedule__c> theaterName(String recordId, String thearterId){
        try {

            List<MovieSchedule__c> msList = [SELECT Id, ShowDate__c, StartTime__c FROM MovieSchedule__c WHERE md_Movie__c =: recordId AND md_Theater__c =: thearterId];
            

            System.debug('msList' + msList);
            return msList;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> movieDate(String recordId, String thearterId, String timeMovie){
        try {

            List<MovieSchedule__c> msDateList = [SELECT Id, ShowDate__c, StartTime__c, ShowDateTime__c FROM MovieSchedule__c 
                                                    WHERE md_Movie__c =: recordId AND md_Theater__c =: thearterId 
                                                    AND ShowDate__c =: Date.valueof(timeMovie)];

            List<String> formatTime = new List<String>();
            for(MovieSchedule__c ms : msDateList) {
                formatTime.add(ms.ShowDateTime__c.format('HH:mm'));
            }
            Map<String, Object> returnMap = new Map<String, Object>();
            
            returnMap.put('msDateList', msDateList);
            returnMap.put('time', formatTime);
            
            
            System.debug('formatTime' + formatTime);
            return returnMap;
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Seat__c> seatView(){
        try {

            List<Seat__c> seatList = [SELECT Id, SeatColumn__c, SeatRow__c FROM Seat__c];

            System.debug('seatList:::' + seatList);

            return seatList;


            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    /*
    @AuraEnabled
    public static List<Seat__C> doReserve(List<String> pId){
        try {

            List<Seat__c> seatList = [SELECT Id, SeatColumn__c, SeatRow__c, isReserved__c FROM Seat__c WHERE Id IN :pId];

            System.debug('seatList:::' + seatList);

            for (Seat__c seat : seatList) {
                seat.isReserved__c = true;
            }

            update seatList;
            
            return seatList;
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
           
        }
    }
    */

    @AuraEnabled
    public static List<Reservation__c> doReserve(String mId, String thId, String msId, List<String> seatId){
        System.debug('doReserve 시작');
        System.debug('mId :: ' + mId);
        System.debug('thId :: ' + thId);
        System.debug('msId :: ' + msId);
        System.debug('seatId :: ' + seatId);
        try {

            List<Reservation__c> sList = [SELECT Id, Name, ReservationNum__c, md_Movie__c, md_Theater__c, l_Seat__c, l_Seat__r.SeatColumn__c, l_Seat__r.SeatRow__c 
                                            FROM Reservation__c
                                            WHERE md_Movie__c = : mId
                                            AND md_Theater__c = : thId
                                            AND l_MovieSchedule__c = : msId
                                            AND l_Seat__c IN : seatId];

            
            List<Reservation__c> rList = new List<Reservation__c>();

            for(Integer i = 0; i < seatId.size(); i++) {
                Reservation__c r = new Reservation__c();

                r.md_Movie__c = mId;
                r.md_Theater__c = thId;
                r.l_MovieSchedule__c = msId;
                r.l_Seat__c = seatId[i];
                
                rList.add(r);
            }

            System.debug('rList::::::::::' + rList);

            if(sList.isEmpty()) insert rList;


            System.debug('rList::::::::::' + rList);

            return rList;

            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static List<Reservation__c> selectMultiIds(List<String> mId, List<String> thId, List<String> msId){
        System.debug('mId :: ' + mId);
        System.debug('thId :: ' + thId);
        System.debug('msId :: ' + msId);
        try {

            List<Reservation__c> sList = [SELECT Id, Name, ReservationNum__c, md_Movie__c, md_Theater__c, l_Seat__c  FROM Reservation__c
                                            WHERE md_Movie__c IN : mId
                                            AND md_Theater__c IN : thId
                                            AND l_MovieSchedule__c IN : msId];
            
            // soql에서 in으로 id값을 할라면 파라미터를 리스트로 
            System.debug('sList :: ' + sList);
            return sList;
            
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }
}