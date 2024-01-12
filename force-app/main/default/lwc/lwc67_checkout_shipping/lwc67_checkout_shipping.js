import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

// IMPORT RESOURCES
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

// IMPORT APEX METHODS
import getApplicableFees from '@salesforce/apex/lwc67_checkout_shipping_ctrl.getApplicableFees';
import getOrder from '@salesforce/apex/lwc67_checkout_shipping_ctrl.getOrder';
import updateOrder from '@salesforce/apex/lwc67_checkout_shipping_ctrl.updateOrder';
import getUserCountry from '@salesforce/apex/lwc67_checkout_shipping_ctrl.getUserCountry';

// IMPORT CUSTOM LABELS
import lbl_selectShipping from '@salesforce/label/c.LU_Checkout_Shipping_Select_Shipping';
import lbl_homeDelivery from '@salesforce/label/c.LU_Checkout_Shipping_Home_Delivery';
import lbl_newAdressDelivery from '@salesforce/label/c.LU_Checkout_Shipping_New_Adress_Delivery';
import lbl_save from '@salesforce/label/c.LU_Checkout_Shipping_Save';
import lbl_relayPointDelivery from '@salesforce/label/c.LU_Checkout_Shipping_Relay_Delivery';
import lbl_freeDelivery from '@salesforce/label/c.LU_Checkout_Shipping_Free_Delivery';
import lbl_saveShippingSelected from '@salesforce/label/c.LU_Checkout_Shipping_Save_Selected';
import lbl_fieldLastname from '@salesforce/label/c.LU_Checkout_Shipping_Field_Lastname';
import lbl_fieldFirstname from '@salesforce/label/c.LU_Checkout_Shipping_Field_Firstname';
import lbl_fieldStreet from '@salesforce/label/c.LU_Checkout_Shipping_Field_Street';
import lbl_fieldStreetComplement from '@salesforce/label/c.LU_Checkout_Shipping_Field_StreetComplement';
import lbl_fieldPostalCode from '@salesforce/label/c.LU_Checkout_Shipping_Field_PostalCode';
import lbl_fieldCity from '@salesforce/label/c.LU_Checkout_Shipping_Field_City';
import lbl_fieldCountry from '@salesforce/label/c.LU_Checkout_Shipping_Field_Country';
import lbl_fieldAddedInformations from '@salesforce/label/c.LU_Checkout_Shipping_Field_AddedInformations';
import lbl_ErrorShipping from '@salesforce/label/c.LU_Checkout_Shipping_Error_Title';
import lbl_Error_ExternalPoint_NoSelected from '@salesforce/label/c.LU_Checkout_Shipping_Error_ExternalPoint_NoSelected';
import lbl_Error_ExceptionnalAdrress_NotComplete from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_NotComplete';
import lbl_fieldPrefix from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_Prefix';
import lbl_orderLocAttrForMe from '@salesforce/label/c.LU_OrderLocalAttribute6_ForMe';
import lbl_orderLocAttrForCli from '@salesforce/label/c.LU_OrderLocalAttribute6_ForClient';
import LU_Regex_Mobile_Format from '@salesforce/label/c.LU_Regex_Mobile_Format';
import lbl_Error_ExceptionnalAdrress_PhoneFormat from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_PhoneFormat';
import lbl_textDoc from '@salesforce/label/c.LU_Checkout_Shipping_TextDocument';
import lbl_regex_cp_format from '@salesforce/label/c.LU_Regex_CP_Format';
import lbl_error_exceptionnalAddress_cpFormat from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_CpFormat';

export default class Lwc67_checkout_shipping extends LightningElement {

    /* ICONS */
    iconShipping = LogoBtn + '/icons/checkout-shipping.png';

    /* VARIABLES */
    @track isComponentDisplayed = false;

    @track standardShipping;
    @track standardShippingFees = "";
    @track order;
    @track l_shippingMode;

    @track displayNewAdressForm = false;

    @track contactMailingStreet = "";
    @track contactMailingPostalCode = "";
    @track contactMailingCity = "";
    @track contactMailingCountry = "";

