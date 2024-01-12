/* eslint-disable @lwc/lwc/valid-api */
/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { NavigationMixin } from 'lightning/navigation';

/* Import APEX Methods */
import getContactConnected from '@salesforce/apex/LWC03_EmailForm_Ctrl.getCurrentContact';
import searchContact from '@salesforce/apex/LWC03_EmailForm_Ctrl.search';
import sendEmails from '@salesforce/apex/LWC03_EmailForm_Ctrl.sendEmail';
import deleteFile from '@salesforce/apex/LWC03_EmailForm_Ctrl.deleteContentDocument';
import getEmailTemplate from '@salesforce/apex/LWC03_EmailForm_Ctrl.getEmailTemplate';
import getEmailTemplateBackgroundImages from '@salesforce/apex/LWC03_EmailForm_Ctrl.getEmailTemplateBackgroundImages';

/* IMPORT CUSTOM LABELS */
import lbl_Title from '@salesforce/label/c.LU_Action_Email_Title';
import lbl_To from '@salesforce/label/c.LU_Action_Email_To';
import lbl_Subject from '@salesforce/label/c.LU_Action_Email_Subject';
import lbl_Send_Email_Title from '@salesforce/label/c.LU_Send_Email_Title';
import lbl_Send_Email_Subtitle from '@salesforce/label/c.LU_Send_Email_Subtitle';
import lbl_Send_Email_Background from '@salesforce/label/c.LU_Send_Email_Background';
import lbl_Body from '@salesforce/label/c.LU_Action_Email_Body';
import lbl_Close from '@salesforce/label/c.LU_Action_Email_Close';
import lbl_Send from '@salesforce/label/c.LU_Action_Email_Send';
import lbl_TECH_Customer from '@salesforce/label/c.LU_TECH_Contact_Customer';
import lbl_TECH_Team from '@salesforce/label/c.LU_TECH_Contact_Team';
import lbl_Error_NoTargets from '@salesforce/label/c.LU_Email_SelectAtLeastOneTarget';
import lbl_Success_SentTitle from '@salesforce/label/c.LU_Action_Email_Success_Title';
import lbl_Success_SentMsg from '@salesforce/label/c.LU_Action_Email_Success_Msg';
import lbl_Error_Title from '@salesforce/label/c.LU_Action_Email_Error_Title';
import lbl_Error_File from '@salesforce/label/c.LU_Email_File_Error';
import lbl_Error_File_Msg from '@salesforce/label/c.LU_Email_File_Error_Msg';
import lbl_File_Attach from '@salesforce/label/c.LU_Email_File_Attach';
import lbl_File_Attach_SizeMax from '@salesforce/label/c.LU_Email_File_Attach_SizeMax';
import lbl_All_Customer from '@salesforce/label/c.LU_Mail_Target_All_Customer';
import lbl_All_Team from '@salesforce/label/c.LU_Mail_Target_All_Team';
import lbl_Specific_Customer from '@salesforce/label/c.LU_Mail_Target_Specific_Customer';
import lbl_Specific_Team from '@salesforce/label/c.LU_Mail_Target_Specific_Team';
import lbl_add_my_manager from '@salesforce/label/c.LU_Email_Form_Add_Manager';
import lbl_no_template_selected from '@salesforce/label/c.LU_Email_No_Template_Selected';


export default class Lwc03_emailform extends NavigationMixin(LightningElement) {

    /* LABELS */
    label = { 
        lbl_Title,
        lbl_To,
        lbl_Subject,
        lbl_Body,
        lbl_Close,
        lbl_Send,
        lbl_TECH_Customer,
        lbl_TECH_Team,
        lbl_Error_NoTargets,
        lbl_Success_SentTitle,
        lbl_Success_SentMsg,
        lbl_Error_Title,
        lbl_File_Attach,
        lbl_File_Attach_SizeMax,
        lbl_add_my_manager,
        lbl_Send_Email_Title,
        lbl_no_template_selected,
        lbl_Send_Email_Subtitle,
        lbl_Send_Email_Background
    };

    /* VARIABLES */
    @api openEmail = false;
    @api contactId = '';
    @api selectedFromList = [];
    @api selectedtargets = [];
    @track selectedTargetType = 'specific';

    @api contactType = this.label.lbl_TECH_Customer;

    @api hideRecipientEdition;
    @api hideSendToManager = false;

    @api parentComponent = "";

    @track subject = '';
    @track emailTitle = '';
    @track emailSubTitle = '';
    @track body = '';

    @track valueRadio = 'specific';

    @track uploadedFiles = [];

    @track sendToManager = false;
    @track displaySendToManager = true;
    
    @track isLoading = false;
    
