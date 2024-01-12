import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInfoRelai from '@salesforce/apex/lwc65_pickup_stations_ctrl.getInfoRelai';
import createPointSelected from '@salesforce/apex/lwc65_pickup_stations_ctrl.createPointSelected';
import getUserCountry from '@salesforce/apex/lwc67_checkout_shipping_ctrl.getUserCountry';

import { fireEvent } from 'c/pubsub';

import Colissimo_Header_Search from '@salesforce/label/c.Colissimo_Header_Search';
import select from '@salesforce/label/c.PUS0001';
import searchResult from '@salesforce/label/c.PUS0002';
import loadingErrorMessage from '@salesforce/label/c.PUS0003';
import LU_Checkout_Shipping_External_PointSelected from '@salesforce/label/c.LU_Checkout_Shipping_External_PointSelected';
import LU_Checkout_Shipping_External_AroundAnotherAddress from '@salesforce/label/c.LU_Checkout_Shipping_External_AroundAnotherAddress';
import LU_Checkout_Shipping_External_AroundAnotherAddress_Street from '@salesforce/label/c.LU_Checkout_Shipping_External_AroundAnotherAddress_Street';
import LU_Checkout_Shipping_External_AroundAnotherAddress_PostalCode from '@salesforce/label/c.LU_Checkout_Shipping_External_AroundAnotherAddress_PostalCode';
import LU_Checkout_Shipping_External_AroundAnotherAddress_City from '@salesforce/label/c.LU_Checkout_Shipping_External_AroundAnotherAddress_City';
import LU_Checkout_Shipping_External_AroundAnotherAddress_Search from '@salesforce/label/c.LU_Checkout_Shipping_External_AroundAnotherAddress_Search';
import LU_Checkout_Shipping_External_Mobile from '@salesforce/label/c.LU_Checkout_Shipping_External_Mobile';
import LU_Regex_Mobile_Format from '@salesforce/label/c.LU_Regex_Mobile_Format';
import lbl_ErrorShipping from '@salesforce/label/c.LU_Checkout_Shipping_Error_Title';
import lbl_Error_ExceptionnalAdrress_PhoneFormat from '@salesforce/label/c.LU_Checkout_Shipping_ExceptionnalAddress_PhoneFormat';

export default class Lwc67_checkout_shipping_relaiscolis extends LightningElement {

    /* INIT */
    @api postalCode;
    @api adress;
    @api city;
    @api phone;
    @api selectedshippingMode;
    @api disabled = false;


    @track orderStreet
    @track record;
    @track mapMarkers = [];
    @track listmapMarkers = [];
    @track center;
    @track zoomlevel;
    @track markersTitle;
    @track showFooter;
    @track listView;
    @track openAnotherAddress = false;

    @track results;

    // @track columns = columns;
    label={
        Colissimo_Header_Search,
        select,
        searchResult,
        loadingErrorMessage,
        LU_Checkout_Shipping_External_PointSelected,
        LU_Checkout_Shipping_External_AroundAnotherAddress,
        LU_Checkout_Shipping_External_AroundAnotherAddress_Street,
        LU_Checkout_Shipping_External_AroundAnotherAddress_PostalCode,
        LU_Checkout_Shipping_External_AroundAnotherAddress_City,
        LU_Checkout_Shipping_External_AroundAnotherAddress_Search,
        LU_Checkout_Shipping_External_Mobile,
        LU_Regex_Mobile_Format,
        lbl_ErrorShipping,
        lbl_Error_ExceptionnalAdrress_PhoneFormat
    }

    @track selectedMarkerValue;
    @track pointSelected = null;
    @track isPointSelected = false;

    @track activeSections = '';

    @track isFRA = false;
    @track isITA = false;

    connectedCallback() {
        // loadStyle(this, STH_Resources + '/STH_Resources/css/lw65_pickupStations.css');
        this.orderStreet = this.adress + ' ' + this.postalCode + ' ' + this.city;
        console.log('>>> selectedshippingMode');
        console.log(this.selectedshippingMode);
        this.getPointsRelai();
    }

