cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
  {
    "id": "cordova-plugin-splashscreen.SplashScreen",
    "file": "plugins/cordova-plugin-splashscreen/www/splashscreen.js",
    "pluginId": "cordova-plugin-splashscreen",
    "clobbers": [
      "navigator.splashscreen"
    ]
  },
  {
    "id": "com.kyee.kymhv2.baidumap.KyeeBaiduMap",
    "file": "plugins/com.kyee.kymhv2.baidumap/www/BaiduMap.js",
    "pluginId": "com.kyee.kymhv2.baidumap",
    "clobbers": [
      "navigator.map"
    ]
  }
];
module.exports.metadata = 
// TOP OF METADATA
{
  "cordova-plugin-whitelist": "1.3.3",
  "cordova-plugin-splashscreen": "4.0.4-dev",
  "com.kyee.kymhv2.baidumap": "1.1.0"
};
// BOTTOM OF METADATA
});