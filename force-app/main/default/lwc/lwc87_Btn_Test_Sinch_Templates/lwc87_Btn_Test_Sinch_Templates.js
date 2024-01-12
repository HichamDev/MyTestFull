import { LightningElement, track } from 'lwc';
import sendTests from '@salesforce/apex/AP50_Btn_Test_Sinch_Templates.sendTests';

export default class Lwc87_Btn_Test_Sinch_Templates extends LightningElement {

    @track result;
    @track error;

    handleSendTestSMS() {
        sendTests()
            .then(result => {
                console.log(`result ${result}`, result);
                
                return result;
            })
            .catch(error => {
                console.log(`error ${error}`);
            });
    }
}