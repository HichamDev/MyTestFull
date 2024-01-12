/* eslint-disable guard-for-in */
/* IMPORT */
import { LightningElement, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';
import DefaultPP from '@salesforce/resourceUrl/LU_DefautProfilePicture';

/* IMPORT FIELDS */
import USER_ID from '@salesforce/user/Id';

/* IMPORT OBJECT */
import CONTACT_OBJECT from '@salesforce/schema/Contact';

/* IMPORT STANDARD METHODS */
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

/* APEX METHODS */
import getContactList from '@salesforce/apex/LWC01_ListView_Ctrl.getContactList';
import getUserCountry from '@salesforce/apex/LWC01_ListView_Ctrl.getUserCountry';
import getContactConnected from '@salesforce/apex/LWC01_ListView_Ctrl.getContactConnected';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* IMPORT CUSTOM LABELS */
import lbl_Title from '@salesforce/label/c.LU_Action_Email_Title';
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_View from '@salesforce/label/c.LU_Contact_Item_View';
import lbl_Edit from '@salesforce/label/c.LU_Contact_Item_Edit';
import lbl_Email from '@salesforce/label/c.LU_Contact_Email';
import lbl_Email_all from '@salesforce/label/c.LU_Contact_Email_All';
import lbl_Whatsapp from '@salesforce/label/c.LU_Contact_Whatsapp';
import lbl_nb_team from '@salesforce/label/c.LU_Contact_Nb_TeamMember';
import lbl_nb_customer from '@salesforce/label/c.LU_Contact_Nb_Customer';
import lbl_export_excel from '@salesforce/label/c.LU_Contact_Export_Excel';
import lbl_no_results_found from '@salesforce/label/c.LU_Contact_NoResults';
import lbl_order_by_placeholder from '@salesforce/label/c.LU_Contact_Order_By_Placeholder';
import lbl_order_alpha from '@salesforce/label/c.LU_Contact_Order_Alphabetical';
import lbl_order_lastorderdate from '@salesforce/label/c.LU_Contact_Order_LastOrderDate';
import lbl_order_job from '@salesforce/label/c.LU_Contact_Order_Job';
import lbl_order_typology from '@salesforce/label/c.LU_Contact_Order_Typology';
import lbl_order_segmentation_dealer from '@salesforce/label/c.LU_Contact_Order_Segmentation_Dealer';
import lbl_Contact from '@salesforce/label/c.LU_Contact_ContactTitle';
import lbl_SelectAll from '@salesforce/label/c.LU_Contact_SelectAll';
import lbl_Contact_LastOrder from '@salesforce/label/c.LU_Contact_LastOrder';
import lbl_Contact_PostalAddress from '@salesforce/label/c.LU_Contact_PostalAddress';
import lbl_Contact_Mobile_Filter from '@salesforce/label/c.LU_Contact_Mobile_Filter';
import lbl_Contact_Mobile_Sort from '@salesforce/label/c.LU_Contact_Mobile_Sort';
import lbl_pagination_postion from '@salesforce/label/c.LU_Pagination_Position';
import lbl_pagination_max_element from '@salesforce/label/c.LU_Pagination_Max_Element';
import lbl_search from '@salesforce/label/c.LU_Contat_Search';
import lbl_lastOrderDate from '@salesforce/label/c.LU_LastOrderDate';
import lbl_GDPR_Consent_Locker_Title from '@salesforce/label/c.LU_GDPR_Consent_Locker_Title';
import lbl_GDPR_Consent_Tick_Title from '@salesforce/label/c.LU_GDPR_Consent_Tick_Title';
import lbl_displayContactButtons from '@salesforce/label/c.LU_Contact_DisplayContactButton';
import lbl_GDPR_resentConsent from '@salesforce/label/c.LU_GDPR_ResentConsent';
import lbl_SeniorSegmentation from '@salesforce/label/c.LU_TeamFilters_SeniorSegmentation';
import lbl_source from '@salesforce/label/c.LU_Contact_Source';
import lbl_source_Stanhome from '@salesforce/label/c.LU_Contact_Source_Stanhome';
import lbl_source_personal from '@salesforce/label/c.LU_Contact_Source_Personal';
import lbl_contact_current_turnover from '@salesforce/label/c.LU_Contact_Current_Turnover';
import lbl_contact_last2cycle_turnover from '@salesforce/label/c.LU_Contact_Last2Cycle_Turnover';
import lbl_contact_cumulated_turnover_year from '@salesforce/label/c.LU_Contact_Cumulated_Turnover_Year';

/* CONSTANTS */


export default class LWC01_ListView extends NavigationMixin(LightningElement) {
    rebate_job_title = 'Stanlover';

    /* LABELS */
    labels = {
        lbl_Title,
        lbl_TECH_Customer,
        lbl_TECH_Team,
        lbl_View,
        lbl_Edit,
        lbl_Email,
        lbl_Email_all,
        lbl_Whatsapp,
        lbl_nb_team,
        lbl_nb_customer,
        lbl_export_excel,
        lbl_no_results_found,
        lbl_Contact_Mobile_Filter,
        lbl_order_by_placeholder,
        lbl_order_alpha,
        lbl_order_lastorderdate,
        lbl_order_job,
        lbl_order_typology,
        lbl_order_segmentation_dealer,
        lbl_Contact,
        lbl_SelectAll,
        lbl_Contact_LastOrder,
        lbl_Contact_PostalAddress,
        lbl_search,
        lbl_Contact_Mobile_Sort,
        lbl_lastOrderDate,
        lbl_GDPR_Consent_Locker_Title,
        lbl_GDPR_Consent_Tick_Title,
        lbl_displayContactButtons,
        lbl_GDPR_resentConsent,
        lbl_SeniorSegmentation,
        lbl_source,
        lbl_source_Stanhome,
        lbl_source_personal,
        lbl_contact_current_turnover,
        lbl_contact_last2cycle_turnover,
        lbl_contact_cumulated_turnover_year
    };

    /* ICONS */
    iconLock = LogoBtn + '/icons/lock.svg';
    iconCheck = LogoBtn + '/icons/check-grpd.svg';

    btn_mail = LogoBtn + '/icons/contact_mail.PNG';
    btn_whastapp = LogoBtn + '/icons/icon_whatsapp.PNG';
    btn_excel = LogoBtn + '/icons/download.png';
    icon_phone = LogoBtn + '/icons/contact_tel.PNG';
    icon_mail = LogoBtn + '/icons/contact_mail.PNG';
    icon_address = LogoBtn + '/icons/contact_address.png';
    icon_edit = LogoBtn + '/icons/icon_edit.PNG';
    icon_view = LogoBtn + '/icons/icon_view_white.png';
    
    btn_filters = LogoBtn + '/icons/btn_filters.png';
    btn_sort = LogoBtn + '/icons/icon_sort.PNG';
    input_search = LogoBtn + '/icons/input_search.png';
    header_contact = LogoBtn + '/icons/header-contact.png';
    contact_mail = LogoBtn + '/icons/contact_mail.png';
    btn_whattsapp = LogoBtn + '/icons/personal-contact-whatsapp.png';
    user_pictures = LogoBtn + '/icons/pictures-user.png';
    btn_download = LogoBtn + '/icons/download.png';
    btn_trash = LogoBtn + '/icons/trash.png';
    btn_dialog = LogoBtn + '/icons/contact_mail.svg';
    default_profile_pictures = DefaultPP;


    /* VARIABLES */
    userId = USER_ID;
    @track contactObj;
    @track isLoading = false;
    
    @track typeContact = this.labels.lbl_TECH_Customer;

    @track contacts = [];
    @track filteredcontacts = [];
    // @track nbFilteredContacts = '';
    // @track isFilteredContactsEmpty = false;
    @track error;

    @track sortedBy = 'LastName';
    @track valueOrderBy = "";
    @track sortedDirection = 'ASC';
    @track rowsSelected = [];
    
    @track filters;
    searchTxt = '';
    @track openEmail = false;
    @track selectedReady = [];

    @track displayEditView = false;
    @track displayWhatsApp = false;
    @track contactId = "";

    @track displayExportExcel = false;

    @track selectAll = false;

    @track isFRA = false;
    @track isITA = false;

    @track contactSelectedId = '';
    @track openMobileFilters = false;
    @track openMobileSort = false;
    @track openMobileContact = false;
    @track mobileDisplayFilters = false;

    @track displayedContact = [];
    @track pageDisplayed = 1;
    @track maxPageNumber = 1;

    @track searchedTerms = "";

    @track maxElement = parseInt(lbl_pagination_max_element, 10);

    @track displaySwitch = false;
    @track connectedContact = null;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo({ data, error }) {
        if (data) {
            this.contactObj = data;
        }
    }
	connectedCallback() {
        
        // Display the spinner
        this.isLoading = true;

        this.searchContact();

        getUserCountry()
            .then(results => {
                if(results === "FRA"){
                    this.isFRA = true;
                } else {
                    // this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Team);
                    this.isITA = true;
                }
                // Display / Hide the spinner
                this.isLoading = false;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
        
        getContactConnected()
        .then(result => {
            this.connectedContact = result;
            if (this.connectedContact) {
                // ITA
                if (this.connectedContact.AccountCountryCode__c == 'ITA') {

                    if (this.connectedContact.Title == 'Group Sales Consultant') { // Dealer manager
                        this.displaySwitch = true;
                        this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Team);
                    } else if (this.connectedContact.Title == 'Incaricata' || this.connectedContact.Title == 'Sales Consultant' || this.connectedContact.Title == 'Smile' || this.connectedContact.Title == this.rebate_job_title) { // Dealers
                        this.displaySwitch = false;
                        this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Customer);
                        fireEvent(this.pageRef, 'contactTypeToggle', this.labels.lbl_TECH_Customer);
                    } else { // Top managers
                        this.displaySwitch = false;
                        this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Team);
                        fireEvent(this.pageRef, 'contactTypeToggle', this.labels.lbl_TECH_Team);
                    }

                } else if (this.connectedContact.AccountCountryCode__c == 'FRA') { // FRA

                    if (this.connectedContact.Title != 'Conseillère' || this.connectedContact.Contact_Type__c == 'Leader') { // Manager
                        this.displaySwitch = true;
                        this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Team);
                        fireEvent(this.pageRef, 'contactTypeToggle', this.labels.lbl_TECH_Team);
                    } else { // Dealer
                        this.displaySwitch = false;
                        this.handleEvtContactTypeToggle(this.labels.lbl_TECH_Customer);
                        fireEvent(this.pageRef, 'contactTypeToggle', this.labels.lbl_TECH_Customer);
                    }

                }

                if(this.typeContact === this.labels.lbl_TECH_Team || this.labels.lbl_displayContactButtons === "true"){
                    this.displayContactDiv = true;
                }
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        // subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);
        registerListener('applyFilter', this.handleSendFilters, this);
        registerListener('applyFilterSource', this.handleSendFiltersSource, this);
        registerListener('filtereddata', this.showFilteredContacts, this);
        registerListener('updatesearchterm', this.handleUpdateSearchTerm, this);
        registerListener('changeOrderBy', this.handleEventChangeOrderBy, this);

    }
    renderedCallback() {
        // this.nbFilteredContacts = this.filteredcontacts.length + ' ';
        // this.isFilteredContactsEmpty = (this.filteredcontacts.length === 0);
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }
    
    get nbFilteredContacts() {
        return this.filteredcontacts.length + ' ';
    }

    get isFilteredContactsEmpty(){
        return (this.filteredcontacts.length === 0);
    }

    /* METHODS - EVENTS */
    onClickContactMobile(event) {
        if (this.openMobileContact) {
            this.openMobileContact = false;
        } else {
            this.openMobileContact = true;
        }
    }

    handleOpenMobileFilters(event) {
        if (this.openMobileFilters || this.openMobileSort) {
            this.openMobileFilters = false;
            this.openMobileSort = false;
        } else {
            this.openMobileFilters = true;
        }

    }

    handleOpenMobileSort(event) {
        if (this.openMobileSort) {
            this.openMobileSort = false;
        } else {
            this.openMobileSort = true;
        }

    }

    handleRefreshList(event) {
        this.searchContact();

        this.refreshSelectedContact();
    }

    refreshSelectedContact(){
        this.rowsSelected = [];
        let checkboxes = this.template.querySelectorAll(".checkboxContact");

        for (let i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
        }
    }

    handleUpdateSearchTerm(value) {
        this.searchTxt = value;
    }

    handleEvtContactTypeToggle(value) {
        console.log('>>>> listview handleEvtContactTypeToggle : ' + value);
        // Change the type of contact displayed
        this.typeContact = value;

        // Reset variables
        this.filters = '';

        this.refreshSelectedContact();

        if(this.typeContact === this.labels.lbl_TECH_Customer){
            this.sortedBy = 'LastName';
            this.sortedDirection = 'ASC';
            this.mobileDisplayFilters = false;
        }
        else{
            this.mobileDisplayFilters = true;

            if(this.valueOrderBy === "Last order date"){
                this.sortedBy = 'LastOrderDate__c';
                this.sortedDirection = 'DESC';
            }
            else if(this.valueOrderBy === "Job"){
                this.sortedBy = 'LU_TECH_Job__c';
                this.sortedDirection = 'ASC';
            }
            else if(this.valueOrderBy === "Typology"){
                this.sortedBy = 'LU_TECH_Typology__c';
                this.sortedDirection = 'ASC';
            }
            else {
                this.sortedBy = 'LastName';
                this.sortedDirection = 'ASC';
            }
        }

        if(value === this.labels.lbl_TECH_Team || this.labels.lbl_displayContactButtons === "true"){
            this.displayContactDiv = true;
        }
        else{
            this.displayContactDiv = false;
        }

        // Launch the search
        this.searchContact();
    }

    sortTable(event) {
        /* Get the event data */
        var fieldName = event.detail.fieldName;
        
        if (fieldName === this.sortedBy) {
            if (this.sortedDirection === 'asc' || this.sortedDirection === 'ASC') {
                this.sortedDirection = 'desc';
            } else {
                this.sortedDirection = 'asc';
            }
        } else {
            this.sortedBy = fieldName;
            this.sortedDirection = 'asc';
        }       

        this.searchContact();
    }

    handleSendFilters(value) {
        console.log('handleSendFilters ');
        this.filters = value;
        this.searchContact();
        this.handleOpenMobileFilters();
    }

    @track initialContacts = [];

    handleSendFiltersSource(value) {
        this.isLoading = true;

        if(this.initialContacts.length === 0){
            this.initialContacts = this.filteredcontacts;
        }
        
        if(value.length === 1 && value[0] === 'Personnel'){
            this.displayedContact = this.initialContacts.filter(x => !x.LU_Id_Online__c)
        }
        if(value.length === 1 && value[0].includes("Stanhome")){
            this.displayedContact = this.initialContacts.filter(x => x.LU_Id_Online__c)
        }
        if(value.length !== 1){
            this.displayedContact = this.initialContacts;
        }
        this.filteredcontacts = this.displayedContact;
        this.refreshPagination();

        this.isLoading = false;

        console.log('xxxxx initialContacts : ' + this.initialContacts.length, this.initialContacts);
        console.log('xxxxx filteredcontacts : ' + this.filteredcontacts.length, this.filteredcontacts);
    }

    updateSelection(event) {

        let selectedCheckbox = [];
        let checkboxes = this.template.querySelectorAll(".checkboxContact");
        let setAllcheckedToFalse = false;

        for (let i = 0; i < checkboxes.length; i++) {

            if (checkboxes[i].checked === true) {

                // Add the selected contact to the list of selected contact
                for (let j = 0 ; j < this.displayedContact.length ; j++) {
                    if (this.displayedContact[j].Id == checkboxes[i].dataset.item) {
                        selectedCheckbox.push(this.displayedContact[j]);break;
                    }
                } 

            }
            else{
                setAllcheckedToFalse = true;
            }
        }
        this.rowsSelected = selectedCheckbox;

        if(setAllcheckedToFalse && this.selectAll){
            this.template.querySelector('[data-id="checkboxSelectAllId"]').checked = false;
        }

    }

    handleSendEmail(event) {

        var lSelected = [];
        var i = 0;        
        const selected = this.rowsSelected;

        for ( i ; i < selected.length ; i++) {
            // Check done in controler. To uncomment if evolution
            //if(selected[i].Email != '' && selected[i].Email != null && selected[i].Email != 'undefined'){
            if(selected[i].displayCheckIcon){
                lSelected.push({ id: selected[i].Id, sObjectType: 'Contact', icon: 'standard:contact', 
                                title: selected[i].FirstName + ' ' + selected[i].LastName,
                                subtitle: selected[i].Email});
            }
            //}            
        }

        this.selectedReady = lSelected;

        this.openEmail = true;
    }

    handleSendEmailToAll(event) {

        var lSelected = [];

        for ( let i = 0 ; i < this.filteredcontacts.length ; i++) {
            if(this.typeContact === this.labels.lbl_TECH_Team || (this.typeContact === this.labels.lbl_TECH_Customer && this.filteredcontacts[i].displayCheckIcon)){
                lSelected.push({ id: this.filteredcontacts[i].Id, sObjectType: 'Contact', icon: 'standard:contact', 
                                title: this.filteredcontacts[i].FirstName + ' ' + this.filteredcontacts[i].LastName,
                                subtitle: this.filteredcontacts[i].Email});
            }            
        }

        this.selectedReady = lSelected;

        this.openEmail = true;
    }

    handleCloseEmail(event) {
        this.openEmail = false;
    }


    /* UI METHODS */
    get isTypeTeam() {
        if (this.typeContact == this.labels.lbl_TECH_Team) {
            return (true);
        }
        return (false);
    }

    get isTypeCustomer() {
        if (this.typeContact == this.labels.lbl_TECH_Customer) {
            return (true);
        }
        return (false);
    }

    get optionsOrderBy() {
        let options = [];
        if(this.isFRA){
            options = [
                { label: this.labels.lbl_order_alpha , value: "Alphabetical" },
                { label: this.labels.lbl_order_lastorderdate, value: "Last order date" },
                { label: this.labels.lbl_order_job, value: "Job" },
                { label: this.labels.lbl_order_typology, value: "Typology" }
            ];
        }
        else {
            options = [
                { label: this.labels.lbl_order_alpha , value: "Alphabetical" },
                { label: this.labels.lbl_order_lastorderdate, value: "Last order date" },
                { label: this.labels.lbl_order_job, value: "Job" },
                // { label: this.labels.lbl_order_typology, value: "Typology" },
                { label: this.labels.lbl_order_segmentation_dealer, value: "Activity Segment" }
            ];
        }
        return options;
    }
    
    // Whatsapp
    showWhatsApp() {
        this.displayWhatsApp = true;
    }
    hideWhatsApp() {
        this.displayWhatsApp = false;
    }


    selectAllContact(event){

        let checkboxes = this.template.querySelectorAll(".checkboxContact");
        
        let checkAllValue = this.template.querySelector(".checkboxSelectAll");

        this.selectAll = event.detail.checked;
        let selectedCheckbox = [];
        if(checkAllValue.checked) {
            for (let i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].disabled == false) {
                    checkboxes[i].checked = true;

                    // Add the selected contact to the list of selected contact
                    for (let j = 0 ; j < this.displayedContact.length ; j++) {
                        if (this.displayedContact[j].Id == checkboxes[i].dataset.item) {
                            selectedCheckbox.push(this.displayedContact[j]);break;
                        }
                    } 


                }
            }

            this.rowsSelected = selectedCheckbox; //this.filteredcontacts;
        }
        else{
            for (let i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = false;
            }
            this.rowsSelected = [];
        }
    }


    /* METHODS - BUSINESS */
    showFilteredContacts(value){
        this.filteredcontacts = JSON.parse(value);
        this.refreshSelectedContact();
        this.refreshPagination();
    }

    searchContact() {
        
        // Display the spinner
        this.isLoading = true;

        getContactList({userId : this.userId, 
                        typeContact : this.typeContact,
                        filters : JSON.stringify(this.filters), 
                        sortedBy: this.sortedBy, 
                        sortedDirection: this.sortedDirection,
                        altPP: this.default_profile_pictures })
            .then(results => {
console.log('getContactList', results, JSON.stringify(this.filters))
                this.contacts = results;
                
                if (this.typeContact === this.labels.lbl_TECH_Team){
                    let m_postalCode = new Map();
                    for (const cont of this.contacts) {
                        cont.displayActSegment = ( cont.Title === cont.ActivitySegment__c ? false : true ) ; 
                        if(cont.MailingPostalCode){
                            m_postalCode.set(cont.MailingPostalCode.substring(0, 2), {label : cont.MailingPostalCode.substring(0, 2), value : cont.MailingPostalCode.substring(0, 2)});
                        }
                        if(cont.Users){
                            cont.isV2 = cont.Users[0].LU_Use_New_Order_v2__c;
                        }
                    }
                    fireEvent(this.pageRef, 'l_contactsPostalCode', Array.from( m_postalCode.values() ));
                }

                this.filteredcontacts = results;
                
                let compt = 0;
                this.filteredcontacts.forEach(con => {
                    con.indexDesktop = compt;
                    compt++;
                    con.indexMobile = compt;
                    compt++;
                    con.mobileClickToCall = 'tel:' + con.MobilePhone;
                    con.displayResendLink = false;
                    con.displayResendYet = false;

                    if(con.HasOptedOutOfEmail == false) {
                        con.displayCheckIcon = true;
                    } else {
                        if (con.LU_GDPR_Customer_Informed__c == true) {
                            con.displayCheckIcon = true;
                        } else {
                            con.displayCheckIcon = false;
                            if (con.LU_Consent_Answer_Date__c == null && this.isFRA) {
                                if(con.LU_Consent_Resend_Email_Date__c == null){
                                    con.displayResendLink = true;
                                } else {
                                    con.displayResendYet = true;
                                }
                            }
                        }
                    }
               });

               fireEvent(this.pageRef, 'contacts', { detail: JSON.stringify(this.filteredcontacts) });

               this.refreshPagination();

               // Hide the spinner
                this.isLoading = false;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
                 // Hide the spinner
                 this.isLoading = false;
            });
    }

    // Display more information on selected contact
    displayInformations(event) {

        // Get the contact clicked
        let idCon = event.currentTarget.dataset.contact;

        // close the contact opened
        if (this.contactSelectedId !== '' && this.contactSelectedId !== idCon) {
            this.template.querySelectorAll('[data-idcon="' + this.contactSelectedId + '"]').forEach(element => {
                element.classList.toggle('hideInfo');
           });
        }
        
        // this.template.querySelectorAll('[data-idcon="' + idCon + '"]');
        
        // Display / Hide information of the contact clicked
        this.template.querySelectorAll('[data-idcon="' + idCon + '"]').forEach(element => {
             element.classList.toggle('hideInfo');
        });

        // Set the contact selected to the contact clicked
        this.contactSelectedId = idCon;
    }

    startExportExcel(event){
        
        // Display the spinner
        this.isLoading = true;

        // call the helper function which "return" the CSV data as a String   
        let csv, counter, keys, columnDivider, lineDivider;
       
        if (this.filteredcontacts == null || !this.filteredcontacts.length) {
            // hide the spinner
            this.isLoading = false;
            return null;
        }

        let contactToExport = [];

        if(this.rowsSelected === null || !this.rowsSelected.length){
            contactToExport = this.filteredcontacts;
        }
        else{
            contactToExport = this.rowsSelected;
        }

        columnDivider = ';';
        lineDivider =  '\n';
        //JJE Rajout Stanhome T1740
        //T-1946 : changer les colonnes 
        let headers = [];

        if(!this.isFRA){
            keys = [
                'AccountName__c', 
                'STHID__c',
                'LastName',
                'FirstName',
                'Title',
                'DealerSenioritySegment__c',
                'SalesMgtSegment__c',
                'Email',
                'MobilePhone',
                'LU_LastOrderDate__c', 
                'Last_Order_Total_Amount__c', 
                'LocalAttribute4__c', 
                'LocalAttribute1__c', 
                'LocalAttribute2__c',
                'LU_Life_Cycle__c'
            ];
            headers = [
                this.contactObj.fields.AccountName__c.label, 
                this.contactObj.fields.STHID__c.label, 
                this.contactObj.fields.LastName.label, 
                this.contactObj.fields.FirstName.label,
                this.contactObj.fields.Title.label, 
                this.contactObj.fields.DealerSenioritySegment__c.label, 
                this.contactObj.fields.SalesMgtSegment__c.label, 
                this.contactObj.fields.Email.label, 
                this.contactObj.fields.MobilePhone.label,
                this.contactObj.fields.LastOrderDate__c.label, 
                this.contactObj.fields.Last_Order_Total_Amount__c.label,
                this.contactObj.fields.LocalAttribute4__c.label,
                this.contactObj.fields.LocalAttribute1__c.label,
                this.contactObj.fields.LocalAttribute2__c.label,
                this.contactObj.fields.LU_Life_Cycle__c.label
            ];
        }

        //T-1945 différence si FRA
        if(this.isFRA){
            keys = [
                'AccountName__c', 
                'STHID__c',
                'LastName',
                'FirstName',
                'Title',
                'LU_Typologie__c',
                'DealerSenioritySegment__c',
                'Email',
                'MailingStreet',
                'MailingPostalCode',
                'MailingCity',
                'LU_LastOrderDate__c', 
                'Last_Order_Total_Amount__c', 
                'MobilePhone',
                'Success_Bearing__c',
                'TECH_Level__c',
                'LocalAttribute1__c',
                'Birthdate',
                'LU_Sponsor_Level_1_Name__c',
                'Parent_STH_Name__c',
                'DirectCommissionRate__c',
                'LU_Number_Of_Inactive_Weeks__c',
                // 'LoyaltyProgram1Balance__c',
                // 'LoyaltyProgram2Balance__c',
                // 'LoyaltyProgram3Balance__c',
                'LU_Counter_1__c',
                'LU_Counter_2__c',
                'LU_Counter_3__c',
                'Tech_DR__c',
                'Tech_ZMDD__c',
                'Tech_Secteur__c',
                'LU_Reactivation_Date__c',
                'LocalAttribute3__c',
                'LU_Sleep_Status__c',
                'LU_Last_Order_Period__c',
                'LU_Sleep_Nb_Period_No_Activity__c',
            ];

            headers = [
                this.contactObj.fields.AccountName__c.label, 
                this.contactObj.fields.STHID__c.label, 
                this.contactObj.fields.LastName.label, 
                this.contactObj.fields.FirstName.label,
                this.contactObj.fields.Title.label, 
                this.contactObj.fields.LU_Typologie__c.label, 
                this.contactObj.fields.DealerSenioritySegment__c.label, 
                this.contactObj.fields.Email.label, 
                this.contactObj.fields.MailingStreet.label, 
                this.contactObj.fields.MailingPostalCode.label, 
                this.contactObj.fields.MailingCity.label, 
                this.contactObj.fields.LastOrderDate__c.label, 
                this.contactObj.fields.Last_Order_Total_Amount__c.label,
                this.contactObj.fields.MobilePhone.label,
                this.contactObj.fields.Success_Bearing__c.label,
                this.contactObj.fields.TECH_Level__c.label,
                this.contactObj.fields.LocalAttribute1__c.label,
                this.contactObj.fields.Birthdate.label,
                this.contactObj.fields.LU_Sponsor_Level_1_Name__c.label,
                this.contactObj.fields.Parent_STH_Name__c.label,
                this.contactObj.fields.DirectCommissionRate__c.label,
                this.contactObj.fields.LU_Number_Of_Inactive_Weeks__c.label,
                this.contactObj.fields.LU_Counter_1__c.label,
                this.contactObj.fields.LU_Counter_2__c.label,
                this.contactObj.fields.LU_Counter_3__c.label,
                'Division', 
                'Région', 
                'Secteur',
                // this.contactObj.fields.Tech_DR__c.label,
                // this.contactObj.fields.Tech_ZMDD__c.label,
                // this.contactObj.fields.Tech_Secteur__c.label,
                this.contactObj.fields.LU_Reactivation_Date__c.label,
                this.contactObj.fields.LocalAttribute3__c.label,
                this.contactObj.fields.LU_Sleep_Status__c.label,
                this.contactObj.fields.LU_Last_Order_Period__c.label,
                this.contactObj.fields.LU_Sleep_Nb_Period_No_Activity__c.label
            ];
        }


        csv = '';
        csv += headers.join(columnDivider);
        csv += lineDivider;

 
        for(let i=0; i < contactToExport.length; i++){   
            counter = 0;

            console.log(contactToExport[i]["LocalAttribute3__c"]);
           
            for(let sTempkey in keys) {
                let skey = keys[sTempkey];

                console.log(contactToExport[i][skey]);
 
                if(counter > 0) { 
                    csv += columnDivider; 
                }   
                
                if(!contactToExport[i][skey]){
                    if(contactToExport[i][skey] == 0){
                        csv += "0"
                    }
                    else {
                        csv += "";
                    }
                }
                else if(skey === "LU_LastOrderDate__c"){
                    let dateJs = new Date(contactToExport[i][skey]);
                    let strDate = dateJs.getDate() + "/" + (dateJs.getMonth()+1) + "/" + dateJs.getFullYear();

                    csv += '"'+ strDate +'"';
                }
                else if(skey === "Last_Order_Total_Amount__c"){
                    let amount = (Math.round(contactToExport[i][skey] * 100) / 100).toFixed(2);

                    csv += '"'+ amount +' €"';
                }
                // else if(skey === "LoyaltyProgram2Balance__c" || skey === "LoyaltyProgram3Balance__c"){
                //     let amount = contactToExport[i][skey]? (Math.round(contactToExport[i][skey] * 100) / 100).toFixed(2):'';

                //     csv += contactToExport[i][skey]?'"'+ amount +' €"':'';
                // }
                else if(contactToExport[i][skey] === 0){
                    console.log('I have a 0 here');
                    csv += '"0"';
                }
                // else if(contactToExport[i][skey] === undefined){
                //     console.log('I have an undefined here');
                //     csv += '"0"';
                // }
                else{
                    csv += '"'+ contactToExport[i][skey]+'"'; 
                }
                counter++;
            }

            console.log('csv'+csv);
            csv += lineDivider;
        }    

        if (csv == null){
            // Hide the spinner
            this.isLoading = false;
            return null;
        }

        if (window.navigator.msSaveBlob) {
            //Internet Explorer
            window.navigator.msSaveBlob(new Blob([csv]), "ExportData.csv");
        } 
        else {
 
            let hiddenElement = document.createElement('a');
            hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(csv);
            hiddenElement.target = '_self'; // 
            hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
            document.body.appendChild(hiddenElement); // Required for FireFox browser
            hiddenElement.click(); // using click() js function to download csv file
        }
        
        // Hide the spinner
        this.isLoading = false;
        
        return null;
    } 

    handleEventChangeOrderBy(value){
        this.valueOrderBy = value;

        if(this.valueOrderBy === "Last order date"){
            this.sortedBy = 'LastOrderDate__c';
            this.sortedDirection = 'DESC';
        }
        else if(this.valueOrderBy === "Job"){
            this.sortedBy = 'LU_TECH_Job__c';
            this.sortedDirection = 'ASC';
        }
        else if(this.valueOrderBy === "Typology"){
            this.sortedBy = 'LU_TECH_Typology__c';
            this.sortedDirection = 'ASC';
        }
        else if(this.valueOrderBy === "Activity Segment"){
            this.sortedBy = 'LU_TECH_Segmentation_Dealer__c';
            this.sortedDirection = 'ASC';
        }
        else {
            this.sortedBy = 'LastName';
            this.sortedDirection = 'ASC';
        }

        this.handleOpenMobileFilters();

        this.searchContact();
    }

    handleChangeOrderBy(event) {
        this.valueOrderBy = event.target.value;

        if(this.valueOrderBy === "Last order date"){
            this.sortedBy = 'LU_LastOrderDate__c';
            this.sortedDirection = 'DESC';
        }
        else if(this.valueOrderBy === "Job"){
            this.sortedBy = 'LU_TECH_Job__c';
            this.sortedDirection = 'ASC';
        }
        else if(this.valueOrderBy === "Typology"){
            this.sortedBy = 'LU_TECH_Typology__c';
            this.sortedDirection = 'ASC';
        }
        else if(this.valueOrderBy === "Activity Segment"){
            this.sortedBy = 'LU_TECH_Segmentation_Dealer__c';
            this.sortedDirection = 'ASC';
        }
        else {
            this.sortedBy = 'LastName';
            this.sortedDirection = 'ASC';
        }

        this.searchContact();
    }

    refreshPagination(){
        this.pageDisplayed = 1;
        this.maxPageNumber = Math.floor( this.filteredcontacts.length / this.maxElement ) + 1;
        this.displayedContact = this.filteredcontacts.slice(0, this.maxElement);
        this.labels.lbl_pagination_postion_edited = lbl_pagination_postion.replace('xx', this.pageDisplayed).replace('yy', this.maxPageNumber);
    }
    nextPage(){
        if(this.pageDisplayed < this.maxPageNumber){
            this.pageDisplayed++;
            this.displayedContact = this.filteredcontacts.slice(this.pageDisplayed * this.maxElement - this.maxElement, this.pageDisplayed * this.maxElement);
            this.refreshSelectedContact();
            this.labels.lbl_pagination_postion_edited = lbl_pagination_postion.replace('xx', this.pageDisplayed).replace('yy', this.maxPageNumber);
        }
    }
    previousPage(){
        if(this.pageDisplayed > 1){
            this.pageDisplayed--;
            this.displayedContact = this.filteredcontacts.slice(this.pageDisplayed * this.maxElement - this.maxElement, this.pageDisplayed * this.maxElement);
            this.refreshSelectedContact();
            this.labels.lbl_pagination_postion_edited = lbl_pagination_postion.replace('xx', this.pageDisplayed).replace('yy', this.maxPageNumber);
        }
    }
    firstPage(){
        this.pageDisplayed = 1;
        this.displayedContact = this.filteredcontacts.slice(0, this.maxElement);
        this.refreshSelectedContact();
        this.labels.lbl_pagination_postion_edited = lbl_pagination_postion.replace('xx', this.pageDisplayed).replace('yy', this.maxPageNumber);
    }
    lastPage(){
        this.pageDisplayed = this.maxPageNumber;
        this.displayedContact = this.filteredcontacts.slice(this.pageDisplayed * this.maxElement - this.maxElement, this.pageDisplayed * this.maxElement);
        this.refreshSelectedContact();
        this.labels.lbl_pagination_postion_edited = lbl_pagination_postion.replace('xx', this.pageDisplayed).replace('yy', this.maxPageNumber);
    }

    getDefaultPP(event){
        event.target.src = default_profile_pictures;
    }

    //UPDATE VARIABLE FROM INPUT
    updateSearchedTermsVariable(event) {

        this.searchedTerms = event.target.value;

        let filteredList = [];
        let i;

        if (this.searchedTerms && this.contacts) {
            
            for (i = 0; i < this.contacts.length; i++) { 

                if (this.typeContact === this.labels.lbl_TECH_Team) {
                    if ( (this.contacts[i].STHID__c && this.contacts[i].STHID__c.toLowerCase().startsWith(this.searchedTerms.toLowerCase()) ) || 
                        ( this.contacts[i].FirstName && this.contacts[i].FirstName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) || 
                        ( this.contacts[i].LastName && this.contacts[i].LastName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) ){

                            filteredList.push(this.contacts[i]);
                    }
                } else {
                    if ( ( this.contacts[i].FirstName && this.contacts[i].FirstName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) || 
                        ( this.contacts[i].LastName && this.contacts[i].LastName.toLowerCase().includes(this.searchedTerms.toLowerCase()) ) ){

                            filteredList.push(this.contacts[i]);
                    }
                }
            }

            this.showFilteredContacts(JSON.stringify(filteredList));
        
        } else if (this.searchedTerms !== '' || this.searchedTerms !== undefined) {

            this.showFilteredContacts({ detail: JSON.stringify(this.contacts) });
        }

        this.handleUpdateSearchTerm(this.searchedTerms);
    }

    hideResendLink(event){
        console.log("hideResendLink");
        console.log(event);

        for (let i = 0; i < this.displayedContact.length; i++) { 

            if(this.displayedContact[i].Id === event.detail){
                this.displayedContact[i].displayResendLink = false;
                this.displayedContact[i].displayResendYet = true;
                break;
            }
        }
    }
}