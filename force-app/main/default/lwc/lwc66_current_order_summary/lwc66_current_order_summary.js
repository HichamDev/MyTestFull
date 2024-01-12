import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import LogoBtn from '@salesforce/resourceUrl/Lu_Icons';

import getDraftOrder from '@salesforce/apex/lwc66_current_order_summary_ctrl.getDraftOrder';
import getWishlist from '@salesforce/apex/lwc66_current_order_summary_ctrl.getWishlist';
import addWishlistToOrder from '@salesforce/apex/lwc66_current_order_summary_ctrl.addWishlistToOrder';
import deleteWishlist from '@salesforce/apex/lwc66_current_order_summary_ctrl.deleteWishlist';
import updateWishlistStatus from '@salesforce/apex/lwc66_current_order_summary_ctrl.updateWishlistStatus';

/* IMPORT CUSTOM LABELS */
import LU_Order_Tab_Summary_Title from '@salesforce/label/c.LU_Order_Tab_Summary_Title';
import LU_Order_Tab_Summary_CurrentOrder_Title from '@salesforce/label/c.LU_Order_Tab_Summary_CurrentOrder_Title';
import LU_Order_Tab_Summary_CurrentOrder_ViewButton from '@salesforce/label/c.LU_Order_Tab_Summary_CurrentOrder_ViewButton';
import LU_Order_Tab_Summary_CurrentOrder_CheckoutButton from '@salesforce/label/c.LU_Order_Tab_Summary_CurrentOrder_CheckoutButton';
import lbl_pagination_postion from '@salesforce/label/c.LU_Pagination_Position';
import lbl_Max_Orders_Per_Page from '@salesforce/label/c.LU_Order_History_Max_Orders_Per_Page';
import lbl_wishlist_button_complete from '@salesforce/label/c.LU_Wishlist_Button_Complete';
import lbl_wishlist_button_delegate from '@salesforce/label/c.LU_Wishlist_Button_Delegate';
import lbl_wishlist_button_close from '@salesforce/label/c.LU_Wishlist_Button_Close';
import lbl_wishlist_list_title from '@salesforce/label/c.LU_Wishlist_List_Title';

export default class Lwc66_current_order_summary extends NavigationMixin(LightningElement) {

    iconEdit = LogoBtn + '/icons/icon-edit.svg';
    iconFlip = LogoBtn + '/icons/icon-flip.svg';
    iconDelete = LogoBtn + '/icons/icon-delete.svg';

    // LABELS
    labels = {
        LU_Order_Tab_Summary_Title,
        LU_Order_Tab_Summary_CurrentOrder_Title,
        LU_Order_Tab_Summary_CurrentOrder_ViewButton,
        LU_Order_Tab_Summary_CurrentOrder_CheckoutButton,
        lbl_pagination_postion,
        lbl_wishlist_button_complete,
        lbl_wishlist_button_delegate,
        lbl_wishlist_button_close,
        lbl_wishlist_list_title
    }

    @track order;
    @track isDraftOrder = false;
    @track displayWishlist = false;
    @track displayPopoverDeletion = false;
    @track currentPage = 1;
    @track maxPage = 1;
    @track maxWishListsPerPage = 5;
    @track l_wishlist = [];
    @track l_wishlistToDisplay = [];

    connectedCallback(){
        getDraftOrder() 
            .then(results => {
                console.log('getDraftOrder results');
                console.log(results);
                this.order = results;

               /* if(this.order !== null && results.OrderItems.length != 0){
                    this.isDraftOrder = true;
                }*/

                if(this.order !== null){
                    this.isDraftOrder = true;
                }

                console.log('this.isDraftOrder',this.isDraftOrder);
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });

        getWishlist()
            .then(results => {
                console.log('XXXXXXXXXXXXXX getWishlist XXXXXXXXXXXXXXXXXXX')
                console.log(results)
                
                this.l_wishlist = results;
                this.l_wishlistToDisplay = results;

                if(this.l_wishlist !== null && this.l_wishlist.length > 0){
                    this.refreshPagination();
                    this.displayWishlist = true;
                }
                
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    goToOrder(event){
        console.log(event.target.dataset.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                actionName: 'view',
            },
            state: {
                orderId: event.target.id
            },
        });
        // .then(url => {
        //     this.recordPageUrl = url;
        // });
    }

    goToCheckout() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'order-checkout',
            },
            state: {
                orderId: this.order.Id
            },
        });
    }

    validateWishlist(event){

        addWishlistToOrder({idWishlist : event.target.dataset.id})
            .then(results => {
                
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'order',
                    }
                });
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    displayDeletePopover(event){
        this.idWishlistToDelete = event.target.dataset.id;

        this.displayPopoverDeletion = true;
    }

    handleCloseDeletePopover(){
        this.displayPopoverDeletion = false;
    }

    deleteSelectedWishlist(event){
        deleteWishlist({idWishlist : event.target.dataset.id})
            .then(results => {
                
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'order',
                    }
                });
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    cloturerSelectedWishlist(event){
        updateWishlistStatus({idWishlist : event.target.dataset.id, status : 'Cancelled'})
            .then(results => {
                //this.l_wishlist = this.l_wishlist.filter(x=> x.Id !== selectedId);
                this.displayPopoverDeletion = false;
                location.reload();
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'order',
                    }
                });*/
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    
    deleguerSelectedWishlist(event){
        updateWishlistStatus({idWishlist : event.target.dataset.id, status : 'Delegated'})
            .then(results => {
                location.reload();
            })
            .catch(error => {
                console.log('>>>> error :');
                console.log(error);
            });
    }

    //* PAGINATION
    refreshPagination(){
        if (this.l_wishlist != null) {
            this.maxPage = Math.floor( this.l_wishlist.length / this.maxWishListsPerPage ) + 1;
            this.l_wishlistToDisplay = this.l_wishlist.slice(0, this.maxWishListsPerPage);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
        
    }
    nextPage(){
        if(this.currentPage < this.maxPage){
            this.currentPage++;
            this.l_wishlistToDisplay = this.l_wishlist.slice(this.currentPage * this.maxWishListsPerPage - this.maxWishListsPerPage, this.currentPage * this.maxWishListsPerPage);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    previousPage(){
        if(this.currentPage > 1){
            this.currentPage--;
            this.l_wishlistToDisplay = this.l_wishlist.slice(this.currentPage * this.maxWishListsPerPage - this.maxWishListsPerPage, this.currentPage * this.maxWishListsPerPage);
            this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
        }
    }
    firstPage(){
        this.currentPage = 1;
        this.l_wishlistToDisplay = this.l_wishlist.slice(this.currentPage * this.maxWishListsPerPage - this.maxWishListsPerPage, this.currentPage * this.maxWishListsPerPage);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }
    lastPage(){
        this.currentPage = this.maxPage;
        this.l_wishlistToDisplay = this.l_wishlist.slice(this.currentPage * this.maxWishListsPerPage - this.maxWishListsPerPage, this.currentPage * this.maxWishListsPerPage);
        this.labels.lbl_pagination_postion_edited = this.labels.lbl_pagination_postion.replace('xx', this.currentPage).replace('yy', this.maxPage);
    }
}