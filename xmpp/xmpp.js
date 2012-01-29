var mongo = require('mongoskin');
/** Config here **/
var server = "192.168.1.5";
var port = 5275;
var serverJID = "sora.whs.whs.in.th";
var password = "lolrofl"; // Component password
var DB = mongo.db("sora:sora@localhost:27017/sora");
/** Don't touch **/

var xmpp = require('./xmppjs/lib/xmpp');

var conn = new xmpp.Connection(server, port);

conn.log = function (_, m) { console.log(m); };

conn.connect(serverJID, password, function (status, condition) {
	function errwrap(f){
		var args = Array.prototype.slice.call(arguments);
		try{f.apply(null, args.slice(1))}catch(e){console.log(e.toString())}
	};
	if(status == xmpp.Status.CONNECTED){
		conn.addHandler(errwrap.bind(null,onMessage), null, 'message', null, null,  null);
		conn.addHandler(errwrap.bind(null,presenceHandler), null, 'presence', null, null,  null);
		conn.addHandler(errwrap.bind(null,iqHandler), null, 'iq', null, null,  null);
	}else
		conn.log(xmpp.LogLevel.DEBUG, "New connection status: " + status + (condition?(" ("+condition+")"):""));
});

function presenceHandler(msg){
	to = msg.getAttribute("to");
	if(to == "sora@"+serverJID){
		statusText = "Send 'help' to me for help";
		pres = xmpp.presence({
			to:msg.getAttribute("from"),
			from:to,
		});
		pres.s("status").t(statusText);
		conn.send(pres);
	}else{
		streams = DB.collection("streams")
		streams.findById(to.match(/^([a-f0-9]{12,24})@/)[1], (function(msg, err, out){
			if(err) return;
			statusText = out.name + " | Send message to me to publish";
			pres = xmpp.presence({
				to:msg.getAttribute("from"),
				from:msg.getAttribute("to"),
			});
			pres.s("status").t(statusText);
			conn.send(pres);
		}).bind(null, msg));
	}
}

function iqHandler(msg){
	pres = xmpp.iq({
		to: msg.getAttribute("from"),
		from:msg.getAttribute("to"),
		type: "result",
		id: msg.getAttribute("id")
	});
	// get the type
	var xmlns = msg.getChild("query").getAttribute("xmlns");
	if(xmlns == "http://jabber.org/protocol/disco#items"){
		var roster = pres.c("query", {"xmlns": xmlns});
		roster.s("item", {"jid": "sora@"+serverJID, "name": "Sora master controller"});
		roster.s("item", {"jid": "test@"+serverJID, "name": "Let's talk iPhone"});
	}else if(xmlns == "http://jabber.org/protocol/disco#info"){
		var roster = pres.c("query", {"xmlns": xmlns});
		roster.s("identity", {"category": "client", "type": "bot"});
		roster.s("feature", {"var": "http://jabber.org/protocol/disco#info"});
		roster.s("feature", {"var": "http://jabber.org/protocol/disco#items"});
	}
	conn.send(pres);
}

function chat(from, to, message){
	return conn.send(xmpp.message({
		to: to,
		from: from,
		type: "chat"
	}).c("body").t(message));
}

function onMessage(message) {
	if(!message.getChild("body")) return;
	jid = message.getAttribute("from");
	recv = message.getAttribute("to")
	body = message.getChild("body").getText();
	if(recv.match(/^sora@/)){
		if(body == "help"){
			chat(recv, jid, "project Sora XMPP gateway\nType subscribe then ID of chat to subscribe to a room. (eg. subscribe 4e8b1c775a069edd6b000002)");
		}else if(body.match(/^subscribe [a-f0-9]{12,24}$/)){
			streams = DB.collection("streams");
			streams.findById(body.match(/ (.*)$/)[1], (function(jid,recv,body, err, res){
				if(err){
					chat(recv,jid,"Error: "+JSON.stringify(res));
				}else{
					chat(recv, jid, "You'll get authorization request from "+res._id+" ("+res.name+")");
					conn.send(xmpp.presence({
						to: jid.replace(/\/(.*)$/, ""),
						from: res._id+"@"+serverJID,
						type: "subscribe"
					}));
				}
			}).bind(null, jid,recv,body));
		}else{
			chat(recv, jid, "Sorry, I don't get it. Type 'help' for help.");
		}
	}else{
		streams = DB.collection("streams")
		streams.findById(recv.match(/^([a-f0-9]{12,24})@/)[1], (function(jid,recv,body, err, res){
			if(err){
				chat(recv,jid,"Error: "+err.toString());
			}else{
				// Add
				DB.collection("messages").insert({
					"time": new Date(),
					"stream": {'$ref': 'streams', '$id': DB.collection("messages").id(recv.match(/^([a-f0-9]{12,24})@/)[1])},
					"published": false,
					"text": body
				})
			}
		}).bind(null, jid,recv,body));
	}
}