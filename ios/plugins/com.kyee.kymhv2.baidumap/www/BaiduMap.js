    var exec = require('cordova/exec');
               
    var kyeeBaiduMap = {
        getCityName: function (success, error, params) {
            exec(success, error, "KyeeBaiduMap", "getCityName", params);
        },
        getLatitudeAndLongtitude: function (success, error, params) {
            exec(success, error, "KyeeBaiduMap", "getLatitudeAndLongtitude", params);
        },
        showMap: function (success, error, params) {
            exec(success, error, "KyeeBaiduMap", "showMap", params);
        },
        getCityCode: function (success, error, params) {
            exec(success, error, "KyeeBaiduMap", "getCityCode", params);
        }
    };

    module.exports = kyeeBaiduMap;
