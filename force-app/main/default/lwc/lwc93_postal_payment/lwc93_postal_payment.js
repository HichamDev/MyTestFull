import { LightningElement, track, api } from 'lwc';

/* APEX METHODS */
import sendPostalPaymentEmail from '@salesforce/apex/lwc93_postal_payment_ctrl.sendPostalPaymentEmail';

/* CUSTOM LABELS */
import lbl_Close from '@salesforce/label/c.LU_ContactSelection_Modal_Close';

export default class Lwc93_postal_payment extends LightningElement {

    labels = {
        lbl_Close
    };

    @track amount = 0;
    @track displayPopUp = false;

    @api buttonLabel = "Paga con bollettino 896";

    handleClickButton(){
        this.displayPopUp = true;
    }

    handleSendEmail(){
        this.buttonDisabled = true;

        sendPostalPaymentEmail({amount : this.amount})
            .then(results => {

                if(results !== "OK"){
                    const evtError = new ShowToastEvent({
                        title: this.label.lbl_Error_Title,
                        message: 'Unable to send email',
                        variant: 'error'
                    });
                    this.dispatchEvent(evtError);

                    this.displayPopUp = false;
                }
                else{
                    // Display a success message
                    const evt = new ShowToastEvent({
                        title: "Email sent",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);

                    this.displayPopUp = false;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    handle

}