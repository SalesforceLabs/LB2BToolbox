import { LightningElement, api, wire } from 'lwc';

import getConsumtion from '@salesforce/apex/LoyaltyPoints.getConsumtion';

export default class LoyaltyPointConsumtion extends LightningElement {
    
    columns = [
        { label: 'Date', fieldName: 'createdDate', type: 'date' },
        { label: 'Points', fieldName: 'point', initialWidth: 100 },
        { label: 'Type', fieldName: 'type' },
    ];

    @api effectiveAccountId;
    @api title;
    @api consumtiontDataTable = [];
    @api pointBalance;
    @api hasData = false;

    @wire(getConsumtion, { 
        accountId : "$resolvedEffectiveAccountId"
    })
    consumtionData({ error, data }) {
        if(data) {
            let dataTable = [];
            let balance = 0;
            window.console.log("data: %O", data);
            data.forEach(line => {
                let p = {
                    createdDate : line.CreatedDate,
                    id : line.Id,
                    point : line.lb2bt__Point__c,
                }
                if(line.lb2bt__Type__c == 'Earned') {
                    p.type = 'Earned';
                }
                else {
                    p.type = 'Spent';
                }
                balance = balance + p.point
                dataTable.push(p);
            });
            this.consumtiontDataTable = dataTable;
            window.console.log("consumtiontDataTable: %O", this.consumtiontDataTable);
            this.hasData = true;
            this.pointBalance = balance;
            this.title = 'Your Balance: ' + this.pointBalance;
        }
        else if(error) {
            window.console.group('%c LoyaltyPointConsumtion Error', 'background: #ff0000; color: #ffffff');
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
        window.console.log("resolvedEffectiveAccountId End, return:%O", resolved);

        return resolved;
    }

}