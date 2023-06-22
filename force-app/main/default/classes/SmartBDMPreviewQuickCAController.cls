public class SmartBDMPreviewQuickCAController {

    public class productItem {
        @AuraEnabled
        public string Index {
            get;
            set;
        }
        @AuraEnabled
        public string oppProdId {
            get;
            set;
        }
        @AuraEnabled
        public OpportunityLineItem oppProd {
            get;
            set;
        }
        @AuraEnabled
        public Host_Product_Mapping__c hostMapTemp {
            get;
            set;
        }
        @AuraEnabled
        public string amount {
            get;
            set;
        }
        @AuraEnabled
        public string productName {
            get;
            set;
        }
        public productItem(string i, string o, OpportunityLineItem ol, Host_Product_Mapping__c h, string a, string p) {
            Index = i;
            oppProdId = o;
            oppProd = ol;
            hostMapTemp = h;
            amount = a;
            productName = p;
        }
    }

    public class wrapProductList {
        @AuraEnabled
        public string programName {
            get;
            set;
        }
        @AuraEnabled
        public List < productItem > programList {
            get;
            set;
        }

    }

    public static Map < String, String > mapProductGroupID {
        get {
            if (mapProductGroupID != null) {
                return mapProductGroupID;
            } else {
                map < String, String > retDat = new map < String, String > ();
                for (Host_Product_Mapping__c hp: [SELECT Host_Product_Group__c, Product_Group_ID__c
                        FROM Host_Product_Mapping__c WHERE Active_Flag__c = true
                    ]) {
                    retDat.put(hp.Host_Product_Group__c, hp.Product_Group_ID__c);
                }
                return retDat;
            }
        }
        set;
    }

    @AuraEnabled
    public static List < wrapProductList > getProductionList(String opptyId) {
        List < productItem > listOpportunityProduct2 = new List < productItem > ();
        List < wrapProductList > listOfProgram = new List < wrapProductList > ();
        Integer indexList2 = 0;
        string productGroup;
        string productGroup2;
        string oldProductGroup;
        String host = Smart_BDM_Constant.HOST_SYSTEM;
        boolean isCanSelectProductGroup;

        isCanSelectProductGroup = true;
        //isHasProductGroup = true;
        oldProductGroup = '';
        //oldHost = '';

        Opportunity oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Name, CAID__c, Host_Product_Group__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c
            FROM Opportunity Where Id =: opptyId
        ];

        if (oppty.Host_Product_Group__c != '' && oppty.Host_Product_Group__c != null) {
            productGroup = oppty.Host_Product_Group__c;
            isCanSelectProductGroup = false;
            oldProductGroup = oppty.Host_Product_Group__c;
        }
        if (productGroup2 != null && productGroup2 != '') {
            productGroup = productGroup2;
        }

        for (OpportunityLineItem ol: [SELECT Id, Name, Product2.Name, product2Id, Host_Product_Mapping__c, Host_Product_Mapping__r.Host_Name__c, Host_Product_Mapping__r.Host_Product_Group__c, Host_Product_Mapping__r.Product_Program__c, Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c, Host_Product_Mapping__r.Salesforce_Product__c, Host_Product_Mapping__r.Salesforce_Product__r.Name, Quantity, UnitPrice, PricebookEntryId, opportunity.Host_Product_Group__c

                FROM OpportunityLineItem
                Where OpportunityId =: opptyId
            ]) {
            Host_Product_Mapping__c hp = new Host_Product_Mapping__c();
            if (ol.Host_Product_Mapping__c != null) {
                hp.Host_Name__c = ol.Host_Product_Mapping__r.Host_Name__c;
                hp.Host_Product_Group__c = ol.Host_Product_Mapping__r.Host_Product_Group__c;
                hp.Product_Program__c = ol.Host_Product_Mapping__r.Product_Program__c;
                hp.Host_Prod_Name_Credit_Facility__c = ol.Host_Product_Mapping__r.Host_Prod_Name_Credit_Facility__c;
                hp.salesforce_product__r = ol.Host_Product_Mapping__r.Salesforce_Product__r;
            } else {
                hp.Host_Name__c = host;
                hp.Host_Product_Group__c = productGroup;
            }

            string productNameTmp = (string.isNotBlank(ol.Host_Product_Mapping__r.Salesforce_Product__r.name)) ? ol.Host_Product_Mapping__r.Salesforce_Product__r.name : ol.product2.name;
            listOpportunityProduct2.add(new productItem(string.valueof(indexList2), string.valueof(ol.id), ol, hp, string.valueof(ol.unitprice), productNameTmp));
            indexList2++;
        }

        Map < String, List < productItem >> programMap = new Map < String, List < productItem >> ();

        for (productItem pd: listOpportunityProduct2) {
            //System.debug('name:'+pd.hostMapTemp.Product_Program__c);
            if (!programMap.containsKey(pd.hostMapTemp.Product_Program__c)) {
                programMap.put(pd.hostMapTemp.Product_Program__c, new List < productItem > ());
            }
            programMap.get(pd.hostMapTemp.Product_Program__c).add(pd);
        }

        for (String name: programMap.keySet()) {
            wrapProductList program = new wrapProductList();
            program.programName = name;
            program.programList = programMap.get(name);
            listOfProgram.add(program);
        }
        return listOfProgram;
    }

    @AuraEnabled
    public static Opportunity getOppty(String opptyId) {
        Opportunity oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Account.ID_Type_PE__c, Account.ID_Number_PE__c, Name, CAID__c, Host_Product_Group__c, App_Ref_Number__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c, Product_Group_ID__c, Host_System__c, Expected_submit_date__c
        FROM Opportunity Where Id =: opptyId
        ];
        return oppty;
    }
    
    @AuraEnabled
    public static String getHost() {
        return Smart_BDM_Constant.HOST_SYSTEM;
    }

    @AuraEnabled
    public static void submitToHost(String opptyId) {
        string errMsg = '';
        try {
            Opportunity oppty = [SELECT Id, AccountId, Account.Name, Account.Customer_Type__c, Name, CAID__c, Host_Product_Group__c, App_Ref_Number__c, Owner.Name, Owner.Employee_ID__c, Owner.Zone_Code__c, Owner.Region_Code__c, Product_Group_ID__c, Host_System__c, Expected_submit_date__c
                FROM Opportunity Where Id =: opptyId
            ];

            System.debug('oppty:'+oppty);

            if (string.isNotBlank(oppty.Host_Product_Group__c) && string.isBlank(oppty.Product_Group_ID__c)) {
                oppty.Product_Group_ID__c = mapProductGroupID.get(oppty.Host_Product_Group__c);
            }

            if (oppty.Host_System__c == 'SLS') {
                              
                SLOSContext.SLOSRequest req = new SLOSContext.SLOSRequest(oppty, null);
                SLOSContext.SLOSRespond resp = SLOSServiceBroker.sendRequest(req);
                
                if (resp.Status == true) {
                    oppty.App_Ref_Number__c = resp.AppRefNo;

                    Id seCreditPproduct2RecordType = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product2').getRecordTypeId();
                    oppty.RecordTypeId = seCreditPproduct2RecordType;
                    oppty.StageName = 'Submit to Credit Process';
                    update oppty;
                } else {
                    errMsg = Status_code__c.getValues('8044').status_message__c + '' + resp.ErrorCode + '.Error: ' + resp.Message;
                    throw new AuraHandledException(errMsg);
                }

            } else if (oppty.Host_System__c.toLowerCase().contains('excel')) {
                oppty.RecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('SE Credit Product2').getRecordTypeId();
                oppty.StageName = 'Submit to Credit Process';
                update oppty;
            }
        } catch (Exception e) {
            if (errMsg != '') {
                System.debug(errMsg);
                throw new AuraHandledException(errMsg);
            } else {
                System.debug(e.getMessage());
                throw new AuraHandledException(e.getMessage());
            }

        }
    }
    @AuraEnabled
    public static string getDeepLink(){
        return Smart_BDM_Constant.DEEP_LINK_TO_KONY_TELL_LANDING;
    }

}