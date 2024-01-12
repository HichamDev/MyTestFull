import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

import getProductListOfBundle from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getProductListOfBundle';
import updateBundleProduct from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.updateBundleProduct';
import getOrderItemsOfBundle from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getExistingOrderItemsOfBundle';
import getOrderStatus from '@salesforce/apex/lwc70_order_detail_basket_view_Ctrl.getOrderStatusFromOrderItem';

import lbl_bundle_title from '@salesforce/label/c.LU_Basket_Bundle_Selection_Title';
import lbl_bundle_cancel from '@salesforce/label/c.LU_Basket_Bundle_Selection_Cancel';
import lbl_bundle_save from '@salesforce/label/c.LU_Basket_Bundle_Selection_Save';
import lbl_Bundle_Txt from '@salesforce/label/c.LU_Basket_Bundle_Txt';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_bundlemaxnotreaded from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityNotReached';
import lbl_bundlemaxreaded from '@salesforce/label/c.LU_Basket_Bundle_MaxQuantityReached';
import lbl_childmaxreached from '@salesforce/label/c.LU_Basket_Child_MaxQuantityReached';

import lbl_bundle_choose from '@salesforce/label/c.LU_Basket_Bundle_Choose_Button';

export default class Lwc80_order_detail_basket_view_bundle extends LightningElement {

    /* LABELS */
    labels = {
        lbl_bundle_title,
        lbl_bundle_cancel,
        lbl_bundle_save,
        lbl_bundle_choose,
        lbl_Bundle_Txt,
        lbl_Close,
        lbl_bundlemaxreaded, 
        lbl_bundlemaxnotreaded,
        lbl_childmaxreached
    }

    @track isBundle = false;
    @track isClosedBundle = false;
    @track idOrderItem;
    @track bundleTxt;
    @track bundleNbArticles;
    @track isValidated = true;//Modification suite bug challenges
    @track isDraft = false;

    @api line
    @api ischall;
    @api isfra = false;
    @api isita = false;

    @track m_productInModal = new Map();
    @track isModalOpen = false;

    connectedCallback(){

        if(this.line.Product2.RecordType.DeveloperName === 'LU_Bundle'){

            registerListener('lwc80_refresh', this.handleOrderLineQuantityUpdate, this);

            this.isBundle = true;
            this.idOrderItem = this.line.Id;

            if (this.line.Product2.LU_Bundle_Type__c == 'CloseSet') {
                this.isClosedBundle = true;
            }

            // Get bundle status
            this.bundleNbArticles = this.line.Product2.LU_Number_Of_Articles__c * this.line.Quantity;

            getOrderStatus({idOrderItem : this.idOrderItem})
            .then(results => {
                if(results === "Draft"){
                    this.isDraft = true;
                }
            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.log(error);
            });

            getProductListOfBundle({idOrderItem : this.idOrderItem})
            .then(results => {

                var l_productInModal = JSON.parse(results);
                this.m_productInModal = new Map();

                getOrderItemsOfBundle( {idOrderItem : this.idOrderItem})
                .then(existingLines => {
                    for (let p of l_productInModal) {

                        if(!this.ischall){
                            // Check if the children is a close set
                            if (p.isReadOnly) {
                                p.quantity = p.minQuantity * this.line.Quantity;
                            }
            
                            if(!p.isSelectable){
                                p.quantity = p.maxQuantity * this.line.Quantity;
                            }

                            // if(p.stockAvailable < 0 || p.stockAvailable === 0){
                            //     p.isReadOnly = true;
                            // }
                        }
                        
                        if (existingLines != null && existingLines.length > 0) {
                            for (let orderLine of existingLines) {                                
                                if (p.productId == orderLine.LU_Child_Product__c) {
                                    p.quantity = orderLine.Quantity;
                                    break;
                                }
                            }
                        }

                        this.m_productInModal.set(p.productId, p);
                    }

                    this.calculateStatus(true);

                })
                .catch(error => {
                    console.log('>>>> error lwc16_orderhomebasket:');
                    console.error(error);
                });

                
            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.log(error);
            });

        }
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
	}

    showBundlePopUp() {

        this.bundleNbArticles = this.line.Product2.LU_Number_Of_Articles__c * this.line.Quantity;

        this.bundleTxt = this.labels.lbl_Bundle_Txt;
        this.bundleTxt = this.bundleTxt.replace('$REF', this.line.Product2.Name);
        this.bundleTxt = this.bundleTxt.replace('$QUANTITYTOCHOOSE ', this.bundleNbArticles + ' ');

        getProductListOfBundle({idOrderItem : this.idOrderItem})
        .then(results => {

            var l_productInModal = JSON.parse(results);
            this.m_productInModal = new Map();

            getOrderItemsOfBundle( {idOrderItem : this.idOrderItem})
            .then(existingLines => {

                for (let p of l_productInModal) {
                     // Check if the children is a close set
                    if (p.isReadOnly) {
                        p.quantity = p.minQuantity * this.line.Quantity;
                    }
    
                    if(!p.isSelectable){
                        p.quantity = p.maxQuantity * this.line.Quantity;
                    }

                    // if(p.stockAvailable < 0 || p.stockAvailable === 0){
                    //     p.isReadOnly = true;
                    // }
                    
                    if (existingLines != null && existingLines.length > 0) {

                        for (let orderLine of existingLines) {
                            if (p.productId == orderLine.LU_Child_Product__c) {
                                p.quantity = orderLine.Quantity;
                                break;
                            }
                        }
                    }

                    this.m_productInModal.set(p.productId, p);
                }
    
                this.isModalOpen = true;

            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.error(error);
            });

            
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });
    }
    
