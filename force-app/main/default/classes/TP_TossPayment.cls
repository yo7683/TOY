public without sharing class TP_TossPayment {
    
    @AuraEnabled
    public static String authPayment() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.tosspayments.com');
        req.setMethod('POST');
        Blob blobKey = Blob.valueOf('test_sk_P9BRQmyarYGQmgkWxGp3J07KzLNk:');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(blobKey));
        System.debug('base :: ' + EncodingUtil.base64Encode(blobKey));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('res :: ' + res);
        return String.valueOf(res);
    }
}