import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMovieList from '@salesforce/apex/TP_HomeController.getMovieList';

export default class Tp_home extends NavigationMixin(LightningElement) {

    isMovieChart = true;
    isSoonChart;
    @track movieList = [];
    @track soonList = [];
    currentPage = 0;
    page = 0;
    backBtn = '<';

    connectedCallback() {
        this.getMovie();
    }

    /** 영화 목록 가져오는 함수 */
    getMovie() {
        getMovieList().then(res => {
            let movie = res.movie;
            let cd = res.cd;
            let soonMovie = res.soonMovie;
            let soonCd = res.soonCd;
            if(!this.isSoonChart) this.page = movie.length/5;
            else this.page = soonMovie.length/5;
            let nextBtn = this.template.querySelector('.next');
            if(this.page <= 1) {
                nextBtn.style.display = 'none';
            } else {
                nextBtn.style.display = 'block';
            }
            for(let i = 0; i < movie.length; i++) {
                this.movieList.push({
                    id : movie[i].Id,
                    name : movie[i].Name,
                    img : cd[i].ContentDownloadUrl
                });
            }
            for(let i = 0; i < soonMovie.length; i++) {
                this.soonList.push({
                    id : soonMovie[i].Id,
                    name : soonMovie[i].Name,
                    img : soonCd[i].ContentDownloadUrl
                });
            }
        }).catch(err => {
            console.log('err :: ',err);
        });
    }

    /** 헤더 클릭 시 탭 활성화 onclick() 함수 */
    onHedaerClick(e) {
        let movie = this.template.querySelector('.movie-chart');
        let soon = this.template.querySelector('.soon-chart');
        let backBtn = this.template.querySelector('.back');
        backBtn.style.display = 'none';
        this.movieList = [];
        this.soonList = [];
        this.currentPage = 0;
        let slider = this.template.querySelector('.slider-box');
        switch(e.target.dataset.id) {
            case 'movie-chart' :
                if(this.isMovieChart) slider.style.transform = 'translate(0%)';
                this.isSoonChart = false;
                this.isMovieChart = true;
                this.getMovie();
                movie.style.fontWeight = 'bold';
                movie.style.color = '#000000CC';
                soon.style.fontWeight = '500';
                soon.style.color = 'gray';
                break;
            case 'soon-chart' :
                if(this.isSoonChart) slider.style.transform = 'translate(0%)';
                this.isMovieChart = false;
                this.isSoonChart = true;
                this.getMovie();
                movie.style.fontWeight = '500';
                movie.style.color = 'gray';
                soon.style.fontWeight = 'bold';
                soon.style.color = '#000000CC';
                break;
        }
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

    /** 영화 상세보기 버튼 */
    onDetailClick(e) {
        this.navigation('movieDetail__c',e.target.dataset.id);
    }

    /** 영화 예매하기 버튼 */
    onReserveClick(e) {
        this.navigation('reservation__c',e.target.dataset.id);
    }

    /** 차트 다음 페이지 화살표 클릭 버튼 */
    onNextClick() {
        if(this.currentPage < this.page) {
            let slider = this.template.querySelector('.slider-box');
            if(this.currentPage < 0) this.currentPage = 0;
            this.currentPage += 1;
            let move = this.currentPage * 98;
            slider.style.transform = 'translate(-' + move + '%)';
        }
        let nextBtn = this.template.querySelector('.next');
        let backBtn = this.template.querySelector('.back');
        if((this.currentPage + 1) >= this.page) {
            nextBtn.style.display = 'none';
            backBtn.style.display = 'block';
        } else if(this.currentPage < this.page) {
            backBtn.style.display = 'block';
        }
    }

    /** 차트 이전 페이지 화살표 클릭 버튼 */
    onBackClick() {
        let slider = this.template.querySelector('.slider-box');
        let move = (this.currentPage - 1) * 98;
        slider.style.transform = 'translate(-' + move + '%)';
        this.currentPage -= 1;
        let nextBtn = this.template.querySelector('.next');
        let backBtn = this.template.querySelector('.back');
        if(this.currentPage < 1) {
            nextBtn.style.display = 'block';
            backBtn.style.display = 'none';
        }
        if(this.currentPage < this.page) {
            nextBtn.style.display = 'block';
        }
    }

    /** 전체보기 버튼 */
    onViewAllClick() {
        this.navigation('movies__c', '');
    }
}