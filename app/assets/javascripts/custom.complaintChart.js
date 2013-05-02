//Display complaint chart
function drawChart() {
  google.load('visualization', '1.0', {'packages':['corechart','controls']});
  google.setOnLoadCallback(apiLoaded);
  function apiLoaded() {
    drawChartRangeFilter();
  }
  
  function drawChartRangeFilter() {
    var dashboard = new google.visualization.Dashboard(
        document.getElementById('chartRangeFilter_dashboard_div'));

    // 1 day in milliseconds = 24 * 60 * 60 * 1000 = 86,400,000
    startDate = new Date(new Date() - 7*86400000);
    var control = new google.visualization.ControlWrapper({
      'controlType': 'ChartRangeFilter',
      'containerId': 'chartRangeFilter_control_div',
      'options': {
        // Filter by the date axis.
        'filterColumnIndex': 0,
        'ui': {
          'chartType': 'LineChart',
          'chartOptions': {
            'chartArea': {'width': '90%'},
            'hAxis': {'baselineColor': 'none'}
          },
          // Display a single series that shows the number of complaints.
          // Thus, this view has two columns: the date (axis) and the number of complaints (line series).
          'chartView': {
            'columns': [0, 1]
          },
          'minRangeSize': 86400000
        }
      },
      // Initial range: prev 7 days to today.
      'state': {'range': {'start': startDate, 'end': new Date()}}
    });

    var chart = new google.visualization.ChartWrapper({
      'chartType': 'ColumnChart',
      'containerId': 'chartRangeFilter_chart_div',
      'options': {
        // Use the same chart area width as the control for axis alignment.
        'chartArea': {'height': '80%', 'width': '90%'},
        'hAxis': {'slantedText': false},
        'vAxis': {'viewWindow': {'min': 0, 'max': 30}},
        'legend': {'position': 'none'}
      },
      // Convert the first column from 'date' to 'string'.
      'view': {
        'columns': [
          {
            'calc': function(dataTable, rowIndex) {
              return dataTable.getFormattedValue(rowIndex, 0);
            },
            'type': 'string'
          }, 1, 2, 3]
      }
    });

    var data = new google.visualization.DataTable();
    data.addColumn('date', 'Date');
    data.addColumn('number', 'Complaints');
    data.addColumn('number', 'Resolved');
    data.addColumn('number', 'Unresolved');

    //Request values
    $.ajax({
      url: "/complaint/getComplaintData",
      dataType: "json",
      }).success(function(complaintData) {
        totalComplaints = complaintData.totalComplaints;
        totalResolved = complaintData.totalResolved;
        totalUnresolved = complaintData.totalUnresolved;
        var date, numOfComplaints, numOfResolved, numOfUnresoleved;
        for (key in totalComplaints) {
          date = new Date(key);
          numOfComplaints = totalComplaints[key];
          numOfResolved = totalResolved[key];
          numOfUnresoleved = totalUnresolved[key];
          data.addRow([date, numOfComplaints, numOfResolved, numOfUnresoleved]);
        }
        dashboard.bind(control, chart);
        dashboard.draw(data);
    });
  }
}