    @track l_emailTemplate = [];
    @track chosedEmailTemplate;
    @track optionsEmailTemplate = [];
    @track contentPreview;
    @track originalTemplate;
    @track displayPreview = false;
    @track displayPreviewSubtitle = false;
    @track displaySelectTemplate = false;

    @track m_backgroundImageTemplate = new Map();
    @track l_bacjgroundImages = [];
    @track displayBackgroundImages = false;
    @track linkBackgroundImage;

    /* INIT */
    @wire(CurrentPageReference) pageRef; // Required by pubsub
	connectedCallback() {
        this.isLoading = true;
        if(this.hideRecipientEdition == 'false') this.hideRecipientEdition = false;
        else if(this.hideRecipientEdition == 'true') this.hideRecipientEdition = true;
        // Get current contact connected
        getContactConnected()
        .then(contact => {
                
            this.contactId = contact.Id;
            this.isLoading = false;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
            this.isLoading = false;
        });

        getEmailTemplate()
        .then(l_templates => {

            this.optionsEmailTemplate.push({label : this.label.lbl_no_template_selected, value : this.label.lbl_no_template_selected});
            this.chosedEmailTemplate = this.label.lbl_no_template_selected;
            for(let template of l_templates){
                this.optionsEmailTemplate.push({label : template.Subject, value : template.Subject});
                this.l_emailTemplate.push(template);
                this.displaySelectTemplate = true;
            }

            this.isLoading = false;
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
            this.isLoading = false;
        });

        getEmailTemplateBackgroundImages()
        .then(l_backgroundImages => {

            for(let img of l_backgroundImages){
                if(!this.m_backgroundImageTemplate.has(img.templateName)){
                    this.m_backgroundImageTemplate.set(img.templateName, []);
                }
                this.m_backgroundImageTemplate.get(img.templateName).push(img.link);
            }
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
            this.isLoading = false;
        });

        if(this.parentComponent === "managerInformations"){
            this.displaySendToManager = false;
        }

        // subscribe to events
        registerListener('contactTypeToggle', this.handleEvtContactTypeToggle, this);
	}
	disconnectedCallback() {

		// unsubscribe from events
		unregisterAllListeners(this);
    
    }


/* UI METHODS */
    
    // Define the accepted format for attachments
    get acceptedFormats() {
        return ['.pdf', '.zip', '.txt', '.docx', '.xlsx', '.pptx', '.png', '.jpg', '.jpeg'];
    }

    // Define the values of the radio button target
    get optionsRadio() {

        if (this.contactType == this.label.lbl_TECH_Customer) {
            return [
                { label: lbl_Specific_Customer, value: 'specific' },
                { label: lbl_All_Customer, value: 'all' },
            ];
        }

        return [
            { label: lbl_Specific_Team, value: 'specific' },
            { label: lbl_All_Team, value: 'all' },
        ];
        
    }

    // Define if the target defined is specific
    get isSelectedSpecific() {
        if (this.selectedTargetType === 'specific') {
            return (true);
        }
        return (false);
    }

    // Modal - Open
    open() {
        this.openEmail = true;
    }

    // Modal - Close
    close() {

        this.isLoading = true;

        this.displayPreview = false;
        this.chosedEmailTemplate = this.label.lbl_no_template_selected;
        this.originalTemplate = "";
        this.contentPreview = "";

        // Remove the files uploaded from the server
        if (this.uploadedFiles != null && this.uploadedFiles.length > 0) {
            
            let lIds = [];

            for (let i = 0 ; i < this.uploadedFiles.length ; i++) {
                console.log('>>> files : ' + this.uploadedFiles[i].documentId);
                lIds.push(this.uploadedFiles[i].documentId);
            }

            deleteFile({contentDocumentIds: lIds})
            .then(success => {
                console.log('>>> success :' + success);
                if (success) {
                    this.resetForm();

                    // Close the popup
                    this.openEmail = false;
                    const evtCloseEmail = new CustomEvent('closeemail', {
                        detail: false
                    });
                    this.dispatchEvent(evtCloseEmail);

                } else {
                    // Display an error message
                    const evtEmpty = new ShowToastEvent({
                        title: lbl_Error_File,
                        message: lbl_Error_File_Msg ,
                        variant: 'error'
                    });
                    this.dispatchEvent(evtEmpty);
                }
                
                this.isLoading = false;

            })
            .catch(error => {
                console.log('>>>> error :');
                console.error(error);
                this.isLoading = false;
            });
        } else {
            this.resetForm();

            // Close the popup
            this.openEmail = false;
            const evtCloseEmail = new CustomEvent('closeemail', {
                detail: false
            });
            this.dispatchEvent(evtCloseEmail);
            this.isLoading = false;
        }

    } 


    /* EVENTS METHODS */

