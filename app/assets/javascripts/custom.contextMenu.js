//Register right-clicked menu
$(function(){
    var isAdmin =  $("#my_tree :first-child").attr('id');
    if (isAdmin == "isAdmin") {
      $.contextMenu({
          selector: '.root_node', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var url;
              switch (key) 
              {
                case "new child":
                  $('#addNewNode').modal();
                  $(".modal-body #parent").val(node_id);
                  break;
                case "new resource":
                  $('#addNewResource').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "import json":
                  $('#importJSON').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" },
              "import json": {name: "Import JSON"}
          }
      });

      $.contextMenu({
          selector: '.tree_nodes', 
          callback: function(key, opt) {
              var node_id = opt.$trigger.attr("id").split("_")[1];
              var node_name = opt.$trigger.text();
              switch (key) 
              {
                case "new child":
                  $('#addNewNode').modal();
                  $(".modal-body #parent").val(node_id);
                  break;
                case "new resource":
                  $('#addNewResource').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
                case "delete":
                  $('#deleteNode').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body .node_name").text(node_name);
                  break;
                case "deleteAll":
                  $('#deleteAll').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body .node_name").text(node_name);
                  break;
                case "edit":
                  var description = opt.$trigger.attr("data-original-title");
                  $('#editNode').modal();
                  $(".modal-body #node_id").val(node_id);
                  $(".modal-body #name").val(node_name);
                  $(".modal-body #description").val(description);
                  break;
                case "import json":
                  $('#importJSON').modal();
                  $(".modal-body #node_id").val(node_id);
                  break;
              }
          },
          items: {
              "new child": {name: "Add a child" },
              "new resource": {name: "Add a resource" },
              "edit": {name: "Edit node"},
              "import json": {name: "Import JSON"},
              "delete": {name: "Remove node"},
              "deleteAll" : {name: "Remove all"}
          }
      });

      $.contextMenu({
          selector: '.resources', 
          callback: function(key, opt) {
              var resource_id = opt.$trigger.attr("id").split("_")[1];
              var resource_name = opt.$trigger.text();
              switch (key) 
              {
                case "delete":
                  $('#deleteResource').modal();
                  $(".modal-body #resource_id").val(resource_id);
                  $(".modal-body .resource_name").text(resource_name);
                  break;
                case "edit":
                  var url = opt.$trigger.attr("href");
                  $('#editResource').modal();
                  $(".modal-body #resource_id").val(resource_id);
                  $(".modal-body #name").val(resource_name);
                  $(".modal-body #url").val(url);
                  break;
              }
          },
          items: {
              "edit": {name: "Edit resource" },
              "delete": {name: "Remove resource" }
          }
      });
    }
});

