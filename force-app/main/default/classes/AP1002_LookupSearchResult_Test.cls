@IsTest
public class AP1002_LookupSearchResult_Test {

    @IsTest
    static void testAP1002_LookupSearchResult() {

        AP1002_LookupSearchResult lsr = new AP1002_LookupSearchResult();
        lsr = new AP1002_LookupSearchResult('0031a00000AAaAaAAA', 'a', 'a', 'a', 'a');
        lsr.quantity = 1;
        lsr.unitPrice = 1;
        lsr.priceHT = 1;
        lsr.taxRate = 1;
        lsr.priceTTC = 1;
        lsr.isInBundle = true;
        lsr.idBundle = '0031a00000AAaAaAAA';
        lsr.displayInPreBasketList = true;
        lsr.isReadOnly = true;
        lsr.maxQuantity = 1;
        lsr.minQuantity = 1;
        lsr.numberOfArticle = 1;
        lsr.priceBook = '0031a00000AAaAaAAA';
        lsr.productId = '0031a00000AAaAaAAA';
        lsr.validForTotalMountBase = true;
    }
}