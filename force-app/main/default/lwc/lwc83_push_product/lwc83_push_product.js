import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* APEX */
import getPushedProducts from '@salesforce/apex/lwc83_push_product_ctrl.getPushedProducts';

/* CUSTOM LABELS */
import lbl_push_product_title from '@salesforce/label/c.LU_Push_Product_Title';
import lbl_push_product_button_label from '@salesforce/label/c.LU_Push_Product_Button_Label';
import lbl_catalog_personal_use from '@salesforce/label/c.LU_Offer_Type_PersonalUse';
import lbl_order_popin_not_personal_use from '@salesforce/label/c.LU_OrderPopinNotPersoUse';
import lbl_Close from '@salesforce/label/c.LU_ContactSelection_Modal_Close';

export default class Lwc83_push_product extends NavigationMixin(LightningElement) {

    @track l_pushedProducts;
    @api isOnOrderBasket = false;
    @api country = "";
    @api productGroupToDisplay = "";

    @track orderId = "";

    @track nbSlides = 1;
    @track is2pagesMinimum = false;
    @track is3pagesMinimum = false;
    @track preLastPage = "";
    @track l_pages = [];
    @track l_carrouselArrows = [];

    @track selectedCatalog = "Regular";
    @track displayPopupErrorPersonalUse = false;
    @track orderPopinNotPersonalUse = '';

    labels = {
        lbl_push_product_title,
        lbl_push_product_button_label,
        lbl_catalog_personal_use,
        lbl_order_popin_not_personal_use,
        lbl_Close
    };

    @wire(CurrentPageReference) pageRef; // Required by pubsub
    connectedCallback(){
        registerListener('catalogChange', this.setCurrentCatalog, this);
        registerListener('pushProductDirectly', this.pushProduct, this);

        let parameters = this.getQueryParameters();

        if(parameters.orderId){
            this.orderId = parameters.orderId;
        }

        getPushedProducts({country : this.country, productGroup : this.productGroupToDisplay, orderId : this.orderId, isOnOrderBasket : this.isOnOrderBasket})
        .then(results => {
            console.log('country : '+ this.country  + ' - '+ typeof(this.country));
            console.log('productGroup : '+ this.productGroupToDisplay  + ' - '+ typeof(this.productGroupToDisplay));
            console.log('orderId : '+ this.orderId  + ' - '+ typeof(this.orderId));
            console.log('isOnOrderBasket : ' +this.isOnOrderBasket  + ' - '+ typeof(this.isOnOrderBasket));
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
            }
        })
        .catch(error => {
            console.log('>>>> error lwc83_orderhomebasket:');
            console.log(error);
        });
    }
	disconnectedCallback() {
		unregisterAllListeners(this);
    }

    pushProduct(event){
        console.log('pushProduct event', event);
        console.log(this.isOnOrderBasket + ' ' + event.target.value );
        if(this.selectedCatalog !== this.labels.lbl_catalog_personal_use && this.country === 'Italy' ){
            var vSubstituteProduct = event.target.dataset.value;
            if(vSubstituteProduct) {
                this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_not_personal_use.replace("{0}", event.target.dataset.value);
            } else {
                this.orderPopinNotPersonalUse = this.labels.lbl_order_popin_not_personal_use.replace("{0}", '');
            }

            this.displayPopupErrorPersonalUse = true;
        }
        else if(this.country === 'ITA'){
            console.log('fire event ' + event.target.value );
            const eventToFire = new CustomEvent('child'
            , {
                //Que des primitives dans les détails
                detail: {key1: 'lwc83, Id externe : ', key2: event.target.value}
            });
            this.dispatchEvent(eventToFire);
            // fireEvent(this.pageRef, 'lwc83_pushProduct', event.target.value);
        }
        else{
            if(this.isOnOrderBasket){
                fireEvent(this.pageRef, 'lwc83_pushProduct', event.target.value);
            }
            else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'order-home'
                    },
                    state : {
                        "push" : event.target.value.externalId
                    }
                })
            }
        }
    }

    closePopupError(){
        this.displayPopupErrorPersonalUse = false;
    }

    setCurrentCatalog(data){
        this.selectedCatalog = data;
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
}