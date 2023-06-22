const FIELDS = {
    Lead: [
        'Name'
    ],
    Account: [
        'Name', 'Type', 'Phone', 'Website', 'OwnerId', 'Site',
        'Industry', 'BillingAddress', 'ParentId', 'AnnualRevenue'
    ],
    Contact: [

    ],
    Opportunity: [

    ],
    Case: [

    ],
    User: [
        'Name', 'Title', 'Email',
        'Phone', 'ManagerId', 'Employee_ID__c',
    ],
    Branch_and_Zone__c: [
        'Name', 'RTL_Branch_Contact_Number__c', 'RTL_Branch_Manager_User__c',
        'RTL_Branch_Manager_Contact_Number__c', 'RTL_Working_Date_Hours__c',
        'RTL_Operating_Days_EN__c', 'RTL_Operating_Days_TH__c', 'IsActive__c',
    ]
};

export {
    FIELDS
}