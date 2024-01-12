/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';

/* IMPORT OBJECT */
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* Import APEX Methods */
import getContactInformations from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getContactInformations';
import getUserCountry from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getUserCountry';

/* IMPORT CUSTOM LABELS */
import lbl_label_startingdate from '@salesforce/label/c.LU_MyProfile_StartingDate';
import lbl_label_commissionrate from '@salesforce/label/c.LU_MyProfile_CommissionRate';
import lbl_label_currentbalancetotal from '@salesforce/label/c.LU_MyProfile_CurentBalanceTotal';

export default class Lwc29_myprofile_contactstatus extends LightningElement {

    @track associatedContact;

    @track displayTitle = false;

    @track isITA = false;

    /* LABELS */
    @track labels = {
        lbl_label_startingdate,
        lbl_label_commissionrate,
        lbl_label_currentbalancetotal
    };

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.labels.field_currentbalance = data.fields.CurrentBalance__c.label;
            this.labels.field_startdate = data.fields.Start_date__c.label;
            this.labels.field_commissionrate = data.fields.DirectCommissionRate__c.label;
            this.labels.field_currentbalanceTotal = data.fields.LU_Current_Balance_Total__c.label;
            console.log('>>> contactobj');
            console.log(this.contactObj);
        }
    }
    connectedCallback() {
        getUserCountry( {} )
            .then(results => {
                if(results === 'ITA'){
                    this.isITA = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getContactInformations( {} )
            .then(results => {
                this.associatedContact = results;
                if(this.associatedContact.Title !== this.associatedContact.ActivitySegment__c){
                    this.displayTitle = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

}