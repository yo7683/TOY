/*************************************************************
 * @author : th.kim
 * @date : 2023-08-08
 * @group :
 * @group-content :
 * @description : 영화 상세정보 페이지 Controller
==============================================================
 * Ver          Date             Author         Modification
   1.0          2023-08-08       th.kim         Initial Version
**************************************************************/

public without sharing class TP_MovieDetailController {

    /**
     * @author th.kim
     * @description 영화 상세정보 가져오기
     * @param recordId 선택한 영화 Movie__c Id
     *
     * @return returnMap
     */
    @AuraEnabled
    public static Map<String, Object> getMovieInfo(String recordId) {
        try {

            ContentDistribution cd = new ContentDistribution();
            cd = [SELECT Id, ContentDownloadUrl, ContentVersionId, ContentDocumentId, RelatedRecordId FROM ContentDistribution WHERE RelatedRecordId = :recordId];
            System.debug('cd :: ' + cd);

            Movie__c movie = new Movie__c();
            movie = [SELECT Id, Name, Movie_OpeningDate__c, ReservationRate__c, Type__c, Actor__c, Description__c, Director__c, BasicInfo__c FROM Movie__c WHERE Id = :recordId];
            System.debug('movie :: ' + movie);

            List<AggregateResult> ratingList = new List<AggregateResult>();
            ratingList = [SELECT AVG(Rating__c) avg, COUNT(Rating__c) cnt FROM Review__c WHERE md_Movie__c = :recordId GROUP BY md_Movie__c];
            System.debug('ratingList :: ' + ratingList);

            Map<String, Object> returnMap = new Map<String, Object>();
            returnMap.put('cd', cd);
            returnMap.put('movie', movie);
            if (!ratingList.isEmpty()) returnMap.put('rating', ratingList[0]);

            return returnMap;

        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + e.getLineNumber());
            return null;
        }
    }

    /**
     * @author th.kim
     * @description 영화에 대한 리뷰 데이터 가져오기
     * @param recordId 영화 Record Id
     * @param count 페이징 수
     *
     * @return returnMap
     */
    @AuraEnabled
    public static Map<String, Object> getReview(String recordId, Integer count) {
        try {

            List<Review__c> rvList = new List<Review__c>();
            rvList = [SELECT Id, Contents__c, Rating__c, md_Movie__c, CreatedDate, CreatedBy.Alias FROM Review__c WHERE md_Movie__c = :recordId ORDER BY CreatedDate DESC];
            System.debug('rvList :: ' + rvList);

            Decimal size = rvList.size();
            Decimal page = size / 10;
            List<Review__c> returnList = new List<Review__c>();
            List<String> dateList = new List<String>();

            for (Integer i = 0; i < 10; i++) {
                Integer n = 10 * (count - 1);
                if (size > n + i) {
                    returnList.add(rvList[n + i]);
                    dateList.add(rvList[n + i].CreatedDate.format());
                }
            }

            Map<String, Object> returnMap = new Map<String, Object>();
            if (!rvList.isEmpty()) {
                returnMap.put('review', returnList);
                returnMap.put('reviewDate', dateList);
                returnMap.put('page', page);
            }

            return returnMap;
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return null;
        }
    }

    /**
     * @author th.kim
     * @description 영화를 예매한 사용자만 리뷰 작성할 수 있게 하기 위한 메서드
     * @param recordId 영화 Record Id
     *
     * @return 예매 O :'S', 예매 X : 'N', 세션 오류 : 'F'
     */
    @AuraEnabled
    public static String userCheck(String recordId) {
        try {
            String session = UserInfo.getSessionId();
            String userId = UserInfo.getUserId();
            List<Reservation__c> resList = new List<Reservation__c>();
            resList = [SELECT Id, md_Movie__c FROM Reservation__c WHERE md_Movie__c = :recordId AND CreatedById = :userId];
            if (session != null) {
                if (resList.isEmpty()) {
                    return 'N';
                } else {
                    return 'S';
                }
            } else {
                return 'F';
            }
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return 'F';
        }
    }

    /**
     * @author th.kim
     * @description 리뷰 작성 시 레뷰 데이터 생성
     * @param recordId 영화 Record Id
     * @param contents 리뷰 내용
     * @param rating 별정
     *
     * @return 성공 : 'S', 실패 'F'
     */
    @AuraEnabled
    public static String insertReview(String recordId, String contents, Integer rating) {
        try {
            Review__c rv = new Review__c();
            rv.md_Movie__c = recordId;
            rv.Contents__c = contents;
            rv.Rating__c = rating;
            insert rv;
            return 'S';
        } catch (Exception e) {
            System.debug('err :: ' + e.getMessage() + ' || ' + e.getLineNumber());
            return 'F';
        }
    }
}