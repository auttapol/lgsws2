({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb 
     
    uploadHelper: function(component, event) {
        var object = component.find("object").get("v.value");
        console.log('object: ' + object);
        var fileInput = component.find("fuploader").get("v.files");
        var file = fileInput[0];
        var self = this;
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            return;
        }
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
            self.uploadInChunk(component, csv, object);
        }
        reader.readAsText(file, "UTF-8");
    },
     
    
    uploadInChunk: function(component, file, object) {
        var action = component.get("c.uploadFile");
        action.setParams({
            CSV: file,
            objectName: object,
        });
         
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' + state);
            if (state === "SUCCESS") {
                this.showToast('Success','Success','File Uploaded successfully');
            } else if (state === "INCOMPLETE") {
                this.showToast('Error','Error','Issue in uploading File '+response.getReturnValue());   
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        this.showToast('Error','Error','Issue in uploading File '+errors[0].message);   
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },

    showToast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
})