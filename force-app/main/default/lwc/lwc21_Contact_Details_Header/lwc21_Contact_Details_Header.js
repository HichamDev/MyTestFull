import { LightningElement, wire, track, api } from 'lwc';

/* IMPORT METHODS */
import { getRecord } from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT LABELS */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Customer_Title from '@salesforce/label/c.LU_Customer_Title';
import lbl_TECH_RT_Contact_Customer from '@salesforce/label/c.LU_TECH_Contact_RT_Customer';
import lbl_Customer_Edit from '@salesforce/label/c.LU_Customer_Edit';

/* CONSTANT */
const FIELDS = [
    'Contact.Id',
    'Contact.RecordTypeId',
    'Contact.FirstName',
    'Contact.LastName'
];
const TYPE_CUSTOMER = 'Customer';
const TYPE_DEALER = 'Dealer';

export default class Lwc21_Contact_Details_Header extends LightningElement {

    /* LABELS */
    labels = {
        lbl_Close,
        lbl_Customer_Title,
        lbl_TECH_RT_Contact_Customer,
        lbl_Customer_Edit
    }

    /* VARIABLES */
    @api recordId;
    @track record;
    @track objectInfo;
    @track typeContact = '';
    @track openEditCustomer = false;

    /* INIT */
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecordContactDetails ({ error, data }) {
        this.record = data;
        // Find the contact type to display to right component
        this.findContactType();
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    wiredGetObject ({ error, data }) {
        this.objectInfo = data;
        // Find the contact type to display to right component
        this.findContactType();
    }

    /* EVENTS METHODS */

    // Handle click on edit button for customer to open the popup
    handleEditCustomerOpen(event) {
        this.openEditCustomer = true;
    }

    // Handle the closing of the edit customer popup
    handleEditCustomerClose(event) {
        this.openEditCustomer = false;
    }

    /* UI METHODS */

    // Determine if the current contact is a customer
    get isCustomer() {
        if (this.typeContact == TYPE_CUSTOMER) {
            return (true);
        } 
        return (false);
    }

    // Determine if the current contact is a dealer
    get isDealer() {
        if (this.typeContact == TYPE_DEALER) {
            return (true);
        }
        return (false);
    }


    /* BUSINESS METHODS */
    findContactType() {

        if (this.record && this.objectInfo) {

            // Find if it is a customer
            const rtis = this.objectInfo.recordTypeInfos;
            const customerRtId = Object.keys(rtis).find(rti => rtis[rti].name === this.labels.lbl_TECH_RT_Contact_Customer);

            if (customerRtId == this.record.fields.RecordTypeId.value) {
                this.typeContact = TYPE_CUSTOMER;
            } else {
                this.typeContact = TYPE_DEALER;
            }

        }

    }

}