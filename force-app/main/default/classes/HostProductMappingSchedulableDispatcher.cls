public with sharing class HostProductMappingSchedulableDispatcher {
	public Interface IHostProductMappingSchedulableDispatched {
		void execute();
	}
	@TestVisible
	private static integer emode = 0;
	public static void execute() {
		if (emode == 1 ) {
			emode = 2;
			return ;
		}
		if(emode == 3){
			throw new HostProductMappingSchedulableDispatcherException('HostProductMappingSchedulableDispatcher');
		}
		try {
			system.debug('=> Invoked HostProductMappingSchedulableDispatcher ');
			// Independent class when this class scheduled
			Type targettype = Type.forName('HostProductMappingSchedulableHandler');
			if (targettype != null) {
				IHostProductMappingSchedulableDispatched obj = (IHostProductMappingSchedulableDispatched)targettype.NewInstance();
				obj.execute();
			}
		} catch (exception ex) {
			system.debug('HostProductMappingSchedulableDispatcher Error cause :' + ex.getMessage() );
			throw new HostProductMappingSchedulableDispatcherException('HostProductMappingSchedulableDispatcher Error cause :' + ex.getMessage() , ex);
		}
	}
	public class HostProductMappingSchedulableDispatcherException extends Exception {
	}
}