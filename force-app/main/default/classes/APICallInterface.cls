public interface APICallInterface {
	String getAPIBatchQuery();
    String createRequestWS(SObject sobj,String status,Map<Id,String> reqMap);
    void   updateResponseWS(SObject sobj,String status,Map<String,Object>  resMap);
    String getStatusForAPICall();
    void   done_job();
    Boolean isUpdateMainObj();
    Boolean getIntegrationResult(Map<String,Object>  resMap);
    Map<String,String> getCustomizedResponse(String responseBody);

    String getTokenEndpoint();
}