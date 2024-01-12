import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* IMPORT CUSTOM LABELS */
import lbl_Contacts from '@salesforce/label/c.LU_Menu_Contacts';
import lbl_Contacts_Img from '@salesforce/label/c.LU_Menu_Contacts_Img';
import lbl_Order from '@salesforce/label/c.LU_Menu_Order';
import lbl_Order_Img from '@salesforce/label/c.LU_Menu_Order_Img';
import lbl_Followup from '@salesforce/label/c.LU_Menu_Followup';
import lbl_Followup_Img from '@salesforce/label/c.LU_Menu_Followup_Img';
import lbl_Mag from '@salesforce/label/c.LU_Menu_Mag';
import lbl_Mag_Img from '@salesforce/label/c.LU_Menu_Mag_Img';

/* Load CSS */
import cssStatic from '@salesforce/resourceUrl/whiteMenuIcon';
import { loadStyle } from 'lightning/platformResourceLoader';

/* IMPORT APEX */
import getMenuItems from '@salesforce/apex/LWC08_community_header_Ctrl.getMenuItems';

export default class Lwc08_community_header extends NavigationMixin(LightningElement) {
    
    /* LABELS */
    labels = {
        lbl_Contacts,
        lbl_Contacts_Img,
        lbl_Order,
        lbl_Order_Img,
        lbl_Followup,
        lbl_Followup_Img,
        lbl_Mag,
        lbl_Mag_Img
    }

    /* VARIABLES */
    @track mainmenu = [];
    @track burgerlinks = [];
    @track stanmag;

    @track hideHeader = false;

    /* INIT */
    @wire(CurrentPageReference) pageRef;
    connectedCallback() {
        /* Load CSS */
        loadStyle(this, cssStatic + '/whiteMenuIcon.css');

        let parameters = this.getQueryParameters();

        if(parameters.showheader !== undefined && parameters.showheader === "false"){
            this.hideHeader = true;
        }

        getMenuItems({ device: 'Desktop' })
        .then(links => {
            console.log('------ lwc08_community_menu_desktop ------')
            console.log(links)
            let currentURL = window.location.href;

            if (links != null) {
               this.burgerlinks = links.lBurgerItems;
               this.mainmenu = links.lMenuItems;
               this.stanmag = links.stanmag;

               let b_links = [];
                let b_order = 1;
                let eshopLink = '';
                for(const l of links.lBurgerItems){
                    if(l.label.toUpperCase().includes('STANHOME.FR')){
                        l.label = 'eShop'
                        l.b_order = 0;
                        l.target = "_blank";
                        eshopLink = l.link;
                    }
                    else if(l.label === 'StanLive '){
                        l.b_order = 1;
                        l.target = "_self";
                    }else{
                        l.b_order = b_order++;
                        l.target = "_self";
                    }
                    b_links.push(l);
                }
                b_links.sort((a, b) => (a.b_order > b.b_order) ? 1 : -1)
               this.burgerlinks = b_links;

               let m_links = [];
               let m_order = 4;

               /*this.mainmenu.push({
                icon: "https://mystan--c.eu25.content.force.com/servlet/servlet.ImageServer?id=0152o000006fi13&oid=00DD0000000rV9g",
                label: "eShop",
                link: eshopLink,
                target: "_self",
               })*/

               for(let link of this.mainmenu){
                    if( link.label === "Agenda" && currentURL.includes("genda")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Equipe / Clients" || link.label === "I Miei Contatti") && currentURL.includes("ontacts")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Commandes" || link.label === "I Miei Ordini") && currentURL.includes("rder")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Etat de comptes" || link.label === "Situazione Contabile") && currentURL.includes("tatement")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Factures" || link.label === "Fatture") && currentURL.includes("nvoice")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Agenda" || link.label === "Agenda") && currentURL.includes("agenda")){
                        link.isSelected = true;
                    }
                    else if( ( link.label === "Tickets" || link.label === "Tickets") && currentURL.includes("tickets")){
                        link.isSelected = true;
                    }

                    if(link.label === 'Equipe / Clients'){
                        link.m_order = 0;
                    }
                    else if(link.label === 'Commandes'){
                        link.m_order = 1;
                    }
                    else if(link.label === 'Factures'){
                        link.m_order = 2;
                    }
                    else if(link.label === 'eShop'){
                        link.m_order = 3;
                        link.target = '_blank';
                    }
                    else if(link.label === 'StanLive'){
                        link.m_order = 4;
                    }else{
                        link.m_order = m_order++;
                    }
                    m_links.push(link);                    
               }
               m_links.sort((a, b) => (a.m_order > b.m_order) ? 1 : -1)
               this.mainmenu = m_links;
               console.log('this.mainmenu',this.mainmenu)
            }

            // subscribe to events
            registerListener('toHomePage', this.toHomePage, this);
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });

    }
	disconnectedCallback() {

		// unsubscribe from events
		unregisterAllListeners(this);
    
    }

    toHomePage(event){
        for(let link of this.mainmenu){
            link.isSelected = false;
        }
    }

    selectLink(event){
        for(let link of this.mainmenu){
            if(link.label === event.currentTarget.dataset.id){
                link.isSelected = true;
            }
            else{
                link.isSelected = false;
            }
        }
    }

    /* UI METHODS */
    navigateToContacts(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'contacts',
            },
        });

    }

    navigateToOrder(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'order',
            },
        });

    }

    navigateToFollowUp(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'dashboards',
            },
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