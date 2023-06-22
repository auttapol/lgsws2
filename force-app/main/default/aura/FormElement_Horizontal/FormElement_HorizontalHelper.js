({
    parseObj: function (obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : null;
    }
})