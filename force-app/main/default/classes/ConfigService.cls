public without sharing class ConfigService {
	/**
	*  @author Keattisak
	*  @date 01/11/2016
	*  @description This class leverages the Config custom metadata type to
	*               return configuration options for the application.
	*
	*   @CHANGE_HISTORY
	*   ==================================================================
	*   Date            Name                    Description
	*   01/11/2016      Keattisak.C             Created
	**/

	/** Licensed User state value for testing */
	@TestVisible private static Boolean testLicensedUser = true;
	/** Person Accounts state value for testing */
	@TestVisible private static Boolean testPersonAccounts = false;
	/** MultiCurrency state value for testing */
	@TestVisible private static Boolean testMultiCurrency = false;
	/** DebugInfoRecipientEmails value for testing */
	@TestVisible private static String testDebugInfoEmails = 'kct@ii.co.th';  //Defualt
	/** EmailDebugInfoLog value for testing */
	@TestVisible private static Boolean testEmailDebugInfoLog = false;
	/** KillSwitch value for testing */
	@TestVisible private static Boolean testKillSwitch = false;
	/** DebugInfoMaxAge value for testing */
	@TestVisible private static Integer testDebugInfoMaxAge = 30; //Defualt
	/** DebugInfoMaxNum value for testing */
	@TestVisible private static Integer testDebugInfoMaxNum;
	/** Default config options */
	private static Config Settings {
		get {
			// Use cached value, if any, unless in test context
			return ( Settings != null && !Test.isRunningTest() ) ? Settings : new Config();
		}
	}

	/** Email Recipients for DebugInfo and using ";" to sparate email address*/
	public static String DebugInfoEmails {
		get
		{
			return Settings.DebugInfoEmailRecipients;
		}
	}

	/** DebugInfo Log Emailing state */
	public static Boolean EmailDebugInfoEnabled {
		get
		{
			return Settings.EmailDebugInfo;
		}
	}

	/** Diagnostics state */
	public static Boolean DiagnosticsEnabled {
		get
		{
			return Settings.Diagnostics;
		}
	}

	/** Kill Switch state */
	public static Boolean KillSwitchEnabled {
		get
		{
		
			return Settings.KillSwitch;
		}
	}

	/** Maximum age in days of DebugInfo records */
	public static Integer DebugInfoMaxAge {
		get
		{
			return Settings.DebugInfoAgeMax;
		}
	}

	/** Maximum number of DebugInfo records */
	public static Integer DebugInfoMaxNum {
		get
		{
			return Settings.DebugInfoNumMax;
		}
	}

	/** Organization Id */
	public static String OrgId {
		get{
			return Settings.OrganizationId;
		}
	}

	/** Organization Name */
	public static String OrgName {
		get{
			return Settings.OrganizationName;
		}
	}




	// Config Class
	private class Config {
		/** Licensed User State */
		private Boolean UserLicensed;
		/** Email Recipients for DebugInfo */
		private String DebugInfoEmailRecipients;
		/** DebugInfo Log Emailing state */
		private Boolean EmailDebugInfo;
		/** Diagnostics state */
		private Boolean Diagnostics;
		/** Kill Switch state */
		private Boolean KillSwitch;
		/** Maximum age in days of DebugInfo records */
		private Integer DebugInfoAgeMax;
		/** Maximum number of DebugInfo records */
		private Integer DebugInfoNumMax;
		/** Organization Id */
		private String OrganizationId;
		/** Organization Name */
		private String OrganizationName;


		/** Default Config Settings */
		//private Diagnostic_Config__mdt defaultSettings = Test.isRunningTest() ? null : [SELECT DebugInfoRecipientEmails__c, EmailDebugInfoLog__c, EnableDiagnostics__c, KillSwitch__c, MaxDebugInfoAge__c, MaxDebugInfoRecords__c FROM Diagnostic_Config__mdt WHERE DeveloperName = 'Default'];

		/**
		* @author Keattisak Chinburarat
		* @date 02/11/2016
		* @description Constructor method for Config inner class
		*/
        
		private Config() {
			/*this.DebugInfoEmailRecipients = Test.isRunningTest() ? testDebugInfoEmails : defaultSettings.DebugInfoRecipientEmails__c;
			this.EmailDebugInfo = Test.isRunningTest() ? testEmailDebugInfoLog : defaultSettings.EmailDebugInfoLog__c;
			this.Diagnostics = Test.isRunningTest() ? true : defaultSettings.EnableDiagnostics__c;
			this.KillSwitch = Test.isRunningTest() ? testKillSwitch : defaultSettings.KillSwitch__c; // For Async Task
			this.DebugInfoAgeMax = Test.isRunningTest() ? testDebugInfoMaxAge : (Integer)defaultSettings.MaxDebugInfoAge__c;
			this.DebugInfoNumMax = Test.isRunningTest() ? testDebugInfoMaxNum : (Integer)defaultSettings.MaxDebugInfoRecords__c;*/
			this.OrganizationId = /*Test.isRunningTest() ? testOrgId : */ UserInfo.getOrganizationId();
			this.OrganizationName = /*Test.isRunningTest() ? testOrgName :*/ UserInfo.getOrganizationName();
		}
	}


}