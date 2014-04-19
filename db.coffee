express = require('express')
app = express()
server = app.listen(process.env.PORT || 5000)
io = require('socket.io').listen(server)
instagram = require './instagram'

last_set = []
nenhumNovo = 0

process.env.CLIENT_ID = '464ed34dfbb2461584b9b7667128b6e3'
process.env.CLIENT_SECRET = 'de3e0b55b80b4ac49a04f72153ef3ced'	
tagName = 'maringa' # instalove arquitetaweb maringa

app.configure ->
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'ejs'  
	app.use express.static(__dirname + "/public")
	app.use express.bodyParser()
	app.use express.cookieParser()

io.set('log level', 1)

io.configure ->
	io.set("transports", ["xhr-polling"])
	io.set("polling duration", 10)

io.on 'connection', (socket) ->
	socket.emit 'bootstrap', last_set
	socket.on 'array new', (photo) ->
		#last_set.splice(photo, 1);  
		index = last_set.indexOf(photo)
		console.log("Remover ou gravar no banco ", index)
		console.log(last_set.length)
		last_set.splice(index, 1); 
		console.log(last_set.length)		
		console.log("Remover ou gravar no banco ", photo.id)
		io.sockets.emit 'bootstrap', last_set

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
		nenhumNovo = 1
	else
		console.log("- NOT new: #{photo.id}")

update_tag_media = (object_id) ->
	nenhumNovo = 0
	console.log('update_tag_media ' + object_id)
	instagram.getTagMedia object_id, (err, data) ->
		for photo in data.data
			insert_if_new(photo)		
		if nenhumNovo == 0
			io.sockets.emit 'one call', photo

app.get '/barracauniversitaria', (req, res) -> # 
	tagName = 'barracauniversitariaoriginal2014'	
	res.sendfile './public/maringafm.html'

app.get '/admin', (req, res) -> # 
	res.sendfile './public/admin.html'
	
app.get '/add/:tagname', (req, res) -> # 
	console.log 'Notification for', req.params.tagname
	last_set = []
	tagName = req.params.tagname	
	res.send 'OK LISTENING... ' + req.params.tagname
	
app.get '/clear', (req, res) -> # delete array
	console.log 'clear'
	last_set = []
	res.send 'CLEAR OK'
	
update_tag_media(tagName)

setInterval ->
	update_tag_media(tagName)
, 15000