    @track firstName = "";
    @track lastName = "";
    @track street = "";
    @track streetComplement = "";
    @track postalCode = "";
    @track city = "";
    @track country = "";
    @track addedInformations = "";
    @track disabledNewAddressFields = false;
    @track prefixAndLastName = "";

    @track externalPointSelected = null;
    @track externalShippingFees = "";
    @track displayExternal = false;
    @track externalModeTitle = "";
    @track externalModeName = "";
    @track mobilephone = "";

    @track isFRA = false;
    @track isITA = false;

    @track currentAdress = true;
    @track newAdress = false;
    @track externalMode = false;

    @track isOpen = false;
    @track isSelectable = false;
    @track isOtherAddressSelectable = false;
    @track isExternalModeSelectable = false;

    @track txtExceptionnalAddress = '';
    @track txtRelaisPoint = '';

    @track displaySaveNewAdressButton = false;
    @track displayValidatedText = false;

    @track displayExceptionnalAdressPrefix = false;

    @track displayRecipientChoice = false;
    @track recipientChoice;
    @track recipientText;

    @track isFreeDelivery = false;

    labels = {
        lbl_saveShippingSelected,
        lbl_selectShipping,
        lbl_homeDelivery,
        lbl_newAdressDelivery,
        lbl_save,
        lbl_relayPointDelivery,
        lbl_freeDelivery,
        lbl_fieldLastname,
        lbl_fieldFirstname,
        lbl_fieldStreet,
        lbl_fieldStreetComplement,
        lbl_fieldPostalCode,
        lbl_fieldCity,
        lbl_fieldCountry,
        lbl_fieldAddedInformations,
        lbl_fieldPrefix,
        LU_Regex_Mobile_Format,
        lbl_Error_ExceptionnalAdrress_PhoneFormat,
        lbl_textDoc,
        lbl_regex_cp_format
    };

