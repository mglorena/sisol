var rootDir = "";
var _WebSitePath = document.location.href;
_WebSitePath = _WebSitePath.substring(0, _WebSitePath.indexOf(rootDir + "/", 0) + 5);
var _iBrowserHeight;
var _iBrowserWidth;
getWindowsSize();
function getWindowsSize() {
    if (document.all) {
        _iBrowserHeight = document.documentElement.offsetHeight;
        _iBrowserWidth = document.documentElement.offsetWidth;
    } else {
        try {
            if (document.documentElement) {
                _iBrowserHeight = document.documentElement.clientHeight;
                _iBrowserWidth = document.documentElement.clientWidth;
            } else {
                _iBrowserHeight = document.body.clientHeight;
                _iBrowserWidth = document.body.clientWidth;
            }
        } catch (e) { //            var iBrowserHeight = $(window).height();  var iBrowserWidth = $(window).width();
        }
    }
}
/***********/
var dates = {
    convert: function(d) {
        // Converts the date in d to a date-object. The input can be:
        //   a date object: returned without modification
        //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
        //   a number     : Interpreted as number of milliseconds
        //                  since 1 Jan 1970 (a timestamp) 
        //   a string     : Any format supported by the javascript engine, like
        //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
        //  an object     : Interpreted as an object with year, month and date
        //                  attributes.  **NOTE** month is 0-11.
        return (d.constructor === Date ? d : d.constructor === Array ? new Date(d[0], d[1], d[2]) : d.constructor === Number ? new Date(d) : d.constructor === String ? new Date(d) : typeof d === "object" ? new Date(d.year, d.month, d.date) : NaN);
    },
    compare: function(a, b) {
        // Compare two dates (could be of any type supported by the convert
        // function above) and returns:
        //  -1 : if a < b
        //   0 : if a = b
        //   1 : if a > b
        // NaN : if a or b is an illegal date
        // NOTE: The code inside isFinite does an assignment (=).
        return (isFinite(a = this.convert(a).valueOf()) && isFinite(b = this.convert(b).valueOf()) ? (a > b) - (a < b) : NaN);
    },
    inRange: function(d, start, end) {
        // Checks if date in d is between dates in start and end.
        // Returns a boolean or NaN:
        //    true  : if d is between start and end (inclusive)
        //    false : if d is before start or after end
        //    NaN   : if one or more of the dates is illegal.
        // NOTE: The code inside isFinite does an assignment (=).
        return (isFinite(d = this.convert(d).valueOf()) && isFinite(start = this.convert(start).valueOf()) && isFinite(end = this.convert(end).valueOf()) ? start <= d && d <= end : NaN);
    }
}

function getId(id) {
    if (document.getElementById(id) != null) {
        return document.getElementById(id);
    } else return null;
}

