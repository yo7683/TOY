public without sharing class UserLogInSignUpController {   
    @AuraEnabled
    public static string doLogin(String username, String password, String startUrl) {
       
        system.debug('asdasdsa');
        system.debug('123' + userInfo.getUserId());
        try {
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);
            
            if(pageRef != null) return pageRef.getUrl();
            system.debug('pageRef'+ pageRef);

            return null;
            
        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            return null;

        }
    }

    @AuraEnabled
    public static string registerUser(Map<String,string> signUpData) {

        String returnValue = '';
        try {
        
            Account acc = new Account();
            acc = [SELECT Id FROM Account WHERE Name = 'toyAccount' LIMIT 1];
            Contact con = insertContact(signUpData, acc);
            User user = insertUser(signUpData, con);
            update acc;
            returnValue = 'S';
            
        } catch (Exception e) {
            returnValue = e.getMessage() + ' || ' + e.getLineNumber();
        }
        
        return returnValue;

    }

    // @AuraEnabled
    // public static Account insertAccount() {
    //     Account acc = new Account();
    //     acc.Name = 'toyAccount';

    //     insert acc;
    //     return acc;
    // }

    @AuraEnabled
    public static Contact insertContact(Map<String, String> signUpData, Account acc) {
        Contact con = new Contact();
        con.AccountId = acc.Id;
        System.debug('name :: ' + signUpData.get('lastName'));
        con.LastName = signUpData.get('lastName');
        con.Email = signUpData.get('email');

        insert con;
        return con;
    }

    @AuraEnabled
    public static User insertUser(Map<String, String> signUpData, Contact con) {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'toy'];
        User user = new User();
        user.ContactId = con.Id;
        user.LastName = signUpData.get('lastName');
        user.Alias = signUpData.get('alias');
        user.Username = signUpData.get('email');
        user.Email = signUpData.get('email');
        user.ProfileId = profile.Id;
        user.EmailEncodingKey = 'UTF-8';
        user.TimeZoneSidKey = 'Asia/Seoul';
        user.LocaleSidKey = 'ko_KR';
        user.LanguageLocaleKey = 'ko';

        insert user;
        return user;
    }


}