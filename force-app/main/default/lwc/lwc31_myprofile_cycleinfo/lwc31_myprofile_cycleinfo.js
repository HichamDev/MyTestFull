/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';

/* Import APEX Methods */
import getCurrentCycle from '@salesforce/apex/lwc28_myprofile_contactinfo_ctrl.getCurrentCycle';

export default class lwc31_myprofile_cycleinfo extends LightningElement {

    @track currentCycle;

    connectedCallback() {
        console.log("results");
        getCurrentCycle( {} )
            .then(results => {
                this.currentCycle = results;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

}