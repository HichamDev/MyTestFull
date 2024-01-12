/** STOCK MANAGEMENT class **/
public without sharing class AP38_StockManagement {
    
	public static String separatorProduct = ',';
	public static String DYNAMIC_STOCK = 'Dynamic Stock';
	public static String LIMITED_QUANTITY = 'Limited quantity';
	
    /** Check if the article is in limited stock **/
    /** Parameter in custom setting STHEndpoints **/
    public static Boolean checkIfLimitedStock(CTA_CatalogArticle__c cat, String isoCode, String qtyOrdered) {

		boolean limited = false;

		try {
			
            Decimal stockOrdered = Decimal.valueOf(qtyOrdered);

			if (cat.Article__r.AvailableInStock__c != null) {

				Decimal lowerIndicator = [SELECT stock_lower_indicator__c FROM STHEndpoints__c WHERE Name = :isoCode].stock_lower_indicator__c;
				Decimal stockLeft = cat.Article__r.stock_remaining__c;
				Decimal stockAfterOrder = stockLeft - stockOrdered;

				if (cat.Article__r.OnhandStockStatus__c == LIMITED_QUANTITY || 
					(cat.Article__r.OnhandStockStatus__c == DYNAMIC_STOCK && (stockAfterOrder < 0 || stockAfterOrder < lowerIndicator))) {
					// Stock is limited
					limited = true;
				}

			}

		} catch (Exception e) { AP37_ErrorLog_Utils.add_errorLog(null, AP37_ErrorLog_Utils.FEATURE_STOCK, AP37_ErrorLog_Utils.WHERE_ORDERSTEP1, 'Check stock limited : ', e.getMessage()); 	}

		return limited;
	}
    
    /*
     * public static Boolean checkIfLimitedStock(CTA_CatalogArticle__c cat, String isoCode) {

		boolean limited = false;

		try {
            
			if (cat.Article__r.AvailableInStock__c != null) {
				Decimal lowerIndicator = [SELECT stock_lower_indicator__c FROM STHEndpoints__c WHERE Name = :isoCode].stock_lower_indicator__c;
				Decimal stockLower = (cat.Article__r.AvailableInStock__c - ((cat.Article__r.AvailableInStock__c * lowerIndicator) / 100));
				if (cat.Article__r.OnhandStockStatus__c == LIMITED_QUANTITY || (cat.Article__r.OnhandStockStatus__c == DYNAMIC_STOCK && cat.Article__r.stock_used__c > stockLower)) {
					// Stock is limited
					limited = true;
				}
			}

		} catch (Exception e) {
			AP37_ErrorLog_Utils.add_errorLog(null, AP37_ErrorLog_Utils.FEATURE_STOCK, AP37_ErrorLog_Utils.WHERE_ORDERSTEP1, 
											'Check stock limited : ', e.getMessage());
		}

		return limited;
	}*/
    
    
    /** Get the order line in Dynamic Stock **/
	public static List<ORL_OrderLine__c> getOrderLine (Id orderId) {
        
		List<ORL_OrderLine__c> allOrderLineList =  [SELECT Id, Qty__c, Article__c, Article__r.stock_remaining__c, Article__r.StockStatusMessage__c, Article__r.TECH_offer_children__c, TECH_outOfStock__c From ORL_OrderLine__c Where Order__c = :orderId AND article__r.OnhandStockStatus__c =: DYNAMIC_STOCK];
		if (allOrderLineList.size() > 0) {
			return (allOrderLineList);
		} else { return (null); }
        
	}
    
    /** Check if all order lines in Dynamic Stock of the order have enough stock for the order **/
	public static Set<Id> checkIfAllInStock (Id orderId) {
	
        // Instanciate variables 
        Set<Id> sProductOut = new Set<Id>();
		Boolean withSub = false;
		Boolean withOffer = false;
		Map<Id,Decimal> mOrderLine = new Map<Id,Decimal>();
		Map<Id,Decimal> mOrdersub = new Map<Id,Decimal>();
		Map<Id,Decimal> mOrderStock = new Map<Id,Decimal>();
		Map<String,String> mSubstituteStatus = new Map<String,String>();
		Set<String> sSub = new Set<String>();
		Map<String,String> mOfferProduct = new Map<String,String>();
		Set<String> sOffer = new Set<String>();
		Map<String,Decimal> mIdOffer = new Map<String,Decimal>();
		Map<String,ART_Article__c> mArtOffer = new Map<String,ART_Article__c>();
		Map<Id,Id> mLineArticle = new Map<Id,Id>();
		Map<String,ART_Article__c> mArticleStockStatus = new Map<String,ART_Article__c>();
		List<ORL_OrderLine__c> allOrderLineList = getOrderLine(orderId);
		Map<String, Decimal> mapChildQty = new Map<String, Decimal>();

		// If some order lines have to be check
        if (allOrderLineList != null) {

			List<Id> lOLToResetStockStatus = new List<Id>();
            // For each order line, check the status message, the tech offer children
            for(ORL_OrderLine__c orderLine : allOrderLineList) {

				if (orderLine.TECH_outOfStock__c) {
					lOLToResetStockStatus.add(orderLine.Id);
				}

                // Get the article of the order line
                mLineArticle.put(orderLine.Id,orderLine.Article__c);
				
                // Get substitute article of the article if exists
                if(orderLine.Article__r.StockStatusMessage__c != null) {
					mSubstituteStatus.put(orderLine.Article__c,orderLine.Article__r.StockStatusMessage__c);
					for (String thisLoop : orderLine.Article__r.StockStatusMessage__c.split(separatorProduct)) 
						sSub.add(thisLoop);
				}
				
                // If it is an offer, get the children article of the offer
                if(orderLine.Article__r.TECH_offer_children__c != null) {
					mOfferProduct.put(orderLine.Article__c,orderLine.Article__r.TECH_offer_children__c);
					for (String thisLoop : orderLine.Article__r.TECH_offer_children__c.split(separatorProduct)) {
						sOffer.add(thisLoop);
						if (mapChildQty.containsKey(thisLoop)) {
							mapChildQty.put(thisLoop, mapChildQty.get(thisLoop) + 1);
						} else {
							mapChildQty.put(thisLoop, 1);
						}
					}
				}

				// Aggregate if an article is several time on the order
				if (mOrderLine.containsKey(orderLine.article__c)) {
					mOrderLine.put(orderLine.Article__c,mOrderLine.get(orderLine.Article__c) + orderLine.Qty__c);
				} else {
					mOrderLine.put(orderLine.Article__c,orderLine.Qty__c);
				}
				
                // Get the article current stock
				if (!mOrderStock.containsKey(orderLine.Article__c)) {
					mOrderStock.put(orderLine.Article__c,orderLine.Article__r.stock_remaining__c);
				}
			
            }

			// Reset the stock status of all the order lines
			if (!lOLToResetStockStatus.isEmpty()) {
				List<ORL_OrderLine__c> lUpdateLineStockStatus = new List<ORL_OrderLine__c>();
				for (Id lineId : lOLToResetStockStatus) {
					ORL_OrderLine__c orl = new ORL_OrderLine__c(Id = lineId, TECH_outOfStock__c = false);
					lUpdateLineStockStatus.add(orl);
				}
				update(lUpdateLineStockStatus);
			}
			
            
            // If some offers are to be managed
            if (!mOfferProduct.isEmpty()) {

                // For each article of the offers
                for (ART_Article__c thisOfferArt : [SELECT TECH_ExternalId__c,StockStatusMessage__c,Id,stock_remaining__c,TECH_offer_children__c FROM ART_Article__c WHERE TECH_ExternalId__c IN :sOffer AND OnhandStockStatus__c =: DYNAMIC_STOCK]) {

                    // If the article of the offer has a stock status message equals "Dynamic Stock"
                    if (thisOfferArt.StockStatusMessage__c != null) {
						mSubstituteStatus.put(thisOfferArt.Id,thisOfferArt.StockStatusMessage__c);
						for (String thisLoop : thisOfferArt.StockStatusMessage__c.split(separatorProduct)) 
							sSub.add(thisLoop);
					}
					
                    mIdOffer.put(thisOfferArt.TECH_ExternalId__c,thisOfferArt.stock_remaining__c);
					mArtOffer.put(thisOfferArt.TECH_ExternalId__c,thisOfferArt);
				
                }
			
            }
            
			// If the offer product got substitutes, get only the dynamic stock one
			if (!mSubstituteStatus.isEmpty()) {				
				for (ART_Article__c thisSubArt : [SELECT TECH_ExternalId__c,Id,stock_remaining__c,TECH_offer_children__c FROM ART_Article__c WHERE TECH_ExternalId__c IN :sSub AND OnhandStockStatus__c =: DYNAMIC_STOCK]) {
					mArticleStockStatus.put(thisSubArt.TECH_ExternalId__c,thisSubArt);
				}
                
			}


			// Check the stock status of each order line
			for (Id orderLine : mOrderLine.keySet()){

				// If the stock ordered is bigger than the current article stock
                if (mOrderLine.get(orderLine) > mOrderStock.get(orderLine)) {
					
                    // Check if the article of the order line has substitute to fullfill the stock
					Decimal totalQty = mOrderStock.get(orderLine);

					if (mSubstituteStatus.get(orderLine) != null) {

						// Verify substitute
						for (String subArt : mSubstituteStatus.get(orderLine).split(separatorProduct)) {
							Id subArticle = (mArticleStockStatus.containsKey(subArt) ? mArticleStockStatus.get(subArt).Id : null);
							if (!withSub && subArticle != null) {
								// If the quantity orderd is superior, check the next substitute
								if (mOrderLine.get(orderLine) > totalQty + mArticleStockStatus.get(subArt).stock_remaining__c) {
									if (mArticleStockStatus.get(subArt).stock_remaining__c - totalQty <= 0) {
										mOrdersub.put(subArticle,mArticleStockStatus.get(subArt).stock_remaining__c);
									} else {
										mOrdersub.put(subArticle,mOrderLine.get(orderLine) - totalQty);
									}
									totalQty += mArticleStockStatus.get(subArt).stock_remaining__c;
								} else {
									mOrdersub.put(subArticle,mOrderLine.get(orderLine) - totalQty);
									withSub = true;
									// Max stock of 1st article
									mOrderLine.put(orderLine,mOrderStock.get(orderLine));
								}
							}
						}
					} else {
						withSub = false;
					}
                    
				} else {
					//Stock OK, no need sub
					withSub = true;
				}

				// If not enough stock on the main article and on its substitute if some, set the article out of stock
				if (!withSub) {
					//Order > stock + sub OR no sub
					sProductOut.add(orderLine);
				}
                
				// If the order line is an offer
				if (mOfferProduct.get(orderLine) != null) {

						if (withSub) {
							// this product is already out of stock
							for (String prodOffer : mOfferProduct.get(orderLine).split(separatorProduct)) {

								Decimal qty = mOrderLine.get(orderLine);
								if (mapChildQty.containsKey(prodOffer)) {
									qty = mOrderLine.get(orderLine) * mapChildQty.get(prodOffer);
								}

								if (mArtOffer.get(prodOffer) != null) {

									// if (mOrderLine.get(orderLine) > mArtOffer.get(prodOffer).stock_remaining__c) {
									if (qty > mArtOffer.get(prodOffer).stock_remaining__c) {
										//no stock without sub for this product
										withOffer = false;
										//with sub
										Decimal totalQty = mArtOffer.get(prodOffer).stock_remaining__c;

										if (mSubstituteStatus.get(orderLine) != null) {
											//Verify substitute
											for (String subArt : mSubstituteStatus.get(orderLine).split(separatorProduct)) {
												Id subArticle = mArticleStockStatus.get(subArt).Id;

												//Si la commande est toujours supérieur, on vérifie le suivant
												// if (mOrderLine.get(orderLine) > totalQty + mArticleStockStatus.get(subArt).stock_remaining__c) {
												if (qty > totalQty + mArticleStockStatus.get(subArt).stock_remaining__c) {

													if (mArticleStockStatus.get(subArt).stock_remaining__c-totalQty <= 0) {
														if (mArticleStockStatus.get(subArt).stock_remaining__c > 0)
															mOrdersub.put(subArticle,mArticleStockStatus.get(subArt).stock_remaining__c);
													} else {
														// if (mOrderLine.get(orderLine)-totalQty > 0)
														if (qty-totalQty > 0) {
															// mOrdersub.put(subArticle,mOrderLine.get(orderLine)-totalQty);
															mOrdersub.put(subArticle,qty-totalQty);
														}
													}
													totalQty += mArticleStockStatus.get(subArt).stock_remaining__c;

												} else {

													// if (mOrderLine.get(orderLine)-totalQty > 0) {
													if (qty-totalQty > 0) {
														//with sub this product is ok
														mOrdersub.put(subArticle,mOrderLine.get(orderLine)-totalQty);

													}

													withOffer = true;
												}
											}
										} else {
											//No stock for this product offer
											withOffer = false;
											break;
										}
									} else {
										//Stock for this product offer
										// mOrdersub.put(mArtOffer.get(prodOffer).Id,mOrderLine.get(orderLine));
										mOrdersub.put(mArtOffer.get(prodOffer).Id,qty);
										withOffer = true;
									}
								}
								
							}
						}
						if (!withOffer) {

							// One product offer is out, add orderLine Id
							sProductOut.add(orderLine);
						}
					} else {
						//No offer product
						withOffer = true;
					}

					//withSub = false;
				//If qty > stock (with substitute)

			}
            
			// If at least one line if out of stock
			//if ((!withSub || !withOffer) && sProductOut.size() > 0) {
			if ((withSub || withOffer) && sProductOut.size() > 0) {

				Set<Id> sOrderLineOut = new Set<Id>();
				
				for (Id thisIdLoop : mLineArticle.keySet()) {
					if (sProductOut.contains(mLineArticle.get(thisIdLoop))) {
						sOrderLineOut.add(thisIdLoop);
					}
				}

				return sOrderLineOut;
			} 
            
			// If every line dynmamic stock have enough stock, insert the stock used for the main line and for the substitutes if some used
			setStockUsed(mOrderLine,orderId);
            if (mOrdersub != null && mOrdersub.size() > 0) {
                setStockUsed(mOrdersub,orderId);
            }

			Set<Id> sOrderLine = new Set<Id>();				
			// Set the line of line ok to outofstock = false
			List<ORL_Orderline__c> lOrderLine = [SELECT Id,TECH_outOfStock__c FROM ORL_Orderline__c WHERE Id IN :mLineArticle.keySet()];
		 	for (ORL_Orderline__c loopLine : lOrderLine) {
		 		loopLine.TECH_outOfStock__c = false;
		 	}
		 	if (lOrderLine != null)
		 		update(lOrderLine);

			//Tous les produits ont un stock disponible - sProductOut empty
			return null;

		} else {
			//no product - sProductOut empty
			return sProductOut;
		}
        
	}
    
    
    /** Create the article used line of the order **/
	public static void setStockUsed (Map<Id,Decimal> mOrderItem,Id orderId) {
		
		try {

			List<Stock_use__c> lstStockUse = new List<Stock_use__c>();
			for (Id articleId : mOrderItem.keySet()) {
				Stock_use__c thisStockUse = new Stock_use__c();
				thisStockUse.article__c = articleId;
				thisStockUse.order__c = orderId;
				thisStockUse.quantity_use__c = mOrderItem.get(articleId);
				lstStockUse.add(thisStockUse);
			}

			insert lstStockUse;

		} catch (Exception e) { AP37_ErrorLog_Utils.add_errorLog(orderId, AP37_ErrorLog_Utils.FEATURE_STOCK, AP37_ErrorLog_Utils.WHERE_ORDERSTEP3, 'Insert stock used : ', e.getMessage()); }
	
    }
    
}