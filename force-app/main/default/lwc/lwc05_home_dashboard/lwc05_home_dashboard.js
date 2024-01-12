import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* CHARTS */
import chartjs from '@salesforce/resourceUrl/chart';
import { loadScript } from 'lightning/platformResourceLoader';

/* IMPORT APEX */
import getContact from '@salesforce/apex/lwc05_home_dashboard_Ctrl.getCurrentContact';
import getIndicators from '@salesforce/apex/lwc05_home_dashboard_Ctrl.getCurrentContactIndicators';
import getUserCountry from '@salesforce/apex/lwc05_home_dashboard_Ctrl.getUserCountry';

/* IMPORT LABELS */
import lbl_btn from '@salesforce/label/c.LU_Home_Dashboard_Action';
import title from '@salesforce/label/c.LU_Home_Dashboard_Title';

export default class lwc05_home_dashboard extends NavigationMixin(LightningElement) {

    /* LABELS */
    labels = {
        lbl_btn,
        title
    }

    /* VARIABLES */
    @track contact;
    @track indicators;
    @track userCountry;

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


    /* INIT */
    connectedCallback() {

        getContact() 
        .then(result => {
            if (result != null) {
               this.contact = result;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });

        getUserCountry() 
        .then(result => {
            if (result != null) {
               this.userCountry = result;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });

        getIndicators()
        .then(kpis => {
            
            console.log('>>>> kpis: ');
            console.log(kpis);

            if (kpis != null) {
                this.indicators = kpis;

                // Load the donughts indicators
                for (let x = 0 ; x < this.indicators.length ; x++) {
                    console.log('>>> this.indicators[x]: ' + this.indicators[x].label);

                    if (this.indicators[x].isDonught) {

                        console.log('>>> DONUGHT : ' + this.indicators[x].label);
                        console.log(this.indicators[x].vDecimal1);
                        console.log(this.indicators[x].vDecimal2);
                        console.log(this.indicators[x].vDecimal3);

                        loadScript(this, chartjs)
                        .then(() => {
            
                            const canvas = document.createElement('canvas');
                            this.template.querySelector('div.' + this.indicators[x].vString2).appendChild(canvas);
                            const ctx = canvas.getContext('2d');

                            const configChart = {
                                type: 'doughnut',
                                data: {
                                    datasets: [
                                        {
                                            data: [
                                                this.indicators[x].vDecimal1,
                                                this.indicators[x].vDecimal3
                                            ],
                                            backgroundColor: [
                                                "#6ca5c3", "#CDCDCD"
                                            ],
                                            label: this.indicators[x].label
                                        }
                                    ],
                                    labels: ["Done", "Left to be done" ]
                                },
                                options: {
                                    legend: { display: false },
                                    tooltips: { enabled: true },
                                    circumference: 1 * Math.PI,
                                    rotation: 1 * Math.PI,
                                    cutoutPercentage: 90,
                                    responsive: true,
                                    animation: { animateScale: true, animateRotate: true },
                                    maintainAspectRatio: false
                                }
                            };



                            this.chart.push(new window.Chart(ctx, configChart));
            
                        })
                        .catch(error => {
                            this.error = error;
                        });

                    }

                }

            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });
    }

    renderedCallback() {
    }

    /* UI METHODS */
    get displaySeeMoreBtn() {
        let ret = false;
        if (this.contact) {
            if (this.contact.LU_Is_Manager__c && ( this.contact.Title !== "Group Sales Consultant" || this.userCountry !== "ITA") ) {
                ret = true;
            }
            if (this.userCountry == "FRA" && this.contact.LU_Is_Manager__c && this.contact.Title == "Conseillère" ) {
                ret = false;
            }
        }

        return (ret);
    }


    navigateToFollowUp(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'dashboards',
            },
        });

    }

}