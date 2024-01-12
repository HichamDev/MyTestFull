import { LightningElement, track, wire } from 'lwc';

/* IMPORT RESOURCES */
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* IMPORT CUSTOM LABELS */
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';

export default class lwc26_contact_header_Image extends LightningElement {

    /* VARIABLES */
    @track typeContact = 'customer';

    /* RESOURCES */
    header_team = LogoBtn + '/icons/contact_header.png';
    header_customer = LogoBtn + '/icons/customer_header.png';


    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {

        // subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);

	}
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
	}


    /* EVENTS METHODS */
    handleEvtContactTypeToggle(value) {

        // Change the type of contact displayed
        this.typeContact = value;

    }



    /* UI METHODS */
    get getImgURL() {
        if (this.typeContact == lbl_TECH_Customer) {
            return (this.header_customer);
        }
        return (this.header_team);
    }
}