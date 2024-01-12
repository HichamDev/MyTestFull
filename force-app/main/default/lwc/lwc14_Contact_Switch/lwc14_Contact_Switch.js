import { LightningElement, wire, track } from 'lwc';

/* IMPORT METHODS */
import { CurrentPageReference } from 'lightning/navigation'; 
import { fireEvent } from 'c/pubsub';
import getContact from '@salesforce/apex/LWC14_Contact_Switch_Ctrl.getCurrentContact';

/* LABELS */
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_Customer from '@salesforce/label/c.LU_Customer_Title';
import lbl_Team from '@salesforce/label/c.LU_Team_Title';

export default class Lwc14_Contact_Switch extends LightningElement {

    /* LABELS */
    labels = {
        lbl_TECH_Customer,
        lbl_TECH_Team,
        lbl_Customer,
        lbl_Team
    }

    /* VARIABLES */
    valueMyTeam = this.labels.lbl_Team; //'My Team';
    valueEndCustomers = this.labels.lbl_Customer; //'End Customers';
    @track isManager = false;
    @track valueSent = this.labels.lbl_TECH_Team;

    @track isClient = false;


    /* WIRE METHODS */
    @wire(CurrentPageReference) pageRef;
    connectedCallback() {

        let parameters = this.getQueryParameters();

        // Get contact info from current user
        getContact()
        .then(result => {
            
            let displayTeam = true;
            
            if(parameters.display !== undefined && parameters.display !== "Team"){
                displayTeam = false;
            }
            console.log('>>switch');
            console.log(result);
            if (result != null) {
                if(result.LU_Is_Manager__c ){
                    console.log('>>> is manager');
                    this.isManager = true;
                }

                if (this.isManager === true && displayTeam) {

                    // Fire the event to listeners
                    const valueSent = this.labels.lbl_TECH_Team;
                    fireEvent(this.pageRef, 'contactTypeToggle', valueSent);

                    this.isClient = false;
                }
                else if (this.isManager === true && !displayTeam) {

                    const valueSent = this.labels.lbl_TECH_Customer;
                    fireEvent(this.pageRef, 'contactTypeToggle', valueSent);

                    this.isClient = true;
                }
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });
    }

    //get url parameters
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


    /* EVENT HANDLERS */
    handleToggle(event) {

        //var valueSelected = event.target.outerText;
        //var valueSent = '';

        // if (valueSelected.includes(this.valueMyTeam)) {
        //     valueSent = this.labels.lbl_TECH_Team;
        // } else {
        //     valueSent = this.labels.lbl_TECH_Customer;
        // }

        if (this.valueSent === this.labels.lbl_TECH_Team) {
            this.valueSent = this.labels.lbl_TECH_Customer;
        } else {
            this.valueSent = this.labels.lbl_TECH_Team;
        }
        
        // Fire the event to listeners
        fireEvent(this.pageRef, 'contactTypeToggle', this.valueSent);

    }
}