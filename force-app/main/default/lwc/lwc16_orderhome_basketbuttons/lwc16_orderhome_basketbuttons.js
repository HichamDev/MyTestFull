import { LightningElement, track, wire, api } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* IMPORT APEX */
import getUserInfo from '@salesforce/apex/lwc16_orderhome_basketbuttons_ctrl.getUserInformation';
import getUserProfile from '@salesforce/apex/lwc16_orderhome_basketbuttons_ctrl.getUSerProfile';
import getAllConstants from '@salesforce/apex/lwc16_orderhome_basketbuttons_ctrl.getAllConstants';

/* IMPORT LABELS */
import lbl_basket_addtobasketcontinue from '@salesforce/label/c.LU_Basket_AddToBasket_Continue';
import lbl_basket_addtobasketorder from '@salesforce/label/c.LU_Basket_AddToBasket_Order';
import lbl_basket_gotoorder from '@salesforce/label/c.LU_Basket_Go_To_Order';
import { CurrentPageReference } from 'lightning/navigation';
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class Lwc16_orderhome_basketbuttons extends LightningElement {

    /* VARIABLES */
    iconShopping = LogoBtn + '/icons/icon-shopping.svg';

    /* LABELS */
    labels = {
        lbl_basket_addtobasketcontinue,
        lbl_basket_addtobasketorder,
        lbl_basket_gotoorder
    }

    @track isLoading = false;

    @track contact = null;
    @track isFRA = false;
    @track isITA = false;
    @api isShow;
    @track isdisplay;

    @track showBtnAddToBasketAndContinue = false;
   /*  @track showBtnAddToBasketAndGoToOrder = false;
    @track showBtnGoToOrder = false; */

    @track constants;

    @wire(CurrentPageReference) pageRef; // Required by pubsub

    @wire(getAllConstants) 
    allConstants ({error, data}) {
        if (data) {
            this.constants = data;
        }
    } 

    /* INIT */
    connectedCallback() {
        if(this.isShow) {
            this.isdisplay = 'display:block;';
        } else {
            this.isdisplay = 'display:none;';
        }
        
        registerListener('hideSpinner', this.hideSpinner, this);
        registerListener('hideCardComponent', this.hideCardComponent, this);
        registerListener('ShowProductSelection', this.displayProduct, this);
        registerListener('HideProductSelection', this.hideProduct, this);

        getUserInfo()
            .then(userInfo => {

                if (userInfo != null) {
                    if (userInfo.AccountCountryCode__c == 'FRA') {
                        this.isITA = false;
                        this.isFRA = true;
                    } else {
                        this.isITA = true;
                        this.isFRA = false;
                    }
                }
                
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getUserProfile()
        .then(userProfile => {
            /* if(userProfile == this.constants.ITA_PROFILE_SMILELOGIN || 
                    userProfile == this.constants.ITA_LU_SMILE_MEMBER || 
                    userProfile == this.constants.ITA_LU_MANAGER || 
                    userProfile == this.constants.ITA_LU_MANAGER) {
                this.showBtnAddToBasketAndGoToOrder = true;
            } else  */if(userProfile == this.constants.ITA_PROFILE_DEALERLOGIN ||
                    userProfile == this.constants.ITA_PROFILE_DEALERMANAGER ||
                    userProfile == this.constants.ITA_PROFILE_DEALERMEMBER) {
                this.showBtnAddToBasketAndContinue = true;
            }
            
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

    }

    displayProduct(nextStep) {
        this.isdisplay = 'display:block;';
    }
    hideProduct(nextStep) {
        this.isdisplay = 'display:none;';
    }

    hideCardComponent() {
        this.isdisplay = 'display:none;';
    }

	disconnectedCallback() {
		unregisterAllListeners(this);
    }


    /* EVENT METHODS */
   

    /* UI METHODS */
    addBasketContinue() {
        this.isLoading = true;
        fireEvent(this.pageRef, 'lwc16_addBasket', "continue");
    }

    addBasketContinueFRA() {
        this.isLoading = true;
        fireEvent(this.pageRef, 'lwc16_addBasket', "continue");
        //continue-popup-contact-opens
    }
    addBasketOrder() {
        this.isLoading = true;
        fireEvent(this.pageRef, 'lwc16_addBasket', "order");
    }

    goToOrder() {
        fireEvent(this.pageRef, 'lwc16_addBasket_go_to_order', "straighttoorder");
    }

    hideSpinner(){
        this.isLoading = false;
    }
}