// Anonymous exec: List<ConnectApi.ManagedContentVersion> results = cmsContentFilter.searchForMetadata('BannerURL','magasin','standard');
public with sharing class matchCMSContent {

    // vboucher - begin
    @AuraEnabled(cacheable=true)
    public static String getProductSKU(String productId) {
        // SELECT Id, Name, StockKeepingUnit FROM Product2
        System.debug('My productId is: '+productId);
        string soql='SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id =: '+productId;
        System.debug('My SOQL is: '+soql);

        Product2 myProd = null;

        if(Schema.sObjectType.Product2.fields.Name.isAccessible()
        && Schema.sObjectType.Product2.fields.StockKeepingUnit.isAccessible()) {

            myProd = [ SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id =: productId][0];

        }

        System.debug('My Product SKU is: '+myProd.StockKeepingUnit);
        return myProd.StockKeepingUnit;
    }
  
    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.ManagedContentVersion> searchForProductMetadata(String cmsContentType, String cmsContentFieldName, String matchingRecord){

        String managedContentIdsStr;
        String topicNamesStr;
        String contentType;
        String errorMessage;
        String resultSearchFor;
        
        //communityId = '0DBB00000008oxBOAQ';
        //userId = '005B0000006uv21IAA';
        //Test with Promocash COmmunity ID from Network Object

        System.debug('INPUT PARAMETERS: cmsContentType '+cmsContentType);
        System.debug('INPUT PARAMETERS: cmsContentFieldName '+cmsContentFieldName);
        System.debug('INPUT PARAMETERS: matchingRecord '+matchingRecord);
        
        List<ConnectApi.ManagedContentVersion> results;
        // Initiate this new list
        List<ConnectApi.ManagedContentVersion> personalisedResults= new List<ConnectApi.ManagedContentVersion>();
        // Initiate this new list
        List<ConnectApi.ManagedContentVersion> standardResults= new List<ConnectApi.ManagedContentVersion>();
        String communityId = Network.getNetworkId();
        String userId = UserInfo.getUserId();
    
        List<String> contentIds = new List<String>();
        List<String> topicNames = new List<String>();
        try{
            if(topicNamesStr != null && !String.isEmpty(topicNamesStr)){
                topicNames = topicNamesStr.split(',',-1); 
            }
            
            for(Integer i=0;i<topicNames.size();i++){
                topicNames.set(i,topicNames.get(i).trim());
            }
            
            String language = 'en_US';

            ConnectApi.ManagedContentVersionCollection contentList = null;

            If(Test.isRunningTest() == false) {
                contentList = ConnectApi.ManagedContent.getManagedContentByTopicsAndIds(communityId, contentIds, topicNames, 0, 25, language, cmsContentType);
            }
            else {
                contentList = new ConnectApi.ManagedContentVersionCollection();

                List<ConnectApi.ManagedContentVersion> contentItems = new List<ConnectApi.ManagedContentVersion>();

                Map<String, ConnectApi.ManagedContentNodeValue> contentNodes = new Map<String, ConnectApi.ManagedContentNodeValue>();

                // This is the node we match on
                ConnectApi.ManagedContentTextNodeValue contentNode = new ConnectApi.ManagedContentTextNodeValue();
                contentNode.nodeType = ConnectApi.ConnectManagedContentNodeType.TEXT;
                contentNode.value = matchingRecord;
                contentNodes.put(cmsContentFieldName, contentNode);

                // Some extra Text nodes
                ConnectApi.ManagedContentTextNodeValue contentNode2 = new ConnectApi.ManagedContentTextNodeValue();
                contentNode2.nodeType = ConnectApi.ConnectManagedContentNodeType.TEXT;
                contentNode2.value = 'So, you’ve decided to dive in and open your very own café. Opening a successful coffee shop can be a rewarding experience.';
                contentNodes.put('Title', contentNode2);

                ConnectApi.ManagedContentTextNodeValue contentNode3 = new ConnectApi.ManagedContentTextNodeValue();
                contentNode3.nodeType = ConnectApi.ConnectManagedContentNodeType.NameField;
                contentNode3.value = 'HOW TO OPEN A CAFÉ: A STEP-BY-STEP GUIDE';
                contentNodes.put('Description', contentNode3);

                ConnectApi.ManagedContentVersion item = new ConnectApi.ManagedContentVersion();
                item.contentNodes = contentNodes;
                item.language = 'en_US';
                item.title = 'HOW TO OPEN A CAFÉ: A STEP-BY-STEP GUIDE';
                item.type = 'Blog';
                item.typeLabel = 'Blog';
                item.contentUrlName = 'how-to-open-a-caf-a-step-by-step-guide';
                item.publishedDate = DateTime.now();

                contentItems.add(item);

                contentList.items = contentItems;

            }

            results = contentList.items;  
            System.debug('#### SIZE :' + results.size());

            for(ConnectApi.ManagedContentVersion resultElement : results){
                System.debug('ALL ELEMENT: '+ resultElement);

                System.debug('#### We have :' + resultElement.contentNodes.get(cmsContentFieldName));
                //Retrieve value of content type text field
                String cmsValue;
                if (resultElement.contentNodes.get(cmsContentFieldName) != null){
                 cmsValue= ((ConnectApi.ManagedContentTextNodeValue)resultElement.contentNodes.get(cmsContentFieldName)).value;
                }
                System.debug('####  We have cms value equal to :' + cmsValue);
                System.debug('####  We have metadata value equal to :' + matchingRecord);
                if (cmsValue==matchingRecord)
                {
                    System.debug('####  yes');
                    personalisedResults.add(resultElement);
                }

            }

            if (personalisedResults.size() != 0){
                System.debug('#### FINALOYYYYYYYYY :' + personalisedResults);
                return personalisedResults;
            }
            else return null;
            
        }
        catch(ConnectApi.ConnectApiException e){
            errorMessage = e.getMessage();
            System.debug('Error Message : '+e);
            ApexPages.addMessages(e);
            results = new List<ConnectApi.ManagedContentVersion>();
            return results;
        }           
    } 

}