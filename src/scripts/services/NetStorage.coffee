`angular.module('app').factory("NetStorage", function($localStorage, Net) {

   var storage = $localStorage.$default({
      nets: [ new Net({
         name: "Sample Net",
         nodes: [],
         edges: []
      }) ]
   });

   var getNets = function() {
      return storage.nets;
   }

   // returns false if net with this name alreade exists
   var addNet = function(name) {
      if (getNetByName(name)) return false;
      storage.nets.push( new Net({
         name: name,
         nodes: [],
         edges: []
      }));
   }

   var deleteNet = function(id) {
      storage.nets.splice(id, 1);
   }

   var getNetByName = function(name) {
      for(i = 0; i < storage.nets.length; i++) {
         if (storage.nets[i].name === name) {
            return storage.nets[i];
         }
      }
      return false;
   }

   var interface = {
      getNets: getNets,
      addNet: addNet,
      deleteNet: deleteNet,
      getNetByName: getNetByName
   }
   return interface;
});`
