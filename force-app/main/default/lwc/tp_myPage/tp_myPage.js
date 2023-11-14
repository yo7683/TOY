import { LightningElement } from 'lwc';
import getUser from '@salesforce/apex/TP_MyPageController.getUser';

export default class Tp_myPage extends LightningElement {

    alias;

    connectedCallback() {
        getUser().then(res => {
            console.log('res :: ',res);
            this.alias = res.Alias;
        }).catch(err => {
            console.log('err :: ',err);
        });
    }
}