    getPointsRelai(){     

        console.log('>>id shiping mode');
        console.log(this.selectedshippingMode.LU_Parent_Order_Rule__r.Id);
        getInfoRelai({ codePostal :this.postalCode, selectedShippingModeId : this.selectedshippingMode.LU_Parent_Order_Rule__r.Id})
        .then(results => {

            this.results = results;
            let markers = [];
                for(let ii=0;ii<results.length;ii++){
                    markers.push({
                        location:{
                            Street: results[ii].Street,
                            City: results[ii].City,
                            PostalCode: results[ii].PostalCode,
                            Country: results[ii].Country,
                        },
                        icon: results[ii].icon,
                        title: results[ii].title,
                        description: results[ii].description,
                        value:results[ii].nom,
                        identifiant: results[ii].identifiant
                    })
                }
                this.mapMarkers = markers;
                this.listmapMarkers = markers;
                this.center = {
                    location: {
                        Street: results[0].Street,
                        City: results[0].City,
                    },
                };
    
                
                this.markersTitle = this.label.searchResult;//'Résultats de la recherche';
                this.showFooter = false;
                this.listView = 'visible'; 
                
            })
        .catch(error => {

            // Dire à la VF Page d'arrêter de charger et d'afficher une erreur
            this.dispatchEvent(new CustomEvent(
                'notify', 
                {
                    detail: {type : error, message : this.label.loadingErrorMessage},//'Problème au chargement de la carte. merci de réessayer plus tard.'},
                    bubbles: true,
                    composed: true
                }
            ));
        })
        .finally(() => {

        });

        getUserCountry() 
            .then(results => {
                if(results === 'FRA'){
                    this.isFRA = true;
                }
                else if(results === 'ITA'){
                    this.isITA = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            }
        );
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        this.activeSections = this.selectedMarkerValue;
        const searchinfo = this.selectedMarkerValue;
        this.dispatchEvent(new CustomEvent(
            'dosearch', 
            {detail: searchinfo}
        ));
    }

    // Déroule une section d'accordion - automatique à l'initialisation du composant
    handleSectionToggle(event){
        this.activeSections = event.detail.openSections;
        this.selectedMarkerValue = this.activeSections;

        // refaire la map à chaque fois qu'un accordion est cliqué        
        let markers = [];
        for(let ii=0;ii<this.results.length;ii++){
            if(this.results[ii].nom === this.selectedMarkerValue){
                markers.unshift({
                    location:{
                        Street: this.results[ii].Street,
                        City: this.results[ii].City,
                        PostalCode: this.results[ii].PostalCode,
                        Country: this.results[ii].Country,
                    },
                    icon: this.results[ii].icon,
                    title: this.results[ii].title,
                    description: this.results[ii].description,
                    value : this.results[ii].nom,
                    identifiant : this.results[ii].identifiant,//num,
                    adresse2 : this.results[ii].adresse2,
                })
            }          
        }

        // centre la carte à chaque fois qu'une section est déroulée
        this.center = {
            location: {
                Street: markers[0].location.Street,
                City: markers[0].location.City,
            },
        }

        // Dire à la VF page que le composant est bien chargé
        this.dispatchEvent(new CustomEvent(
            'notify', 
            {
                detail: 'ok',
                bubbles: true,
                composed: true
            }
        ));
    }

    // Au clic du bouton sélectionné
    handleclick(event) {    
        this.selectedMarkerValue = event.target.value;

        if(this.isFRA && this.phone && !this.phone.match(this.label.LU_Regex_Mobile_Format)){
            
            const evt = new ShowToastEvent({
                title: lbl_ErrorShipping,
                message: lbl_Error_ExceptionnalAdrress_PhoneFormat,
                variant: "error",
            });
            this.dispatchEvent(evt);
            return;
        }
        fireEvent(null, 'checkout_shippingExternal_MobilePhone', this.phone);
        
        let markers = [];
        for(let ii=0;ii<this.results.length;ii++){
            if(this.results[ii].nom === this.selectedMarkerValue){
                markers.unshift({
                    location:{
                        Street: this.results[ii].Street,
                        City: this.results[ii].City,
                        PostalCode: this.results[ii].PostalCode,
                        Country: this.results[ii].Country,
                    },
                    icon: this.results[ii].icon,
                    title: this.results[ii].title,
                    description: this.results[ii].description,
                    value : this.results[ii].nom,
                    identifiant : this.results[ii].identifiant,//num,
                    adresse2 : this.results[ii].adresse2,
                })
            }          
        }
        
        // Envoi des données brutes récupérées en front pour créer un point relai
        createPointSelected({ 
            Street : markers[0].location.Street,
            City : markers[0].location.City,
            PostalCode : markers[0].location.PostalCode,
            Country : markers[0].location.Country,
            title : markers[0].title,
            identifiant : markers[0].identifiant,//num,
            adresse2 : markers[0].adresse2,
         })
        .then(results => {
            this.isPointSelected = true;
            this.PointSelected = results;

            // Send the point selected
            fireEvent(null, 'checkout_shippingExternal_PointSelected', JSON.stringify(this.PointSelected));

            // Envoyer le point relai à la VF page
            // this.dispatchEvent(new CustomEvent(
            //     'checkout_shipping_external_notify', 
            //     {
            //         detail: JSON.stringify(this.PointSelected),
            //         bubbles: true,
            //         composed: true
            //     }
            // ));
        })
        .catch(error => {
            console.error(error);
        })
        // .finally(() => {
        //     console.log('>>>> FINALYY');
            
        //     console.log('>>> after');
        // })

    }


    /* UI EVENTS */
    changePhoneNumber(event) {
        this.phone = event.target.value;

        fireEvent(null, 'checkout_shippingExternal_MobilePhone', this.phone);
    }

    changeAnotherAddressStreet(event) {
        this.adress = event.target.value;
    }

    changeAnotherAddressPostalCode(event) {
        this.postalCode = event.target.value;
    }

    changeAnotherAddressCity(event) {
        this.city = event.target.value;
    }

    handleClickSearchAnotherAddress(event) {
        console.log('>>> adress : ' + this.address);
        console.log('>>> postalCode : ' + this.postalCode);
        console.log('>>> city : ' + this.city);

        this.orderStreet = this.adress + ' ' + this.postalCode + ' ' + this.city;
        this.getPointsRelai();
    }
    
    handleOpenAnotherAddress(event) {
        if (this.openAnotherAddress == true) {
            this.openAnotherAddress = false;
        } else {
            this.openAnotherAddress  = true;
        }
    }
}