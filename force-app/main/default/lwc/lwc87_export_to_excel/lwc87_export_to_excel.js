import { LightningElement, track, api  } from "lwc";  
import LANG from '@salesforce/i18n/lang';
import LOCALE from '@salesforce/i18n/locale';
import CURRENCY from '@salesforce/i18n/currency';

//import Lwc87_export_to_excel from "@salesforce/apex/lwc87_export_to_excel_ctrl.getContacts";  
export default class ExportToExcelDemo extends LightningElement {  
  @track hrefdata;  
  @api l_ordersToDisplay;
  @api orderObject;
  @api labels;
  @api isITA;
  @api isDirector;
  @api isFRA;

  connectedCallback() {  
    //this.getContacts();  
  }  

  formatDateExcel(DateVal) {
    var date = new Date(Date.parse(DateVal));
    //24/06/21 10:52
    var yr = date.getFullYear();
    var mo = date.getMonth() + 1;
    var day = date.getDate();
    
    var hours = date.getHours();
    var hr = hours < 10 ? '0' + hours : hours;
    
    var minutes = date.getMinutes();
    var min = (minutes < 10) ? '0' + minutes : minutes;
    
    var seconds = date.getSeconds();
    var sec = (seconds < 10) ? '0' + seconds : seconds;
    
    var newDateString = day + '/' + mo + '/' + yr; //yr + '-' + mo  + '-' + day;
    var newTimeString = hr + ':' + min + ':' + sec;
    
    var excelDateString = newDateString + ' ' + newTimeString;
    return excelDateString;
  }

  formatCurrencyExcel(strAmount) {
      return new Intl.NumberFormat(LOCALE, {
        style: 'currency',
          currency: CURRENCY,
          currencyDisplay: 'symbol'
      }).format(parseInt(strAmount));
  }

  exportToCSV() {  
    let columnHeader = []; //This array holds the Column headers to be displayd
    let jsonKeys = []; //This array holds the keys in the json data 
    let l_ordersToDisplay = JSON.parse(JSON.stringify(this.l_ordersToDisplay))
    try {
      this.l_ordersToDisplay.forEach((x, i) => {
        if(x.BillToContact) {
          if(x.BillToContact.Account) {
            l_ordersToDisplay[i].BillToContactAccountName = x.BillToContact.Account.Name;
          }
          l_ordersToDisplay[i].BillToContactLastName = x.BillToContact.LastName;
          l_ordersToDisplay[i].BillToContactName = x.BillToContact.Name;
          l_ordersToDisplay[i].BillToContactSTHID = x.BillToContact.STHID__c;
        }
        if(x.CreatedBy) {
          l_ordersToDisplay[i].CreatedByName = x.CreatedBy.Name;
        }

        l_ordersToDisplay[i].LU_Total_Price_Without_Taxes__c = x.LU_Total_Price_Without_Taxes__c;
        l_ordersToDisplay[i].LU_TECH_Order_Date__c = this.formatDateExcel(x.LU_TECH_Order_Date__c); 
      })
    } catch (error) {
      console.error(error);
      // expected output: ReferenceError: nonExistentFunction is not defined
      // Note - error messages will vary depending on browser
    }
    let orderObject = this.orderObject;
    let labels = this.labels;
    if(this.isITA) {
      if(this.isDirector) {
        columnHeader = [orderObject.BillToContactId, orderObject.BillToContactId, orderObject.Name, orderObject.Status, 
          orderObject.CreatedDate, orderObject.TotalAmount, orderObject.CreatedBy, orderObject.LU_Invoice_Date__c, 
          orderObject.LU_Invoice_Number__c, orderObject.LU_Amount_To_Pay__c]; 
          jsonKeys = ["BillToContactSTHID", "BillToContactName", "Name", "Status", "LU_TECH_Order_Date__c", "LU_TECH_AmountForMinimumOrder__c", "CreatedByName", "LU_Invoice_Date__c", "LU_Invoice_Number__c", "LU_Amount_To_Pay__c"];
      } else {
        columnHeader = [orderObject.Name, orderObject.Type, orderObject.Status, orderObject.EffectiveDate, orderObject.LU_Number_Of_Articles__c,
          orderObject.TotalAmount, orderObject.LU_Invoice_Number__c, orderObject.BillToContactId, orderObject.LU_Invoice_Date__c, orderObject.LU_Amount_To_Pay__c];
          jsonKeys = ["Name", "Type", "Status", "LU_TECH_Order_Date__c", "LU_TECH_AmountForMinimumOrder__c", "LU_Invoice_Number__c", "BillToContactName", "LU_Invoice_Date__c", "LU_Amount_To_Pay__c"];
      }
    }
    if(this.isFRA) {
      columnHeader = [orderObject.Name, labels.LU_Order_Column_Account, labels.LU_Order_Column_Contact, 'Client', 
      orderObject.EffectiveDate, orderObject.Status, orderObject.LU_Transporter__c, orderObject.LU_Shipping_Date__c, 
      orderObject.LU_Total_Price_Without_Taxes__c, orderObject.LU_Total_Amount_For_Valid_Base__c, 
      orderObject.LU_Invoice_Number__c, orderObject.LU_Invoice_Status__c
    ];  
      jsonKeys = ["Name", "BillToContactAccountName", "BillToContactLastName", "LU_CUSTOMER_LASTNAME__c", "LU_TECH_Order_Date__c",
        "Status", "LU_Transporter__c", "LU_Shipping_Date__c", "LU_Total_Price_Without_Taxes__c", "LU_Total_Amount_For_Valid_Base__c", "LU_Invoice_Number__c", "LU_Invoice_Status__c"]; 
    }

    var jsonRecordsData = l_ordersToDisplay;  
    let csvIterativeData;  
    let csvSeperator ;
    let newLineCharacter;  
    csvSeperator = ";";  
    newLineCharacter = "\n";  
    csvIterativeData = "";  
    csvIterativeData += columnHeader.join(csvSeperator);  
    csvIterativeData += newLineCharacter;  
    for (let i = 0; i < jsonRecordsData.length; i++) {  
      let counter = 0;  
      for (let iteratorObj in jsonKeys) {  
        let dataKey = jsonKeys[iteratorObj];  
        if (counter > 0) {  csvIterativeData += csvSeperator;  }  
        if (  jsonRecordsData[i][dataKey] !== null &&  
          jsonRecordsData[i][dataKey] !== undefined  
        ) {  csvIterativeData += '"' + jsonRecordsData[i][dataKey] + '"';  
        } else {  csvIterativeData += '""';  
        }  
        counter++;  
      }  
      csvIterativeData += newLineCharacter;  
    }  
    console.log("csvIterativeData", csvIterativeData);  
    this.hrefdata = "data:text/csv;charset=utf-8," + encodeURI(csvIterativeData);  
  }  
}