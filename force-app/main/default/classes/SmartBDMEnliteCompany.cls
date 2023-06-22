global class SmartBDMEnliteCompany {

    global CompanyResponse companyResponse {get; set;}
    global CompanyRequest companyRequest {get; set;}
    global SmartBDMEnliteCompany() {
        companyResponse = new CompanyResponse();
        companyRequest = new CompanyRequest();
    }

    global CompanyResponse convertToResponseObject(String responseBody){
        companyResponse = (CompanyResponse)JSON.deserialize(responseBody, CompanyResponse.class);
        return companyResponse;
    }

    global class Request {
        global String ToKenKey {get; set;}
        global String RequiredTable {get; set;}
        global String ResultFields {get; set;}
        global String CriteriaField0 {get; set;}
        global String CriteriaOperator0 {get; set;}
        global String CriteriaValues0 {get; set;}
        global String CriteriaAndOr0 {get; set;}
        global String CriteriaField1 {get; set;}
        global String CriteriaOperator1 {get; set;}
        global String CriteriaValues1 {get; set;}
        global String CriteriaAndOr1 {get; set;}
        global String CriteriaField2 {get; set;}
        global String CriteriaOperator2 {get; set;}
        global String CriteriaValues2 {get; set;}
    }
    global class CompanyRequest {
        global Request GetExcuteSearchRequest {get; set;}

        global CompanyRequest() {
            GetExcuteSearchRequest = new Request();
        }

        global String parseJson() {
            return System.JSON.serialize(this);
        }
    }
 
    global class CompanyResponse {
        global Response GetExcuteSearchResponse {get; set;}
        // Handler Error
        global Status status {get; set;}
        
        // global CompanyResponse() {
        //    GetExcuteSearchResponse = new Response();
        // }

        global String parseJson() {
            return System.JSON.serialize(this);
        }

        global List<Company> parseList() {
            return this.parseMap().values();
        }

        global Map<String, Company> parseMap() {
            Map<String, List<String>> listSearchDesc = new Map<String, List<String>>();
            Integer size = this.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs.size() > 0 ? this.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs.get(0).Value.size() : 0;
            for (ResultSearchDesc r : this.GetExcuteSearchResponse.ListOfExcuteSearchs.ListOfSearchDescs) {
                listSearchDesc.put(r.ResultDesc, r.Value);
            }

            Map<String, Company> companiesMap = new Map<String, Company>();
            for (Integer i = 0; i < size; i++) {
                String RegID = listSearchDesc.containsKey('REGISTRATION_ID') ? listSearchDesc.get('REGISTRATION_ID').get(i) : null;
                String NameEN = listSearchDesc.containsKey('NAME_EN') ? listSearchDesc.get('NAME_EN').get(i) : null;
                String NameTH = listSearchDesc.containsKey('NAME_TH') ? listSearchDesc.get('NAME_TH').get(i) : null;
                String FiscalYear = listSearchDesc.containsKey('FS_YEAR') ? listSearchDesc.get('FS_YEAR').get(i) : null;
                companiesMap.put(RegID, new Company(RegID, NameEN, NameTH, FiscalYear));
            }
            return companiesMap;
        }
    }

    global class Response {
        global String Status {get; set;}
        global ExcuteSearch ListOfExcuteSearchs {get; set;}
    }

    global class ExcuteSearch {
        global List<ResultSearchDesc> ListOfSearchDescs {get { if(ListOfSearchDescs == null) ListOfSearchDescs = new List<ResultSearchDesc>(); return ListOfSearchDescs;} set;}
    }
    global class ResultSearchDesc {
        global String ResultDesc {get; set;}
        global List<String> Value {get; set;}
    }

    global class Status {
        // global String system {get; set;}
        global Integer code {get; set;}
        global String description {get; set;}
    }

    global class Company {
        global String REGISTRATION_ID {get; set;}
        global String NAME_EN {get; set;}
        global String NAME_TH {get; set;}
        global String FS_YEAR {get; set;}

        global Company(String Registration_Id, String Name_EN, String Name_TH, String Fiscal_Year) {
            this.REGISTRATION_ID = Registration_Id;
            this.NAME_EN = Name_EN;
            this.NAME_TH = Name_TH;
            this.FS_YEAR = Fiscal_Year;
        }
    }
}