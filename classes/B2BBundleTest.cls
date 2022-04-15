@IsTest
public with sharing class B2BBundleTest {

    private static Id parentProductId;
    private static Id bundleProductId;
    private static Id bundleItemId;
    private static Id bundlePbeId;
    private static Id bundleStdPbeId;

    private static String bundleProductSku = '999AAA000222';

    private static void setupTestData() {

        parentProductId =  B2BTestUtils.createProduct('Parent Product', '999AAA000111', '');

        bundleProductId =  B2BTestUtils.createProduct('Bundle Product', bundleProductSku, '');

        bundleItemId = B2BTestUtils.createBundleItem(parentProductId, bundleProductId, 2);

        Id pricebookId = B2BTestUtils.createPricebook();

        B2BTestUtils.createStandardPricebookEntry(parentProductId);

        B2BTestUtils.createPricebookEntry(pricebookId, parentProductId);

        bundleStdPbeId = B2BTestUtils.createStandardPricebookEntry(bundleProductId);

        bundlePbeId = B2BTestUtils.createPricebookEntry(pricebookId, bundleProductId);

    }
    
    @IsTest
    /*
        Test getting the product detail
    */
    public static void testCode1() {

        User adminUser = B2BTestUtils.createAdminUser();
        
        B2BTestUtils.assignPermissionSetToUser(adminUser.Id, 'LB2B_Toolbox_Permissions');

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        List<ConnectApi.ProductDetail> myProductsInformations = null;

        Test.startTest();

        myProductsInformations = B2BBundle.getBundleProducts(communityId, parentProductId, effectiveAccountID);

        Test.stopTest();

        System.debug('myProductsInformations: ' + JSON.serialize(myProductsInformations));

        ConnectApi.ProductDetail pd = null;

        pd = myProductsInformations.get(0);

        Map<String, String> fieldMap = pd.fields;

        Product2 product = B2BTestUtils.getProduct(bundleProductId);

        String sku = fieldMap.get('StockKeepingUnit');

        System.assertEquals(bundleProductSku, sku);
    }

    @IsTest
    /*
        Test getting the product price
    */
    public static void testCode2() {

        User adminUser = B2BTestUtils.createAdminUser();
        
        B2BTestUtils.assignPermissionSetToUser(adminUser.Id, 'LB2B_Toolbox_Permissions');

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        ConnectApi.ProductPrice price = null;

        Test.startTest();

        price = B2BBundle.getProductPrice(communityId, bundleProductId, effectiveAccountID);

        Test.stopTest();

        System.debug('price: ' + JSON.serialize(price));

        String listPrice = price.listPrice;
        String unitPrice = price.unitPrice;

        PricebookEntry pbe = B2BTestUtils.getPricebookEntry(bundleStdPbeId, bundleProductId);

        System.assertEquals(listPrice, pbe.UnitPrice.format());

        PricebookEntry pbe2 = B2BTestUtils.getPricebookEntry(bundlePbeId, bundleProductId);

        System.assertEquals(unitPrice, pbe2.UnitPrice.format());

    }

    @IsTest
    /*
        Test adding to the cart
    */
    public static void testCode3() {

        User adminUser = B2BTestUtils.createAdminUser();
        
        B2BTestUtils.assignPermissionSetToUser(adminUser.Id, 'LB2B_Toolbox_Permissions');

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        ConnectApi.CartItem cartItem = null;

        Test.startTest();

        cartItem = B2BBundle.addToCart(communityId, bundleProductId, '1', effectiveAccountID);

        Test.stopTest();
        System.assertEquals(cartItem, null);

    }

    @IsTest
    /*
        Test getting the bundle item qty
    */
    public static void testCode4() {

        User adminUser = B2BTestUtils.createAdminUser();
        
        B2BTestUtils.assignPermissionSetToUser(adminUser.Id, 'LB2B_Toolbox_Permissions');

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        Decimal qty = null;

        Test.startTest();

        qty = B2BBundle.getItemQuantity(parentProductId, bundleProductId);

        Test.stopTest();

        Bundle_Item__c bundle = B2BTestUtils.getBundleItem(bundleItemId);

        System.assertEquals(qty, bundle.Quantity__c);

    }

    @IsTest
    /*
        Test the search page url function
    */
    public static void testCode5() {

        User adminUser = B2BTestUtils.createAdminUser();
        
        B2BTestUtils.assignPermissionSetToUser(adminUser.Id, 'LB2B_Toolbox_Permissions');

        System.runAs(adminUser) {
            setupTestData();
        }

        String myCurrentProductURL = null;

        Test.startTest();

        myCurrentProductURL = B2BBundle.searchCurrentProductPageURL();

        Test.stopTest();

        System.debug(myCurrentProductURL);

        Boolean checkIt = myCurrentProductURL.endsWith('/s/product/');

        System.assertEquals(checkIt, true);

    }

}