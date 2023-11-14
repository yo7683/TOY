import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import movieReservation from '@salesforce/apex/TP_MovieInfoController.movieReservation';
import theaterName from '@salesforce/apex/TP_MovieInfoController.theaterName';
import movieDate from '@salesforce/apex/TP_MovieInfoController.movieDate';
import seatView from '@salesforce/apex/TP_MovieInfoController.seatView';
import doReserve from '@salesforce/apex/TP_MovieInfoController.doReserve';
import selectMultiIds from '@salesforce/apex/TP_MovieInfoController.selectMultiIds';
import authPayment from '@salesforce/apex/TP_TossPayment.authPayment';


// import { loadScript } from 'lightning/platformResourceLoader';
// import toss from '@salesforce/resourceUrl/toss';
// import nicepay from '@salesforce/resourceUrl/nicepay';
// import jquery from '@salesforce/resourceUrl/jquery';
// import iamport from '@salesforce/resourceUrl/iamport';

export default class Tp_movie_reservation extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference)
    pageRef;
    movieName;
    movieTheater;
    movieTime;
    @track movieClock;

    @track seatArray =[];
    @track selectedSeatId = [];
    @track selectedSeatLabel = [];
    @track selectedSeat;
    colRow;
    @track movieId;
    theaterId;
    movieScheduleId;
    startTime;
    seatClick = [];
    selectMovie;
    totalAmounts = 0;
    movieAmount = 0;
    
    isSelected;
    isShowModal;
    isReserveInfoModal;
    isReservedButton;
    isMovieSelected;

    onHomeClick() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
        });
    }
    

    connectedCallback () {
        this.movieId = this.pageRef.state.recordId;
        console.log('movieId :: ',this.movieId);
        movieReservation()
            .then((result) => {
                this.movieName = result.movieSchedule;
                this.movieTheater = result.theater;
                console.log('totalMovie :: ',result);
            }).catch((error) => {
                console.log('err :: ',error);
                this.error = error;
            });

            
    }

    renderedCallback(){
        let active = this.template.querySelector('button[data-id="' + this.movieId + '"]');
        if(active) {
        this.selectMovie = active.dataset.name;
        this.movieAmount = active.dataset.amount;
        console.log('selectMovie :: ',this.selectMovie);
            active.classList.add('active');
            active.focus();
        }
    }

    onCloseModalClick() {
        this.isShowModal = false;
    }

    onClosInfoClick() {
        this.isReserveInfoModal = false;
    }

    /** 목록 버튼 색깔 비활성화 함수 */
    removeActive(type) {
        if(type == 'movie') {
            let activeMovie = this.template.querySelector('.active');
            if(activeMovie) activeMovie.classList.remove('active');
        }
        if(type == 'movie' || type == 'theater') {
            let activeTheater = this.template.querySelector('.theater-active');
            if(activeTheater) activeTheater.classList.remove('theater-active');
        }
        if(type == 'movie' || type == 'theater' || type == 'date') {
            let activeDate = this.template.querySelector('.date-active');
            if(activeDate) activeDate.classList.remove('date-active');
        }
        if(type == 'movie' || type == 'theater' || type == 'date' || type == 'time') {
            let activeTime = this.template.querySelector('.time-active');
            if(activeTime) activeTime.classList.remove('time-active');
        }
    }

    /** 영화 클릭 시 작동 하는 메서드 */
    onMovieClick(e) {
        this.removeActive('movie');
        e.target.classList.add('active');
        this.movieId = e.target.dataset.id;

        this.theaterId = '';
        this.movieTime = [];
        this.movieClock = [];
        this.seatArray = [];
        this.isReservedButton = false;

        // Promise.all([
        //     loadScript(this, toss),
        //     loadScript(this, jquery)
        //     // loadScript(this, iamport)
        // ]).then(() => {
        //     window.console.log('Files loaded.');
        //     const clientKey = 'test_ck_DLJOpm5QrlxBRYlYBa0rPNdxbWnY'; // 테스트용 클라이언트 키
        //     const customerKey = 'zthQmGkyvV1_CXvisYyZQ'; // 내 상점에서 고객을 구분하기 위해 발급한 고객의 고유 ID

        //     // 2. 결제위젯 SDK 초기화
        //     const paymentWidget = PaymentWidget(clientKey, customerKey); // 회원 결제

        //     const paymentMethodWidget = paymentWidget.renderPaymentMethods();
        //     const selectedPaymentMethod = paymentMethodWidget.getSelectedPaymentMethod();
        //     paymentWidget.requestPayment({
        //         orderId: 'AD8aZDpbzXs4EQa-UkIX6',
        //         orderName: '토스 티셔츠 외 2건',
        //         successUrl: 'http://localhost:8080/success',
        //         failUrl: 'http://localhost:8080/fail',
        //         customerEmail: 'customer123@gmail.com',
        //         customerName: '김토스',
        //       })
        //     authPayment().then(res => {
        //     }).catch(err => {
        //         console.log('err 1 :: ',JSON.stringify(err));
        //     })
        // }).catch(err => {
        //     console.log('err 2 :: ',JSON.stringify(err));
        // });

        // var IMP = window.IMP;
        //         IMP.init('imp54278488');

        //         IMP.request_pay({
        //             pg: "html5_inicis",
        //             // pay_method: "kakaopay",
        //             merchant_uid : 'merchant_001',
        //             name : '결제테스트',
        //             amount : 1000,
                    
        //             buyer_email : 'nicepay@siot.do',
        //             buyer_name : '구매자',
        //             buyer_tel : '010-1234-5678',
        //             buyer_addr : '서울특별시 강남구 삼성동',
        //             buyer_postcode : '123-456'
        //             }, function (rsp) { // callback
        //                 if (rsp.success) {
        //                 // 결제 성공 시 로직,
        //                 console.log('success !')
        //                 } else {
        //                 // 결제 실패 시 로직,
        //                 console.log('외않되 :: ',rsp.error_msg);
        //                 }
        //             });

        // AUTHNICE.requestPay({
        //     clientId: 'S2_da11a232956a4df9b9ecc9258c598ede',
        //     method: 'card',
        //     orderId: 'order-1',
        //     amount: 1004,
        //     goodsName: '나이스페이-상품',
        //     returnUrl: 'http://localhost:3000/serverAuth', //API를 호출할 Endpoint 입력
        //     fnError: function (result) {
        //         console.log('res :: ',JSON.stringify(result));
        //         alert('개발자확인용 : ' + result.errorMsg + '')
        //     }
        //  });
        
    }

    /** 극장 클릭 시 작동하는 메서드 */
    onTheaterClick(e) {
        this.removeActive('theater');
        e.target.classList.add('theater-active');
        console.log('극장 :: ',e.target.dataset.id);
        this.theaterId = e.target.dataset.id;
        this.movieTime =[];
        this.movieClock = [];
        theaterName({recordId:this.movieId, thearterId:this.theaterId})
            .then((result) => {
                this.movieTime = result;
                console.log('result :: ',result);
                console.log('영화시간좀 나와라');

            }).catch((error) => {
                console.log('err :: ',error);
                this.error = error;
            });
        console.log('id :: ',e.target.dataset.id);
        console.log('target :: ',e.target);
    }

    /** 날짜 클릭시 작동하는 메서드 */
    dateClick(e) {
        this.removeActive('date');
        e.target.classList.add('date-active');
        console.log('시간 나와라', e.target.dataset.id);
        this.startTime = e.target.dataset.id;
        this.movieClock = [];
        movieDate({recordId:this.movieId, thearterId:this.theaterId, timeMovie:this.startTime})
            .then((result) => {
                // this.movieClock = result.time;
                let ms = result.msDateList;
                let time = result.time;
                for(let i = 0; i < ms.length; i++) {
                    this.movieClock.push({id : ms[i].Id, time : time[i]});
                }
                console.log('result :: ',JSON.stringify(this.movieClock));
                    
            }).catch((error) => {
                console.log('err :: ',error);
                this.error = error;
            });
    
    }


    /** 시간 클릭시 좌석 리스트 나오는 메서드 */
    onSeatBatch(e) {
        this.removeActive('time');
        e.target.classList.add('time-active');
        const setIds = [];
        this.movieScheduleId = e.target.dataset.id;

        seatView()
            .then((seats) => {
                console.log('좌석 나와라2');

                console.log('result :: ',seats);
                this.createSeatArray(seats);

                //영화, 극장, 시간의 아이디를 가져오는 것 좌석 예매
                selectMultiIds({mId:this.movieId, thId:this.theaterId, msId:this.movieScheduleId})
                    .then((result) => {
                        console.log('res :: ',result);
                        console.log('@@@@');
                        result.forEach(el => {
                            setIds.push(el.l_Seat__c);
                        });
                        
                        console.log('setIds :: ',JSON.stringify(setIds));

                        this.seatArray.forEach(seat => {
                            seat.seats.forEach(res => {
                                if(setIds.includes((res.id))) {
                                    res.isReserved = true;
                                }
                            })
                        })

                    }).catch((error) => {
                        console.log('err :: ',JSON.stringify(error));
                        console.log('err :: ',JSON.stringify(error.message));
                        this.error = error;
                    });

            }).catch((error) => {
                console.log('err :: ',JSON.stringify(error));
                console.log('err :: ',JSON.stringify(error.message));
                this.error = error;
            });
    }

    // 2차원 배열을 사용하여 행, 열 영화관 좌석처럼 만드는 매서드
    createSeatArray(seats){
        console.log('createSeatArray start');
        const seatArray = [];


        seats.forEach(item => {
            // console.log('createSeatArray item :: ' + JSON.stringify(item));

            const column = item.SeatColumn__c;
            const row = item.SeatRow__c
            const label = column + row;
            let isSelected = null;
            
            const newSeat = {id:item.Id, column, row, label, isSelected};

            // console.log('newSeat', JSON.stringify(newSeat));
            
            let rowFound = false;
            seatArray.forEach(result => {
                // console.log('result' + JSON.stringify(result));
                if(result.column === column) {
                    result.seats.push(newSeat);
                    rowFound = true;
                }else{
                    console.log('else');
                }
            });
            if(!rowFound && (row != undefined) && (column != undefined)) {
                seatArray.push({column, seats:[newSeat]});
            }
            
            
        });
        console.log('seats :: ',JSON.stringify(seats));
        console.log('seatArray1:::', JSON.stringify(seatArray));
        console.log('abc:::');

        this.seatArray = seatArray;

        console.log('seatArray2:::', seatArray);
    }

    /** 클릭된 좌석의 아이디 값을 가져오는 메서드 */
    onSeatNumber(e) {
        this.isReservedButton = true;

        console.log('눌렸다');

        console.log('Test:::::', e.target.dataset.id);

        let clickSeat = this.template.querySelector('button[data-id="' +  e.target.dataset.id + '"]');
        console.log('clickSeat :: ',clickSeat);

        console.log('this.seatArray.seats :: ',JSON.stringify(this.seatArray));
        console.log('this.seatArray.seats :: ',JSON.stringify(this.seatArray.seats));
        
        this.seatArray.forEach(array => {
            array.seats.forEach(result =>{
                if(result.id == e.target.dataset.id) {
                    console.log('label :: ',result.label);
                    console.log('resultid ====>' + result.id);
                    if(result.isSelected != true){
                        console.log('selected');
                        result.isSelected = true;
                    }else{
                        console.log('not selected');
                        result.isSelected = false;
                    }
                }else{
                    
                }})
            });
            console.log('this.seatArray.seats :: ',JSON.stringify(this.seatArray.seats));
            console.log('result' + JSON.stringify(this.seatArray));

        this.seatClick.push(e.target.dataset.id);
        

        // 배열 콘솔 찍을 때는 JSON.stringify를 사용
        // console.log('seatClick::::', JSON.stringify(this.seatClick));

    }

    /** 예약하기 버튼 클릭했을 때 발생하는 이벤트 */
    doReserveClick(e) {
        this.isShowModal = true;
        this.selectedSeatId = [];
        this.selectedSeatLabel = [];
        this.selectedSeat = [];
        this.seatArray.forEach(array => {
            array.seats.forEach(result =>{
                if(result.isSelected == true) {
                    console.log('selected둘다 찍히는거임?');
                    this.selectedSeatId.push(result.id);
                    this.selectedSeatLabel.push(result.label);
                    this.selectedSeat = JSON.stringify(this.selectedSeatLabel);
                    console.log('selectedSeat::: ', this.selectedSeat);
            
                } else {
                    
                    console.log('not selected2222');
                }
            });
        });
        
        console.log('this.selectedSeatId::::', JSON.stringify(this.selectedSeatId));
        console.log('this.selectedSeatLabel::::', JSON.stringify(this.selectedSeatLabel));


        let count = this.selectedSeatId.length;

        this.totalAmounts = (count * this.movieAmount);
        console.log(typeof this.movieAmount);
        console.log(typeof this.totalAmounts);
        console.log('토탈 가격::::', this.totalAmounts);

        console.log('이건 찍히나?');

        
    }


    /** 예약하는 메서드 */
    onReserveClick() {
        this.isReserveInfoModal = true;
        this.isShowModal = false;

        doReserve({mId:this.movieId, thId:this.theaterId, msId:this.movieScheduleId, seatId:this.selectedSeatId})
        .then((res) => { 
            console.log('잘되네?');
            console.log('qeqeqeqeqe ::::::::: ', this.movieId);
            console.log('result :: ', res);
                    
            }).catch((error) => {
                console.log('err :: ', error);
            });

    }
 
 
   
}