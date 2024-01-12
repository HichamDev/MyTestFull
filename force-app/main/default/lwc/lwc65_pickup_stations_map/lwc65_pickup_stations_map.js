import { LightningElement, track, wire, api } from 'lwc';
import getInfoRelai from '@salesforce/apex/lwc65_pickup_stations_ctrl.getInfoRelai';
import createPointSelected from '@salesforce/apex/lwc65_pickup_stations_ctrl.createPointSelected';

import Colissimo_Header_Search from '@salesforce/label/c.Colissimo_Header_Search';
import select from '@salesforce/label/c.PUS0001';
import searchResult from '@salesforce/label/c.PUS0002';
import loadingErrorMessage from '@salesforce/label/c.PUS0003';

// import { loadStyle } from 'lightning/platformResourceLoader';
// import STH_Resources from '@salesforce/resourceUrl/STH_Resources';
// force-app\main\default\staticresources\STH_Resources\STH_Resources\css\lw65_pickupStations.css 


const columns = [
    {label: 'Title', fieldName: 'Title'}
];

export default class Lwc65_pickup_stations_map extends LightningElement {
    /* INIT */
    @api postalCode;
    @api adress;
    @api city;
    @api selectedshippingMode;

    @track orderStreet
    @track record;
    @track mapMarkers = [];
    @track listmapMarkers = [];
    @track center;
    @track zoomlevel;
    @track markersTitle;
    @track showFooter;
    @track listView;

    @track results;

    @track columns = columns;
    label={
        Colissimo_Header_Search,
        select,
        searchResult,
        loadingErrorMessage
    }

    @track selectedMarkerValue;
    @track pointSelected;

    @track activeSections = '';

    
    connectedCallback() {
        // loadStyle(this, STH_Resources + '/STH_Resources/css/lw65_pickupStations.css');
        this.orderStreet = this.adress + ' ' + this.postalCode + ' ' + this.city;

        this.getPointsRelai();
    }

    getPointsRelai(){        
        getInfoRelai({ codePostal :this.postalCode, selectedShippingModeId : this.selectedshippingMode})
        .then(results => {
            //console.log(results);
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
            //console.log('>>>> error :');
            //console.log(error);
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
    }

    
    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
        //console.log(this.selectedMarkerValue);
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
            this.PointSelected = results;
            //console.log('results' + results);

        })
        // .catch(error => {
        //     console.log(error);
        // })
        .finally(() => {
            // Envoyer le point relai à la VF page
            this.dispatchEvent(new CustomEvent(
                'notify', 
                {
                    detail: JSON.stringify(this.PointSelected),
                    bubbles: true,
                    composed: true
                }
            ));
        })

    }
}