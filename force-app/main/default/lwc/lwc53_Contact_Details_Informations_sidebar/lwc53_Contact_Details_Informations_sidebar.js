/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';
import DefaultPP from '@salesforce/resourceUrl/LU_DefautProfilePicture';

/* IMPORT METHODS */
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* APEX */
import getContactInfos from '@salesforce/apex/lwc18_Contact_Details_Ctrl.getContactInfos';
import getContactIndicator from '@salesforce/apex/lwc18_Contact_Details_Ctrl.getContactIndicator';

/* LABEL */
import lbl_Title_detail_team from '@salesforce/label/c.LU_Contact_Detail_Team';
import lbl_Title_personnal_infos from '@salesforce/label/c.LU_Contact_Detail_Infos_Personnelles';
import lbl_Title_commercial_infos from '@salesforce/label/c.LU_Contact_Detail_Infos_Commerciales';
import lbl_Title_payment_account from '@salesforce/label/c.LU_Contact_Detail_Payment_Account';
import lbl_Title_Technique from '@salesforce/label/c.LU_Contact_Detail_Technique';
import lbl_Contact_PostalAddress from '@salesforce/label/c.LU_Contact_PostalAddress';
import lbl_Section_Information from '@salesforce/label/c.LU_Contact_Details_Informations';
import lbl_Section_Contact from '@salesforce/label/c.LU_Contact_Details_Contact';



export default class Lwc53_Contact_Details_Informations_sidebar extends LightningElement {

    user_pictures = LogoBtn + '/icons/pictures-user.png';

    /* VARIABLES */
    @track contact = [];
    @track objectInfo;
    @track parameters = [];
    @track l_indicators = [];

    @track cahtpersocycle = 0;

    /* LABELS */
    labels = {
        lbl_Title_detail_team,
        lbl_Title_personnal_infos,
        lbl_Title_commercial_infos,
        lbl_Title_payment_account,
        lbl_Title_Technique,
        lbl_Contact_PostalAddress,
        lbl_Section_Information,
        lbl_Section_Contact
    }

    default_profile_pictures = DefaultPP;

    /* INIT */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredGetObject ({ error, data }) {
        if(error){
            console.log(error);
        }
        else if(data){
            this.objectInfo = data;
            console.log('>>> objectinfo');
            console.log(this.objectInfo);
        }
    }
    connectedCallback(){

        this.parameters = this.getQueryParameters();

        getContactInfos( { contactId : this.parameters.id } )
            .then(results => {
                this.contact = results;

                if(!this.contact.LU_TECH_ProfilePicture__c){
                    this.contact.LU_TECH_ProfilePicture__c = this.default_profile_pictures;
                }

                this.contact.mobileClickToCall = 'tel:' + this.contact.MobilePhone;
                this.contact.homeClickToCall = 'tel:' + this.contact.HomePhone;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getContactIndicator( { contactId : this.parameters.id } )
            .then(results => {
                this.l_indicators = results;

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        // subscribe to events
        registerListener('contactDetailToRefresh', this.handleEvtRefreshContactDetail, this);

    }
    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }

    /* UTILITY METHODS */
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    
    /* UI METHODS */
    @api
    get accountName() {
        return this.contact.Account.Name;
    }

    @api
    get reportsToName() {
        return this.contact.ReportsTo.Name;
    }

    /* EVENT HANDLING */
    handleEvtRefreshContactDetail(event) {

        getContactInfos( { contactId : this.parameters.id } )
            .then(results => {
                this.contact = results;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getContactIndicator( { contactId : this.parameters.id } )
            .then(results => {
                this.l_indicators = results;

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

    }
}