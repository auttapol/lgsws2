({
    // handleUploadFinished: function (cmp, event) {
    //     // Get the list of uploaded files
    //     var uploadedFiles = event.getParam("files");
    //     alert("Files uploaded : " + uploadedFiles[0].name);

    //     // Get the file name
    //     var uploadFile = event.getSource().get("v.files");
    //     console.log(uploadFile);
    //     console.log(uploadedFiles[0].name);
    //     console.log(uploadedFiles[0]);
    // }

    handleUploadFinished : function(component, event, helper) {
        console.log('component: ' + component);
        console.log('event: ' + event);
        console.log('file: ' + component.find("fuploader").get("v.files"));
        console.log('length: ' + component.find("fuploader").get("v.files").length);
        var uploadedFiles = event.getParam("files");
        var documentId = uploadedFiles[0].documentId;
        var fileName = uploadedFiles[0].name;
        // alert("Files uploaded : " + uploadedFiles[0].name);
        helper.showToast('Success','Success','File Uploaded successfully');        
    },
    
    handleClick: function(component, event, helper) {
        
        console.log('file: ' + component.find("fuploader").get("v.files"));
        console.log('length: ' + component.find("fuploader").get("v.files").length);
        if (component.find("fuploader").get("v.files")!=null && component.find("fuploader").get("v.files").length > 0) {

            helper.uploadHelper(component, event);
        } else {
            helper.showToast('Error','Error','Please Select a Valid File');
        }
    },
     
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        var uploadFile = event.getSource().get("v.files")[0];
        var file = uploadFile;
        var reader = new FileReader();
        reader.onload = function (evt) {
            var csv = evt.target.result;
            console.log('csv: ' + csv);
            var rows = csv.split("\r\n");
            rows.pop();
            // console.log('rows: ',rows);
            console.log('rows: ',rows[0]);
            console.log('eiei');
            var size = rows.length - 1;
            console.log('size: ',size);
        }
        // helper.showToast('Success','Success','File Uploaded successfully');   
        reader.readAsText(file, "UTF-8");
        console.log('reader: ' + reader);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
        var uploadFile = component.find("fuploader").get("v.files");
        var object = component.find("object").get("v.value");
        console.log('object: ' + object);

        if(uploadFile!=null && uploadFile.length > 0 && object != 'choose one...'){
            component.set("v.valid", false);
        }
        
    },
    handleObjectChange:function(component, event, helper){
        var uploadFile = component.find("fuploader").get("v.files");
        var object = component.find("object").get("v.value");
        console.log('object: ' + object);
        if(uploadFile!=null && uploadFile.length > 0 && object != 'choose one...'){
            component.set("v.valid", false);
        }

    }
})