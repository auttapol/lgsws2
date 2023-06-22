({
 
     doInit : function(component, event, helper) {
         component.set('v.Message1', {
             Header: '',
             TextMessage: ''
            });
         component.set('v.Message2', {
             Header: '',
             TextMessage: ''
            });
         component.set('v.colors1','black');
         component.set('v.colors2','black');
         component.set('v.displayName', 'display : none;');

         var workspaceAPI = component.find("workspace");
         workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTabId = response.tabId;
             workspaceAPI.setTabLabel({
                 tabId: focusedTabId,
                 label: "Upload Task"
             });
         });

        // helper.getErrorMessage(component,event,helper);
     },
      
     showfiledata :  function (component, event, helper){        
         var uploadFile = event.getSource().get("v.files")[0];
         var file = uploadFile;
         var ErrorMessage = component.get('v.ErrorMessage');
         console.log(file);
         if (file) {
             var filename = file.name.toLowerCase();
             var CSVName = file.name;
             component.set('v.CSVNameUpsert',CSVName);
 
             filename = filename.substr(filename.length - 3);
             console.log(filename);
             if (filename == 'csv'){
                 component.set('v.displayName', '');
                 component.set('v.uploadErrorUpsert',false);
                 var reader = new FileReader();
                 reader.readAsText(file, "UTF-8");
                 reader.onload = function (evt) {
                 var csv = evt.target.result;
                 var table = document.createElement("table");
                 var rows = csv.split("\n");
                 rows.pop();
                 console.log('rows 1: ',rows);
                 var size = rows.length -1;
                 if (size > 5001){
                     component.set('v.confirmUpsert',false);
                     console.log('not csv file');
                     component.set('v.uploadErrorUpsert',true);
                     component.set('v.Message1', {
                         Header: 'Error!',
                         TextMessage: ErrorMessage[2].split('2,000').join('5,000'),
                        });
                     component.set('v.colors1','red');
                 }else {
                     component.set('v.confirmUpsert',true);
                     component.set('v.CSVArray',rows);
                     component.set('v.CSVNameUpsert', CSVName); 

                     component.set('v.Message1', {
                        Header: 'Confirm to Upload ' + size + ' records?',
                        TextMessage: '',
                       });
                     
                 }
                 
                 }
                 reader.onerror = function (evt) {
                     console.log("error reading file");
                     component.set('v.uploadErrorUpsert',false);
                     component.set('v.UpsertTask',true);
                     component.set('v.confirmUpsert',false);
                     component.set('v.Message1', {
                         Header: 'Error!',
                         TextMessage: ErrorMessage[1],
                     });
                     component.set('v.colors1','red');
             }
             }else {
                 component.set('v.confirmUpsert',false);
                 console.log('not csv file');
                 component.set('v.uploadErrorUpsert',true);
                 component.set('v.Message1', {
                     Header: 'Error!',
                     TextMessage: ErrorMessage[0],
                    });
                 component.set('v.colors1','red');
             }
             component.set('v.showLoadButton',false);
         }
     },  
     
     DeleteCSV : function (component, event, helper){
         var uploadFile = event.getSource().get("v.files")[0];
         var ErrorMessage = component.get('v.ErrorMessage');
         var file = uploadFile;
         var CSVName = file.name;
         component.set('v.CSVNameDelete',CSVName);
         if (file) {
             var filename = file.name.toLowerCase();
             filename = filename.substr(filename.length - 3);
             console.log(filename);
             if (filename == 'csv'){
                 var reader = new FileReader();
                 reader.readAsText(file, "UTF-8");
                 reader.onload = function (evt) {
                 var csv = evt.target.result;
                 var table = document.createElement("table");
                 var rows = csv.split("\n");
                 rows.pop();
                 console.log('rows 1: ',rows);
                 console.log('eiei');
                 var size = rows.length - 1;
                 if (size > 5001){
                     component.set('v.uploadErrorDelete',true);
                     component.set('v.confirmDelete',false);
                         component.set('v.Message2', {
                             Header: 'Error!',
                             TextMessage: ErrorMessage[2].split('2,000').join('5,000'),
                         });
                         component.set('v.colors2','red');
                 }else {
                     component.set('v.Message2', {
                         Header: 'Confirm to Delete ' + size + ' records?',
                         TextMessage: 'This process will not be able to roll back.',
                        });
                     component.set('v.uploadErrorDelete',false);
                     component.set('v.confirmDelete',true);
                     component.set('v.CSVArray',rows);
                 }
                 
                 }
                 reader.onerror = function (evt) {
                     console.log("error reading file");
                     component.set('v.confirmDelete',false);
                     component.set('v.uploadErrorDelete',false);
                     component.set('v.DeleteTask',false);
                     component.set('v.Message2', {
                         Header: 'Error!',
                         TextMessage: ErrorMessage[1],
                     });
                     component.set('v.colors2','red');
                 }
             }else {
                 component.set('v.uploadErrorDelete',true);
                 component.set('v.confirmDelete',false);
                     component.set('v.Message2', {
                         Header: 'Error!',
                         TextMessage: ErrorMessage[0],
                     });
                     component.set('v.colors2','red');
             }
             
         }
     } ,
     confirmUpsert : function (component, event, helper) {

         var rows = component.get('v.CSVArray');
         component.set('v.showLoadButton',false);
         component.set('v.confirmUpsert',false);
         component.set('v.UpsertTask',false);
         component.set('v.Message1', {
             Header: 'Import Task!',
             TextMessage: 'System will take approx 3-5 mins to import data. Email notification will be sent after finished. Please click the link from an email or Press F5 on screen to see result in tab log File.',
             TextMessageTH: '(ระบบกำลังโหลดข้อมูล ใช้เวลา 3-5 นาที ท่านจะได้รับ E-Mail เพื่อใช้ Link หรือกด F5 เพื่อดูผลการโหลดใน tab Log File)',
            });
         component.set('v.colors1','black');   
         component.set('v.displayName', 'display : none;');
         
         console.log('SUCCESS !');
         helper.sendCSVArray(component, event, helper, rows);
     },
 
     confirmDelete : function (component, event, helper) {
         var rows = component.get('v.CSVArray');
         component.set('v.Message2', {
             Header: 'Delete Task!',
             TextMessage: 'System will take approx 3-5 mins to import data. Email notification will be sent after finished. Please click the link from an email or Press F5 on screen to see result in tab log File.',
             TextMessageTH: '(ระบบกำลังโหลดข้อมูล ใช้เวลา 3-5 นาที ท่านจะได้รับ E-Mail เพื่อใช้ Link หรือกด F5 เพื่อดูผลการโหลดใน tab Log File)',
           });
         component.set('v.DeleteTask',false);
         component.set('v.confirmDelete',false);
         component.set('v.colors2','black');
         helper.DeleteTasks(component, event, helper, rows);
     },
     cancelDelete : function (component, event ,helper){
         component.set('v.DeleteTask',true);
         component.set('v.confirmDelete',false);
         component.set('v.CSVNameDelete', '');
         component.set('v.FileDelete', undefined);
     },
     cancelUpsert :function(component, event, helper) {
         component.set('v.UpsertTask',true);
         component.set('v.confirmUpsert',false);
         component.set('v.CSVNameUpsert', '');
         component.set('v.FileUpsert',undefined);
         component.set('v.showResult',false);         
      
     },

     showLogfile : function(component, event, helper) {
        component.set('v.showlog',true);
        helper.logFileHelper(component, event, helper);
    }
    /*
    showLoadResultMessage : function(component, event, helper) {
        helper.LoadResultMessage(component, event, helper);
    }
    */
 
 })