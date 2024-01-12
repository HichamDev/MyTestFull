import { LightningElement, track, wire } from 'lwc';

/* Import APEX Methods */
import getManager from '@salesforce/apex/lwc24_managerinformations_ctrl.getManager';
import getUserCountry from '@salesforce/apex/lwc24_managerinformations_ctrl.getUserCountry';

/* Import Label */
import lbl_EmailAction from '@salesforce/label/c.LU_Action_Email_Title';
import lbl_MyManager from '@salesforce/label/c.LU_Header_MyManager';
import lbl_Facebook_Icon from '@salesforce/label/c.LU_Manager_Facebook_Icon';

/* Static Resources */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc24_managerinformations extends LightningElement {

    /* href img */
    btn_facebook = LogoBtn + '/icons/personal-contact-facebook.png';
    btn_instagram = LogoBtn + '/icons/personal-contact-instagram.png';
    btn_whatsapp = LogoBtn + '/icons/logo_whatsapp.png';
    contact_mail = LogoBtn + '/icons/contact_mail.PNG';
    contact_tel = LogoBtn + '/icons/contact_tel.PNG';
    contact_birthday = LogoBtn + '/icons/contact_birthday.png';

    /* LABELS */
    labels = {
        lbl_EmailAction,
        lbl_MyManager,
        lbl_Facebook_Icon
    }

    /* VARIABLES */
    @track displayPopover = false;
    @track displayWhatsApp = false;
    @track displayWhatsAppButton = false;
    @track manager;
    @track displayEmailForm;
    @track l_manager = [];
    @track isFRA = null;
    @track displayFB = false;
    @track linkPhone = "";

    connectedCallback() {
        getUserCountry( {} )
            .then(results => {
                if(results === "FRA"){
                    this.isFRA = true;
                    this.displayWhatsAppButton = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    showData() {
        if(this.displayPopover === false){
            this.displayPopover = true;
        }
        else {
            this.displayPopover = false;
        }
        
    }

    hideData() {
        this.displayPopover = false;
    }

    showEmailForm() {
        this.displayPopover = false;
        this.displayEmailForm = true;
    }
    hideEmailForm() {
        this.displayEmailForm = false;
    }

    showWhatsApp() {
        this.displayPopover = false;
        this.displayWhatsApp = true;
    }
    hideWhatsApp() {
        this.displayWhatsApp = false;
    }
    

    @wire(getManager, )
    wiredCycleObjectives({ error, data }) {
        if (data) {
            this.manager = JSON.parse(JSON.stringify(data));
            if(this.manager.LU_Facebook_URL__c !== null && this.manager.LU_Facebook_URL__c !== undefined && this.manager.LU_Facebook_URL__c !== ""){
                this.displayFB = true;
            }
            this.linkPhone = "tel:" + this.manager.MobilePhone;

            this.l_manager.push({ id : data.Id, 
                                  sObjectType : 'Contact', 
                                  icon : 'standard:contact', 
                                  title : data.FirstName + ' ' + data.LastName,
                                  subtitle : data.Email});

        } else if (error) {
            this.error = error;
        }
    }
}