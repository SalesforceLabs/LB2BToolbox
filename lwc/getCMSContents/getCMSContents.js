import { LightningElement, api,track} from 'lwc';
import searchForProductMetadata from '@salesforce/apex/matchCMSContent.searchForProductMetadata';


export default class getCMSContent extends LightningElement {
    @track contentList;
    //@api recordId;
    @api contentType;
    @api cmsContentFieldName;
    @api productSKU;
    //@track MyproductSKU;
    @track baseURL;
    @track recordList;
    @api
    effectiveAccountId;
  
    
    connectedCallback() {
        window.console.log('contentType', this.contentType);
        this.fetchContent();

        const urlString = window.location.href; 
        this.baseURL = urlString.substring(0,urlString.indexOf('/s'));
        window.console.log('baseUrl', this.baseURL);
      }

    /*@wire(searchForProductMetadata, {
        cmsContentType: "$contentType",
        cmsContentFieldName: "$cmsContentFieldName",
        matchingRecord: "$MyproductSKU"
    })
    myownresults;*/

    async fetchContent() {
        let myContent;
        let i;
        //window.console.log('vboucher log: contentType: ',this.contentType);
        //window.console.log('vboucher log: cmsContentFieldName: ',this.cmsContentFieldName);
        //window.console.log('vboucher log: productSKU: ',this.productSKU);
        try {
          const content = await searchForProductMetadata({cmsContentType:this.contentType, cmsContentFieldName:this.cmsContentFieldName,matchingRecord:this.productSKU});
            //searchForProductMetadata(String cmsContentType, String cmsContentFieldName, String matchingRecord){
          //myContent = content;
          myContent = JSON.parse(JSON.stringify(content));
          window.console.log('myContent:', myContent);

          for (i=0;i<myContent.length;i++)
          {

            //window.console.log('TITLE: ',myContent[i].contentNodes.Title);
            // nodeType, value
            //window.console.log('TITLE nodeType: ',myContent[i].contentNodes.Title.nodeType);
            window.console.log('TITLE value: ',myContent[i].contentNodes.Title.value);
            window.console.log('Description: ',myContent[i].contentNodes.Description.value);
            window.console.log('AssociatedProductSKUs: ',myContent[i].contentNodes.AssociatedProductSKUs.value);
            window.console.log('Details: ',myContent[i].contentNodes.Details.value);
            window.console.log('MainPicture: ',myContent[i].contentNodes.MainPicture.fileName);
            //https://b2bcap-172b6533342.force.com/coffeestore/cms/delivery/media/0m5PRCfVXlPBoDiyrVclxQYHozvBTI3HLwP45eLuDEQ=?width=1518&height=1139
            //window.console.log('MainPicture URL: ',myContent[i].contentNodes.MainPicture.url);
            //window.console.log('SecondPicture: ',myContent[i].contentNodes.SecondPicture.fileName);
            //window.console.log('GoBeyond: ',myContent[i].contentNodes.GoBeyond.value);
            //window.console.log('RedirectURL: ',myContent[i].contentNodes.RedirectURL.value);

            //https://b2bcap-172b6533342.force.com/coffeestore/s/blog/my-beloved-testa-rossa-20YB00000009FKcMAM

            if(myContent[i].contentNodes.RedirectURL.value != null){
              window.console.log('RedirectURL before -: ',myContent[i].contentNodes.RedirectURL.value);
              window.console.log('managedContentId   -: ',myContent[i].managedContentId);
              myContent[i].contentNodes.RedirectURL.value=this.baseURL+"/s/blog/"+myContent[i].managedContentId;
              window.console.log('RedirectURL after - : ',myContent[i].contentNodes.RedirectURL.value);
            }
            
            if(myContent[i].contentNodes.MainPicture.url != null){

                //myContent[i].contentNodes.MainPicture.url = this.baseURL + myContent[i].contentNodes.MainPicture.url;
                myContent[i].contentNodes.MainPicture.url = this.baseURL + myContent[i].contentNodes.MainPicture.url;
                //window.console.log('content URL: ', myContent[i].contentNodes.MainPicture.url);
                //window.console.log('myContent[i] URL: ', myContent[i].contentNodes.MainPicture.url);

            
            }
            
            if(myContent[i].contentNodes.Description.value != null){
                //window.console.log('myDescription:', myContent[i].contentNodes.Description.value);
                myContent[i].contentNodes.Description.value = myContent[i].contentNodes.Description.value.replace('&lt;p&gt;',"").replace('&lt;/p&gt;',"").replace('&lt;h1&gt;',"").replace('&lt;/h1&gt;',"").replace('&lt;br&gt;',"");
                //window.console.log('myDescription:', myContent[i].contentNodes.Description.value.replace('&lt;p&gt;',"").replace('&lt;/p&gt;',"").replace('&lt;h1&gt;',"").replace('&lt;/h1&gt;',"").replace('&lt;br&gt;',""));
                myContent[i].contentNodes.Description.value = myContent[i].contentNodes.Description.value.replace('&lt;p&gt;',"").replace('&lt;/p&gt;',"").replace('&lt;h1&gt;',"").replace('&lt;/h1&gt;',"").replace('&lt;br&gt;',"");
            }
          }
          this.recordList = myContent;

        } catch(error) {
            window.console.log(error);
        }
      }
}