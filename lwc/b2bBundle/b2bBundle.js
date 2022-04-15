import { LightningElement, api, track } from "lwc";

//import { getRecord } from "lightning/uiRecordApi";
//import Products_ID from "@salesforce/schema/Product2.Product__c";
//import USER_ID from "@salesforce/user/Id";
import communityId from "@salesforce/community/Id";
//import ACCOUNT_ID from "@salesforce/schema/User.Contact.Account.Id";

import getBundleProducts from "@salesforce/apex/B2BBundle.getBundleProducts";
import getProductPrice from "@salesforce/apex/B2BBundle.getProductPrice";
import getItemQuantity from "@salesforce/apex/B2BBundle.getItemQuantity";
import addToCart from "@salesforce/apex/B2BBundle.addToCart";
import searchCurrentProductPageURL from "@salesforce/apex/B2BBundle.searchCurrentProductPageURL";
//import { resolve } from "c/cmsResourceResolver";

//import getRelatedProductInfo from "@salesforce/apex/B2BBundle.getRelatedIndividualProductInfo";
import { NavigationMixin } from "lightning/navigation";

// Provides the path prefix to Core resources - Use for Image URL
import { getPathPrefix } from "lightning/configProvider";

export default class B2bBundle extends NavigationMixin(LightningElement) {
  // @api filter;
  //const mycurrentproductID = this.findProductID();

  //https://success.salesforce.com/answers?id=906B0000000DWtiQAC

  /**
   * Gets or sers the effective account - if any - of the user viewing the product.
   *
   * @type {string}
   */
  @api effectiveAccountId;

  /**
   *  Gets or sets the unique identifier of a product.
   *
   * @type {string}
   */
  @api recordId;

  /**
   *  Gets or sets the Bundle Title.
   *
   * @type {string}
   */
  @api bundle_Title;
  /**
   *  Gets or sets the Bundle Name.
   *
   * @type {string}
   */
  @api bundle_Name;
  /**
   *  Gets or sets the Bundle SKU.
   *
   * @type {string}
   */
  @api bundle_SKU;
  /**
   *  Gets or sets the Bundle Quantity.
   *
   * @type {string}
   */
  @api bundle_Quantity;
  /**
   *  Gets or sets the Bundle Unit Price.
   *
   * @type {string}
   */
  @api bundle_UnitPrice;

  @track contactId;
  @track accountId;
  @track relatedProductUrl;
  //Store the webstoreID

  @track myCurrentProductPageURL;

  @track CSModifiedProducts;

  //Nb of items retrieves
  @track nbBundleItems;

  @track url;

  //store quantity for each elements
  @track qtyMap = new Map();

  /**
   * Gets the normalized effective account of the user.
   *
   * @type {string}
   * @readonly
   * @private
   */
  get resolvedEffectiveAccountId() {
    const effectiveAcocuntId = this.effectiveAccountId || "";
    let resolved = null;

    if (
      effectiveAcocuntId.length > 0 &&
      effectiveAcocuntId !== "000000000000000"
    ) {
      resolved = effectiveAcocuntId;
    }
    return resolved;
  }

  // Update Image URLs coming from CMS (URL or Uploaded images)
  resolve(url) {
    /**
     * Regular expressions for CMS resources and for static B2B image resources -
     * specifically the "no image" image - that we want to handle as though they were CMS resources.
     */
    const cmsResourceUrlPattern = /^\/cms\//;
    const b2bStaticImageResourcePattern = /^\/img\//;
    // If the URL is a CMS URL, transform it; otherwise, leave it alone.
    if (
      cmsResourceUrlPattern.test(url) ||
      b2bStaticImageResourcePattern.test(url)
    ) {
      url = `${getPathPrefix()}${url}`;
    }

    return url;
  }

  /**
   * Retrieve Bundle Products on loading Page
   */
  connectedCallback() {
    this.nbBundleItems = 0;
    this.getItemsfromBundle();
  }

  /**
   * Add Quantity in map for each products
   */
  handleQTYChange(event) {
    this.qtyMap.set(event.target.id, event.target.value);
    //window.console.log("event.target.id: ", event.target.id, " ",this.qtyMap.get(event.target.id));
  }

  /**
   * Handles a user request to add the product to their active cart.
   *
   * @private
   */
  addProductToCart(evt) {
    //console.log("add cart communityId", communityId);
    //console.log("add cart productId",evt.target.id.substring(0, evt.target.id.indexOf("-")));
    //console.log("add cart quantity", this.qtyMap.get(evt.target.id));
    //console.log("add cart effectiveAccountId", this.resolvedEffectiveAccountId);

    addToCart({
      communityId: communityId,
      productId: evt.target.id.substring(0, evt.target.id.indexOf("-")),
      quantity: this.qtyMap.get(evt.target.id),
      effectiveAccountId: this.resolvedEffectiveAccountId
    })
      .then((result) => {
        console.log(result);
        console.log("no errors");
      })
      .catch((error) => {
        this.error = error;
        console.log("errors");
      });
  }
  /**
   * Access the Cross Sell Product on Click.
   */
  handleClick(evt) {
    var ctarget = evt.currentTarget;
    var fullURL = ctarget.dataset.value;
    this.relatedProductPageRef = {
      type: "standard__webPage",
      attributes: {
        url: fullURL,
        actionName: "home"
      }
    };
    this[NavigationMixin.Navigate](this.relatedProductPageRef);
  }

