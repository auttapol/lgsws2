global class UploadLead implements Comparable
  {
      public String leadName                                {get;set;}
      public String leadOwner                               {get;set;}
      public String leadOwnername                           {get;set;}
      public String PrimaryCampaign                         {get;set;}
      public String PrimaryCampaignName                     {get;set;}
      public String LeadOwnerExceptionFlag                  {get;set;}
      public String LinktoCustomer                          {get;set;}
      public String LinktoCustomerName                      {get;set;}
      public String CustomerType                            {get;set;}
      public String CustomerName                            {get;set;}
      public String CustomerNameEN                          {get;set;}
      public String IDType                                  {get;set;}
      public String IDNumber                                {get;set;}
      public String ContactTitle                            {get;set;}
      public String ContactFirstname                        {get;set;}
      public String ContactLastname                         {get;set;}
      public String ContactPosition                         {get;set;}
      public String DecisionMap                             {get;set;}
      public String ContactPhoneNumber                      {get;set;}
      public String Industry                                {get;set;}
      public String IndustryName                            {get;set;}
      public String Groupname                               {get;set;}
      public String Groupname2                              {get;set;}
      public String NoOfyears                               {get;set;}
      public String SalesAmountperyear                      {get;set;}
      public String LeadSource                              {get;set;}
      public String OtherSource                             {get;set;}
      public String BranchedReferred                        {get;set;}
      public String BranchedReferredName                    {get;set;}
      public String ReferralStaffID                         {get;set;}
      public String ReferralStaffName                       {get;set;}
      Public String TotalExpectedRevenue                    {get;set;}
      public String Address                                 {get;set;}
      public String SubDistrict                             {get;set;}
      public String District                                {get;set;}
      public String Province                                {get;set;}
      public String ZipCode                                 {get;set;}
      public String Country                                 {get;set;}
      public String MobileNo                                {get;set;}
      public String OfficeNo                                {get;set;}
      public String Ext                                     {get;set;}
      public String Email                                   {get;set;}
      public String Rating                                  {get;set;}
      public String Remark                                  {get;set;}
      public String prescreen								{get;set;}
      public String Status									{get;set;}
      public String LeadId                                  {get;set;}
      public String LeadRecordtypeId                        {get;set;}
      public String LeadRecordtypeName                      {get;set;}
      public String WarningMessage                      	{get;set;}
      
      
      public Integer row                                    {get;set;} 
      // Result in services
      public Boolean Invialid                               {get;set;}
      public String Success                                 {get;set;}
      public String Created                                 {get;set;}
      public String Error                                   {get;set;}
      public String Id                                      {get;set;}
      public Boolean flag                                   {get;set;}
      public String Errormessage                            {get;set;}
      
      
    /* public UploadLead(integer r){
          row = r;
      }*/
      
      
      global Integer compareTo(Object compareTo) {
        UploadLead compareToLead= (UploadLead)compareTo;
        if (row == compareToLead.row) return 0;
        if (row > compareToLead.row) return 1;
        return -1;        
    }
  }