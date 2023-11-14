import { LightningElement, track } from 'lwc';
import getMovies from '@salesforce/apex/TP_MoviesController.getMovies';
import { NavigationMixin } from 'lightning/navigation';

export default class Tp_movies extends NavigationMixin(LightningElement) {
    
    @track movieList = [];
    isShowing = false;
    isSoon = false;
    isLoading = false;
    count = 1;
    page;

    /** 페이지 로드 시 영화 리스트 불러오기 및 스크롤 이벤트 생성 */
    connectedCallback() {
        this.getMovie();
        window.addEventListener('scroll', e => {
            let scrollEnd = window.innerHeight + window.scrollY + 100 > document.body.offsetHeight;
            if(scrollEnd && (this.count < this.page)) {
                this.count++;
                this.getMovie();
            }
        });
    }

    /** 영화 리스트 가져오는 함수 */
    getMovie() {
        this.isLoading = true;
        getMovies({isShowing : this.isShowing, isSoon : this.isSoon, count : this.count}).then(res => {
            console.log('res :: ',res);
            let movie = res.movie;
            let cd = res.cd;
            this.page = res.page;
            for(let i = 0; i < movie.length; i++) {
                this.movieList.push({
                    id : movie[i].Id,
                    name : movie[i].Name,
                    opening : movie[i].Movie_OpeningDate__c,
                    reserve : Number(movie[i].ReservationRate__c).toFixed(1),
                    img : cd[i].ContentDownloadUrl
                });
            }
            this.isLoading = false;
        }).catch(err => {
            console.log('err :: ',err);
            this.isLoading = false;
        });
    }

    /** 헤더 클릭 */
    onHeaderClick(e) {
        let bo = this.template.querySelector('.title-box-office');
        let soon = this.template.querySelector('.title-soon');
        this.movieList = [];
        this.count = 1;
        switch(e.target.dataset.id) {
            case 'box-office' :
                soon.style.border = '0';
                bo.style.border = 'solid';
                this.isShowing = false;
                this.isSoon = false;
                this.getMovie();
                break;
            case 'soon' :
                soon.style.border = 'solid';
                bo.style.border = '0';
                this.isShowing = false;
                this.isSoon = true;
                this.getMovie();
                break;
        }
    }

    /** 체크박스 클릭 */
    onChkClick() {
        let chkValue = this.template.querySelector('.checkbox').checked;
        this.movieList = [];
        this.count = 1;
        if(chkValue) {
            this.isShowing = true;
            this.getMovie();
        }
        else {
            this.isShowing = false;
            this.getMovie();
        }
    }

    /** 컨텐츠 마우스 오버 */
    onMouseOver(e) {
        let imgBox = this.template.querySelector('button[data-id="' + e.target.dataset.id + '"]');
        let img = this.template.querySelector('img[data-id="' + e.target.dataset.id + '"]');
        imgBox.style.display = 'block';
        img.style.opacity = '30%'
    }

    /** 컨텐츠 마우스 아웃 */
    onMouseOut(e) {
        let imgBox = this.template.querySelector('button[data-id="' + e.target.dataset.id + '"]');
        let img = this.template.querySelector('img[data-id="' + e.target.dataset.id + '"]');
        imgBox.style.display = 'none';
        img.style.opacity = '1'
    }

    /** 상세보기 버튼 */
    onDetailClick(e) {
        this.navigation('movieDetail__c', e.target.dataset.id);
    }

    /** 예매하기 버튼 */
    onReserveClick(e) {
        this.navigation('reservation__c', e.target.dataset.id);
    }

    /** 페이지 이동 함수 */
    navigation(apiName, recordId) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: apiName
            },
            state: {
                recordId : recordId
            }
        });
    }
}