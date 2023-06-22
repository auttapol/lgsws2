@isTest
public class UploadProspectControllerTest {
	public static testmethod void P_GetDateString(){
	
	    UploadProspectController ctr = new UploadProspectController();
	    string val = ctr.ValidDateTime;
	
	    System.assertNotEquals('', val);
	
	}
}