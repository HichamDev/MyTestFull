import { LightningElement, api, track, wire } from 'lwc';

// Import APEX Methods 
import getContactInfo from '@salesforce/apex/Lwc95_optin_order_printed_ctrl.getContactInfo';
import updateContactOptin from '@salesforce/apex/Lwc95_optin_order_printed_ctrl.updateContactOptin';
import getUserCountry from '@salesforce/apex/Lwc95_optin_order_printed_ctrl.getUserCountry';

/* IMPORT OBJECT */
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class Lwc95_optin_order_printed extends LightningElement {
    /* VARIABLES */
    @track isFRA;
    @track isITA;
    @track contactId;
    @track isChecked;
    
    @wire(getContactInfo)
    wiredContact({ error, data }) {
        if (data) {
            this.isChecked = data.OptinNewsletter3__c;
        } else if (error) {
            console.error('Error fetching contact information', error);
        }
    }
    connectedCallback() {
        getUserCountry( {} )
            .then(results => {
                console.log('results==> '+results);
                if(results === "FRA"){
                    this.isFRA = true;
                } else if (results === "ITA") {
                    this.isITA = true;
                }
            })
            .catch(error => {
                console.log('>>>> error getUserCountry :');
                console.log(error);
        });
    }
    handleChange(event) {
        this.isChecked = event.target.checked;
        console.log(this.isChecked);
        updateContactOptin({isChecked: this.isChecked })
            .then(result => {
                // Handle success if needed
            })
            .catch(error => {
                console.error('Error updating contact opt-in', error);
            });
    }
}