import { LightningElement,api, wire,track} from 'lwc';
import getProductSKU from '@salesforce/apex/matchCMSContent.getProductSKU';

export default class getCMSBlogBySKU extends LightningElement {
   @api recordId;
   @api contentType;
   @api cmsContentFieldName;

   @track topid;
   @track name;
   @track MyProdSKU;

   @wire(getProductSKU, {productId: '$recordId'})

   process(result){
      if (result.error) {
         window.console.log(result.error);
       } else if (result.data) {
         //success here
         window.console.log('you have data', JSON.stringify(result.data));
         this.MyProdSKU = result.data;
         window.console.log('Product SKU: ', result.data);

       } else {
         //Anything else here
         window.console.log('hm');
       }
      
   }

   get gotBlog(){
      return this.MyProdSKU ? true:false;
   }
   
}