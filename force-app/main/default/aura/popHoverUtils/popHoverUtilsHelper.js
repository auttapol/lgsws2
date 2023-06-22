({
    parseObj: function (obj) {
        return obj ? JSON.parse(JSON.stringify(obj)) : null;
    },
    uuid: function () {
        return 'xxxxyxxx'.replace(/[xy]/g, function (c) {
            let r = Math.random() * 16 | 0,
                v = c == 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
})