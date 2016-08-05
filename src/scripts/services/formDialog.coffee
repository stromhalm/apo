class FormDialog extends Service
	constructor: ($mdDialog) ->

		@runDialog = (options) ->
			# Set dialog dafaults
			{
				title = "APO",
				text = "",
				formElements = [],
				outputElements = [],
				ok = "ok",
				cancel = "cancel",
				event = null
				onComplete = null
			} = options

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
					onComplete: onComplete
					ok: ok
					cancel: cancel
			})

class FormDialogController extends Controller
	constructor: ($mdDialog, $scope) ->
		@dismiss = () -> $mdDialog.hide(null)
		@formIsComplete = () -> if not $scope.formDialog then return false else return $scope.formDialog.$valid
		@complete = () ->
			if @formIsComplete()
				completed = @onComplete() if @onComplete
				$mdDialog.hide(@formElements) if completed isnt false # don't hide dialog if @onComplete returns false
