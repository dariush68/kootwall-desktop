.pragma library

//var BASE = 'http://127.0.0.1:8000'
//var BASE = 'http://medialink.ir'
//var BASE = 'http://microwatt.ir'
var BASE = 'http://kootwall.com'


function get_all(endpoint, cb) {
    request(null, 'GET', endpoint/*null*/, null, cb)
}

function get_all_users(token, endpoint, cb) {
    request(token, 'GET', endpoint/*null*/, null, cb)
}

function logIn(endpoint, entry, cb) {
    request(null, 'POST', endpoint, entry, cb)
}

function refresh(token, endpoint, entry, cb) {
    request(token, 'POST', endpoint, entry, cb)
}

function verify( endpoint, entry, cb) {
    request(null, 'POST', endpoint, entry, cb)
}

function create_item(token, endpoint, entry, cb) {
    request(token, 'POST', endpoint, entry, cb)
}

function get_item(name, cb) {
    request(null, 'GET', name, null, cb)
}

function update_item(token, name, entry, cb) {
    request(token, 'PUT', name, entry, cb)
}

function delete_item(token, name, cb) {
    request(token, 'DELETE', name, null, cb)
}

/*
readyState = Holds the status of the XMLHttpRequest.
0: request not initialized
1: server connection established
2: request received
3: processing request
4: request finished and response is ready
*/
function request(token, verb, endpoint, obj, cb) {
    log('request: ' + verb + ' ' + BASE + (endpoint?'/' + endpoint:''))
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        log('xhr: on ready state change: ' + xhr.readyState + " == " + xhr.HEADERS_RECEIVED)

        var headerType = ""

        //-- check to recived header --//
        if(xhr.readyState == xhr.HEADERS_RECEIVED) {

            log(xhr.status + "-" + xhr.statusText + ", " + xhr.readyState + "," + xhr.getResponseHeader("Content-Type"))
            headerType = xhr.getResponseHeader("Content-Type") // application/json
        }


        //-- check to recived content --//
        if(xhr.readyState === XMLHttpRequest.DONE) {
            if(cb) {

                //-- check server connection --//
                if(xhr.status == 0){

                    var obj = JSON.parse('{ "error":"server not conected"}');
                    cb(obj, xhr)
                    return
                }

                //-- check sdelete operation --//
                if(xhr.statusText == "No Content"){

                    //-- operation is successfull --//
                    if(xhr.status == 204){

                        var obj = JSON.parse('{ "del":"successfull delete operation"}');
                        cb(obj, xhr)
                        return
                    }
                    //-- operation is not successfull --//
                    else{

                        var obj = JSON.parse('{ "del":"delete operation was not successfull"}');
                        cb(obj, xhr)
                        return

                    }

                }


                log(xhr.status + "-" + xhr.statusText + ", " + xhr.responseText.toString() + ",")

                if (typeof xhr.responseText.toString() === "undefined") {
                    cb("{'title':'not JSON data'}", xhr);
                }
                else{                                                         

                    console.log("data recived = " + xhr.responseText.toString())
                    var res = JSON.parse(xhr.responseText.toString())
                    cb(res, xhr);
                }

            }
        }
    }

    xhr.open(verb, BASE + (endpoint?'/' + endpoint:''));
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('Accept', 'application/json');
    if(token) xhr.setRequestHeader('Authorization', 'Bearer ' + token);
    var data = obj?JSON.stringify(obj):''
    xhr.send(data)
}

var isLogEnabled = false //true
var localLogPermission = false //true
var objectName = "apiServer"

//-- log system --//
function log(str){

    //-- check global permission --//
    if(!isLogEnabled) return

    //-- check local permission --//
    if(!localLogPermission) return

    //-- print logs --//
    console.log(objectName + "; " + str)
}
