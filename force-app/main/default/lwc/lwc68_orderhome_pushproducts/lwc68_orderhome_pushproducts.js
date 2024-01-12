import { LightningElement, track } from 'lwc';

/* IMPORT METHODS */
import { fireEvent, registerListener, unregisterAllListeners } from 'c/pubsub';

/* IMPORT APEX METHODS */
import getPriceBookEntry from '@salesforce/apex/lwc68_orderhome_pushproducts_ctrl.getPriceBookEntry';
import getUserInfo from '@salesforce/apex/lwc68_orderhome_pushproducts_ctrl.getUserInformation';

/* IMPORT CUSTOM LABELS */
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Title from '@salesforce/label/c.LU_Push_Popup_Title';
import lbl_text_success from '@salesforce/label/c.LU_Push_Popup_Text_Success';
import lbl_text_error from '@salesforce/label/c.LU_Push_Popup_Text_Error';


export default class Lwc68_orderhome_pushproducts extends LightningElement {

    /* LABELS */
    labels = {
        lbl_Close,
        lbl_Title
    }

    /* VARIABLES */
    @track openPopupPush = false;
    @track isLoading = false;
    @track txtResult = '';
    @track lOffers = null;
    @track isITA = false;


    /* INIT */
    connectedCallback() {
        
        let parameters = this.getQueryParameters();
        
        if(parameters.push !== undefined && parameters.push !== ""){
            
            this.openPopupPush = true;
            this.isLoading = true;
            
            getUserInfo()
                .then(userInfo => {
                    if (userInfo != null) {
                        if (userInfo.AccountCountryCode__c == 'ITA') {
                            this.isITA = true;
                        }
                    }                  
                    
                    getPriceBookEntry( { pbeId : parameters.push } )
                        .then(results => {
                            console.log('>>> getPriceBookEntry results:');
                            console.log(results);
                            this.lOffers = results;
                            
                            fireEvent(this.pageRef, 'lwc68_orderhome_pushproducts', results);

                        })
                        .catch(error => {
                            console.log('>>>> error Lwc68_orderhome_pushproducts :');
                            console.log(error);
                            this.isLoading = false;
                        }
                    );

                })
                .catch(error => {
                    console.log('>>>> error Lwc68_orderhome_pushproducts :');
                    console.log(error);
                    this.isLoading = false;
                }
            );
            
        }

        registerListener('lwc16_orderhome_basket_PushProductResult', this.handleDisplayResultOfPush, this);
    }
    disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }


    /* UTILITY METHODS */
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


    /* EVENTS HANDLE */
    handleClosePopupPush(event) {
        this.openPopupPush = false;

        if (this.isITA) {
            fireEvent(this.pageRef, 'orderHomeContactSelectionToBeOpened', null);
        }
        
    }

    handleDisplayResultOfPush(result) {
        console.log('>> handleDisplayResultOfPush :' + result);

        if (result == 'success') {
            this.txtResult = lbl_text_success;
            this.openPopupPush = false;
            if (this.isITA) {
                fireEvent(this.pageRef, 'orderHomeContactSelectionToBeOpened', null);
            }
        } else {
            this.txtResult = lbl_text_error;
            this.isLoading = false;
        }
    }

}