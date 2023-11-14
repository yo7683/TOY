public without sharing class MovieTriggerHandler {
    
    private Boolean isExecuting {get;set;}   // Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;}     // Trigger에서 Execute된 List Size

    public MovieTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;

        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }

    public void onBeforeDelete(List<Movie__c> olds) {

        Set<Id> ids = new Set<Id>();
        for(Movie__c movie : olds) {
            ids.add(movie.Id);
        }
        System.debug('ids :: ' + ids);

        List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
        cdLinkList = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN : ids];
        System.debug('cdLinkList :: ' + cdLinkList);

        Set<Id> cdIds = new Set<Id>();
        for(ContentDocumentLink cdLink : cdLinkList) {
            cdIds.add(cdLink.ContentDocumentId);
        }
        System.debug('cdIds :: ' + cdIds);

        List<ContentDocument> cdList = new List<ContentDocument>();
        cdList = [SELECT Id FROM ContentDocument WHERE Id IN : cdIds];
        System.debug('cdList :: ' + cdList);

        delete cdList;

        List<ContentDistribution> cdbList = new List<ContentDistribution>();
        cdbList = [SELECT Id FROM ContentDistribution WHERE RelatedRecordId IN : ids];
        System.debug('cdbList :: ' + cdbList);
        
        delete cdbList;
    }
}