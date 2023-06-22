import {
    LightningElement,
    track,
    api
} from 'lwc';
import getRemark from '@salesforce/apex/RetailCSVCustomerChartController.getRemark';

const FIELDS = [
    'Product_Holding_Configuration__mdt.RTL_Remark__c',
];

export default class RetailCSVProductHoldingEachGroupDetail extends LightningElement {
    @track selectedTab;
    @api recordId;
    @track isCalSubGroup = false;
    @track ProductSubGroup = {
        Deposit: '-',
        Investment: '-',
        BA: '-',
        CC_PersonalLoan: '-',
        SecuredLoan: '-',
        AutoLoan: '-',
        Other: '-',
    }

    @track ProductRemark = {
        Deposit: '-',
        Investment: '-',
        BA: '-',
        CC_PersonalLoan: '-',
        SecuredLoan: '-',
        AutoLoan: '-',
        Other: '-',
    }
    isInit = true;

    @api productHolding;
    @api isCalRenders;
    @api partition;

    @track isGetRemark = false;
    @track isSwitchTab = false;
    @track chartData = {
        Active: 0,
        Inactive: 0,
        Outstanding: 0,
        Available: 0
    }
    get chart() {
        return this.chartData;
    }
    @track currProduct = 'Investment';

    renderedCallback() {

        if (this.isCalRenders && !this.isCalSubGroup && this.partition['ProductSubGroup']) {
            this.addSubGroups('Deposit');
            this.addSubGroups('BA');
            this.addSubGroups('CC_PersonalLoan');
            this.addSubGroups('SecuredLoan');
            this.addSubGroups('AutoLoan');
            this.isCalSubGroup = true;
        } else if (!this.partition['ProductSubGroup']) {
            this.ProductSubGroup['Deposit'] = '-';
            this.ProductSubGroup['BA'] = '-';
            this.ProductSubGroup['CC_PersonalLoan'] = '-';
            this.ProductSubGroup['SecuredLoan'] = '-';
            this.ProductSubGroup['AutoLoan'] = '-';
        }

        if (this.isCalRenders && !this.isGetRemark && this.partition['Remark']) {
            this.getRemarkValue('Deposit', 'Deposit');
            this.getRemarkValue('Investment', 'Investment');
            this.getRemarkValue('Bancassurance', 'BA');
            this.getRemarkValue('CC & Personal Loan', 'CC_PersonalLoan');
            this.getRemarkValue('Secured Loan', 'SecuredLoan');
            this.getRemarkValue('Auto Loan', 'AutoLoan');
            this.getRemarkValue('Other', 'Other');
            this.isGetRemark = true;
        } else if (!this.partition['Remark']) {
            this.ProductRemark['Deposit'] = '-';
            this.ProductRemark['Investment'] = '-';
            this.ProductRemark['BA'] = '-';
            this.ProductRemark['CC_PersonalLoan'] = '-';
            this.ProductRemark['SecuredLoan'] = '-';
            this.ProductRemark['AutoLoan'] = '-';
            this.ProductRemark['Other'] = '-';
        }
        if (this.isInit && this.isCalRenders) {
            this.switchChartData('Investment');
            this.isInit = false;
        }
    }

    @api calRenders(isCalRenders, productHolding, dataPartition){
        this.isCalRenders = isCalRenders;
        this.productHolding = productHolding;
        this.partition = dataPartition;
        if (this.isCalRenders && !this.isCalSubGroup && this.partition['ProductSubGroup']) {
            this.addSubGroups('Deposit');
            this.addSubGroups('BA');
            this.addSubGroups('CC_PersonalLoan');
            this.addSubGroups('SecuredLoan');
            this.addSubGroups('AutoLoan');
            this.isCalSubGroup = true;
        } else if (!this.partition['ProductSubGroup']) {
            this.ProductSubGroup['Deposit'] = '-';
            this.ProductSubGroup['BA'] = '-';
            this.ProductSubGroup['CC_PersonalLoan'] = '-';
            this.ProductSubGroup['SecuredLoan'] = '-';
            this.ProductSubGroup['AutoLoan'] = '-';
        }

        if (this.isCalRenders && !this.isGetRemark && this.partition['Remark']) {
            this.getRemarkValue('Deposit', 'Deposit');
            this.getRemarkValue('Investment', 'Investment');
            this.getRemarkValue('Bancassurance', 'BA');
            this.getRemarkValue('CC & Personal Loan', 'CC_PersonalLoan');
            this.getRemarkValue('Secured Loan', 'SecuredLoan');
            this.getRemarkValue('Auto Loan', 'AutoLoan');
            this.getRemarkValue('Other', 'Other');
            this.isGetRemark = true;
        } else if (!this.partition['Remark']) {
            this.ProductRemark['Deposit'] = '-';
            this.ProductRemark['Investment'] = '-';
            this.ProductRemark['BA'] = '-';
            this.ProductRemark['CC_PersonalLoan'] = '-';
            this.ProductRemark['SecuredLoan'] = '-';
            this.ProductRemark['AutoLoan'] = '-';
            this.ProductRemark['Other'] = '-';
        }
        if (this.isInit && this.isCalRenders) {
            this.switchChartData('Investment');
            this.isInit = false;
        }
    }

    getRemarkValue(productgroup, ObjType) {
        if (productgroup && ObjType) {
            getRemark({
                    ProductGroup: productgroup
                })
                .then(data => {
                    this.ProductRemark[ObjType] = data;
                })
                .catch(error => {
                    console.log(ObjType, 'GetRemark Error', error);
                })
        }
    }

    addSubGroups(objType) {
        if (this.productHolding[objType].ProductSubGroup.length > 0) {
            this.productHolding[objType].ProductSubGroup.forEach(subGroup => {
                if (this.ProductSubGroup[objType] == '-') {
                    this.ProductSubGroup[objType] = subGroup;
                } else {
                    this.ProductSubGroup[objType] += ', ' + subGroup;
                }
            });
        }
    }

    parseObj(obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : obj;
    }

    switchChartData(objType) {
        this.currProduct = objType;

        this.chartData.Active = this.productHolding[objType].NumberOfAccount.Active ? this.productHolding[objType].NumberOfAccount.Active : 0;
        this.chartData.Inactive = this.productHolding[objType].NumberOfAccount.Inactive ? this.productHolding[objType].NumberOfAccount.Inactive : 0;
        this.chartData.Outstanding = this.productHolding[objType].TotalOutstanding ? this.productHolding[objType].TotalOutstanding : 0;
        this.chartData.Available = this.productHolding[objType].TotalAvailable ? this.productHolding[objType].TotalAvailable : 0;

        if (!this.partition['Outstanding']) {
            this.chartData.Outstanding = 0;
            this.chartData.Available = 0;
        }
        if (this.chartData.Outstanding < 0) {
            this.chartData.Outstanding = 0;
        }
        if (this.chartData.Available < 0) {
            this.chartData.Available = 0;
        }
    }

    tabSelect(event) {
        this.switchChartData(event.target.value);
        this.tabContent = `Tab ${
            event.target.value
        } is now active`;
    }


}