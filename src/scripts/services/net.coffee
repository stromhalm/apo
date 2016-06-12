###
   The Net is an abstract model for both petri nets and transition systems.
   It consists of nodes and edges.
###

`angular.module('app').factory('Net', function() {

   // instantiate our initial object
   var Net = function(netObject) {
      this.name = netObject.name;
      this.nodes = netObject.nodes;
      this.edges = netObject.edges;
      this.historyObjects = [];
      this.futureObjects = [];
   }

   Net.prototype.addNode = addNode;
   Net.prototype.commit = commit;
   Net.prototype.undo = undo;
   Net.prototype.redo = redo;

   function addNode(point) {
      this.commit();
      var node = {id: this.nodes.length, reflexive: false};
      node.x = point[0];
      node.y = point[1];
      this.nodes.push(node);
   }

   function commit() {
      this.historyObjects.push(JSON.parse(JSON.stringify({
         name: this.name,
         nodes: this.nodes,
         edges: this.edges
      })));
   }

   function undo() {
      this.futureObjects.push(JSON.parse(JSON.stringify({
         name: this.name,
         nodes: this.nodes,
         edges: this.edges
      })));

      var lastStep = this.historyObjects.pop();
      this.name = lastStep.name;
      this.edges = lastStep.edges;
      this.nodes = lastStep.nodes;

      return this;
   }

   function redo() {
   }

   return Net;
});`
