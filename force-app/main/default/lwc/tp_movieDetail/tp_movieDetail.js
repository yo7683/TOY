import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMovieInfo from '@salesforce/apex/TP_MovieDetailController.getMovieInfo';
import userCheck from '@salesforce/apex/TP_MovieDetailController.userCheck';
import insertReview from '@salesforce/apex/TP_MovieDetailController.insertReview';
import getReview from '@salesforce/apex/TP_MovieDetailController.getReview';

export default class Tp_movieDetail extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
    pageRef;
    recordId;
    img;
    showingState;
    contents;
    movie = [];
    cd = [];
    ratingAvg = 0;
    reviewCnt = 0;
    @track reviewList = [];
    isShowModal;
    isNonLoginModal;
    isLoginUserModal;
    isReserveChk;
    isLoading;
    count = 1;
    page;

    connectedCallback() {
        this.recordId = this.pageRef.state.recordId;
        getMovieInfo({recordId : this.recordId}).then(res => {
            this.movie = res.movie;
            this.movie.ReservationRate__c = Number(res.movie.ReservationRate__c).toFixed(1);
            this.cd = res.cd;
            let rating = res.rating;
            
            this.contents = this.movie.Description__c.replaceAll('\n', '<br>');
            if(rating) {
                this.reviewCnt = rating.cnt;
                this.ratingAvg = rating.avg.toFixed(1);
            }
            
            let today = new Date();
            let od = new Date(this.movie.Movie_OpeningDate__c);
            let badge = this.template.querySelector('.state-badge');
            if(today > od) {
                this.showingState = '현재상영중';
                badge.classList.add('badge-showing');
                // badge.style.border = 'solid 2px skyblue';
                // badge.style.color = 'skyblue';
            }
            else {
                this.showingState = '상영예정';
                badge.classList.add('badge-soon');
                // badge.style.border = 'solid 2px gray';
                // badge.style.color = 'gray';
            }
        }).catch(err => {
            console.log('err :: ',err);
        });
        this.getReviewFunc();
        window.addEventListener('scroll', e => {
            let scrollEnd = window.innerHeight + window.scrollY + 100 > document.body.offsetHeight;
            if(scrollEnd && (this.count < this.page)) {
                this.count++;
                this.getReviewFunc();
            }
        });
    }

    /** 영화 정보, 리뷰 가져오는 함수 */
    getReviewFunc() {
        this.isLoading = true;
        getReview({recordId : this.recordId, count : this.count}).then(res => {
            let review = res.review;
            let reviewDate = res.reviewDate;
            this.page = res.page;
            if(review) {
                for(let i = 0; i < review.length; i++) {
                    this.reviewList.push({
                        id : review[i].Id,
                        rvContents : review[i].Contents__c,
                        rating : review[i].Rating__c,
                        date : reviewDate[i],
                        alias : review[i].CreatedBy.Alias
                    });
                }
            }
            this.isLoading = false;
        }).catch(err => {
            console.log('err :: ',err);
            this.isLoading = false;
        });
    }

    /** 페이지 이동 함수 */
    navigation(pageName, recordId) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: pageName
            },
            state: {
                recordId : recordId
            }
        });
    }

    /** 예매하기 버튼 */
    onReserveClick() {
        this.navigation('reservation__c', this.recordId);
    }

    /** 리뷰작성 버튼 */
    onReviewWriteClick() {
        this.isShowModal = true;
        userCheck({recordId : this.recordId}).then(res => {
            if(res == 'S') {
                this.isLoginUserModal = true;
            } else if(res == 'N') {
                this.isReserveChk = true;
            } else {
                this.isNonLoginModal = true;
            }
        }).catch(err => {
            console.log('err :: ',err);
        });
    }

    /** 모달 창 닫기 버튼 */
    onCloseModalClick() {
        this.isShowModal = false;
    }

    /** 비회원일 시 모달 창 로그인 버튼 */
    onLoginClick() {
        this.navigation('login', '');
    }

    /** 회원일 시 모달 창 저장 버튼 */
    onSaveClick() {
        let contents = this.template.querySelector('.textarea').value;
        let rating = this.template.querySelector('.slider').value;
        if(!contents || !rating) {
            this.dispatchEvent(
                new ShowToastEvent({title : '', message : '리뷰 내용과 평점을 작성해주세요 ,,', variant : 'warning'})
            );
        } else {
            insertReview({recordId : this.recordId, contents : contents, rating : rating})
            .then(res => {
                if(res == 'S') {
                    this.dispatchEvent(
                        new ShowToastEvent({title: '', message: '리뷰 작성 완료 !', variant: 'success'})
                    );
                    this.isShowModal = false;
                    this.reviewList = [];
                    this.count = 1;
                    this.getReviewFunc();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({title : '', message : '리뷰 작성 실패,,', variant : 'warning'})
                    );
                }
            }).catch(err => {
                console.log('err :: ',err);
            });
        }
    }
}