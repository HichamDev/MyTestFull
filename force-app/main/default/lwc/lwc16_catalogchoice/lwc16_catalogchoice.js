/* eslint-disable no-alert */
import { LightningElement, track, wire, api } from 'lwc';

/* IMPORT METHODS */
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';

/* APEX METHODS */
import getCatalogList from '@salesforce/apex/lwc16_catalogchoice_ctrl.getCatalogList';
import getCurrentContact from '@salesforce/apex/lwc16_catalogchoice_ctrl.getCurrentContact';

import Id from '@salesforce/user/Id';

/* LABEL */
import lbl_pup_catalog_name from '@salesforce/label/c.LU_PUP_Catalog_Name';

export default class Lwc16_catalogchoice extends LightningElement {
    /* VARIABLES */
    @track contact = null;
    @track catalogList = [];
    @track displayedCatalogList = [];
    @track selectedValue = '';//'Regular';

    @track hasRendered = false;

    @api webonly = false;

    connectedCallback() {

        registerListener('orderHomeContactSelected', this.selectFirstCatalog, this);

        getCurrentContact() 
        .then(contact => {
            this.contact = contact;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });

        if(this.webonly == true){
            this.catalogList.push( { label: 'WEB', value: 'WEB' } );
            this.selectedValue = 'WEB';
            fireEvent(this.pageRef, 'catalogChange', this.selectedValue);
        }else{
            getCatalogList( { userId : Id } )
            .then(data => {
                if (data) {

                    for(let x of data){
                        if (this.selectedValue == '') {
                            this.selectedValue = x;
                        }
                        if(!x.toLowerCase().includes("challenge")){
                            this.catalogList.push( { label: x, value: x } );
                        }
                    }
        
                    this.selectedValue = this.catalogList[0].value;
        
                    fireEvent(this.pageRef, 'catalogChange', this.selectedValue);
        
                }
            })
            .catch(error => {
                console.log('>>>> error lwc16_catalogchoice :');
                console.log(error);
            });
        }
    }
	disconnectedCallback() {
		unregisterAllListeners(this);
    }

    // @wire(getCatalogList, { userId: Id })
    // wiredCycleObjectives({ error, data }) {
    //     console.log('>> callback catalog');
    //     console.log(data);
    //     console.log(error);
    //     if (data) {
    //         //this.catalogList = data;

    //         for(let x of data){
    //             if (this.selectedValue == '') {
    //                 this.selectedValue = x;
    //             }
    //             this.catalogList.push( { label: x, value: x } );
    //         }

    //         this.selectedValue = this.catalogList[0].value;

    //         fireEvent(this.pageRef, 'catalogChange', this.selectedValue);

    //     } else if (error) {
    //         console.error(error);
    //         this.error = error;
    //     }
    // }

    handleChange(event) {
        this.selectedValue = event.target.value;
        fireEvent(this.pageRef, 'catalogChange', this.selectedValue);
    }

    renderedCallback(){
        
        if(!this.hasRendered){

            this.selectFirstCatalog();
        }
    }

    selectFirstCatalog(value){

        if(value !== null && value !== undefined){

            if(value.contact.Id === this.contact.Id){
                this.displayedCatalogList = this.catalogList;
            }
            else{

                this.displayedCatalogList = [];
                for(let i = 0; i < this.catalogList.length; i++){
                    if(this.catalogList[i].value !== lbl_pup_catalog_name){
                        this.displayedCatalogList.push({ label : this.catalogList[i].label, value : this.catalogList[i].value });
                    }
                }
            }
        }
        else{
            this.displayedCatalogList = this.catalogList;
        }
        
        let checkboxes = this.template.querySelectorAll(".checkboxCatalog");
            let defautChecked = false;

        if(checkboxes.length){
            this.hasRendered = true;

            for (let i = 0; i < checkboxes.length; i++) {
                if(checkboxes[i].checked){
                    defautChecked = true;
                }
            }

            if(!defautChecked){
                checkboxes[0].checked = true;
                fireEvent(this.pageRef, 'catalogChange', this.selectedValue);
            }
        }
    }
}