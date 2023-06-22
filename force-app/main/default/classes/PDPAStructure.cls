public class PDPAStructure {    
   

    public PDPAstatus status {get;set;}
    public PDPAdata data {get;set;}

    public class PDPAstatus {
        public String code {get;set;}
        public String description {get;set;}
    }

    public class PDPAdata {
        public String customerId {get;set;}
        public String financialId {get;set;}
        public List<PDPAconsents> consents {get;set;}
    }

    public class PDPAconsents {
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public String flag {get;set;}
        @AuraEnabled
        public String version {get;set;}
        @AuraEnabled
        public Datetime consentDateTime {get;set;}
        @AuraEnabled
        public String channel {get;set;}
        @AuraEnabled
        public String consentBy {get;set;}
        @AuraEnabled
        public String needUpdateFlag {get;set;}
        @AuraEnabled
        public String decriptionEN {get;set;}
        @AuraEnabled
        public String decriptionTH {get;set;}
        @AuraEnabled
        public Date consentSignDate {get; set;}
        @AuraEnabled
        public String needUpdateFlagReason {get; set;}
        @AuraEnabled
        public String wsCurrentFlag {get;set;}
    }

    public static PDPAStructure parseJsonToObj(String json) {
		return (PDPAStructure)System.JSON.deserialize(json, PDPAStructure.class);
	}
}