@IsTest
public with sharing class LoyaltyPointsTest {
    
    private static String accountId = null;
    private static String loyaltyId = null;

    private static void setupTestData() {

        System.debug('begin setupTestData()');

        accountId = B2BTestUtils.createAccount();

        loyaltyId = B2BTestUtils.createLoyaltyRecord(accountId);

    }

    @IsTest
    /*
        Test the method
    */
    public static void testCode1() {

        System.debug('begin testCode1()');

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        Test.startTest();

        List<Loyalty_Reward_Point__c> consumtion = LoyaltyPoints.getConsumtion(accountId);

        Test.stopTest();

        String retrievedAccountId = null;

        for(Loyalty_Reward_Point__c loy : consumtion) {

            retrievedAccountId = loy.Account__c;
            break;

        }

        System.assertEquals(accountId, retrievedAccountId);

    }

    @IsTest
    /*
        Test the method used in by the LWC component to get the loyalty points total.
    */
    public static void testCode2() {

        System.debug('begin testCode2()');

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        Test.startTest();

        Decimal retrievedTotal = LoyaltyPoints.getLoyaltyPointsTotal(accountId);

        Test.stopTest();

        Decimal total = 0;

        List<Loyalty_Reward_Point__c> loyList = [Select Id, Name, Point__c from Loyalty_Reward_Point__c where Id = :loyaltyId];

        if(loyList.size() > 0) {
            Loyalty_Reward_Point__c loy = loyList.get(0);
            total = loy.Point__c;
        }

        System.assertEquals(total, retrievedTotal);

    }

    @IsTest
    /*
        Test the method used in by the Flow to get the loyalty points total.
    */
    public static void testCode3() {

        System.debug('begin testCode2()');

        User adminUser = B2BTestUtils.createAdminUser();

        System.runAs(adminUser) {
            setupTestData();
        }

        LoyaltyPointsFlow.Request request = new LoyaltyPointsFlow.Request();
        request.accountId = accountId;

        List<LoyaltyPointsFlow.Request> requestList = new List<LoyaltyPointsFlow.Request>();
        requestList.add(request);

        Test.startTest();

        Decimal retrievedTotal = 0;

        List<LoyaltyPointsFlow.Response> responseList = LoyaltyPointsFlow.doIt(requestList);

        if(responseList.size() > 0) {
            LoyaltyPointsFlow.Response response = responseList.get(0);
            retrievedTotal = response.totalRewardPoints;
        }

        Test.stopTest();

        Decimal total = 0;

        List<Loyalty_Reward_Point__c> loyList = [Select Id, Name, Point__c from Loyalty_Reward_Point__c where Id = :loyaltyId];

        if(loyList.size() > 0) {
            Loyalty_Reward_Point__c loy = loyList.get(0);
            total = loy.Point__c;
        }

        System.assertEquals(total, retrievedTotal);

    }

}