/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Import APEX Methods */
import deleteContact from '@salesforce/apex/lwc26_deletecontactlist_ctrl.deleteContactList';

/* IMPORT CUSTOM LABELS */
import lbl_button from '@salesforce/label/c.LU_Customer_Delete';
import lbl_confirmDeletion from '@salesforce/label/c.LU_Contact_Delete_Confirmation';
import lbl_confirmYes from '@salesforce/label/c.LU_Contact_Delete_Confirmation_Yes';
import lbl_confirmNo from '@salesforce/label/c.LU_Contact_Delete_Confirmation_No';
import lbl_successContactDeletionTitle from '@salesforce/label/c.LU_Contact_Delete_Sucess_Title';
import lbl_successContactDeletionMessage from '@salesforce/label/c.LU_Contact_Delete_Sucess_Message';
import lbl_warningContactDeletionTitle from '@salesforce/label/c.LU_Contact_Delete_Warning_Title';
import lbl_warningContactDeletionMessage from '@salesforce/label/c.LU_Contact_Delete_Warning_Message';

export default class Lwc26_deletecontactlist extends LightningElement {
    @track open = false;
    @api selectedtargets = [];

    labels = {
        lbl_confirmDeletion,
        lbl_confirmYes,
        lbl_confirmNo,
        lbl_button
    }

    btn_delete = LogoBtn + '/icons/icon_delete2.PNG';
    iconDelete = LogoBtn + '/icons/icon-delete.svg';

    openModal() {
        console.log(this.selectedtargets);
        console.log(this.selectedtargets.length);

        if(this.selectedtargets.length === 0){
            const evtError = new ShowToastEvent({
                title: lbl_warningContactDeletionTitle,
                message: lbl_warningContactDeletionMessage,
                variant: 'warning'
            });
            this.dispatchEvent(evtError);
            return;
        }
        this.open = true;
    }

    cancel() {
        this.open = false;
    }

    deleteList() {
       
        console.log('deletelist');
        console.log(this.selectedtargets);

        deleteContact( { l_contactToDelete : this.selectedtargets } )
            .then(results => {
                const evtError = new ShowToastEvent({
                    title: lbl_successContactDeletionTitle,
                    message: lbl_successContactDeletionMessage,
                    variant: 'success'
                });
                this.dispatchEvent(evtError);

                const eventRefreshList = new CustomEvent('eventrefreshlist', {});
                this.dispatchEvent(eventRefreshList);
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        
        this.open = false;
    }
}