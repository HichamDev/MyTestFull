/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* IMPORT METHODS */
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

/* APEX */
import getContactInfos from '@salesforce/apex/lwc18_Contact_Details_Ctrl.getContactInfos';

/* LABEL */
import lbl_Title_detail_team from '@salesforce/label/c.LU_Contact_Detail_Team';
import lbl_Title_personnal_infos from '@salesforce/label/c.LU_Contact_Detail_Infos_Personnelles';
import lbl_Title_commercial_infos from '@salesforce/label/c.LU_Contact_Detail_Infos_Commerciales';
import lbl_Title_payment_account from '@salesforce/label/c.LU_Contact_Detail_Payment_Account';
import lbl_Title_Technique from '@salesforce/label/c.LU_Contact_Detail_Technique';
import lbl_Contact from '@salesforce/label/c.LU_Contact_ContactTitle';
import lbl_Email from '@salesforce/label/c.LU_Contact_Email';
import lbl_Whatsapp from '@salesforce/label/c.LU_Contact_Whatsapp';
import lbl_Contact_LastOrder from '@salesforce/label/c.LU_Contact_LastOrder';
import lbl_Contact_PostalAddress from '@salesforce/label/c.LU_Contact_PostalAddress';
import lbl_Contact_RecruitmentCampaign from '@salesforce/label/c.LU_Contact_RecruitmentCampaign';
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_TECH_RT_Contact_Customer from '@salesforce/label/c.LU_TECH_Contact_RT_Customer';
import lbl_Customer_Edit from '@salesforce/label/c.LU_Customer_Edit';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Note from '@salesforce/label/c.LU_Contact_Detail_Note_Title';
import lbl_Fonction_Hierarchie from '@salesforce/label/c.LU_Contact_Detail_Fct_Hierarchie_Title';
import lbl_Infos_Diverses from '@salesforce/label/c.LU_Contact_Detail_Infos_Diverses_Title';
import lbl_Paiement_Compte from '@salesforce/label/c.LU_Contact_Detail_Paiement_Compte_Title';
import lbl_Back from '@salesforce/label/c.LU_Contact_Details_Back';
import lbl_Pts from '@salesforce/label/c.LU_Counter_Point';
import lbl_lastOrderDate from '@salesforce/label/c.LU_LastOrderDate';
import lbl_Title_Customer_GDPR from '@salesforce/label/c.LU_Contact_Detail_GDPR';
import lbl_GDPR_Status from '@salesforce/label/c.LU_Contact_Detail_GDPR_Status';
import lbl_GDPR_Consent_Locker_Title from '@salesforce/label/c.LU_GDPR_Consent_Locker_Title';
import lbl_GDPR_Consent_Tick_Title from '@salesforce/label/c.LU_GDPR_Consent_Tick_Title';
import lbl_GDPR_resentConsent from '@salesforce/label/c.LU_GDPR_ResentConsent';