  //#################
  //##### NEW  ###### https://hicglobalsolutions.com/blog/lightning-web-components/
  //#################

  async getItemsfromBundle() {
    let myCSProducts;
    let i;
    //window.console.log(" log: communityId: ", communityId);
    //window.console.log(" log: productID: ", this.recordId);
    //window.console.log(" log: effectiveAccountID: ",this.effectiveAccountId);

    try {
      const myBundleProducts = await getBundleProducts({
        communityId: communityId,
        productID: this.recordId,
        effectiveAccountID: this.effectiveAccountId
      });
      //searchForProductMetadata(String cmsContentType, String cmsContentFieldName, String matchingRecord){
      //myContent = content;

      myCSProducts = JSON.parse(JSON.stringify(myBundleProducts));
      //window.console.log("myBundleProducts:", myCSProducts);
      this.nbBundleItems = myCSProducts.length;

      const myCurrentProductPageURL = await searchCurrentProductPageURL();

      for (i = 0; i < myCSProducts.length; i++) {
        //window.console.log("######## THE PRE ID: ");
        //window.console.log("######## THE ID: ", myCSProducts[i].id);
        //window.console.log("######## THE POST ID: ");
        const productPrice = await getProductPrice({
          communityId: communityId,
          productId: myCSProducts[i].id,
          effectiveAccountId: this.effectiveAccountId
        });
        var itemQuantity = await getItemQuantity({
          currentProductId: this.recordId,
          myBundleItem: myCSProducts[i].id
        });
        //window.console.log("§§§§§§§§ Item QUantity : ", productPrice);
        myCSProducts[i].itemQuantity = itemQuantity;
        //window.console.log("§§§§§§§§ Item Result : ",myCSProducts[i].itemQuantity);

        //Get URL link to Bundle Product
        myCSProducts[i].fullUrl = myCurrentProductPageURL + myCSProducts[i].id;

        //Get Unique Id for add to cart qty in case of two similar
        //myCSProducts[i].uniqueId = i + myCSProducts[i].id;
        //window.console.log("######## unique ID: ", myCSProducts[i].uniqueId);

        //Get Id of the
        myCSProducts[i].myId = myCSProducts[i].id;
        //window.console.log("######## My ID: ", myCSProducts[i].id);
        //window.console.log("######## My ID: ", myCSProducts[i].myId);

        //  window.console.log("######## Final ID: ", myCSProducts[i].id);

        //window.console.log("$$$$$ Price Global: ", productPrice);
        //window.console.log("$$$$$ Currenceiso value: ", productPrice.currencyIsoCode);
        //window.console.log("$$$$$ Price value: ", productPrice.unitPrice);
        //window.console.log("Name value: ", myCSProducts[i].fields.Name);

        //Get Price for this Bundle Product
        myCSProducts[i].unitPrice = productPrice.unitPrice;
        //Get Currency for this Bundle Product
        myCSProducts[i].currencyIsoCode = productPrice.currencyIsoCode;
        //window.console.log("CurrencyISoCode value: ",myCSProducts[i].currencyIsoCode);
        //window.console.log("Price value: ", myCSProducts[i].unitPrice);
        //window.console.log("SKU value: ",myCSProducts[i].fields.StockKeepingUnit);
        //window.console.log "Image Alternative value: ", myCSProducts[i].defaultImage.alternativeText);

        //Get (and update) Description for this Bundle Product
        if (myCSProducts[i].fields.Description != null) {
          //window.console.log('myDescription:', myContent[i].contentNodes.Description.value);
          myCSProducts[i].fields.Description = myCSProducts[
            i
          ].fields.Description.replace("&lt;p&gt;", "")
            .replace("&lt;/p&gt;", "")
            .replace("&#39;", "'")
            .replace("&lt;h1&gt;", "")
            .replace("&lt;/h1&gt;", "")
            .replace("&lt;br&gt;", "");
        }
        //Get Image for this Bundle Product
        if (myCSProducts[i].defaultImage.url != null) {
          // window.console.log("URL value: ", myCSProducts[i].defaultImage.url);
          myCSProducts[i].defaultImage.url = this.resolve(
            myCSProducts[i].defaultImage.url
          );
          //  window.console.log("URL value: ", myCSProducts[i].defaultImage.url);
        }
      }
      // ### IMPORTANT REPLACE THE FOLLOWING LINE AND REMOVE AWAIT IN LOOP
      // Wait for every promise in the loop for getProductPrice
      //https://eslint.org/docs/rules/no-await-in-loop
      this.CSModifiedProducts = await Promise.all(myCSProducts);
      //this.CSModifiedProducts = myCSProducts;
    } catch (error) {
      window.console.log(error);
    }
  }

  /**
   * Gets whether product information has been retrieved for display.
   *
   * @type {Boolean}
   * @readonly
   * @private
   */
  get hasProducts() {
    return this.nbBundleItems !== 0;
  }
}