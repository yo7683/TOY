import { LightningElement } from 'lwc';
import doLogin from '@salesforce/apex/UserLogInSignUpController.doLogin';
import { NavigationMixin } from 'lightning/navigation';

export default class Tp_login extends NavigationMixin(LightningElement) {

    username;
    password;

    navigateToWebPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
        });
    }

    navigateToRegisterPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Register'
            },
        });
    }

    
    onIdChange(e) {
        this.username = e.target.value;
        console.log('value :: ',this.username);
    }

    onPasswordChange(e) {
        this.password = e.target.value;
        console.log('value :: ',this.password);
    }
    
    
    logInClick(event) {
        console.log('로그인 버튼 잘눌림');
        if(this.username && this.password) {
            console.log('username ::', this.username + 'password::', this.password);
            doLogin({ username: this.username, password: this.password, startUrl: this.startUrl})
            .then((result) => {
                console.log('res :: ',result);
                if(result) {
                    window.location.href = result;
                }
            }).catch((error) => {
                console.log('err :: ',error);
                this.error = error;
            });
        }
    }

    signUpClick() {
        this.navigateToRegisterPage();
        console.log('회원가입 버튼 눌림');
    }


}