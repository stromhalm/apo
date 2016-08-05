class FormDialog extends Service
	constructor: ($mdDialog) ->

		@runDialog = (options) ->
			{title = "APO", text = "", formElements = [], outputElements = [], ok = "ok", cancel = "cancel", event = null} = options
			$mdDialog.show({
				targetEvent: event
				templateUrl: 'views/directives/dialog.html'
				controller: FormDialogController
				controllerAs: "dialog"
				clickOutsideToClose: true
				fullscreen: true
				bindToController: true
				locals:
					title: title
					text: text
					formElements: formElements
					outputElements: outputElements
					ok: ok
					cancel: cancel
			})

class FormDialogController extends Controller
	constructor: ($mdDialog, $scope) ->
		@dismiss = () -> $mdDialog.hide(null)
		@formIsComplete = () -> if not $scope.formDialog then return false else return $scope.formDialog.$valid
		@complete = () -> $mdDialog.hide(@formElements) if @formIsComplete()
