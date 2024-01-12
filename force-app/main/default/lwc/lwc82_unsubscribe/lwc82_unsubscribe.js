import { LightningElement, track } from 'lwc';

/* APEX METHODS */
import unsubContact from '@salesforce/apex/lwc82_unsubscribe_ctrl.unsubscribeContact';

import lbl_Unsub from '@salesforce/label/c.LU_Unsubscribe';
import lbl_UnsubTitle from '@salesforce/label/c.LU_Unsubscribe_Title';
import lbl_UnsubTextIntro from '@salesforce/label/c.LU_Unsubscribe_TextIntro';

export default class Lwc82_unsubscribe extends LightningElement {

    @track conEmail = '';
    @track conId = '';
    @track msg = '';

    labels = {
        lbl_Unsub,
        lbl_UnsubTitle,
        lbl_UnsubTextIntro
    }

    connectedCallback() {
        this.conEmail = ((new URL(window.location.href)).searchParams.get("email"));
        this.conId = ((new URL(window.location.href)).searchParams.get("id"));
    }

    handleUnsub(){
        unsubContact({pEmail : this.conEmail,
                        pId : this.conId})
        .then(results => {
            this.msg = results;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }
}