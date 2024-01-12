/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';

/* Import APEX Methods */
import getContactInformations from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getContactInformations';
import getUserCountry from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getUserCountry';
import getUserInfo  from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getUserInfo';

/* IMPORT OBJECT */
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* IMPORT CUSTOM LABELS */
import lbl_label_mystanid from '@salesforce/label/c.LU_MyProfile_MyStanId';
import lbl_label_mystanemail from '@salesforce/label/c.LU_MyProfile_MyStanEmail';
import lbl_label_numberorders from '@salesforce/label/c.LU_MyProfile_Number_Of_Orders';
import lbl_label_paymentmethod from '@salesforce/label/c.LU_MyProfile_Payment_Method';
import lbl_label_minifreetransport from '@salesforce/label/c.LU_MyProfile_Minimum_Free_Transport';
import lbl_label_lastorderdate from '@salesforce/label/c.LU_MyProfile_Last_Order_Date';
import lbl_label_commisionrate from '@salesforce/label/c.LU_MyProfile_Commission_Rate';
import lbl_label_commisiontotal from '@salesforce/label/c.LU_MyProfile_Commision_Total';
import lbl_label_totalsales from '@salesforce/label/c.LU_MyProfile_Total_sales';
import lbl_label_dayscountcredit from '@salesforce/label/c.LU_MyProfile_Dayx_Count_Credit';
import lbl_label_currentCommercialPeriod from '@salesforce/label/c.LU_MyProfile_CurrentCommercialPeriod';
import lbl_label_currentYearWeekPeriod from '@salesforce/label/c.LU_MyProfile_CurrentYearWeekPeriod';
import lbl_label_PersonalMsg from '@salesforce/label/c.LU_MyProfile_PersonalMessage';
import lbl_label_MinOrder from '@salesforce/label/c.LU_MyProfile_MinimumOrder';
import lbl_label_TransportFeesApplicable from '@salesforce/label/c.LU_MyProfile_TransportFeesApplicable';

export default class lwc32_myprofile_oredersInformations extends LightningElement {

    /* VARIABLES */
    @track associatedContact;
    @track isFRA = false;
    @track isITA = false;
    @track contactObj;
    @track isNewOrderTunnel = false;

    /* LABELS */
    labels = {
        lbl_label_mystanid,
        lbl_label_mystanemail,
        lbl_label_numberorders,
        lbl_label_paymentmethod,
        lbl_label_minifreetransport,
        lbl_label_lastorderdate,
        lbl_label_commisionrate,
        lbl_label_commisiontotal,
        lbl_label_totalsales,
        lbl_label_dayscountcredit,
        lbl_label_currentCommercialPeriod,
        lbl_label_currentYearWeekPeriod,
        lbl_label_PersonalMsg,
        lbl_label_MinOrder,
        lbl_label_TransportFeesApplicable
    };

    /* INIT */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.contactObj = data;
            console.log('this.contactObj');
            console.log(this.contactObj);
        }
    }
    connectedCallback() {
        getContactInformations( {} )
            .then(results => {
                this.associatedContact = results;

                // Set checboxes
                // const checkbox = this.template.querySelector('lightning-input[data-value="TransportFeesApplicable"]');

                // checkbox.checked = this.associatedContact.TransportFeesApplicable__c;
            })
            .catch(error => {
                console.log('>>>> error getContactInformations :');
                console.log(error);
            });
        
        getUserCountry( {} )
            .then(results => {

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

        getUserInfo( {} )
            .then(results => {
                this.isNewOrderTunnel = results.LU_Use_New_Order_v2__c;
            })
            .catch(error => {
                console.log('>>>> error getUserInfo :');
                console.log(error);
        });
    }

    /* UI METHODS */
    get pctCommision() {
        return (this.associatedContact.DirectCommissionRate__c / 100);
    }
}