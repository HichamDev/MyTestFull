import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* IMPORT METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT APEX */
import createContact from '@salesforce/apex/lwc12_EndCustomer_Form_ctrl.createContact';

/* IMPORT FIELDS */
import FIRSTNAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LASTNAME_FIELD from '@salesforce/schema/Contact.LastName';
import EMAIL_FIELD from '@salesforce/schema/Contact.Email';
import BIRTHDATE_FIELD from '@salesforce/schema/Contact.Birthdate';
import PHONE_FIELD from '@salesforce/schema/Contact.MobilePhone';
import STREET_FIELD from '@salesforce/schema/Contact.MailingStreet';
import POSTALCODE_FIELD from '@salesforce/schema/Contact.MailingPostalCode';
import CITY_FIELD from '@salesforce/schema/Contact.MailingCity';
import NOTES_FIELD from '@salesforce/schema/Contact.Lu_Notes__c';
import GDPR_FIELD from '@salesforce/schema/Contact.LU_GDPR_Customer_Informed__c';
import OPTOUT_FIELD from '@salesforce/schema/Contact.HasOptedOutOfEmail';

/* IMPORT LABELS */
import lbl_Created from '@salesforce/label/c.LU_Customer_Create_Success';
import lbl_Edited from '@salesforce/label/c.LU_Customer_Update_Success';
import lbl_Customer_Title from '@salesforce/label/c.LU_Customer_Title';
import lbl_TECH_RT_Contact_Customer from '@salesforce/label/c.LU_TECH_Contact_RT_Customer';
import lbl_create from '@salesforce/label/c.LU_Customer_Create_Button_Submit';
import lbl_cancel from '@salesforce/label/c.LU_Customer_Create_Button_Cancel';
import lbl_gdpr_consent_asked_label from '@salesforce/label/c.LU_Customer_Create_GDPR_Consent_Asked';

export default class Lwc12_EndCustomer_Form extends LightningElement {

    /* LABELS */
    labels = {
        lbl_Created,
        lbl_Edited,
        lbl_Customer_Title,
        lbl_TECH_RT_Contact_Customer,
        lbl_create,
        lbl_cancel,
        lbl_gdpr_consent_asked_label
    }


    /* VARIABLES */
    fields = [FIRSTNAME_FIELD, LASTNAME_FIELD, EMAIL_FIELD, BIRTHDATE_FIELD, PHONE_FIELD,
        STREET_FIELD, POSTALCODE_FIELD, CITY_FIELD];
    
    @api mode;
    @api customerid; // Only used in view mode
    recordTypeId = ''; // Only used in edit mode

    @track con = [];
    @track displayGDPR = false;
    @track gdpr_consent_asked_value = false;
    @track isloading = false;


    /* INIT */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredAccount({ error, data }) {
        if (data) {

            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === this.labels.lbl_TECH_RT_Contact_Customer);

        } else if (error) {
            this.error = error;
        }
    }

    connectedCallback(){
        this.con.FirstName = "aaa";
    }

    /* UI METHODS */
    get isEditMode() {
        if (this.mode == 'edit') {
            return (true);
        }
        return (false);
    }

    get isViewMode() {
        if (this.mode == 'edit') {
            return (false);
        }
        return (true);
    }
    

    /* EVENTS HANDLING */
    
    handleSuccess(event) {

        var msg = this.labels.lbl_Created;
        if (this.mode == 'edit') {
            msg = this.labels.lbl_Edited;
        }

        // Display a success message
        const evt = new ShowToastEvent({
            title: this.labels.lbl_Customer_Title + " " + msg,
            variant: "success"
        });
        this.dispatchEvent(evt);

        // Send an event to close the popup
        const evtCloseForm = new CustomEvent('closeendcustomerform', {detail : event.detail.id} );
        this.dispatchEvent(evtCloseForm);
    }
    
    handleCancel(event) {
        this.displayGDPR = false;

        // Send an event to close the popup
        const evtCloseForm = new CustomEvent('closeendcustomerform', { detail: '' } );
        this.dispatchEvent(evtCloseForm);
    }

    handleSubmit(event) {

        this.isloading = true;

        event.preventDefault();       // stop the form from submitting

        const contactData = event.detail.fields;

        contactData.Contact_Type__c = 'Customer';

        if ( ( contactData.Email === "" || contactData.Email === null ) && 
               ( this.gdpr_consent_asked_value !== true ) ) {
            this.displayGDPR = true;
            this.isloading = false;
        } else {
            this.template.querySelector('lightning-record-edit-form').submit(contactData);
        }

        
    }

    handleGdprConsentAskedChanged(event) {
        this.gdpr_consent_asked_value = event.target.checked;
    }

}