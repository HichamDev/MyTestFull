import { LightningElement,api,track } from 'lwc';

import { fireEvent } from 'c/pubsub';

import lbl_url_captcha from '@salesforce/label/c.LU_Wishlist_Captcha_URL';

export default class Recaptcha extends LightningElement {
    @track navigateTo="/apex/portalSmartyAddress";
    @track _url="";
    @track _height="";
    @track data;
    
    @api
    get height() {
        return this._height;
    }

    set height(value) {
       this._height = value;
    }

    @api
    get url() {
        return this._url;
    }

    set url(value) {
       this._url = value;
    }

    @api
    getAddress() {
        return window.address;
    }
    
    @api
    getValue()
    {
       return window.data;
    }
    
    listenMessage(msg) 
    {
        window.data=msg.data;
        this.data=msg.data;
        if(this.data!=='Unlock')
        {
            window.address=msg.data
        }
        else{
            fireEvent(this.pageRef, 'captcha_validated', "");
        }
    }
    connectedCallback()
    {
        // this._url = window.location.origin + '/apex/VFP_Recaptcha.page';
        // this._url = 'https://lineupmig-mystancommunity.cs102.force.com/stanhomeinfo/apex/VFP_Recaptcha';
        this._url = lbl_url_captcha;

        if (window.addEventListener) {
            window.addEventListener("message", this.listenMessage, false);
        } else {
            window.attachEvent("onmessage", this.listenMessage);
        }
    }
}