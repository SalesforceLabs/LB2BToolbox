public with sharing class LoyaltyPointsFlow {
    
    @InvocableMethod(Label='B2B Get Total Loyalty Points')
    public static List<Response> doIt(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for(Request request : requests) {

            Response response = new Response();

            Decimal total = LoyaltyPoints.getAccountLoyaltyPoints(request.accountId);

            response.totalRewardPoints = total;

            responses.add(response);
        }

        return responses;

    }

    public class Request {

        @InvocableVariable(Required=true)
        public String accountId;
    }

    public class Response {

        @InvocableVariable
        public Decimal totalRewardPoints;
    }

}