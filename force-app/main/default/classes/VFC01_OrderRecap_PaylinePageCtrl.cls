public class VFC01_OrderRecap_PaylinePageCtrl {
	
	public VFC01_OrderRecap_PaylinePageCtrl() {

	}
	
    public PageReference redirectBack() {
        
        PageReference pageRef = new PageReference('/apex/VFP01_OrderRecap_France');
    	pageRef.getParameters().put('orderId', ApexPages.currentPage().getParameters().get('orderId'));
        pageRef.getParameters().put('dealerId', ApexPages.currentPage().getParameters().get('dealerId'));
        
        return (pageRef);
    }
    
}