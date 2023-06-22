trigger RTL_LeadTrigger on Lead ( before insert, before update, after insert, after update) {
  	
    Id retailLead = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
    boolean runRetailTrigger = false;
    for(Lead lead: trigger.new){
    	if(lead.RecordTypeId != null && lead.RecordTypeId == retailLead) {
    		System.debug('RTL_LeadTrigger commercail --- ' + lead.RecordTypeId);
    		System.debug('RTL_LeadTrigger retail --- ' + retailLead);
    		runRetailTrigger = true;
    		break;
    	}
    } 
    if(runRetailTrigger) {
    	System.debug('RTL_LeadTrigger Executed --- ' + runRetailTrigger);
        new RTL_LeadTriggerHandler().run();
    }
    
}