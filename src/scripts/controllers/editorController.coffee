`angular.module('app').controller('EditorController', function($scope, $stateParams, $timeout, $state, NetStorage, Net) {

   // Get selected net from storage
   var net = new Net(NetStorage.getNetByName(decodeURI($stateParams.name)));
   $scope.name = net.name;

   // Go to first net if not found
   if (!net || !net.edges) {
       $state.go("editor", {
           name: NetStorage.getNets()[0].name
       });
   }

   $scope.undo = function() {
      net = net.undo();
      restart();
      console.log(net);
   }

   $scope.redo = function() {
      net.redo();
   }

   var svg = d3.select("#main-canvas svg");
   var force = d3.layout.force();
   var colors = d3.scale.category10();
   var drag_line = svg.select('svg .dragline');
   var allPathes = svg.append('svg:g').selectAll('path');
   var allCircles = svg.append('svg:g').selectAll('g');

   // mouse event vars
   var selected_node = null,
      selected_link = null,
      mousedown_link = null,
      mousedown_node = null,
      mouseup_node = null;

   function resetMouseVars() {
      mousedown_node = null;
      mouseup_node = null;
      mousedown_link = null;
   }

   resize();
   d3.select(window).on("resize", resize);

   function resize() {
      var width = (window.innerWidth > 960) ? window.innerWidth-245 : window.innerWidth;
      var height = window.innerHeight;
      svg.attr("width", width).attr("height", height);
      force.size([width, height+80]).resume();
   }

   // init D3 force layout
   var force = force
      .nodes(net.nodes)
      .links(net.edges)
      .size([(window.innerWidth > 960) ? window.innerWidth-245 : window.innerWidth, window.innerHeight+80])
      .linkDistance(150)
      .charge(-500)
      .on('tick', tick);

   // fix lost references to nodes
   for (var i=0; i < net.edges.length; i++) {
      net.edges[i].source = net.nodes.filter(function(node) {
         return (node.id === net.edges[i].source.id);
      })[0];
      net.edges[i].target = net.nodes.filter(function(node) {
         return (node.id === net.edges[i].target.id);
      })[0];
   }

   // update force layout (called automatically each iteration)
   function tick() {
      // draw directed edges with proper padding from node centers
      allPathes.attr('d', function(d) {
        var deltaX = d.target.x - d.source.x,
            deltaY = d.target.y - d.source.y,
            dist = Math.sqrt(deltaX * deltaX + deltaY * deltaY),
            normX = deltaX / dist,
            normY = deltaY / dist,
            sourcePadding = d.left ? 17 : 12,
            targetPadding = d.right ? 17 : 12,
            sourceX = d.source.x + (sourcePadding * normX),
            sourceY = d.source.y + (sourcePadding * normY),
            targetX = d.target.x - (targetPadding * normX),
            targetY = d.target.y - (targetPadding * normY);
        return 'M' + sourceX + ',' + sourceY + 'L' + targetX + ',' + targetY;
      });

      allCircles.attr('transform', function(d) {
        return 'translate(' + d.x + ',' + d.y + ')';
      });
   }

   // update graph (called when needed)
   function restart() {
   // path (link) group
   allPathes = allPathes.data(net.edges);

   // update existing links
   allPathes.classed('selected', function(d) { return d === selected_link; })
     .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
     .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; });


   // add new links
   allPathes.enter().append('svg:path')
     .attr('class', 'link')
     .classed('selected', function(d) { return d === selected_link; })
     .style('marker-start', function(d) { return d.left ? 'url(#start-arrow)' : ''; })
     .style('marker-end', function(d) { return d.right ? 'url(#end-arrow)' : ''; })
     .on('mousedown', function(d) {
       if(d3.event.ctrlKey) return;

       // select link
       mousedown_link = d;
       if(mousedown_link === selected_link) selected_link = null;
       else selected_link = mousedown_link;
       selected_node = null;
       restart();
     });

   // remove old links
   allPathes.exit().remove();

   // circle (node) group
   // NB: the function arg is crucial here! nodes are known by id, not by index!
   allCircles = allCircles.data(net.nodes, function(d) { return d.id; });

   // update existing nodes (reflexive & selected visual states)
   allCircles.selectAll('circle')
     .style('fill', function(d) { return (d === selected_node) ? d3.rgb(colors(d.id)).brighter().toString() : colors(d.id); })
     .classed('reflexive', function(d) { return d.reflexive; });

   // add new nodes
   var g = allCircles.enter().append('svg:g');

   g.append('svg:circle')
     .attr('class', 'node')
     .attr('r', 12)
     .style('fill', function(d) { return (d === selected_node) ? d3.rgb(colors(d.id)).brighter().toString() : colors(d.id); })
     .style('stroke', function(d) { return d3.rgb(colors(d.id)).darker().toString(); })
     .classed('reflexive', function(d) { return d.reflexive; })
     .on('mouseover', function(d) {
       if(!mousedown_node || d === mousedown_node) return;
       // enlarge target node
       d3.select(this).attr('transform', 'scale(1.1)');
     })
     .on('mouseout', function(d) {
       if(!mousedown_node || d === mousedown_node) return;
       // unenlarge target node
       d3.select(this).attr('transform', '');
     })
     .on('mousedown', function(d) {
       if(d3.event.ctrlKey) return;

       // select node
       mousedown_node = d;
       if(mousedown_node === selected_node) selected_node = null;
       else selected_node = mousedown_node;
       selected_link = null;

       // reposition drag line
       drag_line
         .style('marker-end', 'url(#end-arrow)')
         .classed('hidden', false)
         .attr('d', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + mousedown_node.x + ',' + mousedown_node.y);

      restart();
      })
      .on('mouseup', function(d) {
      if(!mousedown_node) return;

      // needed by FF
      drag_line
         .classed('hidden', true)
         .style('marker-end', '');

      // check for drag-to-self
      mouseup_node = d;
      if(mouseup_node === mousedown_node) { resetMouseVars(); return; }

      // unenlarge target node
      d3.select(this).attr('transform', '');

      // add link to graph (update if exists)
      // NB: links are strictly source < target; arrows separately specified by booleans
      var source, target, direction;
      if(mousedown_node.id < mouseup_node.id) {
         source = mousedown_node;
         target = mouseup_node;
         direction = 'right';
      } else {
         source = mouseup_node;
         target = mousedown_node;
         direction = 'left';
      }

      var link;
      link = net.edges.filter(function(l) {
         return (l.source === source && l.target === target);
      })[0];

      if (link) {
         link[direction] = true;
      } else {
         link = {source: source, target: target, left: false, right: false};
         link[direction] = true;
         net.edges.push(link);
         $scope.$apply(); // Quick save net to storage
      }

      // select new link
      selected_link = link;
      selected_node = null;
      restart();
      });

      // show node IDs
      g.append('svg:text')
          .attr('x', 0)
          .attr('y', 4)
          .attr('class', 'id')
          .text(function(d) { return d.id; });

      // remove old nodes
      allCircles.exit().remove();

      // set the graph in motion
      force.start();
   }

   function mousedown() {

      // because :active only works in WebKit?
      svg.classed('active', true);

      if(d3.event.ctrlKey || mousedown_node || mousedown_link) return;

      // insert new node at point
      var point = d3.mouse(this);
      net.addNode(point);
      $scope.$apply(); // Quick save net to storage
      restart();
   }

   function mousemove() {
      if(!mousedown_node) return;

      // update drag line
      drag_line.attr('d', 'M' + mousedown_node.x + ',' + mousedown_node.y + 'L' + d3.mouse(this)[0] + ',' + d3.mouse(this)[1]);
      restart();
   }

   function mouseup() {
      if(mousedown_node) {
         // hide drag line
         drag_line
            .classed('hidden', true)
            .style('marker-end', '');
      }

      // because :active only works in WebKit?
      svg.classed('active', false);

      // clear mouse event vars
      resetMouseVars();
   }

   function spliceLinksForNode(node) {
      var toSplice = net.edges.filter(function(l) {
         return (l.source === node || l.target === node);
      });
      toSplice.map(function(l) {
         net.edges.splice(net.edges.indexOf(l), 1);
      });
   }

   // app starts here
   svg.on('mousedown', mousedown)
      .on('mousemove', mousemove)
      .on('mouseup', mouseup);
   restart();
});`
