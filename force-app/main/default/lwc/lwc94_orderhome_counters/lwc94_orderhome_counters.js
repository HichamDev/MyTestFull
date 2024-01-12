import { LightningElement,track } from 'lwc';

/* APEX METHODS */
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import getHasDraftOrder from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getHasDraftOrder';
import getCounters from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getCountersByCategory';
import getUserCountry from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getUserCountry';

/* LABELS */
import lbl_Counters_SMARTS from '@salesforce/label/c.Counters_SMARTS';
import lbl_Counters_PTS_HOTESSE from '@salesforce/label/c.Counters_PTS_HOTESSE';


export default class Lwc94_orderhome_counters extends LightningElement {
    @track m_counters = new Map();
    @track l_counterCategories = [];
    @track l_cat = [];
    @track idContact = null;
    @track isModalOpened = false;
    @track isChartGenerated = false;
    @track displayComponent = false;
    @track modalCategory = null;
    @track hasDraftOrders = false;
    @track displayInfoMessage = false;
    @track infoMessage = '';
    @track isFRA = false;
    @track smartPTS = 0;
    @track hotesse = 0;
    @track smartPTSDesc = '';
    @track hotesseDesc = '';
    @track smartPTSDisplayInfoMessage = false;
    @track hotesseDisplayInfoMessage = false;

    labels = {
        lbl_Counters_SMARTS,
        lbl_Counters_PTS_HOTESSE
    }


    connectedCallback() {
        registerListener('updateLoyalty', this.updateCounters, this);

        registerListener('orderHomeContactSelected', this.updateContact, this);

        getHasDraftOrder()
            .then(results => {
                console.log('##################################lwc94')
                this.hasDraftOrders = results;
            })
        .catch(error => {
            console.log('>>>> error lwc94_orderhome_counters:');
            console.log(error);
        });

        getCounters()
            .then(results => {
                console.log('>>> lwc94: getCounters 1');
                console.log('>>> COUNTERS: ');
                console.log(results);
                // await new Promise(r => setTimeout(r, 3000));
                // this.l_counterCategories = results.filter( category => (category.name === '1. Comptes'));
                this.infoMessage = '';
                results.forEach((category) => {
                    if(category.name === 'Comptes') {
                        console.log(category.l_counters);
                        category.l_counters.forEach((counter) => {
                            if (counter.id == 'counter1') {
                                this.smartPTS = counter.currentOrderValue;
                                this.smartPTSDesc= counter.description;
                                if (counter.description != null && counter.description != '') {
                                    this.infoMessage += (this.infoMessage != '' ? ',' : '') + counter.description;
                                    this.smartPTSDisplayInfoMessage = true;
                                }
                            } else if (counter.id == 'counter2') {
                                this.hotesse = counter.currentOrderValue;
                                this.hotesseDesc = counter.description
                                if (counter.description != null && counter.description != '') {
                                    this.infoMessage += (this.infoMessage != '' ? ',' : '') + counter.description;
                                    this.hotesseDisplayInfoMessage = true;
                                }
                            }
                        });
                    }
                });

                if (this.displayInfoMessage) {
                    const evt = new ShowToastEvent({
                        message: this.infoMessage,
                        variant: "info",
                    });
                    this.dispatchEvent(evt);
                }
                console.log("Smart PTS 2: " + this.smartPTSDesc);
                console.log("Hôtesse 2: " + this.hotesseDesc);
                if(this.l_counterCategories.length > 0){
                    this.displayComponent = true;
                }
            })
        .catch(error => {
            console.log('>>>> error lwc94_orderhome_counters :');
            console.log(error);
        });

        getUserCountry()
            .then(results => {
                if(results === 'FRA'){
                    this.isFRA = true;
                }
            })
        .catch(error => {
            console.log('>>>> error lwc94_orderhome_counters :');
            console.log(error);
        });
    }
	disconnectedCallback() {
		// unsubscribe from events
		unregisterAllListeners(this);
    }

    updateContact(event){

        if (event.contact != null) {
            this.idContact = event.contact.Id;
        }
//        this.idContact = event.Id;

        this.updateCounters();
    }

    updateCounters(event){

        getHasDraftOrder()
            .then(results => {

                this.hasDraftOrders = results;

                let arrayProduct = event;
                let l_products = [];
                let l_idProducts = [];

                if (arrayProduct != null && arrayProduct != undefined) {
                    for( let [key, value] of arrayProduct ){
                        l_products.push(value);
                        l_idProducts.push(value.id);
                    }
                }
                
                if (this.hasDraftOrders == false && l_products != null && l_products.length > 0) {
                    this.hasDraftOrders = true;
                }

                getCounters({json_l_products : JSON.stringify(l_products), 
                            json_l_idProducts : JSON.stringify(l_idProducts),
                            idContactFor : this.idContact})
                    .then(results => {
                        console.log('>>> lwc94: getCounters 2');
                        this.l_counterCategories = results;
                        // await new Promise(r => setTimeout(r, 3000));
                        console.log('***************************l_counterCategories********************');
                        console.log(results);
                        results.forEach((category) => {
                            if(category.name === 'Comptes') {
                                console.log(category.l_counters);
                                category.l_counters.forEach((counter) => {
                                    if (counter.id == 'counter1') {
                                        this.smartPTS = counter.currentOrderValue;
                                        this.smartPTSDesc= counter.description;
                                    } else if (counter.id == 'counter2') {
                                        this.hotesse = counter.currentOrderValue;
                                        this.hotesseDesc = counter.description
                                    }
                                });
                            }
                        });
                        console.log("Smart PTS: " + this.smartPTS);
                        console.log("Hôtesse: " + this.hotesse);
                        if (this.l_counterCategories.length > 0) {
                            
                            this.displayComponent = true;
                            this.displayInfoMessage = false;

                            this.infoMessage = '';
                            for (let cat of this.l_counterCategories) {

                                for (let counter of cat.l_counters) {
                                    if (counter.infoMessageToBeDisplayed != null && counter.infoMessageToBeDisplayed != '') {
                                        this.infoMessage += (this.infoMessage != '' ? ',' : '') + counter.infoMessageToBeDisplayed;
                                        this.displayInfoMessage = true;
                                    }
                                }
                                
                            }

                            if (this.displayInfoMessage) {
                                const evt = new ShowToastEvent({
                                    message: this.infoMessage,
                                    variant: "info",
                                });
                                this.dispatchEvent(evt);
                            }
                            
                        }



                    })
                    .catch(error => {
                        console.log('>>>> error lwc94_orderhome_counters :');
                        console.log(error);
                    });

            })
        .catch(error => {
            console.log('>>>> error lwc94_orderhome_counters :');
            console.log(error);
        });
    }
}