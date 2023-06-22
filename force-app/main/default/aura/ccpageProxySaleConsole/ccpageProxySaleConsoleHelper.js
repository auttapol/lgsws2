({
    parseObj: function (objFields) {
        return objFields ? JSON.parse(JSON.stringify(objFields)) : null;
    },
})