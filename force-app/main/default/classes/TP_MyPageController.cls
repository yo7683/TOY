public without sharing class TP_MyPageController {

    @AuraEnabled
    public static User getUser(){
        try {
            String userId = System.UserInfo.getUserId();
            User user = [SELECT Id, Name, Username, Alias FROM User WHERE Id =: userId];
            return user;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }
}