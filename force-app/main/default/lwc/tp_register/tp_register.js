import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import registerUser from '@salesforce/apex/UserLogInSignUpController.registerUser';


export default class Tp_register extends NavigationMixin(LightningElement) {

    firstName;
    lastName;
    email;
    name;
    alias;

    isModalOpen = false;

    
    navigateToRegisterPage() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            },
        });
    }

    closeModal() {
        this.isModalOpen = false;
    }


    onIdChange(e) {
        this.username = e.target.value;
        console.log('value :: ',this.username);
    }

    onAliasChange(e) {
        this.alias = e.target.value;
        console.log('value :: ',this.alias);
    }

    onEmailChange(e) {
        this.email = e.target.value;
        console.log('value :: ',this.email);
    }

    onFirstnameChange(e) {
        this.firstName = e.target.value;
        console.log('value :: ',this.firstName);
    }

    onLastnameChange(e) {
        this.lastName = e.target.value;
        console.log('value :: ',this.lastName);
    }


    handleRegister(event) {
        console.log('회원가입');
        let signUpData = {username : this.username,  firstName: this.firstName, lastName : this.lastName, alias: this.alias, email: this.email};
        console.log('signUpData ::', signUpData);
        registerUser({signUpData : signUpData})
            .then(result => {
                console.log('result ::', result);
                if(result == 'S'){
                
                    console.log('result ::', result);
                    console.log('성공?')
                    this.isModalOpen = true;

                }
                
            })
            .catch((error) => {
                this.error = error;

                console.log('error-',error);
                
            });

    }


}