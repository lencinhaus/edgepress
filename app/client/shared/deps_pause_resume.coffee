paused = false
shouldFlush = false

realFlush = Deps.flush
Deps.flush = ->
	if paused
		shouldFlush = true
	else
		realFlush()

_.extend Deps, 
	pause: ->
		if paused then return
		paused = true
		shouldFlush = false
		undefined

	resume: ->
		if not paused then return
		paused = false
		if shouldFlush then @flush()
		undefined