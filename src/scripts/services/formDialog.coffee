class FormDialog extends Service
	constructor: ($mdDialog, $location, $anchorScroll) ->

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

			$mdDialog.show
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

		@close = -> $mdDialog.hide(null)

		@scrollToBottom = ->
			$location.hash('form-bottom')
			$anchorScroll()

class FormDialogController extends Controller
	constructor: ($mdDialog, $scope, $mdConstant) ->
		@chipInput = []
		@filterNotSelected = (all, selected) ->
			notSelected = []
			notSelected.push(item) for item in all when selected.indexOf(item) < 0
			return notSelected

		@getInputWidth = (input) ->
			switch input.type
				when "code" then 100
				when "textArray" then 100
				else "flex"

		@showInput = (input) ->
			return true if not input.showIf
			return input.showIf(@formElements)

		@arraySeperators = [$mdConstant.KEY_CODE.ENTER, $mdConstant.KEY_CODE.COMMA, $mdConstant.KEY_CODE.SPACE]
		@dismiss = -> $mdDialog.hide(null)
		@formIsComplete = -> if not $scope.formDialog then return false else return $scope.formDialog.$valid
		@complete = ->
			if @formIsComplete()
				completed = @onComplete(@formElements) if @onComplete
				$mdDialog.hide(@formElements) if completed isnt false # don't hide dialog if @onComplete returns false
