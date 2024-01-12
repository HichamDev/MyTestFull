/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* IMPORT METHODS */
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

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

/* IMPORT STATIC RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc57_Contact_Details_Header_Buttons extends NavigationMixin(LightningElement) {

    /* ICONS */
    btn_mail = LogoBtn + '/icons/contact_mail.PNG';
    btn_whastapp = LogoBtn + '/icons/icon_whatsapp.PNG';
    btn_edit = LogoBtn + '/icons/icon_edit.PNG';

    /* VARIABLES */
    @track displayComponent = false;

    @track recordId;
    @track parameters = [];
    @track l_manager = [];
    @track displayEmail = false;
    @track displayWhatsApp = false;
    @track isCustomer = false;
    @track isDealer = false;

    /* LABELS */
    @track labels = {
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
        lbl_Pts
    }

    /* INIT */
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredGetObject ({ error, data }) {
        if(error){
            console.log("error");
            console.log(error);
        }
        else if(data){
            this.objectInfo = data;

            this.labels.field_date_de_sortie = this.objectInfo.fields.LocalAttribute3__c.label;
            this.labels.field_dealer_seniority_segment = this.objectInfo.fields.DealerSenioritySegment__c.label;
        }
    }
    connectedCallback(){

        this.displayComponent = location.href.includes("contact-details");

        this.parameters = this.getQueryParameters();

        this.recordId = this.parameters.id;

        getContactInfos( { contactId : this.recordId } )
            .then(results => {
                this.contact = results;

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

    toContactsPage(){
        
        let urlParam = "";

        if (this.contact.ActivityStatus__c === true){
            urlParam = "Team";
        }
        else{
            urlParam = "Client"
        }

        console.log("ok");

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contacts'
            },
            state: {
                "display" : urlParam
            }
        });

        console.log("ok");
    }

    /* BUSINESS METHODS */
    findContactType() {

        if (this.contact && this.objectInfo) {

            // Find if it is a customer
            const rtis = this.objectInfo.recordTypeInfos;
            const customerRtId = Object.keys(rtis).find(rti => rtis[rti].name === this.labels.lbl_TECH_RT_Contact_Customer);

            if (customerRtId === this.contact.RecordTypeId) {
                this.typeContact = this.labels.lbl_TECH_Customer;
                this.isCustomer = true;
                this.isDealer = false;
            } else {
                this.typeContact = this.labels.lbl_TECH_Team;
                this.isCustomer = false;
                this.isDealer = true;
            }
        }
    }
}