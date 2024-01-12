import {LightningElement, track} from 'lwc';
import pageUrl from '@salesforce/resourceUrl/reCaptchav3';
import RecaptchaHandler from '@salesforce/apex/RecaptchaHandler.isReCAPTCHAValid';

export default class reCaptchaLWC extends LightningElement {

    formToken;
    validReCAPTCHA;

    @track navigateTo;

    constructor(){
        console.log("abc");
        super();
        this.navigateTo = pageUrl;
    }

    captchaLoaded(evt){
        let self = this;
        var e = evt;
        console.log(e.target.getAttribute('src') + ' loaded');
        if(e.target.getAttribute('src') == pageUrl){

            window.addEventListener("message", function(e) {
                if (e.data.action == "getCAPCHA" && e.data.callCAPTCHAResponse == "NOK"){
                    console.log("Token not obtained!")
                } else if (e.data.action == "getCAPCHA" ) {
                    console.log(e.data);
                    this.formToken = e.data.callCAPTCHAResponse;
                    RecaptchaHandler({tokenFromClient: e.data.callCAPTCHAResponse}).then(data => {
                        this.validReCAPTCHA = data;
                    console.log('received result from RecaptchaHandler. Value = '+this.validReCAPTCHA);
                        try {self.createEvent(data)}
                        catch (error) {
                            console.log(error);
                        }
                    });
                }
            }, false);
        }
    }

    createEvent(data){
        console.log('creating message for parent');
        const captchaResponse = new CustomEvent('captchareceived', {
            detail: {
                data: data
            }
        });
        this.dispatchEvent(captchaResponse);
    }
}