    closeBundlePopUp(){
        this.isModalOpen = false;
        this.calculateStatus(true);
    }

    handleOrderLineQuantityUpdate(value) {
        console.log('>>handleOrderLineQuantityUpdate');
        if(value == this.idOrderItem && value != null){
            getProductListOfBundle({idOrderItem : this.idOrderItem})
            .then(results => {

                var l_productInModal = JSON.parse(results);
                this.m_productInModal = new Map();

                getOrderItemsOfBundle( {idOrderItem : this.idOrderItem})
                .then(existingLines => {
                    for (let p of l_productInModal) {
                        // Check if the children is a close set
                        if (p.isReadOnly) {
                            p.quantity = p.minQuantity * this.line.Quantity;
                        }
        
                        if(!p.isSelectable){
                            p.quantity = p.maxQuantity * this.line.Quantity;
                        }

                        // if(p.stockAvailable < 0 || p.stockAvailable === 0){
                        //     p.isReadOnly = true;
                        // }
                        
                        if (existingLines != null && existingLines.length > 0) {
                            for (let orderLine of existingLines) {                                
                                if (p.productId == orderLine.LU_Child_Product__c) {
                                    p.quantity = orderLine.Quantity;
                                    break;
                                }
                            }
                        }

                        this.m_productInModal.set(p.productId, p);
                    }

                    this.calculateStatus(true);

                })
                .catch(error => {
                    console.log('>>>> error lwc16_orderhomebasket:');
                    console.error(error);
                });

                
            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.log(error);
            });
        }
    }

    calculateStatus(commit) {
        console.log('>>calculateStatus');
        let bundleTotalQuantity = 0;
        this.bundleNbArticles = this.line.Product2.LU_Number_Of_Articles__c * this.line.Quantity;
        
        for (let x of this.m_productInModal.values()) {
            let qtyLine = 0;
            qtyLine = parseInt(x.quantity);
            bundleTotalQuantity += qtyLine;
        }

        console.log("this.line : ");
        console.log(this.line);

        if (bundleTotalQuantity != this.bundleNbArticles && ( !this.isfra || !this.isClosedBundle )) {
            const evt = new ShowToastEvent({
                title: this.labels.lbl_bundlemaxnotreaded,
                message: this.line.Product2.LU_Local_Code__c + ' - ' + this.line.Product2.Name,
                variant: "warning",
            });
            this.dispatchEvent(evt);
            if (commit)
                this.isValidated = false;
            return false;
        } 
        else {
            if (commit)
                this.isValidated = true;
            return (true);
        }
    }

    updateAmountInBundle(event){

        let productId = event.target.dataset.item;
        let product = this.m_productInModal.get(productId);
        let bundleTotalQuantity = 0;

        console.log("product.stockAvailable");
        console.log(product.stockAvailable);
        console.log("event.target.value");
        console.log(event.target.value);

        if(product.stockAvailable !== null && event.target.value > product.stockAvailable){
            const evt = new ShowToastEvent({
                title: this.labels.lbl_childmaxreached,
                message: "",
                variant: "warning",
            });
            this.dispatchEvent(evt);

            event.target.value = product.quantity;
            return;
        }
        
        for (let x of this.m_productInModal.values()) {

            let qtyLine = 0;

            if (product.productId === x.productId) {
                qtyLine = parseInt(event.target.value);
                
            } else {
                qtyLine = parseInt(x.quantity);
            }
            
            bundleTotalQuantity += qtyLine;
        }

        if (bundleTotalQuantity > this.bundleNbArticles && event.target.value > product.quantity) {
            
            const evt = new ShowToastEvent({
                title: this.labels.lbl_bundlemaxreaded,
                message: this.line.Product2.LU_Local_Code__c + ' - ' + this.line.Product2.Name,
                variant: "warning",
            });
            this.dispatchEvent(evt);

            event.target.value = product.quantity;
            return;
        }

        product.quantity = parseInt(event.target.value);

        this.m_productInModal.set(product.id, product);
    }

    saveBundle(){

        let res = this.calculateStatus(false);

        if (res) {
            updateBundleProduct({idOrderItem : this.idOrderItem, l_bundleProduct : Array.from(this.m_productInModal.values())})
            .then(results => {
                this.isModalOpen = false;
                this.isValidated = true;

                const evtCloseBundleModal = new CustomEvent('closebundlemodal', {});
                this.dispatchEvent(evtCloseBundleModal);
            })
            .catch(error => {
                console.log('>>>> error lwc16_orderhomebasket:');
                console.log(error);
            });
        }
        
    }
}