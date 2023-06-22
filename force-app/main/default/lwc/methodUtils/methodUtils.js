const parseObj = (obj) => {
    return obj ? JSON.parse(JSON.stringify(obj)) : null;
};

const getValueReference = (path, obj) => {
    let key = path.split('.')[0];
    if (path.includes('.') && obj[key]) {
        return getValueReference(path.split('.').slice(1).join('.'), obj[key]);
    }
    return obj[key];
};

const uuid = () => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        let r = Math.random() * 16 | 0,
            v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
    });
};

const replaceFormat = (template, arg) => {
    let _arg = parseObj(arg);
    let regex = /({[0-9]+})/g;
    let matchRex = `${template}`.match(regex);
    return matchRex && matchRex.length > 0 ?
        replaceFormat(
            `${template}`.replace(matchRex.shift(), _arg.shift()),
            _arg
        ) : template;
};

const markAmount = function (value) {
    value = parseFloat(value ? `${value}`.replace(/[,]/g, '') : 0).toLocaleString('en-US', {
        style: 'decimal',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
    return `${value}`.length > 2 ? `${value.substr(0, value.length - 2)}xx` : (`${value}` !== `0` ? 'xx' : '-');
};

const markAccountNo = function (value, replacement) {
    var index = 0;
    return replacement.replace(/[xy]/g, c => {
        var r = value.substr(index, 1) | '',
            v = c === 'x' ? c : r;
        index++;
        return v.toString(16);
    });
};

export {
    uuid,
    parseObj,
    replaceFormat,
    getValueReference,
    markAmount,
    markAccountNo,
};