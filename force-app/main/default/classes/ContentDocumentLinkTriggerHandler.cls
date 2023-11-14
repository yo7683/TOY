public without sharing class ContentDocumentLinkTriggerHandler {

    private Boolean isExecuting {get;set;}   // Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;}     // Trigger에서 Execute된 List Size

    public ContentDocumentLinkTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;

        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    public void onAfterInsert(List<ContentDocumentLink> olds, List<ContentDocumentLink> news) {
        
    }
}