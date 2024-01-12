/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';

/* LABEL */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Send from '@salesforce/label/c.LU_Action_Email_Send';
import lbl_Title from '@salesforce/label/c.LU_Action_WhatsApp_Title';
import lbl_PolicyLink from '@salesforce/label/c.LU_WhatsPolicyLink';
import lbl_PolicyLabel from '@salesforce/label/c.LU_WhatsPolicyLabel';

export default class Lwc42_communication_whatsapp extends LightningElement {

    @track messageContent = "";
    @api managerMobile;

    label = { 
        lbl_Close,
        lbl_Send,
        lbl_Title,
        lbl_PolicyLink,
        lbl_PolicyLabel
    };

    updateMessageContent(event){
        console.log(event.target.value);
        this.messageContent = event.target.value;
    }

    // Modal - Close
    close() {
        const evtCloseEmail = new CustomEvent('closewhatsapp', {
            detail: false
        });
        this.dispatchEvent(evtCloseEmail);
    } 

    send() {
        let ua = navigator.userAgent.toLowerCase();

        let isMobile = null;
        if (ua) {
            isMobile = ua.indexOf("mobile") > -1;
        }

        if(this.managerMobile){
            this.managerMobile = this.managerMobile.replace("0", "33");
        }

        try {

            let urlContent = "text=" + this.messageContent ;
            if (this.managerMobile) {
                urlContent = urlContent + "&phone=" + this.managerMobile;
            }

            if (isMobile) {
                // window.location.href = "whatsapp://send?text=" + this.messageContent + "&phone=" + this.managerMobile;
                //window.location.href = "whatsapp://send?" + urlContent;
                let numMobile = '';
                if (this.managerMobile) {
                    numMobile = this.managerMobile ;
                }
                window.location.href = "https://wa.me/" + numMobile + '?text=' + this.messageContent;
            } else {
                // window.open("https://web.whatsapp.com/send?text=" + this.messageContent + "&phone=" + this.managerMobile, "Share with Whatsapp Web", 'width=800,height=600');
                window.open("https://web.whatsapp.com/send?" + urlContent, "", 'width=800,height=600');
            }
        } catch (error) {
            console.error(error);
        }

        const evtCloseEmail = new CustomEvent('closewhatsapp', {
            detail: false
        });
        this.dispatchEvent(evtCloseEmail);
    }
}