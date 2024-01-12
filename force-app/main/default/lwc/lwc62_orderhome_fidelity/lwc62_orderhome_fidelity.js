import { LightningElement, track } from 'lwc';
import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

/* CHARTS */
import chartjs from '@salesforce/resourceUrl/chart';
import { loadScript } from 'lightning/platformResourceLoader';

import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getCounters from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getCountersByCategory';
import getHasDraftOrder from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getHasDraftOrder';
import getUserCountry from '@salesforce/apex/Lwc62_orderhome_fidelity_ctrl.getUserCountry';

import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_lb_title from '@salesforce/label/c.Lu_Order_Home_LP_Title';
import lbl_lb_solde_title from '@salesforce/label/c.Lu_Order_Home_LP_Solde_Title';
import lbl_lb_consumed from '@salesforce/label/c.Lu_Order_Home_LP_Consumed';
import lbl_lb_credit from '@salesforce/label/c.Lu_Order_Home_LP_Credit';
import lbl_lb_rest from '@salesforce/label/c.Lu_Order_Home_LP_Rest';
import lbl_current_order_value_subtitle from '@salesforce/label/c.Lu_Order_Home_LP_Order_Value_Subtitle';
import lbl_balance_plus_credit_on_order_subtitle from '@salesforce/label/c.Lu_Order_Home_LP_Plus_Credit_Subtitle';
import lbl_debit_value_on_order_subtitle from '@salesforce/label/c.Lu_Order_Home_LP_Debit_Value_Subtitle';

export default class Lwc62_orderhome_fidelity_ctrl extends LightningElement {

    bgLoyalty = LogoBtn + '/icons/bg-fidelity.png';
    iconGift = LogoBtn + '/icons/icon-gift.svg';

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

    chart = [];
    chartjsInitialized = false;

