/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Import APEX Methods */
import deleteContact from '@salesforce/apex/lwc26_deletecontactlist_ctrl.deleteSingleContactFromId';

/* IMPORT CUSTOM LABELS */
import lbl_confirmDeletion from '@salesforce/label/c.LU_Contact_Delete_Confirmation';
import lbl_successContactDeletionTitle from '@salesforce/label/c.LU_Contact_Delete_Sucess_Title';
import lbl_successContactDeletionMessage from '@salesforce/label/c.LU_Contact_Delete_Sucess_Message';
import lbl_No from '@salesforce/label/c.LU_Contact_Delete_Confirmation_No';
import lbl_Yes from '@salesforce/label/c.LU_Contact_Delete_Confirmation_Yes';
import lbl_delete from '@salesforce/label/c.LU_Customer_Delete';

/* IMPORT STATIC RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc27_deletecontact extends NavigationMixin(LightningElement) {
    
    /* ICONS */
    btn_delete = LogoBtn + '/icons/icon_delete.PNG';

    /* LABELS */
    labels = {
        lbl_delete,
        lbl_confirmDeletion,
        lbl_successContactDeletionTitle,
        lbl_successContactDeletionMessage,
        lbl_No,
        lbl_Yes
    }

    /* VARIABLES */
    @track open = false;
    @api selectedcontactId;

    /* EVENT HANDLING */
    openModal() {

        this.open = true;
    }

    cancel() {
        this.open = false;
    }

    deleteList() {
       
        deleteContact( { idContact : this.selectedcontactId } )
        .then(results => {
            const evtError = new ShowToastEvent({
                title: this.lbl_successContactDeletionTitle,
                message: this.lbl_successContactDeletionMessage,
                variant: 'success'
            });
            this.dispatchEvent(evtError);

            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'contacts',
                },
                state: {
                    isTypeTeam: 'false'
                },
            });
            
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

    }
}