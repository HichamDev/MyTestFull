import { LightningElement, api } from 'lwc';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* IMPORT LABELS */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_New from '@salesforce/label/c.LU_Customer_Create';
import lbl_Title_Customer from '@salesforce/label/c.LU_New_Customer_Title';

export default class Lwc13_EndCustomer_New extends LightningElement {

    /* VARIABLES */
    labels = {
        lbl_Close,
        lbl_New,
        lbl_Title_Customer
    }

    btn_new = LogoBtn + '/icons/icon_new2.PNG';

    @api open = false;

    /* EVENTS METHODS */

    closeEndCustomerForm(event) {

        console.log(event.detail);
        
        this.handleClose(event);

        const evtRefreshList = new CustomEvent('refreshcustomerlist', {detail : event.detail} );
        this.dispatchEvent(evtRefreshList);
    }

    // Open the popup
    handleOpenForm(event) {

        this.open = true;
    }

    // CLose the popup
    handleClose(event) {

        this.open = false;
    }

}