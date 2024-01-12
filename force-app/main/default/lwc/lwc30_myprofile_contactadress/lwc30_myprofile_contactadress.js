/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Import APEX Methods */
import getContactInformations from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getContactInformations';
import updateContactInformations from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.updateContact';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* IMPORT CUSTOM LABELS */
import lbl_label_birthdate from '@salesforce/label/c.LU_MyProfile_Birthdate';
import lbl_label_street from '@salesforce/label/c.LU_MyProfile_Street';
import lbl_label_postalcode from '@salesforce/label/c.LU_MyProfile_PostalCode';
import lbl_label_city from '@salesforce/label/c.LU_MyProfile_City';
import lbl_label_country from '@salesforce/label/c.LU_MyProfile_Country';
import lbl_label_phone from '@salesforce/label/c.LU_MyProfile_Phone';
import lbl_label_mobilephone from '@salesforce/label/c.LU_MyProfile_MobilePhone';
import lbl_label_updatebutton from '@salesforce/label/c.LU_MyProfile_Update_Button';
import lbl_label_email from '@salesforce/label/c.LU_MyProfile_Email';
import lbl_Success from '@salesforce/label/c.LU_Profile_Edit_Success_Title';
import lbl_Success_Msg from '@salesforce/label/c.LU_Profile_Edit_Success_Msg';
import lbl_label_title from '@salesforce/label/c.LU_MyProfile_Title';
import lbl_label_AccountOwner from '@salesforce/label/c.LU_MyProfile_AccountOwner';
import lbl_label_Facebook_Link from '@salesforce/label/c.LU_MyProfile_Facebook_Link';
import lbl_label_Marketing_Consent from '@salesforce/label/c.LU_MyProfile_Marketing_Consent';

export default class lwc30_myprofile_contactadress extends LightningElement {
    rebate_job_title = 'Stanlover';

    @track associatedContact;
    @track isAdressEditable = true;
    @track isPhoneEditable = true;
    @track isMobilePhoneEditable = true;

    @track displayActivitySegment = false;

    @track birthdate;

    @track valueMarketingConsent;
    @track optionsMarketingConsent = [];

    @track optinNewsLetter = "";

    /* LABELS */
    labels = {
        lbl_label_birthdate,
        lbl_label_street,
        lbl_label_postalcode,
        lbl_label_city,
        lbl_label_country,
        lbl_label_phone,
        lbl_label_mobilephone,
        lbl_label_updatebutton,
        lbl_label_email,
        lbl_label_title,
        lbl_label_AccountOwner,
        lbl_label_Facebook_Link,
        lbl_label_Marketing_Consent
    };

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredGetObject ({ error, data }) {
        if(error){
            console.log(error);
        }
        else if(data){
            this.objectInfo = data;

            this.labels.field_street = this.objectInfo.fields.MailingStreet.label;
            this.labels.field_postal_code = this.objectInfo.fields.MailingPostalCode.label;
            this.labels.field_city = this.objectInfo.fields.MailingCity.label;
            this.labels.field_country = this.objectInfo.fields.MailingCountry.label;
            this.labels.field_phone = this.objectInfo.fields.Phone.label;
            this.labels.field_mobile = this.objectInfo.fields.MobilePhone.label;
            this.labels.field_birthdate = this.objectInfo.fields.Birthdate.label;
            this.labels.field_facebook = this.objectInfo.fields.LU_Facebook_URL__c.label;
        }
    }

    connectedCallback() {

        this.optionsMarketingConsent.push({ label: 'Si', value: 'true' });
        this.optionsMarketingConsent.push({ label: 'No', value: 'false' });

        getContactInformations( {} )

            .then(results => {
                this.associatedContact = JSON.parse(JSON.stringify(results));

                this.optinNewsLetter = (this.associatedContact.OptinNewsletter1__c ? 'true' : 'false');
                
                let d = this.associatedContact.Birthdate.split("-");

                this.birthdate = d[2] + "/" + d[1] + "/" + d[0];

                if (this.associatedContact.Phone === undefined){
                    this.associatedContact.Phone = "";
                }
                if (this.associatedContact.MobilePhone === undefined){
                    this.associatedContact.MobilePhone = "";
                }
                if (this.associatedContact.LU_Facebook_URL__c === undefined){
                    this.associatedContact.LU_Facebook_URL__c = "";
                }

                if(this.associatedContact.AccountCountryCode__c === 'ITA' && 
                   this.associatedContact.ActivitySegment__c !== 'Sales Consultant' && 
                   this.associatedContact.ActivitySegment__c !== 'Smile' &&
                   this.associatedContact.ActivitySegment__c !== this.rebate_job_title){
                    this.displayActivitySegment = true;
                }

                // If french user
                if (this.associatedContact.TECH_ExternalId__c.substr(0,3) === 'FRA') {

                    this.isAdressEditable = false;
                    this.isPhoneEditable = false;
                
                } else { // If Italian user

                    // For dealer, Smile, Dealer Manager, DF
                    this.isAdressEditable = false;
                    this.isPhoneEditable = true;

                    // For others

                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }


    /* EVENT HANDLER */
    updateContact(){
        console.log('> updateContact');
        console.log(this.associatedContact);
        updateContactInformations( {con : this.associatedContact } )
            .then(() => {
                const evtError = new ShowToastEvent({
                    title: lbl_Success,
                    message: lbl_Success_Msg,
                    variant: 'success'
                });
                this.dispatchEvent(evtError);
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    updateValuePhone(event){
        this.associatedContact.Phone = event.target.value;
    }

    updateValueMobile(event){
        this.associatedContact.MobilePhone = event.target.value;
    }

    updateValueEmail(event){
        this.associatedContact.Email = event.target.value;
    }

    updateValueMailingStreet(event){
        this.associatedContact.MailingStreet = event.target.value;
    }

    updateValueMailingPostalCode(event){
        this.associatedContact.MailingPostalCode = event.target.value;
    }

    updateValueMailingCity(event){
        this.associatedContact.MailingCity = event.target.value;
    }

    updateValueMailingCountry(event){
        this.associatedContact.MailingCountry = event.target.value;
    }

    updateValueFB(event) {
        this.associatedContact.LU_Facebook_URL__c = event.target.value;
    }

    updateValueMarketingConsent(event) {
        this.optinNewsLetter = event.target.value;

        this.associatedContact.OptinNewsletter1__c = ((this.optinNewsLetter === 'true') ? true : false);
        this.associatedContact.HasOptedOutOfEmail = ((this.optinNewsLetter === 'false') ? true : false);
        this.associatedContact.HasOptedOutOfFax = ((this.optinNewsLetter === 'false') ? true : false);
    }

    /* UI METHODS */
    // Check of the connected contact is an italian one
    get isITA() {
        
        if (this.associatedContact.TECH_ExternalId__c.substr(0,3) === 'ITA') {
            return (true);
        }
        return (false);
    }
}