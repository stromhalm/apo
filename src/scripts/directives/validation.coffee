###
	The validation directive can only be used in combination with other input elements.
	Binded to a validator function it can (un)validate form inputs.
###

class Validation extends Directive
	constructor: ->
		return {
			require: 'ngModel'
			restrict: 'A'
			scope:
				validation: '='
				errorMessage: '=?'
				touched: '=?'
			link: (scope, elem, attr, ngModel) ->
				validator = scope.validation
				return if not validator

				# For DOM -> model validation
				ngModel.$parsers.unshift((value) ->
					response = validator(value)
					if response is true
						valid = true
						scope.errorMessage = ""
					else
						valid = false
						scope.errorMessage = response
					ngModel.$setValidity('customValidator', valid)
					return value
				)

				# For model -> DOM validation
				ngModel.$formatters.unshift((value) ->
					response = validator(value)
					if response is true
						valid = true
						scope.errorMessage = ""
					else
						valid = false
						scope.errorMessage = response
					ngModel.$setValidity('customValidator', valid)
					return value
				)

				ngModel.$setTouched(true) if scope.touched
		}
