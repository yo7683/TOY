/*************************************************************
 * @author : th.kim
 * @date : 2023-08-08
 * @group :
 * @group-content :
 * @description : 영화 목록 페이지 Controller
==============================================================
 * Ver          Date             Author         Modification
   1.0          2023-08-08       th.kim         Initial Version
**************************************************************/

public without sharing class TP_MoviesController {

    /**
     * @author th.kim
     * @description 영화관에 대한 데이터와 이미지 리스트 가져오기
     * @param isShowing 상영중 옵션 클릭 시
     * @param isSoon 개봉 예정 옵션 클릭 시
     * @param count 페이징 수
     *
     * @return returnMap
     */
    @AuraEnabled
    public static Map<String, Object> getMovies(Boolean isShowing, Boolean isSoon, Integer count) {
        try {
            String query;

            query = ' SELECT Id, Name, Movie_OpeningDate__c, ReservationRate__c FROM Movie__c ';
            if (isShowing) {
                query += ' WHERE Movie_OpeningDate__c <= TODAY ';
            } else if (isSoon) {
                query += ' WHERE Movie_OpeningDate__c > TODAY ';
            }
            query += ' ORDER BY ReservationRate__c DESC ';
            System.debug('query :: ' + query);

            List<Movie__c> movieList = new List<Movie__c>();
            movieList = Database.query(query);
            System.debug('movieList :: ' + movieList);

            List<ContentDistribution> soonCdList = new List<ContentDistribution>();
            for (Movie__c m : movieList) {
                ContentDistribution cd = new ContentDistribution();
                cd = getCd(m);
                soonCdList.add(cd);
            }

            Decimal size = movieList.size();
            Decimal page = size / 12;
            List<Movie__c> returnList = new List<Movie__c>();
            List<ContentDistribution> returnCdList = new List<ContentDistribution>();

            for (Integer i = 0; i < 12; i++) {
                Integer n = 12 * (count - 1);
                if (size > n + i) {
                    returnList.add(movieList[n + i]);
                    returnCdList.add(soonCdList[n + i]);
                }
            }

            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('movie', returnList);
            returnMap.put('cd', returnCdList);
            returnMap.put('page', page);

            return returnMap;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    /**
     * @author th.kim
     * @description 영화관 데이터에 대한 ContentDistribution 이미지 가져오기
     * @param movie Movie__c 데이터
     *
     * @return cd
     */
    private static ContentDistribution getCd(Movie__c movie) {
        ContentDistribution cd = new ContentDistribution();
        try {
            List<CdFile__c> cdfList = [SELECT Id FROM CdFile__c WHERE RecordId__c = :movie.Id ORDER BY CreatedDate DESC LIMIT 1];
            if (cdfList.isEmpty()) {
                cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE RelatedRecordId = :movie.Id ORDER BY CreatedDate DESC LIMIT 1];
            } else {
                cd = [SELECT Id, ContentDownloadUrl FROM ContentDistribution WHERE RelatedRecordId = :cdfList[0].Id ORDER BY CreatedDate DESC LIMIT 1];
            }
            return cd;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }

    }
}