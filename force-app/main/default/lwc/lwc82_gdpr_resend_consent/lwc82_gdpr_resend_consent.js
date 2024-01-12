import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* APEX */
import apex_resendConsent from '@salesforce/apex/lwc82_gdpr_resend_consent_ctrl.resendConsentEmail';

/* CUSTOM LABELS */
import lbl_Button from '@salesforce/label/c.LU_GDPR_Resend_Button';
import lbl_Msg_Success from '@salesforce/label/c.LU_GDPR_Resend_Success';
import lbl_Msg_Error from '@salesforce/label/c.LU_GDPR_Resend_Error';


export default class Lwc82_gdpr_resend_consent extends LightningElement {

    /* LABELS */
    labels = {
        lbl_Button
    }

    /* VARIABLES */
    @api contactid = '';
    @api styleaction = 'button'; // button or link
    @api styleclass = '';

    @track isLink = false;
    @track isButton = false;

    /* INIT */
    connectedCallback() {
        if (this.styleaction == 'button') {
            this.isButton = true;
        } else if (this.styleaction == 'link') {
            this.isLink = true;
        }
    }

    /* UI METHODS */
    handleClick(event) {
        apex_resendConsent( { contactId : this.contactid } )
        .then(res => {
            if (res == 'ok') {
                const evtRefreshList = new CustomEvent('hideresend', { detail: this.contactid });
                this.dispatchEvent(evtRefreshList);

                const evt = new ShowToastEvent({
                    message: lbl_Msg_Success,
                    variant: 'success'
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    message: lbl_Msg_Error,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    /* BUSINESS METHODS */

}