/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/* Import APEX Methods */
import getIsItalianDirectore from '@salesforce/apex/lwc44_myprofile_changetodirectdebit_ctrl.getIsItalianDirettore';

/* Static Resource */
import Stc_pdf from '@salesforce/resourceUrl/LU_PDF_ChangeToDirectDebit';

/* IMPORT CUSTOM LABELS */
import lbl_changetodirectdebit_action from '@salesforce/label/c.LU_MyProfile_ChangeToDirectDebit_Action';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_changetodirectdebit_text from '@salesforce/label/c.LU_MyProfile_ChangeToDirectDebit_Text';
import lbl_changetodirectdebit_close from '@salesforce/label/c.LU_MyProfile_ChangeToDirectDebit_Close';
import lbl_changetodirectdebit_download from '@salesforce/label/c.LU_MyProfile_ChangeToDirectDebit_Download';
import lbl_img from '@salesforce/label/c.LU_Myprofile_ChangeToDirectDebit_Img';

export default class Lwc44_myprofile_changetodirectdebit extends NavigationMixin(LightningElement) {

    labels = {
        lbl_changetodirectdebit_action,
        lbl_Close,
        lbl_changetodirectdebit_text,
        lbl_changetodirectdebit_close,
        lbl_changetodirectdebit_download,
        lbl_img
    }

    @track displayComponent = false;
    @track displayPopover = false;
    @track displayUrlPDF = false;

    connectedCallback() {

        getIsItalianDirectore( {} )
        .then(results => {
            if(results){
                this.displayComponent = true;
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.log(error);
        });
    }

    showPopover(){
        this.displayPopover = true;
    }

    close() {
        this.displayPopover = false;
    }

    downloadPdf() {
        this.displayUrlPDF = true;

        this.displayPopover = false;

        let urlFormated = window.location.href;

        urlFormated = urlFormated.substring(10, urlFormated.length - 1);
        let indexSecondSlash = urlFormated.search("/") + 11;

        urlFormated = urlFormated.substr( urlFormated.search("/") + 1 , urlFormated.length - 1);
        indexSecondSlash += urlFormated.search("/") + 1;

        urlFormated = window.location.href.substr(0, indexSecondSlash);
        urlFormated += Stc_pdf.substr( Stc_pdf.search("resource"), Stc_pdf.length - 1);

        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: urlFormated
                }
            },
            false
        );

    }

    get urlPDF() {
        return Stc_pdf;
    }
}