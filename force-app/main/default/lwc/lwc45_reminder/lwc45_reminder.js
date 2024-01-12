import { LightningElement, api, track } from 'lwc';

/* LABEL */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Send from '@salesforce/label/c.LU_Action_Email_Send';
import lbl_Title from '@salesforce/label/c.LU_Action_WhatsApp_Title';
import lbl_Email from '@salesforce/label/c.LU_Reminder_SendAnEmail';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';

/* STATIC Resources */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class lwc45_reminder extends LightningElement {

    btn_close = LogoBtn + '/icons/close.png';

    @api reminder;
    @track displayModal = false;
    @track openEmail = false;
    @track selectedReady = [];

    label = { 
        lbl_Close,
        lbl_Send,
        lbl_Title,
        lbl_Email,
        lbl_TECH_Team
    };

    openModal() {
        this.displayModal = true;
    }

    closeModal() {
        this.displayModal = false;
    }

    displaySendMail() {
        this.displayModal = false;

        let lSelected = [];
        let i = 0;

        for ( i ; i < this.reminder.l_contacts.length ; i++) {
            lSelected.push({ id: this.reminder.l_contacts[i].Id, sObjectType: 'Contact', icon: 'standard:contact', 
                            title: this.reminder.l_contacts[i].FirstName + ' ' + this.reminder.l_contacts[i].LastName,
                            subtitle: this.reminder.l_contacts[i].Email});
            
        }

        this.selectedReady = lSelected;

        this.openEmail = true;
    }

    handleCloseEmail() {
        this.openEmail = false;
    }
}