    handleEvtContactTypeToggle(value) {

        this.isLoading = true;
        // Change the type of contact displayed
        this.contactType = value;

        if (this.contactType == this.label.lbl_TECH_Customer) {
            this.displaySendToManager = false;
        } else {
            this.displaySendToManager = true;
        }
        
        // Reset the form
        this.resetForm();
        
    }

    // Handle file upload finished event
    handleUploadFinished(event) {

        // Add the files uploaded to the file list
        for (let i = 0 ; i < event.detail.files.length ; i++) {
            this.uploadedFiles.push(event.detail.files[i]);
        }

    }

    // Event - Handle remove of a file attached
    handleRemoveFile(event) {

        // Get the file to be removed
        const fileId = event.currentTarget.name;
        const fileIds = [];
        fileIds.push(fileId);
        // Remove the file from the server
        deleteFile({contentDocumentIds: fileIds})
        .then(success => {
            
            if (success) {
                // Remove the file from the list displayed
                this.uploadedFiles = this.uploadedFiles.filter(item => item.documentId !== fileId);
            } else {
                // Display an error message
                const evtEmpty = new ShowToastEvent({
                    title: lbl_Error_File,
                    message: lbl_Error_File_Msg ,
                    variant: 'error'
                });
                this.dispatchEvent(evtEmpty);
            }
            
        })
        .catch(error => {
            console.log('>>>> error :');
            console.error(error);
        });

    }

