global class SmartBDMEnliteCompanyDetail {

    global EnliteDataRequest enliteDataRequest {get; set;}
    global EnliteDataResponse enliteDataResponse {get; set;}
 
    global SmartBDMEnliteCompanyDetail() {
        enliteDataRequest = new EnliteDataRequest();
        enliteDataResponse = new EnliteDataResponse();
    }

    global EnliteDataResponse convertToResponseObject(String responseBody){
        enliteDataResponse = (EnliteDataResponse)JSON.deserialize(responseBody, EnliteDataResponse.class);
        return enliteDataResponse;
    }

    global class Request {
        global String ToKenKey {get; set;}
        global String RegistrationID {get; set;}
        global String CompanyName {get; set;}
        global String FiscalYear {get; set;}
        global String Language {get; set;}
        global String TagRequired {get; set;}
    }
    global class EnliteDataRequest {
        global Request GetEnliteDataRequest {get; set;}

        global String parseJson() {
            return System.JSON.serialize(this);
        }
    }

    global class Response {
        global FinancialBalance FinancialBalance {get; set;}
        global FinancialIncome FinancialIncome {get; set;}
        global FinancialRatio FinancialRatio {get; set;}
        global ShareHolderes ShareHolder {get; set;}
        global CompanyProfile CompanyProfile {get; set;}

        global Decimal getTotalRevenue() {
            // FS4110100
            return this.FinancialIncome.getIncomeMap().containsKey(Smart_BDM_Constant.TOTAL_REVENUE_KEY) ? this.FinancialIncome.getIncomeMap().get(Smart_BDM_Constant.TOTAL_REVENUE_KEY).ListOfIncomeValues.Value : 0;
        }

        global Decimal getNetWorth() {
            // FS3700000
            return this.FinancialBalance.getBalanceMap().containsKey(Smart_BDM_Constant.NET_WORTH_KEY) ? this.FinancialBalance.getBalanceMap().get(Smart_BDM_Constant.NET_WORTH_KEY).ListOfBalanceValues.Value : 0;
        }
    }
    global class EnliteDataResponse {
        global Response GetExcuteSearchResponse {get; set;}
        
        // Handler Error
        global Status status {get; set;}

        global String parseJson() {
            return System.JSON.serialize(this);
        }
    }
    global class FinancialBalance {
        global String FinancialType {get; set;}
        global List<Balances> ListOfBalances {get { if(ListOfBalances == null) ListOfBalances = new List<Balances>(); return ListOfBalances; } set;}

        global Decimal sumTotalBalances() {
            Decimal total = 0;
            for (Balances b : this.ListOfBalances) total += b.ListOfBalanceValues.Value;
            return total;
        }

        global Map<String, Balances> getBalanceMap() {
            Map<String, Balances> balanceMap = new Map<String, Balances>();
            for (Balances b : this.ListOfBalances) {
                balanceMap.put(b.BalanceKey, b);
            }
            return balanceMap;
        }
    }
    global class FinancialIncome {
        global String FinancialType {get; set;}
        global List<Incomes> ListOfIncomes {get { if(ListOfIncomes == null) ListOfIncomes = new List<Incomes>(); return ListOfIncomes; } set;}

        global Decimal sumTotalIncomes() {
            Decimal total = 0;
            for (Incomes i : this.ListOfIncomes) total += i.ListOfIncomeValues.Value;
            return total;
        }

        global Map<String, Incomes> getIncomeMap() {
            Map<String, Incomes> incomeMap = new Map<String, Incomes>();
            for (Incomes i : this.ListOfIncomes) {
                incomeMap.put(i.IncomeKey, i);
            }
            return incomeMap;
        }
    }
    global class FinancialRatio {
        global String FinancialType {get; set;}
        global List<Ratios> ListOfRatios {get { if(ListOfRatios == null) ListOfRatios = new List<Ratios>(); return ListOfRatios; } set;}

        global Decimal sumTotalRatio() {
            Decimal total = 0;
            for (Ratios r : this.ListOfRatios) total += r.ListOfRatioValues.Value;
            return total;
        }

        global Map<String, Ratios> getRatioMap() {
            Map<String, Ratios> ratioMap = new Map<String, Ratios>();
            for (Ratios r : this.ListOfRatios) {
                ratioMap.put(r.RatioKey, r);
            }
            return ratioMap;
        }
    }
    global class Balances {
        global String BalanceKey {get; set;}
        global String BalanceDesc {get; set;}
        global BalanceValues ListOfBalanceValues {get; set;}
    }
    global class Incomes {
        global String IncomeKey {get; set;}
        global String IncomeDesc {get; set;}
        global IncomeValues ListOfIncomeValues {get; set;}
    }
    global class Ratios {
        global String RatioKey {get; set;}
        global String RatioDesc {get; set;}
        global RatioValues ListOfRatioValues {get; set;}
    }
    global class BalanceValues {
        global String BalanceDate {get; set;}
        global Decimal Value {get; set;}
    }
    global class IncomeValues {
        global String IncomeDate {get; set;}
        global Decimal Value {get; set;}
    }
    global class RatioValues {
        global String RatioDate {get; set;}
        global Decimal Value {get; set;}
    }
    global class ShareHolderes {
        global List<ShareHolder> ListOfShareHolders {get { if(this.ListOfShareHolders == null) this.ListOfShareHolders = new List<ShareHolder>(); return this.ListOfShareHolders; } set;}

        global List<ShareHolder> shareHoldersReachedFiftyOnePercent() {
            if(this.ListOfShareHolders != null) this.ListOfShareHolders.sort();
            Decimal percent = 0;
            List<ShareHolder> tmpShareHolders = new List<ShareHolder>();
            for (ShareHolder s : this.ListOfShareHolders) {
                tmpShareHolders.add(s);
                percent += s.sharePercent;
                if(percent >= 51) break;
            }
            return tmpShareHolders;
        }
    }
    global class ShareHolder implements Comparable {
        global Decimal numOfSH {get; set;}
        global Decimal shareAmount {get; set;}
        global Decimal sharePercent {get; set;}
        global String nationality {get; set;}
        global String directorship {get; set;}
        global String holderType {get; set;}
        global String title {get; set;}
        global String firstname {get; set;}
        global String lastname {get; set;}
        global String companyName {get; set;}
        global String companyNameFull {get; set;}

        global String shareholderName {
            get {
                return this.holderType == 'บุคคล' || this.holderType == 'Human' ? this.title + ' ' + (this.firstname != null ? this.firstname : '') + ' ' + (this.lastname != null ? this.lastname : '') : ( this.holderType == 'บริษัท' || this.holderType == 'Company' ? this.companyNameFull : '');
            }
        }

        global Integer compareTo(Object compareTo) {
            ShareHolder compareToShareHolder = (ShareHolder)compareTo;
            return this.sharePercent < compareToShareHolder.sharePercent ? 1 : (this.sharePercent > compareToShareHolder.sharePercent ? -1 : 0);
        }
    }
    global class CompanyProfile {
        global String NameFull {get; set;}
        global String NameShort {get; set;}
        global String businessType {get; set;}
        global String regisId {get; set;}
        global String companyStatus {get; set;}
        global String RegistrationType {get; set;}
        global String capital {get; set;}
        global String regisDate {get; set;}
        global Address Address {get; set;}
        global Telephones Telephone {get; set;}
        global String tsicDescrLatest {get; set;}
        global String officialSignatory {get; set;}
        global String SignatoryText {get; set;}
        global Reconcile Reconcile {get; set;}

        global String isicCode {
            get {
                return this.tsicDescrLatest != null ? this.tsicDescrLatest.left(7) : '';
            }
        }
        global String isicDescription {
            get {
                return this.tsicDescrLatest != null ? this.tsicDescrLatest.substring(8) : '';
            }
        }
        global Boolean isMobile {
            get {
                return this.Telephone != null ?  this.Telephone.ListOfTelephones.Telephone != null && this.Telephone.ListOfTelephones.Telephone.replace('-', '').left(2) != '02' : false;
            }
        }
        global String mobileNo {
            get {
                return this.isMobile && this.Telephone != null ? this.Telephone.ListOfTelephones.Telephone : '';
            }
        }
        global String officeNo {
            get {
                return !this.isMobile && this.Telephone != null ? this.Telephone.ListOfTelephones.Telephone : '';
            }
        }
        global String extNo {
            get {
                return !this.isMobile && this.Telephone != null ? this.Telephone.ListOfTelephones.Extension : '';
            }
        }
        global String addressLine1 {
            get {
                return (this.Address.addressNo != null && this.Address.addressNo != '' ?  this.Address.addressNo : '') + (this.Address.FloorRoomNo != null && this.Address.FloorRoomNo != '' ? ' ' + this.Address.FloorRoomNo : '') + (this.Address.BuildingName != null && this.Address.BuildingName != '' ? ' ' + this.Address.BuildingName : '') + (this.Address.RoadName != null && this.Address.RoadName != '' ? ' ' + this.Address.RoadName : '');
            }
        }

        global Account parseToAccount(){
            return new Account(
                Name = this.NameFull,
                ID_Number_PE__c = this.regisId,
                // Business_Type_Code__c = this.isicCode,
                // Business_Type_Description__c = this.businessType,
                Registered_Address_Line_1_PE__c = this.addressLine1,
                Registered_Address_Line_2_PE__c = this.Address.subDistrict,
                Registered_Address_Line_3_PE__c = this.Address.district,
                Province_Registered_PE__c = this.Address.province,
                Zip_Code_Registered_PE__c = this.Address.postcode,
                Mobile_Number_PE__c = this.mobileNo,
                RTL_Office_Phone_Number__c = this.officeNo,
                Primary_Phone_Ext_PE__c = this.extNo
            );
        }
    }
    global class Address { 
        global String addressNo {get; set;}
        global String RoadName {get; set;}
        global String BuildingName {get; set;}
        global String FloorRoomNo {get; set;}
        global String subDistrict {get; set;}
        global String district {get; set;}
        global String province {get; set;}
        global String postcode {get; set;}
        global Reconcile Reconcile {get; set;}
    }
    global class Telephones { 
        global Telephone ListOfTelephones {get; set;}
        global Reconcile Reconcile {get; set;}
    }
    global class Telephone { 
        global String Telephone {get; set;}
        global String Extension {get; set;}
        global String Fax {get; set;}
    }
    global class Reconcile { 
        global Integer TotalCount {get; set;}
    }

    global class Status {
        // global String system {get; set;}
        global Integer code {get; set;}
        global String description {get; set;}
    }
}