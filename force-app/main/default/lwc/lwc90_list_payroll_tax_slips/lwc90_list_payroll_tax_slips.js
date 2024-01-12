import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import communityBasePath from '@salesforce/community/basePath';

/* APEX */
import getPayrollTaxList from '@salesforce/apex/lwc90_list_payroll_tax_slips_ctrl.getPayrollTaxList';
import getUserCountry from '@salesforce/apex/Lwc85_incentive_challenge_ctrl.getUserCountry';

/* CUSTOM LABELS */
import lbl_columns_name_file from '@salesforce/label/c.LU_Payroll_Tax_List_Column_File';
import lbl_columns_name_publication_date from '@salesforce/label/c.LU_Payroll_Tax_List_Column_Public_Date';
import lbl_columns_name_download_link from '@salesforce/label/c.LU_Payroll_Tax_List_Column_Download_Link';

export default class Lwc90_list_payroll_tax_slips extends NavigationMixin(LightningElement) {

    labels = {
        lbl_columns_name_file,
        lbl_columns_name_publication_date,
        lbl_columns_name_download_link
    };

    isFRA = false;
    isITA = false;

    currentcommunityBasePath;

    l_payrollTaxList = [];

    columns = [{label:lbl_columns_name_file, fieldName:'urlPreview', sortable:true, hideDefaultActions:true, type:'url',
                    typeAttributes: { label: { fieldName:'name' } }
                },
               {label:lbl_columns_name_publication_date, fieldName:'createdDate', sortable:true, type:'text', hideDefaultActions:true},
               {label:'', fieldName:'urlDownload', sortable:false, type:'url', hideDefaultActions:true,
                    typeAttributes: { label: lbl_columns_name_download_link },
                    cellAttributes: { class: 'slds-text-color_default', style: 'color:#6ca5c1;font-weight: bold' },
                }];

    downloadURL = "";
    isCssLoaded = false;

    connectedCallback(){

        this.currentcommunityBasePath = communityBasePath;

        getUserCountry()
        .then(country => {
            if(country === 'FRA'){
                this.isFRA = true;
            }
            else if(country === 'ITA'){
                this.isITA = true;
            }
            getPayrollTaxList()
            .then(results => {

                console.log(results);

                for(let payroll of results){
                    payroll.color = 'slds-text-color_error';
                    if(this.isFRA){
                        payroll.urlDownload = window.location.origin + '/fra/sfc/servlet.shepherd/document/download/' + payroll.contentDocumentID + '?operationContexte=S1';
                        payroll.urlPreview = window.location.origin + '/fra/sfc/servlet.shepherd/document/download/' + payroll.contentDocumentID + '?operationContexte=S1';
                        //payroll.urlPreview = window.location.origin + '/fra/sfc/servlet.shepherd/version/renditionDownload?versionId=' + payroll.contentDocumentID
                    }
                    else if(this.isITA){
                        payroll.urlDownload = window.location.origin + '/ita/sfc/servlet.shepherd/document/download/' + payroll.contentDocumentID + '?operationContexte=S1';
                        payroll.urlPreview = window.location.origin + '/ita/sfc/servlet.shepherd/document/download/' + payroll.contentDocumentID + '?operationContexte=S1';
                        //payroll.urlPreview = window.location.origin + '/fra/sfc/servlet.shepherd/version/renditionDownload?versionId=' + payroll.contentDocumentID
                    }
                }

                this.l_payrollTaxList = results;

                // this.l_payrollTaxList = this.l_payrollTaxList.sort((a,b) => (a.createdDate < b.createdDate) ? 1 : ((b.createdDate < a.createdDate) ? -1 : 0))
                // console.log(this.l_payrollTaxList);
            })
            .catch(error => {
                console.log(">>>error");
                console.log(error);
            });
        })
        .catch(error => {
            console.log('>>>> error lwc16_orderhomebasket:');
            console.log(error);
        });
    }
}