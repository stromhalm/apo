###
	This service is used to show dialog forms for I/O.
###

class FormDialog extends Service
	constructor: ($mdDialog, $location, $anchorScroll) ->

		# Shows a new dialog. All otions are optional.
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
				staticError = -> false
				net = null
			} = options

			# Use $mdDialog to show Dialog
			$mdDialog.show
				targetEvent: event
				templateUrl: 'views/directives/dialog.html'
				controller: FormDialogController
				controllerAs: "dialog"
				clickOutsideToClose: true
				fullscreen: true
				bindToController: true
				locals:
					dialog:
						title: title
						text: text
						formElements: formElements
						outputElements: outputElements
						onComplete: onComplete
						staticError: staticError
						net: net
						ok: ok
						cancel: cancel

		# Hide the dialog
		@close = -> $mdDialog.hide(null)

		# Scroll to the bottom of the dialog (used to highlight new output elements)
		@scrollToBottom = ->
			$location.hash('form-bottom')
			$anchorScroll()


###
	Each dialog has its own controller.
###

class FormDialogController extends Controller
	constructor: ($mdDialog, $scope, $mdConstant, dialog) ->

		$scope.dialogConfig = dialog
		console.log $scope.dialogConfig
		console.log $scope

		# ChipInput: All selected items are hidden from options list.
		@chipInput = []
		@filterNotSelected = (all, selected) ->
			notSelected = []
			notSelected.push(item) for item in all when selected.indexOf(item) < 0
			return notSelected

		# Get the input elements width
		@getInputWidth = (input) ->
			return input.flex if input.flex
			switch input.type
				when "code" then 100
				when "textArray" then 100
				else "flex"

		# Some input elements are only shown under conditions.
		@showInput = (input) ->
			return true if not input.showIf
			return input.showIf(dialog.formElements)

		# Use these keys to seperate chips
		@arraySeperators = [$mdConstant.KEY_CODE.ENTER, $mdConstant.KEY_CODE.COMMA, $mdConstant.KEY_CODE.SPACE]

		# Hide dialog
		@dismiss = -> $mdDialog.hide(null)

		# Set a specific input field
		@setInput = (id, value) -> dialog.formElements[id].value = value

		# Checks if all inputs are valid
		@formIsComplete = -> if not $scope.formDialog then return false else return $scope.formDialog.$valid

		# Hide the dialog and run the OnComplete hook
		@complete = ->
			if @formIsComplete()
				completed = dialog.onComplete(dialog.formElements) if dialog.onComplete
				$mdDialog.hide(dialog.formElements) if completed isnt false # don't hide dialog if dialog.onComplete returns false
