import { LightningElement, track } from 'lwc';

/* APEX METHODS */
import updateContact from '@salesforce/apex/lwc72_gdpr_consent_ctrl.updateContact';

import lbl_gdprConsentText from '@salesforce/label/c.LU_GDPR_Consent_Text';
import lbl_gdprConsentTitle from '@salesforce/label/c.LU_GDPR_Consent_Title';
import lbl_gdprPrivacyPolicy from '@salesforce/label/c.LU_GDPR_PrivacyPolicy';
import lbl_gdprPrivacyPolicyLink from '@salesforce/label/c.LU_GDPR_PrivacyPolicyLink';
import lbl_btnYes from '@salesforce/label/c.LU_Contact_Delete_Confirmation_Yes';
import lbl_btnNo from '@salesforce/label/c.LU_Contact_Delete_Confirmation_No';
import lbl_success from '@salesforce/label/c.LU_GDPR_Consent_Apply';

export default class Lwc72_gdpr_consent extends LightningElement {

    @track idContact;
    @track isITA = false;
    @track isFRA = false;
    @track displayButtons = false;
    @track displaySuccessLabel = false;

    /* LABELS */
    labels = {
        lbl_gdprConsentText,
        lbl_gdprConsentTitle,
        lbl_gdprPrivacyPolicy,
        lbl_gdprPrivacyPolicyLink,
        lbl_btnYes,
        lbl_btnNo,
        lbl_success
    }

    connectedCallback(){

        let parameters = this.getQueryParameters();

        if(parameters.id){
            this.idContact = parameters.id;
            this.displayButtons = true;
        }

        var language = parameters.language;
        if(language) {
            if(language == 'fr') {
                this.isFRA = true;
            }

            if(language == 'it') {
                this.isITA = true;
            }
        }
    }

    handleYes(){

        updateContact({idContact : this.idContact, optOut : false})
        .then(results => {
            this.displayButtons = false;
            this.displaySuccessLabel = true;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    handleNo(){

        updateContact({idContact : this.idContact, optOut : true})
        .then(results => {
            this.displayButtons = false;
            this.displaySuccessLabel = true;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

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
}