function parseString(args) {
    //   args = args.replace(/'/g, "&rsquo;");
    //   args = args.replace(/"/g, "&rsquo;");
    //args = args.replace(/\/g, "&rsquo;");
    try {
        var re = new RegExp("/['\"]/g");
        args = args.replace(re, '');
        args = args.replace(/\r\n/g, "<br>");
        args = args.replace(/"/g, "´");
        args = args.replace(/\r/g, "<br>");
        args = args.replace(/\n/g, "<br>");
        args = args.replace(String.fromCharCode(10), "<br>");
        return args;
    } catch (e) {
        return args;
    }
}

function SendJsError(obj, location, data) {
    
    var sExtraData = new String();
    try {
        var sMessage = "";
        var browser;
        //        sExtraData += '<br><b>Browser</b>: ' + $.browserTest.name + ' - v: ' + $.browserTest.version + ' - ' + $.layout.name ;
        sExtraData += '<br><b>Platform</b>: ' + navigator.platform;
        sExtraData += '<br><b>Screen W</b>:' + window.screen.width + 'px - H: ' + window.screen.height + 'px<br>';
        if (obj.message) {
            sExtraData += '<b>Error in</b>:catch code <br>';
            sMessage += parseString(obj.message) + '<br>';
            if (obj.fileName) sExtraData += '<b>Filename</b>: ' + obj.fileName + '<br>';
            if (obj.sourceURL) sExtraData += '<b>Filename</b>: ' + obj.sourceURL + '<br>';
            if (obj.lineNumber) sExtraData += '<b>Line Number</b>: ' + obj.lineNumber + '<br>';
            if (obj.number) sExtraData += '<b>Line Number</b>: ' + obj.number + '<br>';
            if (obj.line) sExtraData += '<b>Line Number</b>: ' + obj.line + '<br>';
            if (obj.name) sExtraData += '<b>Error Type</b>: ' + obj.name + '<br>';
            if (obj.type) sExtraData += '<b>Error Type</b>: ' + obj.type + '<br>';
            if (obj.stack) sExtraData += '<b>Stack</b>: ' + obj.stack + '<br>';
            if (obj.description) sExtraData += '<b>Description</b>: ' + parseString(obj.description) + '<br>';
            if (obj.arguments) {
                var params = parseString(var_export(obj.arguments));
                if (params.length > 500) params = params.substring(0, 300);
                sExtraData += '<b>Arguments</b>: ' + params + '<br>';
            }
        } else {
            if (obj.error) { // response.error
                sMessage += parseString(obj.error.Message) + '<br>';
                sMessage += '<b>Type: </b>' + obj.error.Type;
                if (obj.error.Type === "ConnectFailure") sMessage = +' - (this message wont be reported in the future)';
            } // response.error.Message
            if (obj.Message) {
                sMessage += parseString(obj.Message) + '<br>';
                sMessage += '<b>Type: </b>' + parseString(obj.Type);
            }
            if (obj.value) sExtraData += '<b>Value:</b>: ' + obj.value + '<br>';
            if (obj.request) {
                if (obj.request.method) sExtraData += '<b>Method</b>: ' + obj.request.method + '<br>';
                if (obj.request.args) {
                    var params = parseString(var_export(obj.request.args));
                    sExtraData += '<b>Arguments</b>: <br/>' + params + '<br>';
                }
            }
            if (obj.context) sExtraData += '<b>Context</b>: ' + obj.context + '<br>';
            if (obj.duration) sExtraData += '<b>Duration</b>: ' + obj.duration + '<br>';
        }
        try {
            if (data) {
                if (data.url) {
                    sExtraData += '<b>Object params</b>:<ul>';
                    sExtraData += '<li><b>url</b>: ' + parseString(data.url) + '<br></li>';
                    try {
                        sExtraData += '<li><b>xmlHttp</b>: ' + parseString(var_export(data.xmlHttp)) + '<br></li>';
                    } catch (e) {}
                    sExtraData += '<li><b>isRunning</b>: ' + parseString(data.isRunning) + '<br></li>';
                    sExtraData += '</ul>';
                } else sExtraData += '<b>Object params</b>: ' + parseString(var_export(data)) + '<br>';
            } else sExtraData += '<b>Object params - data is false</b>: ' + parseString(var_export(data)) + '<br>';
        } catch (e) {
            alert(e.message);
        }
        sExtraData += '<br><b>Location:</b> ' + document.location.href;
        sExtraData += '<br><b>Cookies:</b> ' + document.cookie;
        x_SendJsError(parseString(sMessage), parseString(location), parseString(sExtraData), SendJsError_callback);
        //console.log("SendJsError sending mail");
    } catch (et) {
        console.log(et.message);
    }
}

function var_export(mixed_expression, bool_return) {
    var retstr = '',
        iret = '',
        cnt = 0,
        x = [],
        i = 0,
        funcParts = [],
        idtLevel = arguments[2] || 2, // We use the last argument (not part of PHP) to pass in our indentation level
        innerIndent = '',
        outerIndent = '';
    var getFuncName = function(fn) {
        var name = (/\W*function\s+([\w\$]+)\s*\(/).exec(fn);
        if (!name) {
            return '(Anonymous)';
        }
        return name[1];
    };
    var _makeIndent = function(idtLevel) {
        return (new Array(idtLevel + 1)).join(' ');
    };
    var __getType = function(inp) {
        var i = 0;
        var match, type = typeof inp;
        if (!inp) return 'null';
        if (type === 'object' && !inp) return 'null'; // Should this be just null?        
        if (type === 'object' && inp.constructor && getFuncName(inp.constructor) === 'PHPJS_Resource') return 'resource';
        if (type === 'function') return 'function';
        if (type === "object") {
            if (!inp.constructor) return 'object';
            var cons = inp.constructor.toString();
            match = cons.match(/(\w+)\(/);
            if (match) cons = match[1].toLowerCase();
            var types = ["boolean", "number", "string", "array"];
            for (i = 0; i < types.length; i++) {
                if (cons === types[i]) {
                    type = types[i];
                    break;
                }
            }
        }
        return type;
    };
    var type = __getType(mixed_expression);
    if (type === null) {
        retstr = "NULL";
    } else if (type === 'array' || type === 'object') {
        outerIndent = _makeIndent(idtLevel - 2);
        innerIndent = _makeIndent(idtLevel);
        for (i in mixed_expression) {
            var value = this.var_export(mixed_expression[i], true, idtLevel + 2);
            value = typeof value === 'string' ? value.replace(/</g, '&lt;').replace(/>/g, '&gt;') : value;
            x[cnt++] = innerIndent + i + ' => ' + (__getType(mixed_expression[i]) === 'array' ? '\n' : '') + value;
        }
        iret = x.join(',\n');
        var date;
        try {
            date = Date.parse(mixed_expression);
            if (isNaN | (date)) date = dateFormat(date, "mm/dd/yyyy");
            else date = null;
        } catch (e) {}
        if (iret.indexOf("dateFormat") == -1 && outerIndent.indexOf("dateFormat") == -1) retstr = outerIndent + "array (\n" + iret + '\n' + outerIndent + ')';
        else retstr = outerIndent + date;
    } else if (type === 'function') {
        funcParts = mixed_expression.toString().match(/function .*?\((.*?)\) \{([\s\S]*)\}/);
        retstr = "create_function ('" + funcParts[1] + "', '" + funcParts[2].replace(new RegExp("'", 'g'), "\\'") + "')";
    } else if (type === 'resource') {
        retstr = 'NULL'; // Resources treated as null for var_export
    } else {
        retstr = (typeof(mixed_expression) !== 'string') ? mixed_expression : "'" + mixed_expression.replace(/(["'])/g, "\\$1").replace(/\0/g, "\\0") + "'";
    }
    if (bool_return !== true) return retstr;
    else return retstr;
}
/*browser plugin*/
(function($) {
    $.browserTest = function(a, z) {
        var u = 'unknown',
            x = 'X',
            m = function(r, h) {
                for (var i = 0; i < h.length; i = i + 1) {
                    r = r.replace(h[i][0], h[i][1]);
                }
                return r;
            },
            c = function(i, a, b, c) {
                var r = {
                    name: m((a.exec(i) || [u, u])[1], b)
                };
                r[r.name] = true;
                r.version = (c.exec(i) || [x, x, x, x])[3];
                if (r.name.match(/safari/) && r.version > 400) {
                    r.version = '2.0';
                }
                if (r.name === 'presto') {
                    r.version = ($.browser.version > 9.27) ? 'futhark' : 'linear_b';
                }
                r.versionNumber = parseFloat(r.version, 10) || 0;
                r.versionX = (r.version !== x) ? (r.version + '').substr(0, 1) : x;
                r.className = r.name + r.versionX;
                return r;
            };
        a = (a.match(/Opera|Navigator|Minefield|KHTML|Chrome/) ? m(a, [
            [/(Firefox|MSIE|KHTML,\slike\sGecko|Konqueror)/, ''],
            ['Chrome Safari', 'Chrome'],
            ['KHTML', 'Konqueror'],
            ['Minefield', 'Firefox'],
            ['Navigator', 'Netscape']
        ]) : a).toLowerCase();
        $.browser = $.extend((!z) ? $.browser : {}, c(a, /(camino|chrome|firefox|netscape|konqueror|lynx|msie|opera|safari)/, [], /(camino|chrome|firefox|netscape|netscape6|opera|version|konqueror|lynx|msie|safari)(\/|\s)([a-z0-9\.\+]*?)(\;|dev|rel|\s|$)/));
        $.layout = c(a, /(gecko|konqueror|msie|opera|webkit)/, [
            ['konqueror', 'khtml'],
            ['msie', 'trident'],
            ['opera', 'presto']
        ], /(applewebkit|rv|konqueror|msie)(\:|\/|\s)([a-z0-9\.]*?)(\;|\)|\s)/);
        $.os = {
            name: (/(win|mac|linux|sunos|solaris|iphone)/.exec(navigator.platform.toLowerCase()) || [u])[0].replace('sunos', 'solaris')
        };
        if (!z) {
            $('html').addClass([$.os.name, $.browser.name, $.browser.className, $.layout.name, $.layout.className].join(' '));
        }
    };
    $.browserTest(navigator.userAgent);
})(jQuery);
/*************/
function getValueDdl(ddl, index) {
    return ddl.options[index].value;
}

function getTextDdl(ddl, index) {
    return ddl.options[index].text;
}

function getIndexDdlByText(ddl, text) {
    var index;
    for (i = 0; i < ddl.options.length; i++) {
        if (ddl.options[i].text == text) {
            index = i;
            break;
        }
    }
    return index;
}

function getIndexDdlByValue(ddl, value) {
    var index;
    for (i = 0; i < ddl.options.length; i++) {
        if (ddl.options[i].value == value) {
            index = i;
            break;
        }
    }
    return index;
}

function utf8_encode(argString) {
    // http://kevin.vanzonneveld.net
    // +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: sowberry
    // +    tweaked by: Jack
    // +   bugfixed by: Onno Marsman
    // +   improved by: Yves Sucaet
    // +   bugfixed by: Onno Marsman
    // +   bugfixed by: Ulrich
    // +   bugfixed by: Rafal Kukawski
    // +   improved by: kirilloid
    // *     example 1: utf8_encode('Kevin van Zonneveld');
    // *     returns 1: 'Kevin van Zonneveld'
    if (argString === null || typeof argString === "undefined") {
        return "";
    }
    var string = (argString + ''); // .replace(/\r\n/g, "\n").replace(/\r/g, "\n");
    var utftext = '',
        start, end, stringl = 0;
    start = end = 0;
    stringl = string.length;
    for (var n = 0; n < stringl; n++) {
        var c1 = string.charCodeAt(n);
        var enc = null;
        if (c1 < 128) {
            end++;
        } else if (c1 > 127 && c1 < 2048) {
            enc = String.fromCharCode((c1 >> 6) | 192, (c1 & 63) | 128);
        } else {
            enc = String.fromCharCode((c1 >> 12) | 224, ((c1 >> 6) & 63) | 128, (c1 & 63) | 128);
        }
        if (enc !== null) {
            if (end > start) {
                utftext += string.slice(start, end);
            }
            utftext += enc;
            start = end = n + 1;
        }
    }
    if (end > start) {
        utftext += string.slice(start, stringl);
    }
    return utftext;
}

function utf8_decode(str_data) {
    // http://kevin.vanzonneveld.net
    // +   original by: Webtoolkit.info (http://www.webtoolkit.info/)
    // +      input by: Aman Gupta
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: Norman "zEh" Fuchs
    // +   bugfixed by: hitwork
    // +   bugfixed by: Onno Marsman
    // +      input by: Brett Zamir (http://brett-zamir.me)
    // +   bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // *     example 1: utf8_decode('Kevin van Zonneveld');
    // *     returns 1: 'Kevin van Zonneveld'
    var tmp_arr = [],
        i = 0,
        ac = 0,
        c1 = 0,
        c2 = 0,
        c3 = 0;
    str_data += '';
    while (i < str_data.length) {
        c1 = str_data.charCodeAt(i);
        if (c1 < 128) {
            tmp_arr[ac++] = String.fromCharCode(c1);
            i++;
        } else if (c1 > 191 && c1 < 224) {
            c2 = str_data.charCodeAt(i + 1);
            tmp_arr[ac++] = String.fromCharCode(((c1 & 31) << 6) | (c2 & 63));
            i += 2;
        } else {
            c2 = str_data.charCodeAt(i + 1);
            c3 = str_data.charCodeAt(i + 2);
            tmp_arr[ac++] = String.fromCharCode(((c1 & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
            i += 3;
        }
    }
    return tmp_arr.join('');
}

function convertMoney(num) {
    num = String(num);
    return "$" + currency(num);
}

function convertCurr(value) {
    var newvalue = "0";
    if (value != null && value != "" && typeof value != "undefined") {
        var num = value.toString().trim().replace(/\s/g, "").replace(/,/g, "");
        newvalue = isNaN(num) ? value : currency(value);
    }
    return newvalue;
}

function currency(num) {
    num = num.toString().trim().replace(/\s/g, "").replace(/,/g, "");
    if (num === '') return;
    // if the number is valid use it, otherwise clean it
    if (isNaN(num)) num = '0';
    // evalutate number input
    var numParts = String(num).split(',');
    var isPositive = (num == Math.abs(num));
    var hasDecimals = (numParts.length > 1);
    var decimals = (hasDecimals ? numParts[1].toString() : '0');
    var originalDecimals = decimals;
    // format number
    num = Math.abs(numParts[0]);
    num = isNaN(num) ? "0" : num;
    num = String(num);
    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++) {
        num = num.substring(0, num.length - (4 * i + 3)) + '' + num.substring(num.length - (4 * i + 3));
    }
    return num;
}

function strtotime(str, now) {
    // Convert string representation of date and time to a timestamp  
    // 
    // version: 902.2516
    // discuss at: http://phpjs.org/functions/strtotime
    // +   original by: Caio Ariede (http://caioariede.com)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +      input by: David
    // +   improved by: Caio Ariede (http://caioariede.com)
    // %        note 1: Examples all have a fixed timestamp to prevent tests to fail because of variable time(zones)
    // *     example 1: strtotime('+1 day', 1129633200);
    // *     returns 1: 1129719600
    // *     example 2: strtotime('+1 week 2 days 4 hours 2 seconds', 1129633200);
    // *     returns 2: 1130425202
    // *     example 3: strtotime('last month', 1129633200);
    // *     returns 3: 1127041200
    // *     example 4: strtotime('2009-05-04 08:30:00');
    // *     returns 4: 1241418600
    var i, match, s, strTmp = '',
        parse = '';
    strTmp = str;
    strTmp = strTmp.replace(/\s{2,}|^\s|\s$/g, ' '); // unecessary spaces
    strTmp = strTmp.replace(/[\t\r\n]/g, ''); // unecessary chars
    if (strTmp == 'now') {
        return (new Date()).getTime();
    } else if (!isNaN(parse = Date.parse(strTmp))) {
        return parse / 1000;
    } else if (now) {
        now = new Date(now);
    } else {
        now = new Date();
    }
    strTmp = strTmp.toLowerCase();
    var process = function(m) {
        var ago = (m[2] && m[2] == 'ago');
        var num = (num = m[0] == 'last' ? -1 : 1) * (ago ? -1 : 1);
        switch (m[0]) {
            case 'last':
            case 'next':
                switch (m[1].substring(0, 3)) {
                    case 'yea':
                        now.setFullYear(now.getFullYear() + num);
                        break;
                    case 'mon':
                        now.setMonth(now.getMonth() + num);
                        break;
                    case 'wee':
                        now.setDate(now.getDate() + (num * 7));
                        break;
                    case 'day':
                        now.setDate(now.getDate() + num);
                        break;
                    case 'hou':
                        now.setHours(now.getHours() + num);
                        break;
                    case 'min':
                        now.setMinutes(now.getMinutes() + num);
                        break;
                    case 'sec':
                        now.setSeconds(now.getSeconds() + num);
                        break;
                    default:
                        var day;
                        if (typeof(day = __is_day[m[1].substring(0, 3)]) != 'undefined') {
                            var diff = day - now.getDay();
                            if (diff == 0) {
                                diff = 7 * num;
                            } else if (diff > 0) {
                                if (m[0] == 'last') diff -= 7;
                            } else {
                                if (m[0] == 'next') diff += 7;
                            }
                            now.setDate(now.getDate() + diff);
                        }
                }
                break;
            default:
                if (/\d+/.test(m[0])) {
                    num *= parseInt(m[0]);
                    switch (m[1].substring(0, 3)) {
                        case 'yea':
                            now.setFullYear(now.getFullYear() + num);
                            break;
                        case 'mon':
                            now.setMonth(now.getMonth() + num);
                            break;
                        case 'wee':
                            now.setDate(now.getDate() + (num * 7));
                            break;
                        case 'day':
                            now.setDate(now.getDate() + num);
                            break;
                        case 'hou':
                            now.setHours(now.getHours() + num);
                            break;
                        case 'min':
                            now.setMinutes(now.getMinutes() + num);
                            break;
                        case 'sec':
                            now.setSeconds(now.getSeconds() + num);
                            break;
                    }
                } else {
                    return false;
                }
                break;
        }
        return true;
    }
    var __is = {
        day: {
            'sun': 0,
            'mon': 1,
            'tue': 2,
            'wed': 3,
            'thu': 4,
            'fri': 5,
            'sat': 6
        },
        mon: {
            'jan': 0,
            'feb': 1,
            'mar': 2,
            'apr': 3,
            'may': 4,
            'jun': 5,
            'jul': 6,
            'aug': 7,
            'sep': 8,
            'oct': 9,
            'nov': 10,
            'dec': 11
        }
    }
    match = strTmp.match(/^(\d{2,4}-\d{2}-\d{2})(\s\d{1,2}:\d{1,2}(:\d{1,2})?)?$/);
    if (match != null) {
        if (!match[2]) {
            match[2] = '00:00:00';
        } else if (!match[3]) {
            match[2] += ':00';
        }
        s = match[1].split(/-/g);
        for (i in __is.mon) {
            if (__is.mon[i] == s[1] - 1) {
                s[1] = i;
            }
        }
        return strtotime(s[2] + ' ' + s[1] + ' ' + s[0] + ' ' + match[2]);
    }
    var regex = '([+-]?\\d+\\s' + '(years?|months?|weeks?|days?|hours?|min|minutes?|sec|seconds?' + '|sun\.?|sunday|mon\.?|monday|tue\.?|tuesday|wed\.?|wednesday' + '|thu\.?|thursday|fri\.?|friday|sat\.?|saturday)' + '|(last|next)\\s' + '(years?|months?|weeks?|days?|hours?|min|minutes?|sec|seconds?' + '|sun\.?|sunday|mon\.?|monday|tue\.?|tuesday|wed\.?|wednesday' + '|thu\.?|thursday|fri\.?|friday|sat\.?|saturday))' + '(\\sago)?';
    match = strTmp.match(new RegExp(regex, 'g'));
    if (match == null) {
        return false;
    }
    for (i in match) {
        if (!process(match[i].split(' '))) {
            return false;
        }
    }
    return (now);
}
Object.size = function(obj) {
    var size = 0,
        key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
if (!Object.keys) {
    Object.keys = function() {
        var hasOwnProperty = Object.prototype.hasOwnProperty,
            hasDontEnumBug = !({
                toString: null
            }).propertyIsEnumerable('toString'),
            dontEnums = ['toString', 'toLocaleString', 'valueOf', 'hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'constructor'],
            dontEnumsLength = dontEnums.length;
        return function(obj) {
            if (typeof obj !== 'object' && typeof obj !== 'function' || obj === null) throw new TypeError('Object.keys called on non-object');
            var result = [];
            for (var prop in obj) {
                if (hasOwnProperty.call(obj, prop)) result.push(prop);
            }
            if (hasDontEnumBug) {
                for (var i = 0; i < dontEnumsLength; i++) {
                    if (hasOwnProperty.call(obj, dontEnums[i])) result.push(dontEnums[i]);
                }
            }
            return result;
        }
    }
};

function trimL(sString) {
    if (typeof sString != "string") {
        return sString;
    }
    return sString.replace(/^\s+/, "");
}

function trimR(sString) {
    if (typeof sString != "string") {
        return sString;
    }
    return sString.replace(/\s+$/, "");
}

function trim(sString) {
    if (typeof sString != "string") {
        return sString;
    }
    return trimR(trimL(sString));
}

function trimNew(sString) {
    return trim(sString)
}
/* functions ORDER AND FILTER */
function ObjToArray(obj) {
    var myAr = [];
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            myAr.push(obj[key]);
        }
    }
    return myAr;
}

function ObjToArrayAssoc(obj) {
    var myAr = [];
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            myAr[key] = obj[key];
        }
    }
    return myAr;
}
/*
 * alert("Es array response[3] " + (response[3] instanceof Array) );
 alert("Es array response[3][0] " + (response[3][0] instanceof Array));
 alert("Es array myData " + (myData instanceof Array));
 alert("Es array myData[0] " + (myData[0] instanceof Array));
 * 
 */
function writeLog(sText) {
    if (getId('dvLog')) {
        getId('dvLog').innerHTML += sText + '<br>';
    } else {
        var logDiv = document.createElement('div');
        logDiv.className = 'logDiv';
        logDiv.id = 'dvLog';
        logDiv.innerHTML = sText + '<br>';
        logDiv.setAttribute('onclick', 'javascript:document.documentElement.removeChild(this)');
        document.documentElement.appendChild(logDiv);
    }
}