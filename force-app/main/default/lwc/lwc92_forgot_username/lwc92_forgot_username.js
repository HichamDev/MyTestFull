import { LightningElement, track, api } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* APEX METHODS */
import sendUsernameEmail from '@salesforce/apex/lwc92_forgot_username_ctrl.sendUsernameEmail';

export default class Lwc92_forgot_username extends LightningElement {

    @track mail = '';
    @track buttonDisabled = true;

    @api buttonLabel = "Send email";

    connectedCallback(){
        console.log("abc");
    }

    handleSendEmail(){
        this.buttonDisabled = true;

        sendUsernameEmail({email : this.mail})
            .then(results => {

                console.log(this.mail);
                console.log(results);

                // Display a success message
                const evt = new ShowToastEvent({
                    title: "Email sent",
                    variant: "success"
                });
                this.dispatchEvent(evt);
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    handleChangeMail(event){
        this.mail = event.target.value;
    }

    handleCaptchaReceived(event){
        console.log('received message from child');
        console.log('childMessage', JSON.stringify(event.detail));
        if(event.detail.data === true){
            this.buttonDisabled = false;
        }
    }
}