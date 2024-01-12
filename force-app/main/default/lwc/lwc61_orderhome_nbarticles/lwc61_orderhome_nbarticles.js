import { LightningElement, track, wire, api } from 'lwc';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';

/* APEX */
import getUserInfo from '@salesforce/apex/lwc61_orerhome_nbarticles_ctrl.getUserInformation';
import getCurrentDraftOrderNb from '@salesforce/apex/lwc61_orerhome_nbarticles_ctrl.getArticleInCurrentDraftOrder';

import lbl_Title from '@salesforce/label/c.LU_Basket_Title';
import lbl_Nb from '@salesforce/label/c.LU_Basket_NB_Articles';

import {addPushProductToSelection} from 'c/lwc16_orderhome_basket'

export default class Lwc61_orderhome_nbarticles extends LightningElement {

    iconShopping = LogoBtn + '/icons/cart.svg';
    iconBoxOrder = LogoBtn + '/icons/icon-boxOrder.svg';
    
    labels = {
        lbl_Title,
        lbl_Nb
    }

    @track totalArticle = 0;
    @track totalHT = 0;
    @track contact = null;
    @track isITA = false;
    @track isFRA = false;
    @track orderIdFromUrl;

    @api showOrderInfos;
    @track showOrderInfosBool;

    @wire(CurrentPageReference) pageRef;

    connectedCallback() {
        if(this.showOrderInfos == true) this.showOrderInfosBool = true;
        else this.showOrderInfosBool = false;

        registerListener('updateArticleCount', this.updateTotal, this);
        // EVENT : Subscribe to contact selection on the popup
        registerListener('orderHomeContactSelected', this.handleContactSelection, this);
        registerListener('lwc83_pushProduct', addPushProductToSelection, this);
        this.parameters = this.getQueryParameters();
        for (let key in this.parameters) {
            if (key === 'orderId') {
                this.orderIdFromUrl = this.parameters[key];
            }
        }

        console.log('xxxxx URL PARAMS xxxxx' , this.parameters);
        this.calculateNbArticleCurrentDraftOrder();
        getUserInfo()
            .then(userInfo => {
                if (userInfo != null) {
                    this.contact = userInfo;
                    if (this.contact.AccountCountryCode__c == 'ITA') {
                        this.isITA = true;
                        this.isFRA = false;
                    } else {
                        this.isITA = false;
                        this.isFRA = true;
                    }
                }
                this.calculateNbArticleCurrentDraftOrder();
            })
            .catch(error => {
                console.log('>>>> error Lwc61_orderhome_nbarticles :');
                console.error(error);
            }
        );
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
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

    navigateToOrder() {
        console.log('navigateToOrder ', this.pageRef)
        fireEvent(this.pageRef, 'lwc16_addBasket_go_to_order', "straighttoorder");
    }

    // Contact selection handle
    handleContactSelection(value) {
        console.log('handleContactSelection ')
        this.contact = value.contact;
        
        /* if (this.isFRA) { */
            this.calculateNbArticleCurrentDraftOrder();
        /* } */
    }

    calculateNbArticleCurrentDraftOrder() {
        console.log('calculateNbArticleCurrentDraftOrder ')
        if (this.contact != null) {
            getCurrentDraftOrderNb( { contactId : this.contact.Id, orderId : this.orderIdFromUrl } )
                .then(vOrder => {
                    console.log('getCurrentDraftOrderNb', vOrder);
                    console.log('getCurrentDraftOrderNb : orderId', this.orderIdFromUrl);
                    if(vOrder != null){
                        // if (this.isFRA) {
                            console.log('calculateNbArticleCurrentDraftOrder 61', event)
                            this.totalArticle = vOrder.LU_Number_Of_Articles__c;
                            this.totalHT = this.isFRA ? vOrder.LU_Total_Amount_For_Valid_Base__c : vOrder.LU_Total_Amount_To_Pay__c;
                        // }

                        const selectedEvent = new CustomEvent('ordertype', { detail: vOrder.Type });
                        this.dispatchEvent(selectedEvent);

                        console.log(this.totalArticle);
                        console.log(this.totalHT);
                    } else {
                        const selectedEvent = new CustomEvent('ordertype', { detail: 'LineUp' });
                        this.dispatchEvent(selectedEvent);
                    }
                })
                .catch(error => {
                    console.log('>>>> error lwc61_orderhome_nbarticles :');
                    console.error(error);
                }
            );
        }
    }

    updateTotal(event) {
        console.log('updateTotal ', event);
        //Modif JJE 12/08/2021 T1716
        // if (this.isITA) {
        //     this.totalArticle = event;
        // } else {
            this.calculateNbArticleCurrentDraftOrder();
        // }       
    }

}