    connectedCallback(){

        // subscribe to events
        registerListener('lwc85_incentive_challenge', this.handleDisplayComponent, this);
        registerListener('checkout_openShippingMode', this.handleEvtOpen, this);
        registerListener('checkout_shippingExternal_PointSelected', this.handleExternalPointSelected, this);
        registerListener('checkout_shippingExternal_MobilePhone', this.handleExternalPointPhoneChange, this);
        
        this.standardShippingFees = this.labels.lbl_freeDelivery;
        this.externalShippingFees = this.labels.lbl_freeDelivery;

        let parameters = this.getQueryParameters();

        if(parameters.orderId){
            getApplicableFees({ orderId : parameters.orderId }) 
                .then(results => {

                    this.l_shippingMode = JSON.parse(JSON.stringify(results));

                    for (let oRule of this.l_shippingMode) {

                        if (oRule.LU_Parent_Order_Rule__r.LU_Text__c === "Standard") {
                            this.standardShipping = oRule;
                            
                            if(oRule.Fees__c > 0) {
                                this.standardShippingFees = ' ' + oRule.Fees__c + ' € ';
                            }
                            oRule.isStandard = true;
                            oRule.isExternal = false;

                        } else if (oRule.LU_Parent_Order_Rule__r.LU_Text__c === "Colissimo") { // Externe_Colissimo
                            oRule.isStandard = false;
                            oRule.isExternal = true;
                            this.externalModeName = oRule.LU_Parent_Order_Rule__r.LU_Text__c;
                            this.externalModeTitle = this.labels.lbl_relayPointDelivery;

                            if (oRule.Fees__c > 0) {
                                this.externalShippingFees = ' ' + oRule.Fees__c + ' € ';
                            }
                            
                        }

                        console.log(oRule.isExternal);
                        console.log(oRule.isStandard);
                    }

                })
                .catch(error => {
                    console.log('>>>> error :');
                    console.log(error);
                }
            );

            getOrder({ orderId : parameters.orderId }) 
                .then(results => {
                    this.order = JSON.parse(JSON.stringify(results));

                    this.contactMailingStreet = results.BillToContact.MailingStreet;
                    this.contactMailingPostalCode = results.BillToContact.MailingPostalCode;
                    this.contactMailingCountry = results.BillToContact.MailingCountry;
                    this.contactMailingCity = results.BillToContact.MailingCity;

                    if (this.order.BillToContact.MobilePhone == null) {
                        this.order.BillToContact.MobilePhone = '';
                    }

                    this.mobilephone = this.order.BillToContact.MobilePhone;
                })
                .catch(error => {
                    console.log('>>>> error :');
                    console.log(error);
                }
            );

            getUserCountry() 
                .then(results => {
                    if(results === 'FRA'){
                        this.country = "France"
                        this.isFRA = true;
                    }
                    else if(results === 'ITA'){
                        this.country = "Italia"
                        this.isITA = true;
                    }
                    // Add an variable to show "Chez" based on CustomLabel
                    if(this.labels.lbl_fieldPrefix.length > 0 && this.labels.lbl_fieldPrefix && this.isFRA){
                        this.displayExceptionnalAdressPrefix = true;
                        this.prefixAndLastName = "(" + lbl_fieldPrefix + ") " + lbl_fieldLastname;
                    }
                })
                .catch(error => {
                    console.log('>>>> error :');
                    console.log(error);
                }
            );
        }
    }
    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }

    handleDisplayComponent(value){
        console.log(value);
        if(value == true){
            this.isFreeDelivery = true;
            this.standardShippingFees = this.labels.lbl_freeDelivery;
            this.externalShippingFees = this.labels.lbl_freeDelivery;
            this.order.LU_Transport_Fees__c = 0;
        }
        this.isComponentDisplayed = true;
    }


    updateCurrentOrder(){
        // If external point selected
        if (this.externalMode) {
            this.order.LU_Distribution_Center__c = this.externalPointSelected.identifiant;
            this.order.LU_Customer_Mobile__c = this.mobilephone;
            this.order.LU_Shipping_Comment__c = '';
            this.order.ShippingStreet = '';//this.externalPointSelected.adresse1;
            this.order.LU_Shipping_Street_2__c = '';//this.externalPointSelected.adresse2;
            this.order.LU_Shipping_Street_3__c = '';//this.externalPointSelected.adresse3;
            this.order.ShippingPostalCode = '';//this.externalPointSelected.codePostal;
            this.order.ShippingCity = '';//this.externalPointSelected.localite;
            this.order.ShippingCountry = '';//this.externalPointSelected.codePays;
            this.order.LU_Transport_Mode__c = this.externalModeName;
            this.order.LU_Transporter__c = this.externalModeName;
            this.order.LU_Tranport_Mode_Label__c = this.labels.lbl_relayPointDelivery;

            if (this.externalShippingFees === this.labels.lbl_freeDelivery) {
                this.order.LU_Transport_Fees__c = 0;
            } else {
                this.order.LU_Transport_Fees__c = parseFloat(this.externalShippingFees);
            }

            // Set result txt
            this.txtRelaisPoint = this.externalPointSelected.adresse1 + 
                            (this.externalPointSelected.adresse2 != null && this.externalPointSelected.adresse2 != '' ? '<br/>' + this.externalPointSelected.adresse2 : '') +
                            (this.externalPointSelected.adresse3 != null && this.externalPointSelected.adresse3 != '' ? '<br/>' + this.externalPointSelected.adresse3 : '') +
                            '<br/>' + this.externalPointSelected.codePostal + ' ' + this.externalPointSelected.localite;

        } else { // STANDARD
            this.order.LU_Distribution_Center__c = '';
            this.order.LU_Customer_Mobile__c = '';
            this.order.LU_Transporter__c = this.standardShipping.LU_Parent_Order_Rule__r.LU_Text__c;

            if (!this.displayNewAdressForm) { // IF standard address
                this.order.ShippingStreet = '';//this.contactMailingStreet;
                this.order.LU_Shipping_Street_2__c = '';
                this.order.LU_Shipping_Street_3__c = '';
                this.order.ShippingPostalCode = '';//this.contactMailingPostalCode;
                this.order.ShippingCity = '';//this.contactMailingCity;
                this.order.ShippingCountry = '';//this.contactMailingCountry;
                this.order.LU_Shipping_Comment__c = '';
                               
            } else { // If exceptionnal address
                this.order.ShippingPostalCode = this.postalCode;
                this.order.ShippingCity = this.city.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                this.order.ShippingCountry = this.country.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                    
                // MANAGE CONDITIONAL FIELDS
                // EG: ShippingStreet = Chez Pierre PLESSIS
                let comment;
                comment = (this.labels.lbl_fieldPrefix.length > 0 && this.labels.lbl_fieldPrefix != '.' ? this.labels.lbl_fieldPrefix + ' ' : '') + this.firstName + ' ' + this.lastName;
                if (comment != null && comment.length > 255){
                    comment = comment.substring(0,250) +'...';
                }
                this.order.ShippingStreet = comment.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

                // EG: LU_Shipping_Street_2__c = 32 RUE JULLIEN
                this.order.LU_Shipping_Street_2__c = this.street.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

                // EG: 06 10 00 10 10
                let street3 = this.addedInformations;
                if (street3 != null && street3.length > 255) {
                    street3 = street3.substring(0, 250)+ '...';
                }
                this.order.LU_Shipping_Street_3__c = street3.toUpperCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");           

                // Set result TXT
                this.txtExceptionnalAddress =  this.order.ShippingStreet 
                                            + (this.order.LU_Shipping_Street_2__c != null && this.order.LU_Shipping_Street_2__c != '' ? '<br/>' + this.order.LU_Shipping_Street_2__c : '') 
                                            + '<br/>' + this.order.ShippingPostalCode + ' ' + this.order.ShippingCity
                                            + (this.order.LU_Shipping_Street_3__c != null && this.order.LU_Shipping_Street_3__c != '' ? '<br/>'+ this.order.LU_Shipping_Street_3__c : '');

                if(this.isFRA) {
                    console.log("LU_Local_Attribute_6__c");
                    this.order.LU_Local_Attribute_6__c = this.recipientChoice === "forMe" ? lbl_orderLocAttrForMe : lbl_orderLocAttrForCli;
                }
                else if(this.isITA){
                    this.order.LU_Shipping_Comment__c = this.order.ShippingStreet;
                    this.order.ShippingStreet = this.order.LU_Shipping_Street_2__c;
                }
            }

            if (this.standardShippingFees === this.labels.lbl_freeDelivery) {
                this.order.LU_Transport_Fees__c = 0;
            } else {
                this.order.LU_Transport_Fees__c = parseFloat(this.standardShippingFees);
            }

            for(let oRule of this.l_shippingMode){
                if (oRule.isStandard && oRule.LU_Parent_Order_Rule__r.LU_Text__c === "Standard") {
                    this.order.LU_Transport_Mode__c = oRule.LU_Parent_Order_Rule__r.LU_Text__c;
                    if (!this.displayNewAdressForm) {
                        this.order.LU_Tranport_Mode_Label__c = this.labels.lbl_homeDelivery;
                    } else {
                        this.order.LU_Tranport_Mode_Label__c = this.labels.lbl_newAdressDelivery;
                    }
                }
           
            }
        }

        updateOrder({ ord : this.order }) 
            .then(results => {
                this.isSelectable = true;
                if (this.newAdress) {
                    this.isOtherAddressSelectable = false;
                }
                else{
                    this.isOtherAddressSelectable = true;
                }

                if (this.externalMode) {
                    this.isExternalModeSelectable = false;
                }
                else{
                    this.isExternalModeSelectable = true;
                }

                this.isOpen = false;
                
                // Put on read only mode the results
                this.displayValidatedText = true;

                // Fire event : to shipping mode component lwc69_checkout_payment
                fireEvent(null, 'checkout_openPaymentMode', true);
                fireEvent(null, 'basketUpdated', true);

            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            }
        );
    }

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

    showNewAdressForm(event){
        if(this.isFRA){
            this.displayRecipientChoice = true;
        }
        else if(this.isITA){
            this.displayNewAdressForm = true;
        }
        this.currentAdress = false
        this.newAdress = true;
        this.displayExternal = false;
        this.externalMode = false;
    }

    setRecipient(event){
        this.recipientChoice = event.target.value;
        this.displayRecipientChoice = false;
        this.displayNewAdressForm = true;
        if(this.recipientChoice === "forMe"){
            this.recipientText = "Pour moi";
        }
        else if(this.recipientChoice === "forClient"){
            this.recipientText = "Pour un client";
        }
    }

    hideNewAdressForm(event){
        this.displayNewAdressForm = false;
        this.currentAdress = true;
        this.newAdress = false;
        this.displayExternal = false;
        this.externalMode = false;

    }

    saveNewAdressForm(){

        // Check that the fields are filled
        if(this.isFRA){
            if (!this.postalCode.match(this.labels.lbl_regex_cp_format)) {
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_error_exceptionnalAddress_cpFormat,
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
            else if(!this.addedInformations.match(this.labels.LU_Regex_Mobile_Format)){
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_Error_ExceptionnalAdrress_PhoneFormat,
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
            else if (this.lastName == '' || this.street == '' || this.postalCode == '' || this.city == '' || this.country == '' || this.addedInformations == '') {
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_Error_ExceptionnalAdrress_NotComplete,
                    variant: "error",
                });
                this.dispatchEvent(evt);
            }
            else {
                this.disabledNewAddressFields = true;
                this.updateCurrentOrder();
                this.displaySaveNewAdressButton = false;
            }
        }
        else{
            if (this.lastName == '' || this.firstName == '' || this.street == '' || this.postalCode == '' || this.city == '' || this.country == '') {
            const evt = new ShowToastEvent({
                title: lbl_ErrorShipping,
                message: lbl_Error_ExceptionnalAdrress_NotComplete,
                variant: "error",
            });
            this.dispatchEvent(evt);
            } else {
                this.disabledNewAddressFields = true;
                this.updateCurrentOrder();
                this.displaySaveNewAdressButton = false;
            }
        }
        
    }

    clickExternalMode() {
        if (this.displayExternal == false) {
            this.displayExternal = true;
            this.externalMode = true;
            this.displayNewAdressForm = false;
            this.currentAdress = false;
            this.newAdress = false;
        } else {
            this.displayExternal = false;
            this.externalMode = false;
            this.displayNewAdressForm = false;
            this.currentAdress = true;
            this.newAdress = false;
        }
    }

    
    /* EVENTS HANDLER */
    
    setLastName(event){
        this.lastName = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setFirstName(event){
        this.firstName = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setStreet(event){
        this.street = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setStreetComplement(event){
        this.streetComplement = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setPostalCode(event){
        this.postalCode = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setCity(event){
        this.city = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setCountry(event){
        this.country = event.target.value;
        this.displaySaveNewAdressButton = true;
    }
    setAddedInformations(event){
        this.addedInformations = event.target.value;
        this.displaySaveNewAdressButton = true;
    }

    handleEvtOpen(value) {
        this.isOpen = value;
        if (value == true) {
            this.isSelectable = false;
            this.isOtherAddressSelectable = false;
            this.isExternalModeSelectable = false;
        } else {
            this.isSelectable = true;
            this.isOtherAddressSelectable = true;
            this.isExternalModeSelectable = true;
        }
    }


    handleExternalPointSelected(value) {
        console.log('>> external point selelcted shipping');
        console.log(value);
        this.externalPointSelected = JSON.parse(value);
    }

    handleExternalPointPhoneChange(value) {
        this.mobilephone = value;
    }

    saveShipping(event) {
        let isOk = true;

        // Checks
        // IF external, check that the point is selected
        if (this.externalMode) {

            if (this.externalPointSelected == null || this.mobilephone == "") {
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_Error_ExternalPoint_NoSelected,
                    variant: "error",
                });
                this.dispatchEvent(evt);
                isOk = false;
            }
            else if(!this.mobilephone.match(this.labels.LU_Regex_Mobile_Format)){
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_Error_ExceptionnalAdrress_PhoneFormat,
                    variant: "error",
                });
                this.dispatchEvent(evt);
                isOk = false;
            }
        } 

        // If exceptionnal address
        if (this.newAdress) {
            if (this.lastName == '' || this.firstName == '' || this.street == '' || this.postalCode == '' || this.city == '' || this.country == '') {
                const evt = new ShowToastEvent({
                    title: lbl_ErrorShipping,
                    message: lbl_Error_ExceptionnalAdrress_NotComplete,
                    variant: "error",
                });
                this.dispatchEvent(evt);
                isok = false;
            }
        }

        if (isOk) {
            // Save choice on order
            this.updateCurrentOrder();
        }

    }
}