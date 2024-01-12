import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

/* IMPORT LABELS */
import lbl_OrderNew  from '@salesforce/label/c.LU_Order_New';
import lbl_OrderNew_alreadyDraft from '@salesforce/label/c.LU_OrderNew_AlreadyDraft';
import lbl_bad_debt_message from '@salesforce/label/c.LU_Order_New_BadDebpt_Message';
import lbl_Close from '@salesforce/label/c.LU_ContactSelection_Modal_Close';
import lbl_Postal_Payment from '@salesforce/label/c.LU_Postal_Payment';

/* IMPORT APEX */
import getUserCountry from '@salesforce/apex/LWC01_ListView_Ctrl.getUserCountry';
import getUrlPageOrder from '@salesforce/apex/lwc41_Order_New_Ctrl.getOrderPageCurrentUser';
import getIsContentieux from '@salesforce/apex/lwc41_Order_New_Ctrl.getIsContentieux';
import getDraftOrder from '@salesforce/apex/lwc66_current_order_summary_ctrl.getDraftOrder';
import sendPostalPaymentEmail from '@salesforce/apex/lwc93_postal_payment_ctrl.sendPostalPaymentEmail';

export default class Lwc41_Order_New extends NavigationMixin(LightningElement) {

    /* VARIABLES */
    pageUrl = '';

    @track isContentieux = false;
    @track displayButton = false;
    @track isITA = false;
    @track amount = 0;
    @track displayPopUp = false;

    @api buttonLabel = "Paga con bollettino 896";

    /* LABELS */
    labels = {
        lbl_OrderNew,
        lbl_OrderNew_alreadyDraft,
        lbl_Close,
        lbl_Postal_Payment
    }

    label_bad_debt_message = lbl_bad_debt_message.split("#RETURN");

    /* INIT */
    connectedCallback() {

        getUrlPageOrder() 
            .then(pURL => {
                console.log('>>pURL');
                console.log(pURL);
                this.pageUrl = pURL;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getIsContentieux() 
            .then(result => {
                this.isContentieux = result;
                this.displayButton = true;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getUserCountry()
        .then(results => {
            if (results === 'ITA') this.isITA = true;
            else isITA = false; 
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    /* EVENTS */
    handleClickButtonNew(event) {
        getDraftOrder()
        .then(order => {
            console.log('lwc41 >> order found ?');
            console.log(order != null || order != undefined);
            if((order != null || order != undefined) && this.isITA == true){
                alert(lbl_OrderNew_alreadyDraft);
            }
            else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: this.pageUrl,
                    }
                });
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    handleClickButton(){
        this.displayPopUp = true;
    }

    handleSendEmail(){
        this.buttonDisabled = true;

        sendPostalPaymentEmail({amount : this.amount})
            .then(results => {

                console.log(results);

                if(results !== "OK"){
                    const evtError = new ShowToastEvent({
                        title: this.label.lbl_Error_Title,
                        message: 'Error',
                        variant: 'error'
                    });
                    this.dispatchEvent(evtError);

                    this.displayPopUp = false;
                }
                else{
                    // Display a success message
                    const evt = new ShowToastEvent({
                        title: "Grazie per aver utilizzato il servizio di bollettino self-service. Riceverai a breve sul tuo indirizzo email copia del bollettino generato con l’importo da te indicato",
                        variant: "success"
                    });
                    this.dispatchEvent(evt);

                    this.displayPopUp = false;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    handlechangeAmount(event){
        this.amount = event.target.value;
    }

    handleClosePopUp(){
        this.displayPopUp = false;
    }
}