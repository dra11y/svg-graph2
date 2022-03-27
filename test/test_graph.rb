require 'test/unit'
require_relative './../lib/svggraph'

class TestGraph < Test::Unit::TestCase
  class DummyGraph < SVG::Graph::Graph
    def get_css; end
    def draw_data; end

    def get_x_labels
      []
    end
    def get_y_labels
      []
    end
  end

  def test_to_iruby
    graph = DummyGraph.new({})
    graph.add_data({ data: [1,2,3] })
    assert_equal graph.to_iruby, ["text/html", graph.burn_svg_only]
  end
end
