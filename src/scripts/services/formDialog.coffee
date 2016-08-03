class FormDialog extends Service
	constructor: ($mdDialog) ->

		@runDialog = (options) ->
			{title = "APO", text = "", formElements = [], ok = "ok", cancel = "cancel", event = null} = options
			$mdDialog.show({
				templateUrl: 'views/directives/dialog.html'
				parent: angular.element(document.body)
				targetEvent: event
				controller: FormDialogController
				controllerAs: "dialog"
				clickOutsideToClose: true
				fullscreen: true
				locals:
					title: title
					text: text
					formElements: formElements
					ok: ok
					cancel: cancel
			})

class FormDialogController extends Controller
	constructor: ($mdDialog, title, text, formElements, ok, cancel, $scope) ->
		@title = title
		@text = text
		@formElements = formElements
		@ok = ok
		@cancel = cancel

		@dismiss = () -> $mdDialog.hide(null)

		@formIsComplete = () -> if not $scope.formDialog then return false else return $scope.formDialog.$valid

		@complete = () -> $mdDialog.hide(@formElements) if @formIsComplete()
