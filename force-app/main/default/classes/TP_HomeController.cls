/*************************************************************
 * @author : th.kim
 * @date : 2023-08-08
 * @group :
 * @group-content :
 * @description : 영화관 홈페이지 Controller
==============================================================
 * Ver          Date             Author         Modification
   1.0          2023-08-08       th.kim         Initial Version
**************************************************************/

public without sharing class TP_HomeController {

    /**
     * @author th.kim
     * @description 홈페이지에서 영화관 데이터, ContentDistribution 이미지 가져오기
     * @return cdMap
     */
    @AuraEnabled
    public static Map<String,Object> getMovieList(){
        try {
            Date today = Date.today();

            List<Movie__c> movieList = new List<Movie__c>();
            movieList = [SELECT Id, Name, Movie_OpeningDate__c, ReservationRate__c FROM Movie__c ORDER BY ReservationRate__c DESC LIMIT 15];
            
            List<ContentDistribution> cdList = new List<ContentDistribution>();
            cdList = getCdList(movieList);
            
            List<Movie__c> mList = new List<Movie__c>();
            List<ContentDistribution> cList = new List<ContentDistribution>();
            for(Movie__c movie : movieList) {
                for(ContentDistribution cd : cdList) {
                    if(movie.Id == cd.RelatedRecordId) {
                        mList.add(movie);
                        cList.add(cd);
                    }
                }
            }

            List<Movie__c> soonList = new List<Movie__c>();
            soonList = [SELECT Id, Name, Movie_OpeningDate__c, ReservationRate__c FROM Movie__c WHERE Movie_OpeningDate__c > :today ORDER BY ReservationRate__c DESC LIMIT 15];
            
            List<ContentDistribution> soonCdList = new List<ContentDistribution>();
            soonCdList = getCdList(soonList);
            
            List<Movie__c> soonMovieList = new List<Movie__c>();
            List<ContentDistribution> soonCList = new List<ContentDistribution>();
            for(Movie__c movie : soonList) {
                for(ContentDistribution cd : soonCdList) {
                    if(movie.Id == cd.RelatedRecordId) {
                        soonMovieList.add(movie);
                        soonCList.add(cd);
                    }
                }
            }

            Map<String,Object> cdMap = new Map<String,Object>();
            cdMap.put('movie',mList);
            cdMap.put('cd',cList);
            cdMap.put('soonMovie',soonMovieList);
            cdMap.put('soonCd',soonCList);
            return cdMap;
        } catch(Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    /**
     * @author th.kim
     * @description Movie__c 영화 데이터와 관련된 ContentDistribution 이미지 데이터 가져오기
     * @param movieList Movie__c 리스트
     *
     * @return cdList
     */
    private static List<ContentDistribution> getCdList(List<Movie__c> movieList){
        Set<Id> ids = new Set<Id>();
        for(Movie__c m : movieList) {
            ids.add(m.Id);
        }
        List<ContentDistribution> cdList = [SELECT Id, ContentDownloadUrl, ContentVersionId, ContentDocumentId, RelatedRecordId FROM ContentDistribution WHERE RelatedRecordId IN : ids];
    
        System.debug('cdList'+cdList);
        return cdList;
    }
}