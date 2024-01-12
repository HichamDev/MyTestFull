import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import ALL_GACodes from '@salesforce/label/c.ALL_GACodes';

export default class Lwc84_push_banner extends NavigationMixin(LightningElement) {

    @api externalId;
    @api imageUrl;
    @api title;
    @api description;
    @api textLink;
    @api isOnOrderBasket = false;

    @wire(CurrentPageReference) pageRef; // Required by pubsub

    pushProduct(event){
        if(this.isOnOrderBasket){
            fireEvent(this.pageRef, 'lwc83_pushProduct', this.externalId);
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'order-home'
                },
                state : {
                    "push" : this.externalId
                }
            })
        }
    }
}