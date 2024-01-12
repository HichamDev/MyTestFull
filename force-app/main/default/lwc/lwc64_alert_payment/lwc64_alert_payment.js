import { LightningElement, track, wire } from 'lwc';

/* IMPORT OBJECT */
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* Import APEX Methods */
import getContact from '@salesforce/apex/lwc64_alert_payment_ctrl.getContact';
import getUserCountry from '@salesforce/apex/lwc64_alert_payment_ctrl.getUserCountry';

export default class Lwc64_alert_payment extends LightningElement {
    rebate_job_title = 'Stanlover';

    @track contact = {};
    @track displayComponent = false;
    @track contactObject = {};

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.contactObject.CurrentBalance__c = data.fields.CurrentBalance__c.label;
            this.contactObject.LocalAttribute1__c = data.fields.LocalAttribute1__c.label;
            this.contactObject.LocalAttribute2__c = data.fields.LocalAttribute2__c.label;
            this.contactObject.LocalAttribute4__c = data.fields.LocalAttribute4__c.label;
        }
        else if (error){
            console.log('>>>> error :');
            console.log(error);
        }
    }

    connectedCallback(){

        getUserCountry()
            .then(results => {
                if(results === "ITA"){
                    this.displayComponent = true;
                }

                getContact()
                .then(results => {
                    this.contact = results;

                    if (this.contact.Title == 'Smile' || this.contact.Title == this.rebate_job_title || this.contact.Title == 'Sales Consultant' || this.contact.Title == 'Group Sales Consultant') {
                        this.displayComponent = true;
                    } else {
                        this.displayComponent = false;
                    }

                    if(this.contact.LocalAttribute4__c === "Blocked" || this.contact.LocalAttribute4__c === "BLOCKED"){
                        this.contact.LocalAttribute4__c = "Bloccato";
                    }
                    else if(this.contact.LocalAttribute4__c === "Expired" || this.contact.LocalAttribute4__c === "EXPIRED"){
                        this.contact.LocalAttribute4__c = "Scaduto";
                    }
                    else if(this.contact.LocalAttribute4__c === "Legal" || this.contact.LocalAttribute4__c === "LEGAL"){
                        this.contact.LocalAttribute4__c = "In pratica legale";
                    }
                })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

            })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        

        
    }
}