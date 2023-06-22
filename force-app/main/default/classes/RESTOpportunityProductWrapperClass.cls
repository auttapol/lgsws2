global class RESTOpportunityProductWrapperClass{
    public String HostSystem;
    public String OpportunityId;
    public List<prodWrap> Products;

    global class prodWrap {
        public String ProductCode;
        public String AccountNumber;
    }

    public static RESTOpportunityProductWrapperClass parse(String json){
        return (RESTOpportunityProductWrapperClass) System.JSON.deserialize(json, RESTOpportunityProductWrapperClass.class);
    }

}