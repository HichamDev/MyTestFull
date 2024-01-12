/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';


/* APEX METHODS */
import getReminders from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getReminders';
// import getNextEvent from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getNextEvent';
// import getCommunication from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getCommunication';
// import getInactivTeamMembers from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getInactivTeamMembers';
// import getInactivClients from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getInactivClients';
// import getBirthday from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getBirthday';
// import getBadDept from '@salesforce/apex/lwc46_homepage_reminders_ctrl.getBadDept';

/* IMPORT LABELS */
import lbl_Title from '@salesforce/label/c.LU_Reminder_Title';

export default class lwc46_homepage_reminders extends LightningElement {

    @track l_reminders = [];
    @track displayTitle = false;

    labels = {
        lbl_Title
    }

    /* INIT */
    connectedCallback() { 

        console.log('INIT');

        getReminders()
            .then(results => {
                console.log("reminders");
                console.log(results);
                for(let rem of results){
                    console.log("reminders OK");
                    this.l_reminders.push(rem);
                    this.displayTitle = true;
                }
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        // getNextEvent()
        //     .then(results => {
        //         console.log("event");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });
        
        // getCommunication()
        //     .then(results => {
        //         console.log("commu");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });
        
        // getInactivTeamMembers()
        //     .then(results => {
        //         console.log("team");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });
        
        // getInactivClients()
        //     .then(results => {
        //         console.log("clients");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });

        // getBirthday()
        //     .then(results => {
        //         console.log("birthdate");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });

        // getBadDept()
        //     .then(results => {
        //         console.log("baddept");
        //         for(let rem of results){
        //             this.l_reminders.push(rem);
        //         }
        //     })
        //     .catch(error => {
        //         console.log('>>>> error :');
        //         console.log(error);
        //     });
    }
}