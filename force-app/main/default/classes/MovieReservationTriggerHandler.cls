public without sharing class MovieReservationTriggerHandler {

    private Boolean isExecuting {get;set;}   // Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;}     // Trigger에서 Execute된 List Size
    public MovieReservationTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    public void onAfterInsert(List<Reservation__c> newItems) {

        List<Reservation__c> rList = [SELECT Id, Name FROM Reservation__c];
        Decimal regCount = rList.size();
        List<AggregateResult> movieAgg = [SELECT COUNT(Id) recordCount, md_Movie__c FROM Reservation__c GROUP BY md_Movie__c ];
        Map<Id, Decimal> resRateMap = new Map<Id,Decimal>();
        for(AggregateResult ar : movieAgg) {
            Decimal rate = ((Decimal)ar.get('recordCount') / regCount) * 100;
            resRateMap.put((String)ar.get('md_Movie__c'), rate);
        }
        System.debug('resRateMap :::: ' + resRateMap);
        
        List<Movie__c> mList = [SELECT Id, ReservationRate__c FROM Movie__c WHERE Id IN : resRateMap.keySet()];
        List<Movie__c> updateList = new List<Movie__c>();
        for(Movie__c m : mList) {
            m.ReservationRate__c = resRateMap.get(m.Id);
            updateList.add(m);
        }

        System.debug('updateList::::' + updateList);
        update updateList;
    }
}