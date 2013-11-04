Meteor.supportedLocales = ["en", "it"]

Meteor.startup ->
	# set the locale from user language if it's not set already
	if not Meteor.getLocale() and navigator.language
		[language] = navigator.language.split "_"
		Meteor.setLocale navigator.language if navigator.language in Meteor.supportedLocales or language in Meteor.supportedLocales

_.extend Meteor.i18nMessages, 
	locales:
		locale_it: "Italiano"
		locale_en: "English"
	common:
		labels:
			name:
				en: "Name"
				it: "Nome"
			slug: "Slug"
			title:
				en: "Title"
				it: "Titolo"
			content:
				en: "Content"
				it: "Contenuto"
		buttons:
			cancel:
				en: "Cancel"
				it: "Annulla"
			save:
				en: "Save"
				it: "Salva"
			edit:
				en: "Edit"
				it: "Modifica"
			delete:
				en: "Delete"
				it: "Cancella"
			deleteCancel:
				en: "Hmm, maybe not."
				it: "Hmm, forse no."
			deleteConfirm:
				en: "Yes I'm sure!"
				it: "Si sono sicuro!"
		validation:
			required:
				en: "This value is required"
				it: "Questo campo è obbligatorio"
			notblank:
				en: "This field cannot be left blank"
				it: "Questo campo non può essere lasciato vuoto"
			unique:
				en: "This value must be unique"
				it: "Questo valore deve essere univoco"
			slug:
				en: "The slug must only contain lower case alphanumeric characters and hyphens"
				it: "Lo slug deve contenere solo caratteri alfanumerici minuscoli e trattini"
		errors:
			server:
				en: "An error occurred while performing the requested operation. Please try again later"
				it: "Si è verificato un errore durante l'esecuzione dell'operazione richiesta. Si prega di ritentare più tardi"
	client:
		nav:
			brand: "Edgepress"
			dashboard:
				en: "Dashboard"
				it: "Bacheca"
	dashboard:
		header:
			title:
				en: "Dashboard"
				it: "Bacheca"
			subtitle:
				en: "manage your blogs and posts"
				it: "gestisci i tuoi blog e i tuoi post"
		blogsPanel:
			title:
				en: "Your blogs"
				it: "I tuoi blog"
			empty:
				en: "No blogs so far, create one now!"
				it: "Nessun blog, creane uno ora!"
			createButton:
				en: "Create a new blog"
				it: "Crea un nuovo blog"
		createBlogModal:
			title:
				en: "New Blog"
				it: "Nuovo Blog"
		createBlogForm:
			namePlaceholder:
				en: "Interesting Stuff"
				it: "Roba Interessante"
			successFlash:
				en: "Blog {{name}} created successfully"
				it: "Il blog {{name}} è stato creato con successo"
		deleteBlogModal:
			title:
				en: "Delete Blog"
				it: "Cancella Blog"
			text:
				en: "Blog <strong>{{name}}</strong> will be deleted permanently. Proceed?"
				it: "Il blog <strong>{{name}}</strong> sarà cancellato in modo permanente. Procedo?"
			successFlash:
				en: "Blog {{name}} deleted successfully"
				it: "Il blog {{name}} è stato cancellato con successo"
		editBlogModal:
			title:
				en: "Edit Blog"
				it: "Modifica Blog"
		editBlogForm:
			namePlaceholder:
				en: "Enter the blog's name"
				it: "Inserisci il nome del blog"
			successFlash:
				en: "Blog {{name}} modified successfully"
				it: "Il blog {{name}} è stato modificato con successo"
		blog:
			createPost:
				en: "Create a new post"
				it: "Crea un nuovo post"
		newPost:
			title:
				en: "New Post"
				it: "Nuovo Post"
			successFlash:
				en: "Post {{title}} created successfully"
				it: "Il post {{title}} è stato creato con successo"
		editPost:
			title:
				en: "Edit Post"
				it: "Modifica Post"
			successFlash:
				en: "Post {{title}} modified successfully"
				it: "Il post {{title}} è stato modificato con successo"
		postForm:
			titlePlaceholder:
				en: "Cool Title"
				it: "Titolo Fico"
			contentPlaceholder:
				en: "Amazing content"
				it: "Contenuto incredibile"