/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* IMPORT OBJECT */
import USER_OBJECT from '@salesforce/schema/User';

/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* Import APEX Methods */
import getContactInfo from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getContactInfo';

/* IMPORT CUSTOM LABELS */
import lbl_label_mystanid from '@salesforce/label/c.LU_MyProfile_MyStanId';
import lbl_label_mystanemail from '@salesforce/label/c.LU_MyProfile_MyStanEmail';
import lbl_label_eshopurl from '@salesforce/label/c.LU_MyProfile_EshopUrl';
import lbl_label_eshopurlcopymessage from '@salesforce/label/c.LU_MyProfile_EshopUrlCopyMessage';

export default class Lwc28_myprofile_contactinfo extends LightningElement {

    @track currentuser;

    @track displayEshopUrl = false;

    /* LABELS */
    @track labels = {
        lbl_label_mystanid,
        lbl_label_mystanemail,
        lbl_label_eshopurl,
        lbl_label_eshopurlcopymessage
    };

    @wire(getObjectInfo, { objectApiName: USER_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.labels.field_sthid = data.fields.STHID__c.label;
            this.labels.field_email = data.fields.Email.label;
            console.log('>>> contactobj');
            console.log(this.contactObj);
        }
    }
    connectedCallback() {
        getContactInfo( {} )
            .then(results => {
                this.currentuser = JSON.parse(results);

                if(this.currentuser.Contact.FirstName){
                    this.currentuser.FirstName = this.currentuser.Contact.FirstName;
                }
                if(this.currentuser.Contact.LastName){
                    this.currentuser.LastName = this.currentuser.Contact.LastName;
                }
                if(this.currentuser.Contact.Email){
                    this.currentuser.Email = this.currentuser.Contact.Email;
                }
                if(this.currentuser.Contact.STHID__c){
                    this.currentuser.STHID__c = this.currentuser.Contact.STHID__c;
                }

                if(this.currentuser.Contact.Ecommerce_Role__c === "e-dealer"){
                    this.displayEshopUrl = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    copyToClipboard(){
        let msg = this.currentuser.Contact.LU_Personal_URL__c;

        const evtSuccess = new ShowToastEvent({
            title: this.labels.lbl_label_eshopurlcopymessage,
            variant: 'success'
        });
        this.dispatchEvent(evtSuccess);

        if (navigator.clipboard && window.isSecureContext) {
            return navigator.clipboard.writeText(msg);
        } else {
            let textArea = document.createElement("textarea");
            textArea.value = msg;
            textArea.style.position = "fixed";
            textArea.style.left = "-999999px";
            textArea.style.top = "-999999px";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            return new Promise((res, rej) => {
                document.execCommand("copy") ? res() : rej();
                textArea.remove();
            });
        }
    }
}