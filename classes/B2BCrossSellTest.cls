@IsTest
public with sharing class B2BCrossSellTest {
    
    private static Id parentProductId;
    private static Id crossProductId;
    private static Id crossItemId;
    private static Id crossPbeId;
    private static Id crossStdPbeId;

    private static String crossProductSku = '999AAA000222';

    private static void setupTestData() {

        parentProductId =  B2BTestUtils.createProduct('Parent Product', '999AAA000111', '');

        crossProductId =  B2BTestUtils.createProduct('Cross Product', crossProductSku, '');

        crossItemId = B2BTestUtils.createCrossSellItem(parentProductId, crossProductId);

        Id pricebookId = B2BTestUtils.createPricebook();

        B2BTestUtils.createStandardPricebookEntry(parentProductId);

        B2BTestUtils.createPricebookEntry(pricebookId, parentProductId);

        crossStdPbeId = B2BTestUtils.createStandardPricebookEntry(crossProductId);

        crossPbeId = B2BTestUtils.createPricebookEntry(pricebookId, crossProductId);

    }
    
    @IsTest
    /*
        Test getting the product detail
    */
    public static void testCode1() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        List<ConnectApi.ProductDetail> myProductsInformations = null;

        Test.startTest();

        myProductsInformations = B2BCrossSell.getCrossSellProducts(communityId, parentProductId, effectiveAccountID);

        Test.stopTest();

        System.debug('myProductsInformations: ' + JSON.serialize(myProductsInformations));

        ConnectApi.ProductDetail pd = null;

        pd = myProductsInformations.get(0);

        Map<String, String> fieldMap = pd.fields;

        Product2 product = B2BTestUtils.getProduct(crossProductId);

        String sku = fieldMap.get('StockKeepingUnit');

        System.assertEquals(crossProductSku, sku);
    }

    @IsTest
    /*
        Test getting the product price
    */
    public static void testCode2() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        ConnectApi.ProductPrice price = null;

        Test.startTest();

        price = B2BCrossSell.getProductPrice(communityId, crossProductId, effectiveAccountID);

        Test.stopTest();

        System.debug('price: ' + JSON.serialize(price));

        String listPrice = price.listPrice;
        String unitPrice = price.unitPrice;

        PricebookEntry pbe = B2BTestUtils.getPricebookEntry(crossStdPbeId, crossProductId);

        System.assertEquals(listPrice, pbe.UnitPrice.format());

        PricebookEntry pbe2 = B2BTestUtils.getPricebookEntry(crossPbeId, crossProductId);

        System.assertEquals(unitPrice, pbe2.UnitPrice.format());

    }

    @IsTest
    /*
        Test adding to the cart
    */
    public static void testCode3() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        ConnectApi.CartItem cartItem = null;

        Test.startTest();

        cartItem = B2BCrossSell.addToCart(communityId, crossProductId, '1', effectiveAccountID);

        Test.stopTest();
        System.assertEquals(cartItem, null);

    }

    @IsTest
    /*
        Test the search page url function
    */
    public static void testCode4() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String myCurrentProductURL = null;

        Test.startTest();

        myCurrentProductURL = B2BCrossSell.searchCurrentProductPageURL();

        Test.stopTest();

        System.debug(myCurrentProductURL);
        
        Boolean checkIt = myCurrentProductURL.endsWith('/s/product/');

        System.assertEquals(checkIt, true);

    }

}