/* IMPORT STATIC RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc18_Contact_Details_Informations extends NavigationMixin(LightningElement) {

    /* ICONS */
    btn_mail = LogoBtn + '/icons/contact_mail.PNG';
    btn_whastapp = LogoBtn + '/icons/icon_whatsapp.PNG';
    btn_edit = LogoBtn + '/icons/icon_edit.PNG';
    iconLock = LogoBtn + '/icons/lock.svg';
    iconCheck = LogoBtn + '/icons/check-grpd.svg';

    /* LABELS */
    @track labels = {
        lbl_Title_Customer_GDPR,
        lbl_GDPR_Status,
        lbl_GDPR_Consent_Locker_Title,
        lbl_GDPR_Consent_Tick_Title,
        lbl_Close,
        lbl_Back,
        lbl_Customer_Edit,
        lbl_TECH_Customer,
        lbl_TECH_Team,
        lbl_TECH_RT_Contact_Customer,
        lbl_Title_detail_team,
        lbl_Title_personnal_infos,
        lbl_Title_commercial_infos,
        lbl_Title_payment_account,
        lbl_Title_Technique,
        lbl_Contact,
        lbl_Email,
        lbl_Whatsapp,
        lbl_Contact_LastOrder,
        lbl_Contact_PostalAddress,
        lbl_Note,
        lbl_Fonction_Hierarchie,
        lbl_Infos_Diverses,
        lbl_Paiement_Compte,
        lbl_Pts,
        lbl_lastOrderDate,
        lbl_GDPR_resentConsent,
        lbl_Contact_RecruitmentCampaign
    }

    /* VARIABLES */
    @api recordId;
    @track contact = [];
    @track objectInfo;
    @track parameters = [];
    @track l_manager = [];
    @track typeContact = this.labels.lbl_TECH_Customer;

    @track displayWhatsApp = false;
    @track displayEmail = false;

    @track openCustomerEdit = false;
    @track displayCheckIcon = false;

    @track displayResendLink = false;
    @track displayResendYet = false;

    @track isCustomer = false;
    @track isDealer = false;

    @track isV2 = false;

    @track counter1value;
    @track counter2value;
    @track counter3value;
    
    @track counter1Name;
    @track counter2Name;
    @track counter3Name;

    @track displayRecruitmentCampaign =  false;
    @track localAttribute5 = "";

    /* INIT */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredGetObject ({ error, data }) {
        if(error){
            console.log(error);
        }
        else if(data){
            this.objectInfo = data;

            this.labels.field_date_de_sortie = this.objectInfo.fields.LocalAttribute3__c.label;
            this.labels.field_dealer_seniority_segment = this.objectInfo.fields.DealerSenioritySegment__c.label;
        }
    }
    connectedCallback(){
        this.parameters = this.getQueryParameters();

        getContactInfos( { contactId : this.parameters.id } )
            .then(results => {
                this.contact = results;

                console.log("this.contact.Users");
                console.log(this.contact.Users);
                console.log(this.contact);
                if(this.contact.Users){
                    this.isV2 = this.contact.Users[0].LU_Use_New_Order_v2__c;
                }

                var vCounterName1 = this.contact.LU_Counter_1_Name__c;
                var vCounterName2 = this.contact.LU_Counter_2_Name__c;
                var vCounterName3 = this.contact.LU_Counter_3_Name__c;
                if(vCounterName1) {
                    this.counter1Name = vCounterName1.split("#")[0];
                }
                
                if(vCounterName2) {
                    this.counter2Name = vCounterName2.split("#")[0];
                }

                if(vCounterName3) {
                    this.counter3Name = vCounterName3.split("#")[0];
                }

                if(this.contact.LU_Counters_Unit__c){
                    this.counter1value = (this.contact.LU_Counter_1__c!==undefined?this.contact.LU_Counter_1__c + " " + this.contact.LU_Counters_Unit__c.split("#")[0]:'');
                    this.counter2value = (this.contact.LU_Counter_2__c!==undefined?this.contact.LU_Counter_2__c + " " + this.contact.LU_Counters_Unit__c.split("#")[1]:'');
                    this.counter3value = (this.contact.LU_Counter_3__c!==undefined?this.contact.LU_Counter_3__c + " " + this.contact.LU_Counters_Unit__c.split("#")[2]:'');
                }

                if(this.contact.HasOptedOutOfEmail == false) {
                    this.displayCheckIcon = true;
                } else {
                    if (this.contact.LU_GDPR_Customer_Informed__c == true) {
                        this.displayCheckIcon = true;
                    } else {
                        this.displayCheckIcon = false;
                        if (this.contact.LU_Consent_Answer_Date__c === null || this.contact.LU_Consent_Answer_Date__c === undefined || this.contact.LU_Consent_Answer_Date__c === "") {
                            if(this.contact.LU_Consent_Resend_Email_Date__c === null || this.contact.LU_Consent_Resend_Email_Date__c === undefined || this.contact.LU_Consent_Resend_Email_Date__c === ""){
                                this.displayResendLink = true;
                            } else {
                                this.displayResendYet = true;
                            }
                        }
                    }
                }

                if(this.contact.LocalAttribute5__c && this.isFRAUser){

                    if(this.contact.LocalAttribute5__c === "AUTO ENREGISTREMENT"){
                        this.localAttribute5 = this.contact.LocalAttribute5__c;
                    }
                    else{
                        this.localAttribute5 = "Enregistrement coach";
                    }
                    this.displayRecruitmentCampaign = true;
                }

                this.l_manager.push({ id : this.contact.Id, 
                    sObjectType : 'Contact', 
                    icon : 'standard:contact', 
                    title : this.contact.FirstName + ' ' + this.contact.LastName,
                    subtitle : this.contact.Email});
                
                this.findContactType();
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
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

    /* EVENTS HANDLING */
    handleEditCustomerOpen(event) {

        if (this.openCustomerEdit) {
            this.openCustomerEdit = false;
            console.log('>>> EDIT1'); 
            // Refresh the contact info
            getContactInfos( { contactId : this.parameters.id } )
            .then(results => {
                this.contact = results;
                
                this.l_manager.push({ id : this.contact.Id, 
                    sObjectType : 'Contact', 
                    icon : 'standard:contact', 
                    title : this.contact.FirstName + ' ' + this.contact.LastName,
                    subtitle : this.contact.Email});

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

            // Spread the word to refresh
            fireEvent(null, 'contactDetailToRefresh', null);

        } else {
            this.openCustomerEdit = true;
        }

    }

    /* BUSINESS METHODS */
    findContactType() {

        if (this.contact && this.objectInfo) {

            // Find if it is a customer
            const rtis = this.objectInfo.recordTypeInfos;
            const customerRtId = Object.keys(rtis).find(rti => rtis[rti].name === this.labels.lbl_TECH_RT_Contact_Customer);

            if (customerRtId == this.contact.RecordTypeId) {
                this.typeContact = this.labels.lbl_TECH_Customer;
                this.isCustomer = true;
            } else {
                this.typeContact = this.labels.lbl_TECH_Team;
                this.isDealer = true;
            }
        }

    }

    /* UI METHODS */

    showWhatsapp() {
        this.displayWhatsApp = true;
    }

    hideWhatsApp() {
        this.displayWhatsApp = false;
    }

    showEmail() {
        this.displayEmail = true;
    }

    hideEmail() {
        this.displayEmail = false;
    }

    get isFRAUser() {

        if (this.contact.AccountCountryCode__c == 'FRA') {
            return (true);
        }
        return (false);
    }

    toContactsPage(){
        
        let urlParam = "";

        if (this.contact.ActivityStatus__c == true){
            urlParam = "Team";
        }
        else{
            urlParam = "Client"
        }

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contacts'
            },
            state: {
                "display" : urlParam
            }
        });
    }

    hideResend(){
        this.displayResendLink = false;
        this.displayResendYet = true;
    }

    createTicketManager(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'nouvelle-demande-manager',
            },
        });
    }
}