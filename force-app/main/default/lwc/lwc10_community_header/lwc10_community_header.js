/* eslint-disable no-console */
import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getUserInfo from '@salesforce/apex/lwc10_community_header_Ctrl.getUserInfo';
import Id from '@salesforce/user/Id';

// import BRAND_LOGO from '@salesforce/contentAssetUrl/mystan';
import BRAND_LOGO from '@salesforce/label/c.LU_Header_Logo';
import lbl_Welcome from '@salesforce/label/c.LU_Header_Welcome';
import lbl_Profile from '@salesforce/label/c.LU_Header_MyProfile';

/* IMPORT RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* */
import { createRecord } from 'lightning/uiRecordApi';
import ERROR_LOG_OBJECT from '@salesforce/schema/Error_log__c';
import WHERE_FIELD from '@salesforce/schema/Error_log__c.Where__c';
import FEATURE_FIELD from '@salesforce/schema/Error_log__c.Feature__c';
import REQUEST_FIELD from '@salesforce/schema/Error_log__c.Request__c';
import MESSAGE_FIELD from '@salesforce/schema/Error_log__c.Message__c';

export default class Lwc10_community_header extends NavigationMixin(LightningElement) {
    /* LABELS */
    labels = {
        lbl_Welcome,
        lbl_Profile
    }
    /* RESOURCES */
    logoDesktop = LogoBtn + '/icons/mystan.png';
    logoMobile = LogoBtn + '/icons/mystan-mobile.png';

    /* VARIABLES */
    @track userId;
    @track firstName;
    @track imgUrl;
    @track brandLogo = BRAND_LOGO;
    @track error;

    @track profileUrl;

    connectedCallback() {
        document.addEventListener("securitypolicyviolation", (e) => {
            console.log('### securitypolicyviolation ' + e.blockedURI);    
            console.log('### ' + e.violatedDirective);    
            console.log('### ' + e.originalPolicy);
            const fields = {};
            fields[WHERE_FIELD.fieldApiName] = 'Other';
            fields[FEATURE_FIELD.fieldApiName] = 'Other';
            fields[REQUEST_FIELD.fieldApiName] = e.blockedURI;
            fields[MESSAGE_FIELD.fieldApiName] = 'Blocked URL because of CSP rules';
            const recordInput = { apiName: ERROR_LOG_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then((error_log) => {
                    console.log('### Error log created');   
                })
                .catch((error) => {
                    console.log('### Error creating record : ' + JSON.stringify(error));  
                });
        })
    }

    @wire(CurrentPageReference) pageRef;
    @wire(getUserInfo, { userId: Id })
    wiredGetUserDetails({ error, data }) {

        if (data) {
            this.userId = data.Id;
            this.firstName = data.FirstName;
            this.imgUrl = data.SmallPhotoUrl;
        } else if (error) {
            this.error = error;
        }
    }

    /* UI METHODS */
    navigateToHome(event) {

        fireEvent(this.pageRef, 'toHomePage', null);

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home',
            },
        });
    }

    /* UI METHODS */
    navigateToProfile(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.userId,
                objectApiName: 'profil',
                actionName: 'view'
            },
        });
    }

    get getUrlProfilePage() {
        return ('/profile/' + Id);
    }

}