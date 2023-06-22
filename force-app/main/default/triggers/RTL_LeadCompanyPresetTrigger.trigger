trigger RTL_LeadCompanyPresetTrigger on Lead (before insert) {   
    Id retailLead = Schema.Sobjecttype.Lead.getRecordTypeInfosByName().get('Retail Banking').getRecordTypeId();
    for(Lead lead: trigger.new){
        if(lead.RecordTypeId == retailLead) {
            lead.Company = (lead.FirstName != null? lead.FirstName + ' ' + lead.LastName: lead.LastName);
        }
    }
}