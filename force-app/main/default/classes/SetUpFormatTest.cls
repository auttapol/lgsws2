@isTest
public with sharing class SetUpFormatTest {
    public SetUpFormatTest() {
    }

    @isTest
    public static void getSetUpFormatTest(){
        Test.startTest();
        // Test normal Case
        String returnResult = SetUpFormat.getSetupFormat('segment_coloring');
        System.assertNotEquals(returnResult.length(), 0 ,'return json can not be empty');

        // Test Exception Case
        String returnReusltException = SetUpFormat.getSetupFormat('exception');

        // Test RTL_CSVLightningUtil.getSetUpFormat
        RTL_CSVLightningUtil.getSetUpFormat('segment_coloring');
        Test.stopTest();
    }
}