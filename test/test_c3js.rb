require_relative './../lib/svggraph'
require 'minitest/autorun'
require 'minitest/reporters'

reporter_options = { :color => true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]


class TestC3js < Minitest::Test

  def setup
    @bindto_id = "this_is_my_awesom_graph"
    @dataset1 = ['data1', 30, 200, 100, 400, 150, 250]
    @dataset2 = ['data2', 300, 20, 10, 40, 15, 25]

    #hash style
    @hash_chart_spec = {
      bindto: "##{@bindto_id}",
      data: {
        columns: [
          @dataset1,
          @dataset2
        ],
        axes: {
          data1: 'y',
          data2: 'y2',
        }
      },
      axis: {
        x: {
          label: 'X Label'
        },
        y: {
          label: {
            text: 'Y Axis Label',
            position: 'outer-middle'
          }
        },
        y2: {
          show: true,
          label: {
            text: 'Y2 Axis Label',
            position: 'outer-middle'
          }
        }
      },
      tooltip: {
    #   enabled: false
      },
      zoom: {
        enabled: true
      },
      subchart: {
        show: true
      }
    }
    #puts JSON.pretty_generate(@hash_chart_spec)
    @heredoc_chart_spec =<<-HEREDOC
    var my_chart1 = c3.generate({
      // bindto is mandatory
      "bindto": "##{@bindto_id}",
      "data": {
        "columns": [
            #{@dataset1},
            #{@dataset2}
        ],
        "axes": {
          "data1": "y",
          "data2": "y2"
        }
      },
      "axis": {
        "x": {
          "label": "X Label"
        },
        "y": {
          "label": {
            "text": "Y Axis Label",
            "position": "outer-middle"
          }
        },
        "y2": {
          "show": true,
          "label": {
            "text": "Y2 Axis Label",
            "position": "outer-middle"
          }
        }
      },
      "tooltip": {
      },
      "zoom": {
        "enabled": true
      },
      "subchart": {
        "show": true
      }
    });

    setTimeout(function () {
      my_chart1.load({
          columns: [
              ['data1', 230, 190, 300, 500, 300, 400]
          ]
      });
    }, 1000);

    setTimeout(function () {
      my_chart1.load({
            columns: [
                ['data3', 130, 150, 200, 300, 200, 100]
            ]
        });
    }, 1500);

    setTimeout(function () {
      my_chart1.unload({
            ids: 'data1'
        });
    }, 2000);
    HEREDOC


  end # def setup

  # @param method_name [String]
  # @param output [String]
  # @return [void]
  def write_file(method_name, output)
    File.open(File.expand_path("c3js_#{method_name}.html", __dir__), "w+") do |f|
      f.write(output)
    end # File.open
  end

  def test_burn
    g = SVG::Graph::C3js.new()
    g.add_chart_spec(@hash_chart_spec, "mychart1")
    write_file("hash_#{__method__}", g.burn)

    g = SVG::Graph::C3js.new()
    g.add_chart_spec(@heredoc_chart_spec)
    write_file("heredoc_#{__method__}", g.burn)
  end # def test_burn


  def test_burn_svg_only
    g = SVG::Graph::C3js.new()
    g.add_chart_spec(@hash_chart_spec, "mychart1")
    write_file(__method__, g.burn_svg_only)
  end # def test_burn_svg_only

  def test_invalid_file
    opts = {
      "inline_dependencies" => true,
      "d3_js"  => "/path/to/local/copy/of/d3.min.js",
      "c3_css" => "/path/to/local/copy/of/c3.min.css",
      "c3_js"  => "/path/to/local/copy/of/c3.min.js"
    }
    assert_raises(RuntimeError) { |e|
      g = SVG::Graph::C3js.new(opts)
    }
  end

  def test_inlined_dependencies
    opts = {
      "inline_dependencies" => true,
      "d3_js"  => File.expand_path("d3.min.js",__dir__),
      "c3_css" => File.expand_path("c3.min.css",__dir__),
      "c3_js"  => File.expand_path("c3.min.js",__dir__)
    }
    g = SVG::Graph::C3js.new(opts)
    g.add_chart_spec(@heredoc_chart_spec)
    write_file(__method__, g.burn)
  end

end # class TestC3js