    config = {
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [
                        100
                    ],
                    backgroundColor: [
                        'rgb(255, 99, 132)',
                    ],
                    label: 'Turnover'
                }
            ],
            labels: []
        },
        options: {
            responsive: true,
            
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };

    label = { 
        lbl_Close,
        lbl_lb_title,
        lbl_lb_solde_title,
        lbl_lb_consumed,
        lbl_lb_credit,
        lbl_lb_rest,
        lbl_current_order_value_subtitle,
        lbl_balance_plus_credit_on_order_subtitle,
        lbl_debit_value_on_order_subtitle
    };

    connectedCallback() {

        registerListener('updateLoyalty', this.updateCounters, this);

        registerListener('orderHomeContactSelected', this.updateContact, this);

        getUserCountry()
            .then(results => {
                if(results === 'FRA'){
                    this.isFRA = true;
                }
            })
        .catch(error => {
            console.log('>>>> error lwc62_orderhome_fidelity :');
            console.log(error);
        });

        getHasDraftOrder()
            .then(results => {
                console.log('##################################lwc62')
                this.hasDraftOrders = results;
            })
        .catch(error => {
            console.log('>>>> error lwc62_orderhome_fidelity:');
            console.log(error);
        });

        getCounters()
            .then(results => {
                console.log('>>> COUNTERS: ');
                console.log(results);
                this.l_counterCategories = results;
                if (this.isFRA) {
                    console.log('>>>>' + this.isFRA);
                    this.l_counterCategories = results.filter( category => (category.name !== 'Comptes'));
                } else {
                    this.l_counterCategories = results;
                }
                // this.l_counterCategories.forEach((cat,index) => {
                //     cat.number = index +1;
                //   });
                if(this.l_counterCategories.length > 0){
                    this.displayComponent = true;
                }
            })
        .catch(error => {
            console.log('>>>> error lwc62_orderhome_fidelity :');
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
                        console.log('>>>>' + this.isFRA);
                        if (this.isFRA) {
                            this.l_counterCategories = results.filter( category => (category.name !== 'Comptes'));
                        } else {
                            this.l_counterCategories = results;
                        }
                        // this.l_counterCategories.forEach((cat,index) => {
                        //     cat.number = index +1;
                        //   });
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
                        console.log('>>>> error lwc62_orderhome_fidelity :');
                        console.log(error);
                    });

            })
        .catch(error => {
            console.log('>>>> error lwc62_orderhome_fidelity :');
            console.log(error);
        });
    }

    openModal(event){
        let catName = event.target.dataset.id;

        console.log(catName);

        for(let cat of this.l_counterCategories){
            if(cat.name === catName){
                this.modalCategory = cat;
            }
        }

        this.isModalOpened = true;
    }

    renderedCallback() {

        if (this.isModalOpened && !this.isChartGenerated) {

            this.isChartGenerated = false;
            for (let cat of this.l_counterCategories) {
                let chartType = cat.chartType;

                for (let cou of cat.l_counters) {
                
                    if (cou.isDisplayed) {

                        loadScript(this, chartjs)
                            .then(() => {

                                if (this.template.querySelector('div.' + cou.id) != null) {
                                    const canvas = document.createElement('canvas');

                                    this.template.querySelector('div.' + cou.id).appendChild(canvas);
                                    const ctx = canvas.getContext('2d');

                                    if (chartType == 'doughnut') {
                                        const configChart = {
                                            type: 'doughnut',
                                            data: {
                                                datasets: [
                                                    {
                                                        data: [
                                                            cou.balancePlusCreditOnOrder, //cou.value - cou.currentOrderValue,
                                                            cou.debitValueOnOrder //currentOrderValue
                                                        ],
                                                        backgroundColor: [
                                                            "#6ca5c3", "#3c6f8a"
                                                        ],
                                                        label: cou.label
                                                    }
                                                ],
                                                labels: [ this.label.lbl_lb_credit, this.label.lbl_lb_consumed]
                                            },
                                            options: {
                                                legend: { display: true, position: 'bottom' },
                                                tooltips: { enabled: true },
                                                circumference: 2 * Math.PI,
                                                cutoutPercentage: 80,
                                                responsive: true,
                                                animation: { animateScale: true, animateRotate: true },
                                                maintainAspectRatio: false
                                            }
                                        };
                                        this.chart.push(new window.Chart(ctx, configChart));
                                    }

                                    if (chartType == 'bar') {

                                        const configChart = {
                                            type: 'horizontalBar',
                                            data: {
                                                datasets: [ 
                                                    {
                                                        data: [
                                                            - cou.debitValueOnOrder,
                                                        ],
                                                        backgroundColor: [
                                                            "#6ca5c3"
                                                        ],
                                                        label: this.label.lbl_lb_consumed 
                                                    },
                                                    {
                                                        data: [
                                                            cou.currentOrderValue
                                                        ],
                                                        backgroundColor: [
                                                            "#3c6f8a"
                                                        ],
                                                        label: this.label.lbl_lb_rest 
                                                    },

                                                ],
                                            },
                                            options: {
                                                legend: { display: true, position: 'bottom' },
                                                tooltips: { 
                                                    enabled: true,
                                                    callbacks: {
                                                        title: () => cou.label,
                                                    }
                                                },
                                                responsive: true,
                                                maintainAspectRatio: false,
                                                scales: {
                                                    xAxes: [{
                                                        ticks: {
                                                            precision: 0
                                                        },
                                                        scaleLabel:{
                                                            display:false
                                                        },
                                                        gridLines: {
                                                            display:false
                                                        }, 
                                                        stacked: true
                                                    }],
                                                    yAxes: [{
                                                        stacked: true
                                                    }]
                                                }
                                            }
                                        };
                                        this.chart.push(new window.Chart(ctx, configChart));
                                    }
                                }
                                

                            })
                    }
                }
            }
        }
    }

    closeModal(){
        this.isModalOpened = false;
        this.isChartGenerated = false;
    }
}