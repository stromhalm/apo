class Controller
	constructor: ->


class Directive
	constructor: ($log) ->
		return {
			controller: [Controller]
			controllerAs: 'controller'
			templateUrl: '/views/directives/sidenav.html'
		}

angular.module('app').directive 'sidenav', ['$mdSidenav', '$state', '$mdDialog', 'NetStorage', Directive]


###
opn.directive('sidenav', function($mdSidenav, $state, $mdDialog, NetStorage) {

   function link($scope) {
      var prompt;
      var alert;

      $scope.toggleSideMenu = function() {
         $mdSidenav("left-menu").toggle();
      };

      $scope.isNet = function(net) {
         return $state.is('editor', {name: net.name});
      }

      $scope.goToNet = function(net) {
         $state.go("editor", {name: net.name});
         $mdSidenav("left-menu").close();
      }

      $scope.createNewNet = function(name, $event) {
         if (!name) {
         } else if (NetStorage.addNet(name) == false) {
            alert = $mdDialog.alert(
               {
                  title: "Can Not Create Petri Net",
                  textContent: "A petri net with the name '" + name + "' already exists!", ok: "OK",
                  targetEvent: $event // To animate the dialog to/from the click
               }
            );
            $mdDialog.show(alert).finally(function() {
               alert = undefined;
            });
         }
         $scope.newName = "";
      }

      $scope.deleteNet = function(id, $event) {
         prompt = $mdDialog.confirm(
            {
               title: "Delete Petri Net",
               textContent: "Do you really want to delete the petri net '" + $scope.nets[id].name + "'?",
               ok: "Delete",
               cancel: "Cancel",
               targetEvent: $event // To animate the dialog to/from the click
            });

         prompt = $mdDialog.show(prompt).finally(function() {
            prompt = undefined;
         }).then(function() {
            NetStorage.deleteNet(id);
         });
      }
      $scope.nets = NetStorage.getNets();
   }

   return {
      templateUrl: "layout/SideNav.html",
		link: link
   }
});
###
