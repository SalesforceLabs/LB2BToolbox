import { LightningElement, wire, api, track } from "lwc";

import { getRecord, getFieldValue } from "lightning/uiRecordApi";


import getLoyaltyPointsTotal from '@salesforce/apex/LoyaltyPoints.getLoyaltyPointsTotal';

//import COM_ID from "@salesforce/community/Id";
//import basePath_ID from "@salesforce/community/basePath";

export default class LoyaltyPointSingle extends LightningElement {
  @api background_image;
  @api reward_Title;
  @api reward_FirstPart;
  @api reward_LastPart;
  @api backgroundPointColor;
  @api textColor;
  @api effectiveAccountId;

  get rewardTitle() {
    return this.reward_Title;
  }
  get rewardFirstPart() {
    return this.reward_FirstPart;
  }
  get rewardLastPart() {
    return this.reward_LastPart;
  }
  get stylePointsColor() {
    const listOfProperties = [
      "color: " + this.backgroundPointColor + "; font-size: 1.2rem;"
    ];
    return listOfProperties.join(";");
  }
  get styleStartsColor() {
    const listOfProperties = [
      "color: " + this.backgroundPointColor + "; font-size: 1.3rem;"
    ];
    return listOfProperties.join(";");
  }

  get styletextColor() {
    const listOfProperties = [
      "color: " + this.textColor + "; font-size: 1.2rem;"
    ];
    return listOfProperties.join(";");
  }

  get style_background() {
    const listOfProperties = [
      'background-image: url("' +
        this.background_image +
        '");border: none;background-repeat: no-repeat;background-size: cover;background-position: 50%;width: 100%;height: 125px;position: inherit;border-radius: 0px 0px 20px 20px;color: white;'
    ];

    return listOfProperties.join(";");
  }

  @track rewardPointValue;

  @wire(getLoyaltyPointsTotal, { 
    accountId : "$resolvedEffectiveAccountId"
  })
  loyaltyPointsTotal({ error, data }) {
    if(data) {
      window.console.log("loyaltyPointsTotal: %O", data);
      this.rewardPointValue = data;
    }
    else if(error) {
        window.console.group('%c LoyaltyPointSingle Error', 'background: #ff0000; color: #ffffff');
        window.console.log('status:'+error.status);
        window.console.log('exceptionType:'+error.body.exceptionType);
        window.console.log('message:'+error.body.message);
        window.console.log('stackTrace:'+error.body.stackTrace);
        window.console.groupEnd();
    }
  }

  get resolvedEffectiveAccountId() {
    const effectiveAcocuntId = this.effectiveAccountId || "";
    let resolved = null;

    if (effectiveAcocuntId.length > 0 && effectiveAcocuntId !== "000000000000000") {
        resolved = effectiveAcocuntId;
    }
    return resolved;
  }

}