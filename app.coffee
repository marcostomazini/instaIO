express = require('express')
app = express()
server = app.listen(process.env.PORT || 5000)
io = require('socket.io').listen(server)
instagram = require './instagram'
tagName = 'maringa' # instalove arquitetaweb maringa
last_set = []

app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'ejs'  
	app.use express.static(__dirname + "/public")
	app.use express.bodyParser()
	app.use express.cookieParser()
	process.env.CLIENT_ID = '464ed34dfbb2461584b9b7667128b6e3'
	process.env.CLIENT_SECRET = 'de3e0b55b80b4ac49a04f72153ef3ced'	

io.set('log level', 1)

io.configure ->
	io.set("transports", ["xhr-polling"])
	io.set("polling duration", 10)

io.on 'connection', (socket) ->
	socket.emit 'bootstrap', last_set

app.get '/stats', (req, res) ->
	res.json process.memoryUsage()

db_doesnt_include = (db, id) ->
	ids = db.map (item) ->
		item.id
	return ids.indexOf(id) < 0

console.log("should be false:", db_doesnt_include([{id: 1}, {id: 2}], 1))
console.log("should be false:", db_doesnt_include([{id: 1}, {id: 2}], 2))
console.log("should be true:",  db_doesnt_include([{id: 1}, {id: 2}], 3))
console.log("should be false:", db_doesnt_include([{id: 1}, {id: 2}], 3))

insert_if_new = (photo) ->
	if db_doesnt_include(last_set, photo.id)
		console.log("+ YES new: #{photo.id}")
		last_set.push photo
		io.sockets.emit 'new', photo
	else
		#last_set.splice photo
		console.log("- NOT new: #{photo.id}")

update_tag_media = (object_id) ->
	console.log('update_tag_media')
	instagram.getTagMedia object_id, (err, data) ->
		for photo in data.data
			insert_if_new(photo)		
		#console.log('tag', data)

update_geo_media = (object_id) ->
	console.log('update_geo_media')
	instagram.getGeoMedia object_id, (err, data) ->
		console.log('update_geo_media err', err)
		for photo in data.data
			insert_if_new(photo)
		#console.log('geo', data)

app.get '/notify', (req, res) -> # confirm the subscription
	if req.query and req.query['hub.mode'] is 'subscribe'
		console.log "Confirming new Instagram real-time subscription for #{req.params.id} with #{req.query['hub.challenge']}"
		res.send req.query['hub.challenge'] 
	else
		console.log "Weird request to /notify, didn't have a hub.mode..."
		res.send 'OK'

app.post '/notify/:id', (req, res) -> # receive the webhook, we got a new photo!
	console.log 'Notification for', req.params.id # '. Had', notifications.length, 'item(s). Subscription ID:', req.body[0].subscription_id
	console.log req.body
	for notification in req.body
		update_tag_media(notification.object_id) if notification.object is "tag"	        
		update_geo_media(notification.object_id) if notification.object is "geography"	        
	res.send 'OK'


app.get '/add/:tagname', (req, res) -> # 
	console.log 'Notification for', req.params.tagname
	last_set = []
	tagName = req.params.tagname	
	res.send 'OK LISTENING... ' + req.params.tagname
	
app.get '/clear', (req, res) -> # delete array
	console.log 'clear'
	last_set = []
	res.send 'CLEAR OK'
	
#update_geo_media('1615218')
update_tag_media(tagName)

setInterval ->
	#console.log(last_set.length, "last_set length")
	#update_geo_media('3503334')
	update_tag_media(tagName)
, 5000

setTimeout ->
	io.sockets.emit 'reload', ''
, 1500
