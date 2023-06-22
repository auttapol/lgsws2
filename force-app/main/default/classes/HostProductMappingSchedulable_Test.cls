@isTest
private class HostProductMappingSchedulable_Test {

    @isTest
    private static void test_Run_HostProductMappingSchedulable() {
        String CRON_EXP = '0 0 0 15 3 ? 2030';
        // Set Mock HostProductMappingSchedulableDispatcher
        HostProductMappingSchedulableDispatcher.emode = 1;
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('HostProductMappingSchedulable_TEST', CRON_EXP, new HostProductMappingSchedulable());
        Test.stopTest();
        system.assertEquals(2, HostProductMappingSchedulableDispatcher.emode);

    }
    @isTest
    private static void test_Run_HostProductMappingSchedulable_Exception() {
        String CRON_EXP = '0 0 0 15 3 ? 2030';
        // Set Mock HostProductMappingSchedulableDispatcher
        HostProductMappingSchedulableDispatcher.emode = 3;
        boolean isError = false;
        Test.startTest();
        // Schedule the test job
        try {
            HostProductMappingSchedulable b =  new HostProductMappingSchedulable();
            b.execute(null);

        } catch (Exception ex) {
            isError = true;
        }
        Test.stopTest();
        system.assert(isError);
    }
    @isTest
    private static void test_Run_HostProductMappingSchedulable_Pass_Through() {

       //Set Mock Service 
       HostProductMappingService.mockService = new MockHostProductMappingService();
        String CRON_EXP = '0 0 0 15 3 ? 2030';
        // Set Mock HostProductMappingSchedulableDispatcher
        String jobId ='';
        Test.startTest();
        // Schedule the test job
        jobId = System.schedule('HostProductMappingSchedulable_TEST2', CRON_EXP, new HostProductMappingSchedulable());
        Test.stopTest();
        system.assertNotEquals(null , jobId);
    }


    /***********************************************************************************************************
    *   Mock 
    ************************************************************************************************************/
    public class MockHostProductMappingService implements HostProductMappingService.IHostProductMappingService {
        public void nofifyHostProductMappingNeedProductId() {
            system.debug('MockHostProductMappingService.nofifyHostProductMappingNeedProductId was invoked!!');
        }
    }

}