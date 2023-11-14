public without sharing class ContentVersionTriggerHandler {

    private Boolean isExecuting {get;set;}   // Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;}     // Trigger에서 Execute된 List Size

    public ContentVersionTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;

        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    public void onAfterInsert(List<ContentVersion> news) {
        try {
            // Product 대신 사용할 커스텀 개체 생성
            List<CdFile__c> cdFileList = new List<CdFile__c>();
            for(ContentVersion cv : news) {
                CdFile__c cdf = new CdFile__c();
                cdf.Name = string.valueOf(cv.PathOnClient) + ' ' + cv.FirstPublishLocationId;
                cdf.ContentDocumentId__c = cv.ContentDocumentId;
                cdf.RecordId__c = cv.FirstPublishLocationId;
                cdFileList.add(cdf);
            }
            if(!cdFileList.isEmpty()) insert cdFileList;
            System.debug('cdFileList :: ' + cdFileList);
    
            // Product의 파일을 새로 만든 커스텀 개체에 새로 생성
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            for(CdFile__c cdf : cdFileList) {
                ContentDocumentLink cdLink = new ContentDocumentLink();
                cdLink.LinkedEntityId = cdf.Id;
                cdLink.ContentDocumentId = cdf.ContentDocumentId__c;
                cdLinkList.add(cdLink);
            }
            if(!cdLinkList.isEmpty()) insert cdLinkList;
            System.debug('cdLinkList :: ' + cdLinkList);
    
            // Product의 Id와 User Id로는 RelatedRecordId를 생성할 수 없어서 커스텀 개체의 Id로 생성 - Url Contentversion 쓰면 돼서 필요 업슴
            List<ContentDistribution> cdbList = new List<ContentDistribution>();
            for(ContentVersion cv : news) {
                ContentDistribution cdb = new ContentDistribution();
                CdFile__c cdf = [SELECT Id FROM CdFile__c WHERE RecordId__c =: cv.FirstPublishLocationId ORDER BY CreatedDate DESC LIMIT 1];
                cdb.ContentVersionId = cv.Id;
                cdb.Name = string.valueOf(cv.PathOnClient);
                cdb.PreferencesAllowViewInBrowser= true;
                cdb.PreferencesLinkLatestVersion=true;
                cdb.PreferencesNotifyOnVisit=false;
                cdb.PreferencesPasswordRequired=false;
                cdb.PreferencesAllowOriginalDownload= true;
                cdb.RelatedRecordId = cdf.Id;
                cdbList.add(cdb);
            }
            if(!cdbList.isEmpty()) insert cdbList;
            System.debug('cdbList :: ' + cdbList);
        } catch(Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
        }
    }
    public void onAfterDelete(List<ContentVersion> olds) {
        
        Set<Id> ids = new Set<Id>();
        Set<Id> publishIds = new Set<Id>();
        for(ContentVersion cv : olds) {
            ids.add(cv.Id);
            publishIds.add(cv.FirstPublishLocationId);
        }

        List<CdFile__c> cdFileList = new List<CdFile__c>();
        cdFileList = [SELECT Id FROM CdFile__c WHERE RecordId__c IN : publishIds];
        if(!cdFileList.isEmpty()) delete cdFileList;
        
        List<ContentDistribution> cdbList = new List<ContentDistribution>();
        cdbList = [SELECT Id FROM ContentDistribution WHERE ContentVersionId IN : ids];

        if(!cdbList.isEmpty()) delete cdbList;
    }
}