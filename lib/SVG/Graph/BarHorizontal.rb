require 'rexml/document'
require_relative './BarBase'

module SVG
  module Graph
    # === Create presentation quality SVG horitonzal bar graphs easily
    #
    # = Synopsis
    #
    #   require 'SVG/Graph/BarHorizontal'
    #
    #   fields = %w(Jan Feb Mar)
    #   data_sales_02 = [12, 45, 21]
    #
    #   graph = SVG::Graph::BarHorizontal.new({
    #     :height => 500,
    #     :width => 300,
    #     :fields => fields,
    #   })
    #
    #   graph.add_data({
    #     :data => data_sales_02,
    #     :title => 'Sales 2002',
    #   })
    #
    #   print "Content-type: image/svg+xml\r\n\r\n"
    #   print graph.burn
    #
    # = Description
    #
    # This object aims to allow you to easily create high quality
    # SVG horitonzal bar graphs. You can either use the default style sheet
    # or supply your own. Either way there are many options which can
    # be configured to give you control over how the graph is
    # generated - with or without a key, data elements at each point,
    # title, subtitle etc.
    #
    # = Examples
    #
    # * http://germane-software.com/repositories/public/SVG/test/test.rb
    #
    # = See also
    #
    # * SVG::Graph::Graph
    # * SVG::Graph::Bar
    # * SVG::Graph::Line
    # * SVG::Graph::Pie
    # * SVG::Graph::Plot
    # * SVG::Graph::TimeSeries
    #
    # == Author
    #
    # Sean E. Russell <serATgermaneHYPHENsoftwareDOTcom>
    #
    # Copyright 2004 Sean E. Russell
    # This software is available under the Ruby license[LICENSE.txt]
    #
    class BarHorizontal < BarBase
      # In addition to the defaults set in BarBase::set_defaults, sets
      # [rotate_y_labels] true
      # [show_x_guidelines] true
      # [show_y_guidelines] false
      def set_defaults
        super
        init_with(
          :rotate_y_labels    => true,
          :show_x_guidelines  => true,
          :show_y_guidelines  => false
        )
        # self.right_align = self.right_font = 1
      end

      protected

      def get_x_labels
        maxvalue = max_value
        minvalue = min_value
        range = maxvalue - minvalue
        top_pad = range == 0 ? 10 : range / 20.0
        scale_range = (maxvalue + top_pad) - minvalue

        @x_scale_division = scale_divisions || (scale_range / 10.0)

        if scale_integers
          @x_scale_division = @x_scale_division < 1 ? 1 : @x_scale_division.round
        end

        rv = []
        #if maxvalue%@x_scale_division != 0
        #  maxvalue = maxvalue + @x_scale_division
        #end
        minvalue.step( maxvalue, @x_scale_division ) {|v| rv << v}
        return rv
      end

      def get_y_labels
        @config[:fields]
      end

      def y_label_offset( height )
        height / -2.0
      end

      def draw_data
        minvalue = min_value
        fieldheight = field_height

        bargap = bar_gap ? (fieldheight < 10 ? fieldheight / 2 : 10) : 0

        bar_height = fieldheight - bargap
        bar_height /= @data.length if stack == :side
        y_mod = (bar_height / 2) + (font_size / 2)
        field_count = 1

        @config[:fields].each_index { |i|
          dataset_count = 0
          for dataset in @data
            total = 0
            dataset[:data].each {|x|
              total += x
            }
            value = dataset[:data][i]

            top = @graph_height - (fieldheight * field_count) + (bargap/2)
            top += (bar_height * dataset_count) if stack == :side
            # cases (assume 0 = +ve):
            #   value  min  length          left
            #    +ve   +ve  value.abs - min minvalue.abs
            #    +ve   -ve  value.abs - 0   minvalue.abs
            #    -ve   -ve  value.abs - 0   minvalue.abs + value
            length = (value.abs - (minvalue > 0 ? minvalue : 0))/@x_scale_division.to_f * field_width
            left = (minvalue.abs + (value < 0 ? value : 0))/@x_scale_division.to_f * field_width

            @graph.add_element( "rect", {
              "x" => left.to_s,
              "y" => top.to_s,
              "width" => length.to_s,
              "height" => bar_height.to_s,
              "class" => "fill#{dataset_count+1}"
            })
            value_string = ""
            value_string += (@number_format % dataset[:data][i]) if show_actual_values
            percent = 100.0 * dataset[:data][i] / total
            value_string += " (" + percent.round.to_s + "%)" if show_percent
            make_datapoint_text(left+length+5, top+y_mod, value_string, "text-anchor: start; ")
            # number format shall not apply to popup (use .to_s conversion)
            add_popup(left+length, top+y_mod , value_string)
            dataset_count += 1
          end
          field_count += 1
        }
      end
    end
  end
end
