@IsTest
public with sharing class matchCMSContentTest {

    private static Id productId;

    private static String productSku = '999AAA000222';
    
    private static void setupTestData() {

        productId =  B2BTestUtils.createProduct('Some Product', productSku, '');

    }

    @IsTest
    /*
        Test getting the product SKU
    */
    public static void testCode1() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String communityId = null;
        String effectiveAccountID = null;

        Test.startTest();

        String returnedSku = matchCMSContent.getProductSKU(productId);

        Test.stopTest();

        System.assertEquals(productSku, returnedSku);
        
    }

    @IsTest
    /*
        Get managed content
    */
    public static void testCode2() {

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        String cmsContentType = 'Blog';
        String cmsContentFieldName = 'AssociatedProductSKUs';
        String matchingRecord = 'bundle01';

        List<ConnectApi.ManagedContentVersion> personalisedResults = null;

        String returnedMatchingRecord = null;

        Test.startTest();

        personalisedResults = matchCMSContent.searchForProductMetadata(cmsContentType, cmsContentFieldName, matchingRecord);

        Test.stopTest();

        System.debug('personalisedResults: ' + personalisedResults);

        for(ConnectApi.ManagedContentVersion result : personalisedResults){

            Map<String, ConnectApi.ManagedContentNodeValue> contentNodes = result.contentNodes;

            if(contentNodes.containsKey(cmsContentFieldName)) {
                ConnectApi.ManagedContentTextNodeValue contentNode = (ConnectApi.ManagedContentTextNodeValue)contentNodes.get(cmsContentFieldName);

                returnedMatchingRecord = contentNOde.value;

                break;
            }

        }

        System.debug('returnedMatchingRecord: ' + returnedMatchingRecord);

        System.assertEquals(matchingRecord, returnedMatchingRecord);
        
    }

}