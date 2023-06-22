public class approverTableComponentController {
    public class approverWraperClass {
        public String RowNumber {get;set;}
        public User Approver {get; set;}
    }

    public List<User> approverlst {get;set;}
    
    public List<approverWraperClass> approverWraperlst {
        get{
            if(approverWraperlst == null){
                approverWraperlst = new List<approverWraperClass>();
                approverWraperClass approverWrap;
                Integer i = 0;
                System.debug('approverlst : ' + approverlst);
                for (User u : approverlst) {
                    i += 1;
                    approverWrap = new approverWraperClass ();
                    approverWrap.RowNumber = 'Approver ' + i;
                    approverWrap.Approver = u;
                    approverWraperlst.add(approverWrap);
                }
            }
            return approverWraperlst;
        }
        set;
    }
}