import { LightningElement, track, wire, api } from 'lwc';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* LABELS */
import lbl_Title_Customer from '@salesforce/label/c.LU_Customer_Title';
import lbl_Title_Team from '@salesforce/label/c.LU_Team_Title';
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';

export default class Lwc19_Contact_Header extends LightningElement {

    /* LABELS */
    labels = {
        lbl_Title_Customer,
        lbl_Title_Team,
        lbl_TECH_Customer,
        lbl_TECH_Team
    }

    /* VARIABLES */
    @track typeContact = this.labels.lbl_TECH_Customer;

    @api displayToggle = false;
    @api isfrance = false;
    @track ischanged = false;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {
        

        /*
        if (this.displayToggle) {
            this.typeContact = this.labels.lbl_TECH_Team;
        }*/
        //this.displayToggle = true;
        //this.typeContact = this.labels.lbl_TECH_Team;
        // this.typeContact = this.labels.lbl_TECH_Customer;


        // subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);
        
    }
    renderedCallback() {
        // if (this.isfrance == false && this.displayToggle == false) {
        //     this.typeContact = this.labels.lbl_TECH_Team;
        // }
        // if (this.isfrance == true && this.ischanged == false) {
        //     this.typeContact = this.labels.lbl_TECH_Customer;
        // }

    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
	}


    /* EVENTS */

    handleEvtContactTypeToggle(value) {

        // Change the type of contact displayed
        this.typeContact = value;

        this.ischanged = true;
    }


    /* UI METHODS */
    get isCustomer() {
        if (this.typeContact === this.labels.lbl_TECH_Customer) {
            return (true);
        }
        return (false);
    }

    get isMyTeam() {
        if (this.typeContact === this.labels.lbl_TECH_Team) {
            return (true);
        }
        return (false);
    }

}