    // Event - Handle file click
    handleFileClick(event) {

        // File Id clicked
        const recordId = event.currentTarget.name;

        // Navigate to file preview
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: recordId,
                selectedRecordId: recordId
            }
          })

    }

    // Event - generic handler on change
    genericOnChange(event){

        if (event.target.name === 'insubject') {
            this.subject = event.target.value;
        }
        else if (event.target.name === 'inemailtitle') {
            this.emailTitle = event.target.value;
        }
        else if (event.target.name === 'inemailsubtitle') {
            this.emailSubTitle = event.target.value;
        }
    }

    // Event - Body of title changes
    onchangeTitle(event) {
        this.emailTitle = event.target.value;
        this.contentPreview = this.originalTemplate.replace('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', "");
        this.contentPreview = this.contentPreview.replace('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{body}', "");
        this.contentPreview = this.contentPreview.replace('{backgroundImg}', this.linkBackgroundImage);
    }

    // Event - Body of title changes
    onchangeSubTitle(event) {
        this.emailSubTitle = event.target.value;
        this.contentPreview = this.originalTemplate.replace('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', "");
        this.contentPreview = this.contentPreview.replace('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{body}', "");
        this.contentPreview = this.contentPreview.replace('{backgroundImg}', this.linkBackgroundImage);
    }

    // Event - Body of mail changes
    onchangeBody(event) {
        this.body = event.target.value;
        this.contentPreview = this.originalTemplate.replace('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', "");
        this.contentPreview = this.contentPreview.replace('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{body}', "");
        this.contentPreview = this.contentPreview.replace('{backgroundImg}', this.linkBackgroundImage);
    }

    // Event - Body of mail changes
    onchangeBackgroundImage(event) {
        this.linkBackgroundImage = event.target.src;
        this.contentPreview = this.originalTemplate.replace('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{subtitle}', "");
        this.contentPreview = this.contentPreview.replace('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
        this.contentPreview = this.contentPreview.replace('{body}', "");
        this.contentPreview = this.contentPreview.replace('{backgroundImg}', this.linkBackgroundImage);
    }

    // Event - Search event lookup
    handleSearch(event) {

        this.isLoading = true;

        searchContact(event.detail)
            .then(results => {
                this.template.querySelector('c-lwc04_lookup').setSearchResults(results);
                this.isLoading = false;
            })
            .catch(error => {
                console.log('>>>> error :');
                console.error(error);
                this.isLoading = false;
            });
    
    }
    

    // Event - Lookup selection changes
    handleSelectionChange() {

        const selection = this.template.querySelector('c-lwc04_lookup').getSelection();

        if (selection.length != 0) {
            this.selectedtargets = selection;
        } 

    }

    // Event - Radio button target type changes
    handleChangeTargetType(event) {

        this.isLoading = true;

        try {
            const selectedOption = event.detail.value;
            this.selectedTargetType = selectedOption;

            // If "all" is selected
            if (this.selectedTargetType === 'all') {
                searchContact({contactType: this.contactType, searchTerm: '', selectedIds: []})
                .then(results => {
                    this.template.querySelector('c-lwc04_lookup').setSelectionManual(results);
                    this.isLoading = false;
                })
                .catch(error => {
                    console.log('>>>> error :');
                    console.error(error);
                    this.isLoading = false;
                });
            } else { // Specific is selected, so empty the list
                this.template.querySelector('c-lwc04_lookup').setSelectionManual([]);
                this.selectedtargets = [];
                this.isLoading = false;
            }
        } catch (error) {
            console.error(error);
            this.isLoading = false;
        }
    }

    handleChangeSendToManager(event) {

        if (this.sendToManager == true) {
            this.sendToManager = false;
        } else {
            this.sendToManager = true;
        }

    }

/* BUSINESS METHODS */
    
    // Send email
    send() {

        this.isLoading = true;
        // No targets selected
        if (this.selectedtargets != null && this.selectedtargets.length == 0) {

            const evtEmpty = new ShowToastEvent({
                title: this.label.lbl_Error_Title,
                message: this.label.lbl_Error_NoTargets,
                variant: 'error'
            });
            this.dispatchEvent(evtEmpty);
            this.isLoading = false;
        } else { // Targets selected

            // Prepare the list of attachments
            let filesId = [];
            for (let i = 0 ; i < this.uploadedFiles.length ; i++) {
                filesId.push(this.uploadedFiles[i].documentId);
            }

            let bodyWithTemplate;
            if(this.chosedEmailTemplate === this.label.lbl_no_template_selected){
                bodyWithTemplate = this.body;
            }
            else{
                bodyWithTemplate = this.originalTemplate.replaceAll('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
                bodyWithTemplate = bodyWithTemplate.replaceAll('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
                bodyWithTemplate = bodyWithTemplate.replaceAll('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
                bodyWithTemplate = bodyWithTemplate.replaceAll('{backgroundImg}', this.linkBackgroundImage);
            }

            sendEmails({ subject: this.subject, body: bodyWithTemplate, targets: this.selectedtargets, files: filesId, sendToManager : this.sendToManager, contactType: this.contactType}) //attachments : this.uploadedFiles
            .then(results => {

                if (results.success) {
                    const evtSuccess = new ShowToastEvent({
                        title: this.label.lbl_Success_SentTitle,
                        message: this.label.lbl_Success_SentMsg,
                        variant: 'success'
                    });
                    this.dispatchEvent(evtSuccess);
                    this.isLoading = false;

                    this.resetForm();

                    this.close();
                } else {
                    const evtError = new ShowToastEvent({
                        title: this.label.lbl_Error_Title,
                        message: results.message,
                        variant: 'error'
                    });
                    this.dispatchEvent(evtError);
                    this.isLoading = false;
                }                
            })
            .catch(error => {
                const evtError = new ShowToastEvent({
                    title: this.label.lbl_Error_Title,
                    message: error,
                    variant: 'error'
                });
                this.dispatchEvent(evtError);
                this.isLoading = false;
            });

        }

    }

    // Utils - Reset form fields
    resetForm() {

        this.isLoading = true;

        this.subject = '';
        this.body = '';
        this.selectedtargets = [];
        this.uploadedFiles = [];
        //this.selectedtargets.length = 0;

        this.isLoading = false;
    }

    handleChangeEmailTemplate(event){

        this.chosedEmailTemplate = event.target.value;

        if(this.chosedEmailTemplate === this.label.lbl_no_template_selected){
            this.displayPreview = false;
            this.displayPreviewSubtitle = false;
            this.displayBackgroundImages = false;
        }
        else{
            for(let template of this.l_emailTemplate){
                if(template.Subject === this.chosedEmailTemplate){

                    this.originalTemplate = template.HtmlValue;

                    if(this.originalTemplate.includes("{subtitle}")){
                        this.displayPreviewSubtitle = true;
                    }
                    else{
                        this.displayPreviewSubtitle = false;
                    }

                    this.contentPreview = template.HtmlValue.replaceAll('{body}', this.body.replaceAll("</p><p>", "<br/>").replaceAll("<p>", "").replaceAll("</p>", ""));
                    this.contentPreview = this.contentPreview.replaceAll('{title}', this.emailTitle.replaceAll("<p>", "").replaceAll("</p>", ""));
                    this.contentPreview = this.contentPreview.replaceAll('{subtitle}', this.emailSubTitle.replaceAll("<p>", "").replaceAll("</p>", ""));


                    if(this.originalTemplate.includes("{backgroundImg}") && this.m_backgroundImageTemplate.has(template.DeveloperName)){
                        this.l_backgroundImages = this.m_backgroundImageTemplate.get(template.DeveloperName);
                        this.contentPreview = this.contentPreview.replaceAll('{backgroundImg}', this.l_backgroundImages[0]);
                        this.linkBackgroundImage = this.l_backgroundImages[0];
                        this.displayBackgroundImages = true;
                    }
                    else{
                        this.displayBackgroundImages = false;
                    }
                }
                this.displayPreview = true;
            }
        }
    }
}