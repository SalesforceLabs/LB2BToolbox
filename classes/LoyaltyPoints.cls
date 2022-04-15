public with sharing class LoyaltyPoints {
    
    @AuraEnabled(cacheable=true)
    public static List<Loyalty_Reward_Point__c> getConsumtion(String accountId) {
        List<Loyalty_Reward_Point__c> consumtion = new List<Loyalty_Reward_Point__c>();

        try {

            if(Schema.sObjectType.Loyalty_Reward_Point__c.fields.Account__c.isAccessible()
                && Schema.sObjectType.Loyalty_Reward_Point__c.fields.Point__c.isAccessible()
                && Schema.sObjectType.Loyalty_Reward_Point__c.fields.Type__c.isAccessible()
                && Schema.sObjectType.Loyalty_Reward_Point__c.fields.CreatedDate.isAccessible()
                ) {

                consumtion = [
                    SELECT Account__c, Point__c, Type__c, CreatedDate
                    FROM Loyalty_Reward_Point__c
                    WHERE Account__c = :accountId
                    ORDER BY CreatedDate DESC
                ];

            }
        } 
        catch(Exception ex) {  
            System.debug('exception: ' + ex.getMessage());
            throw ex;  
        }
        return consumtion;

    }

    @AuraEnabled(cacheable=true)
    public static Decimal getLoyaltyPointsTotal(String accountId){
        
        Decimal total = getAccountLoyaltyPoints(accountId);

        return total;

    }

    public static Decimal getAccountLoyaltyPoints(String accountId) {

        Decimal total = 0;

        if(Schema.sObjectType.Loyalty_Reward_Point__c.fields.Account__c.isAccessible()
                && Schema.sObjectType.Loyalty_Reward_Point__c.fields.Point__c.isAccessible()
                ) {
            AggregateResult[] AggregateResultList = [SELECT Sum(Point__c)points FROM Loyalty_Reward_Point__c where Account__c = :accountId and Point__c != null];

            if(AggregateResultList != null && AggregateResultList.size() > 0){ 

                Object sumPoints = AggregateResultList[0].get('points');

                if(sumPoints != null) {
                    total = (Decimal)sumPoints;
                }

            }

        }

        return total;

    }
}