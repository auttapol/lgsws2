@isTest
global class ErrorHandlerTest {
    public static final String SUCCESS_CODE = '0000';
    public static final String QUERY_EXCEPTION_CODE = '1001';
    public static final String CALLOUT_EXCEPTION_CODE = '1002';
    public static final String FOUND_DUP_ALLOW_CREATE = '1010';
    public static final String FOUND_DUP_NOT_ALLOW_CREATE = '1011';
    public static final String WEBSERVICE_ERROR_CODE = '1003';
    static testmethod void  ErrorMessageTest(){
        
		TestUtils.createStatuscode();
        ErrorHandler.Messagehandler(QUERY_EXCEPTION_CODE, '');
        ErrorHandler.Messagehandler(CALLOUT_EXCEPTION_CODE, '');
        ErrorHandler.Messagehandler(FOUND_DUP_ALLOW_CREATE, '');
        ErrorHandler.Messagehandler(FOUND_DUP_NOT_ALLOW_CREATE, '');
        ErrorHandler.Messagehandler(WEBSERVICE_ERROR_CODE, '');
        ErrorHandler.ERRORMESSAGE('Message');
        ErrorHandler.INFOMESSAGE('Message');
        ErrorHandler.FATALMESSAGE('Message');
        //ErrorHandler.COMFIRMMESSAGE('Message');
        ErrorHandler.WARNINGMESSAGE('Message');
        ErrorHandler.Messagehandler(SUCCESS_CODE,'1','');
        ErrorHandler.Messagehandler('0001','30','');
        ErrorHandler.Messagehandler('0004','1','');
        ErrorHandler.Messagehandler('0005','1','');                   
        TMBServiceProxy.SearchResultDTO SearchResult1 = new TMBServiceProxy.SearchResultDTO(); 
            SearchResult1.status ='0000';
            SearchResult1.totalrecord = '1';
            SearchResult1.massage = '';
        TMBServiceProxy.ArrayOfSearchDataDTO ArrayOfSearch = new TMBServiceProxy.ArrayOfSearchDataDTO();
        TMBServiceProxy.SearchDataDTO[] searchArr = New List<TMBServiceProxy.SearchDataDTO>();    
        TMBServiceProxy.SearchDataDTO searchdata = new TMBServiceProxy.SearchDataDTO();
                searchdata.ID_TYPE = 'CI';
                searchdata.ID_NUMBER = '151';
        
        searchArr.add(searchdata);
        ArrayOfSearch.SearchDataDTO = searchArr;
        SearchResult1.Datas = ArrayOfSearch;
		TMBServiceProxy.SearchResponse_element searchResponse = new TMBServiceProxy.SearchResponse_element();
        searchResponse.SearchResult = SearchResult1;
        ErrorHandler.isAllowToCreate(SearchResult1);
        searchdata.ID_TYPE = 'PP';
        ErrorHandler.isAllowToCreate(SearchResult1);
    }
    
}