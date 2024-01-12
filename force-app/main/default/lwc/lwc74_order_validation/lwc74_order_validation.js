import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* LABELS */
import lbl_validation from '@salesforce/label/c.LU_Ordervalidation_Confirmation';
import lbl_orderIsValidated from '@salesforce/label/c.LU_Ordervalidation_Order_Is_Validated';
import lbl_backHome from '@salesforce/label/c.LU_Ordervalidation_Back_Home';
import lbl_newOrder from '@salesforce/label/c.LU_Ordervalidation_New_Order';
import lbl_Stock_Info_On_The_Order from '@salesforce/label/c.LU_Ordervalidation_Stock_Order_Info';

/* APEX */
/* IMPORT APEX */
import getUrlPageOrder from '@salesforce/apex/lwc41_Order_New_Ctrl.getOrderPageCurrentUser';
import getOrderValidated from '@salesforce/apex/lwc74_order_validation.getOrderById';

export default class Lwc74_order_validation extends NavigationMixin(LightningElement) {

    orderConfirm = LogoBtn + '/icons/order-confirm.svg';

    labels = {
        lbl_validation,
        lbl_orderIsValidated,
        lbl_backHome,
        lbl_newOrder,
        lbl_Stock_Info_On_The_Order
    }

    @track idOrder;
    @track pageUrl = '';
    @track ord = null;
    @track strStock = null;

    connectedCallback() {

        getUrlPageOrder() 
        .then(pURL => {
            this.pageUrl = pURL;
        })
        .catch(error => {
            console.log('>>>> error lwc74:');
            console.error(error);
        });

        let parameters = this.getQueryParameters();

        if (parameters.orderId) {
            this.idOrder = parameters.orderId;

            getOrderValidated( { orderId : this.idOrder} )
            .then(currentOrder => {
                if (currentOrder) {
                    this.ord = currentOrder;
                    if (currentOrder.OrderItems != null && currentOrder.OrderItems.length > 0) {
                        let strStockTemp = '';
                        for (let cpt = 0; cpt < currentOrder.OrderItems.length; cpt++) {
                            if(currentOrder.LU_Country_Code__c != "ITA" || !currentOrder.OrderItems[cpt].LU_Child_Product__c || currentOrder.OrderItems[cpt].Product2.LU_Bundle_Type__c != "CloseSet"){
                                if (currentOrder.OrderItems[cpt].LU_Stock_Message__c != null && currentOrder.OrderItems[cpt].LU_Stock_Message__c != '') {
                                    
                                    strStockTemp = (strStockTemp != '' ? strStockTemp + ', ' : '') + currentOrder.OrderItems[cpt].Product2.LU_Local_Code__c + ' ' +
                                                                                                    currentOrder.OrderItems[cpt].Product2.Name + ' : ' + 
                                                                                                    currentOrder.OrderItems[cpt].LU_Stock_Message__c;
                                }
                            }
                        }
                        if (strStockTemp != '') {
                            this.strStock = strStockTemp;
                        }
                    }
                }
            })
            .catch(error => {
                console.log('>>>> error lwc74:');
                console.error(error);
            })

        }
    }

    backHome(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home',
            },
        });
    }

    newOrder(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.pageUrl,
            }
        });
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