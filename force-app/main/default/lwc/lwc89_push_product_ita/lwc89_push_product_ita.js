import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* APEX */
import getUserContactTitle from '@salesforce/apex/LWC26_OrderHome_SelectContact_Ctrl.getUserContactTitle';
import getPushedProducts from '@salesforce/apex/lwc83_push_product_ctrl.getPushedProductsITA';
import getCurrentOrder from '@salesforce/apex/lwc83_push_product_ctrl.getCurrentOrderType';

/* CUSTOM LABELS */
import lbl_push_product_title from '@salesforce/label/c.LU_Push_Product_Title';
import lbl_push_product_button_label from '@salesforce/label/c.LU_Push_Product_Button_Label';
import lbl_push_product_button_label_for_me from '@salesforce/label/c.LU_Push_Product_Button_Label_For_Me';
import lbl_push_product_button_label_to_sell from '@salesforce/label/c.LU_Push_Product_Button_Label_To_Sell';
import lbl_catalog_personal_use from '@salesforce/label/c.LU_Offer_Type_PersonalUse';
import lbl_order_popin_not_personal_use from '@salesforce/label/c.LU_OrderPopinNotPersoUse';
import lbl_order_popin_error_not_personal_use from '@salesforce/label/c.LU_OrderPopinErrorNotPersoUse';
import lbl_order_popin_error_not_for_sale from '@salesforce/label/c.LU_OrderPopinErrorNotForSale';
import lbl_Close from '@salesforce/label/c.LU_ContactSelection_Modal_Close';

export default class Lwc89_push_product_ita extends NavigationMixin(LightningElement) {
    rebate_job_title = 'Stanlover';

    @track l_pushedProducts;
    @track country = "ITA";
    @api isOnOrderBasket = false;
    @api productGroupToDisplay = "";

    @track displayComponent = false;

    @track nbSlides = 1;
    @track is2pagesMinimum = false;
    @track is3pagesMinimum = false;
    @track preLastPage = "";
    @track l_pages = [];
    @track l_carrouselArrows = [];

    @track selectedCatalog = null;
    @track displayPopupErrorPersonalUse = false;
    @track orderPopinNotPersonalUse = '';

    @track isSCorGSC = false;
    @track orderType = null;

    labels = {
        lbl_push_product_title,
        lbl_push_product_button_label,
        lbl_catalog_personal_use,
        lbl_order_popin_not_personal_use,
        lbl_Close,
        lbl_push_product_button_label_for_me,
        lbl_push_product_button_label_to_sell,
        lbl_order_popin_error_not_personal_use,
        lbl_order_popin_error_not_for_sale
    };

    @wire(CurrentPageReference) pageRef; // Required by pubsub
    connectedCallback(){
        registerListener('catalogChange', this.setCurrentCatalog, this);
        registerListener('pushProductDirectly', this.pushProduct, this);
        registerListener('updatedBasket', this.handleSelectionChange, this);

        getCurrentOrder()
            .then(resultOrderType => {
                this.orderType = resultOrderType;
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });
            
        getUserContactTitle()
            .then(resultTitle => {
                if(resultTitle === "Sales Consultant" || resultTitle === "Group Sales Consultant"){
                    this.isSCorGSC = true;
                }
                else if(resultTitle !== "Smile" && resultTitle !== this.rebate_job_title){
                    return;
                }

                getPushedProducts({country : this.country, contactTitle : resultTitle})
                    .then(results => {

                        console.log('pushed product lwc83 successful');
                        this.l_pushedProducts = results;

                        if(results.length > 0){
                            this.nbSlides = Math.floor(((results.length - 1) / 3)) + 1;

                            if(this.nbSlides > 1){
                                this.is2pagesMinimum = true;

                                this.preLastPage = "carousel-slide-activator-" + (this.nbSlides - 1);

                                for(let i = 2; i <= this.nbSlides; i++){
                                    this.l_pages.push("carousel-slide-activator-" + i);
                                }
                            }
                            if(this.nbSlides > 2){
                                this.is3pagesMinimum = true;

                                for(let i = 2; i < this.nbSlides; i++){
                                    this.l_carrouselArrows.push({pre : "carousel-slide-activator-" + (i - 1), next : "carousel-slide-activator-" + (i + 1)});
                                }
                            }

                            this.displayComponent = true;
                        }
                    })
                    .catch(error => {
                        console.log('>>>> error lwc83_orderhomebasket:');
                        console.log(error);
                    });

            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });

    }
	disconnectedCallback() {
		unregisterAllListeners(this);
    }

    pushProduct(event){
        console.log('pushProduct event', event);
        if(this.isOnOrderBasket){
            console.log('fire event ' + event.target.value );
            fireEvent(this.pageRef, 'lwc83_pushProduct', event.target.value);
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'order-home'
                },
                state : {
                    "push" : event.target.value
                }
            })
        }
    }

    pushProductForMe(event){
        if (this.selectedCatalog === null && this.orderType === null){
            this.pushProduct(event);
        }
        else if(this.orderType !== null){
            if(this.orderType !== this.labels.lbl_catalog_personal_use || this.selectedCatalog !== this.labels.lbl_catalog_personal_use && this.selectedCatalog !== null){

                this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_error_not_personal_use;
    
                this.displayPopupErrorPersonalUse = true;
            }
            else{
                this.pushProduct(event);
            }
        }
        else if(this.selectedCatalog !== this.labels.lbl_catalog_personal_use){

            this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_error_not_personal_use;

            this.displayPopupErrorPersonalUse = true;
        }
        else{
            this.pushProduct(event);
        }
    }

    pushProductToSell(event){
        if (this.selectedCatalog === null && this.orderType === null){
            this.pushProduct(event);
        }
        else if(this.orderType !== null){
            if(this.orderType === this.labels.lbl_catalog_personal_use || this.selectedCatalog === this.labels.lbl_catalog_personal_use){
                
                this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_error_not_for_sale;

                this.displayPopupErrorPersonalUse = true;
            }
            else{
                this.pushProduct(event);
            }
        }
        else if(this.selectedCatalog === this.labels.lbl_catalog_personal_use){

            this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_error_not_personal_use;

            this.displayPopupErrorPersonalUse = true;
        }
        else{
            this.pushProduct(event);
        }
    }

    // Event - Lookup selection changes
    handleSelectionChange(selection) {
        console.log("selection selection selection selection selection selection selection selection selection selection ");
        console.log(selection);
        if (selection) {
            for(let [k, v] of selection){
                this.orderType = v.offerType;
                return;
            }
            getCurrentOrder()
            .then(resultOrderType => {
                this.orderType = resultOrderType;
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });
        }
    }

    closePopupError(){
        this.displayPopupErrorPersonalUse = false;
    }

    setCurrentCatalog(data){
        this.selectedCatalog = data;
    }
}