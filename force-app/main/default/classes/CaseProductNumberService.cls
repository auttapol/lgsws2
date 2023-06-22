public class CaseProductNumberService {


	public class CaseProductWrapper {
        public Integer rowNum {get; set;}
        public String apiAccountNumber {get; set;}
        public String apiAccountNumberMarking {get; set;}
        public String apiSuffix {get; set;}
        public String apiProductType {get; set;}
        public String apiProductSubGroup {get; set;}
        public String apiProductName {get; set;}

        public CaseProductWrapper(){

        }

        public CaseProductWrapper(Integer rowNum, String apiAccountNumber,String apiAccountNumberMarking, String apiSuffix,String apiProductType,
                                        String apiProductSubGroup, String apiProductName) {
            this.rowNum = rowNum;
            this.apiAccountNumber = apiAccountNumber;
            this.apiAccountNumberMarking = apiAccountNumberMarking;
            this.apiSuffix = apiSuffix;
            this.apiProductType = apiProductType;
            this.apiProductSubGroup = apiProductSubGroup;
            this.apiProductName = apiProductName;
        }
    }

}