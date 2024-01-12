import { LightningElement, wire, track, api } from 'lwc';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* APEX */
import getPushedProducts from '@salesforce/apex/lwc83_push_product_ctrl.getPushedProducts';
import product_add from '@salesforce/label/c.LU_Challenge_Add';
import { CurrentPageReference } from 'lightning/navigation';
import {addPushProductToSelection} from 'c/lwc16_orderhome_basket'

export default class Lwc88_offer_products extends LightningElement {
    @api isFRA;
    @api isITA;
    @api productGroupToDisplay;
    @track l_pushedOfferProducts;
    @track country;
    @track redirectToOrderHome;
    @track isLoading = true;

    // Expose the labels to use in the template.
    label = {
        product_add
    };


    @wire(CurrentPageReference) pageRef;
    connectedCallback(){
        registerListener('showLoading88', this.showLoading, this);
        registerListener('hideLoading88', this.hideLoading, this);
        
        this.isLoading = false;
        if(this.isFRA){
            this.country = 'FRA';
        } else if(this.isITA){
            this.country = 'ITA';
        }
        
        getPushedProducts({country : this.country, productGroup : this.productGroupToDisplay})
        .then(results => {
            this.l_pushedOfferProducts = results;
        })
        .catch(error => {
            console.log('>>>> error lwc88_orderhomebasket:');
            console.log(error);
        });

        //if we are on order-checkout page we don't want to redirect after "add a product"
        if(location.href.search('order-checkout') != -1){
            this.redirectToOrderHome=false;
        }
        else{
            this.redirectToOrderHome=true;
        }
    }

    showLoading(whatToDo) {
        this.isLoading = true;
    }

    hideLoading(whatToDo) {
        this.applyTimeout = setTimeout(() => {
                // Send search event if search term is long enougth
                if(this.isFRA){
                    const evt = new ShowToastEvent({
                        title: 'Votre panier a bien été mis à jour',
                        variant: "success"
                    });
                    this.dispatchEvent(evt);
                }
                this.isLoading = false;
                this.applyTimeout = null;
            },
            1000 //1 secondes
        );
    }

    addDirectlyToBasket(event){
        this.isLoading = true;
        console.log(event.target.value);
        fireEvent(this.pageRef, 'lwc88_pushProduct', event.target.value);
        
        if(event.target.dataset.bundleType == 'OpenSet') {
            fireEvent(this.pageRef, 'ShowProductSelection', event.target.value);
            setTimeout(() => {this.isLoading = false;}, 2000); //2 secondes
        } else {
            this.applyTimeout = setTimeout(() => {
                    // Send search event if search term is long enougth
                    if(this.isFRA){
                        const evt = new ShowToastEvent({
                            title: 'Votre panier a bien été mis à jour',
                            variant: "success"
                        });
                        this.dispatchEvent(evt);
                    }
                    this.isLoading = false;
                    this.applyTimeout = null;
                },
                3000 //3 secondes
            );
        }

    }

}