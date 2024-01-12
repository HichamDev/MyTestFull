import { LightningElement, track } from 'lwc';

/* IMPORT APEX */
import getLinks from '@salesforce/apex/lwc05_home_shortcuts_Ctrl.getShortcuts';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

export default class lwc05_home_shortcuts extends LightningElement {

    icon_chart = LogoBtn + '/icons/icon-chart.svg';
    icon_speed = LogoBtn + '/icons/icon-speed.svg';
    icon_cup = LogoBtn + '/icons/icon-cup.svg';
    icon_contract = LogoBtn + '/icons/icon-contract.svg';
    icon_pie = LogoBtn + '/icons/icon-pie.svg';
    icon_accounts = LogoBtn + '/icons/icon-accounts.svg';
    icon_faq = LogoBtn + '/icons/icon-faq.svg';
    icon_documents = LogoBtn + '/icons/icon-documents.svg';

    /* VARIABLES */
    @track links = [];


    /* INIT */
    connectedCallback() {

        getLinks()
        .then(result => {
            if (result != null) {
                console.log('----- lwc05_home_shortcuts -----')
                console.log(result)
                let links = [];
                let order = 1;
                for(const l of result){
                    if(l.label.toUpperCase().includes('STANHOME.FR')){
                        l.label = 'eShop'
                        l.order = 0;
                    }
                    else if(l.label === 'StanLive '){
                        l.order = 1;
                    }else{
                        l.order = order++;
                    }
                    links.push(l);
                }
               links.sort((a, b) => (a.order > b.order) ? 1 : -1)
               this.links = links;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });

    }

}