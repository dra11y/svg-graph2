require 'date'
require_relative './Plot'

module SVG
  module Graph
    # === For creating SVG plots of scalar temporal data
    #
    # = Synopsis
    #
    #   require 'SVG/Graph/TimeSeries'
    #
    #   # Data sets are x,y pairs
    #   projection = ["6/17/72", 11,    "1/11/72", 7,    "4/13/04", 11,
    #                "9/11/01", 9,    "9/1/85", 2,    "9/1/88", 1,    "1/15/95", 13]
    #   actual = ["8/1/73", 18,    "3/1/77", 15,    "10/1/98", 4,
    #             "5/1/02", 14,    "3/1/95", 6,    "8/1/91", 12,    "12/1/87", 6,
    #             "5/1/84", 17,    "10/1/80", 12]
    #
    #   title = "Ice Cream Cone Consumption"
    #
    #   graph = SVG::Graph::TimeSeries.new( {
    #     :width => 640,
    #     :height => 480,
    #     :graph_title => title,
    #     :show_graph_title => true,
    #     :no_css => true,
    #     :key => true,
    #     :scale_x_integers => true,
    #     :scale_y_integers => true,
    #     :min_x_value => 0,  # Integer, Time, or parseable by DateTime#parse
    #     :min_y_value => 0,  # Integer, Time, or parseable by DateTime#parse
    #     :show_data_values => true,
    #     :show_x_guidelines => true,
    #     :show_x_title => true,
    #     :x_title => "Time",
    #     :show_y_title => true,
    #     :y_title => "Ice Cream Cones",
    #     :y_title_text_direction => :bt,
    #     :stagger_x_labels => true,
    #     :x_label_format => "%m/%d/%y",
    #   })
    #
    #   graph.add_data({
    #     :data => projection,
    #     :title => 'Projected',
    #     :template => '%d/%m/%y'
    #   })
    #
    #   graph.add_data({
    #     :data => actual,
    #     :title => 'Actual',
    #     :template => '%d/%m/%y'
    #   })
    #
    #   print graph.burn()
    #
    # = Description
    #
    # Produces a graph of temporal scalar data.
    #
    # = Examples
    #
    # http://www.germane-software/repositories/public/SVG/test/timeseries.rb
    #
    # = Notes
    #
    # The default stylesheet handles upto 10 data sets, if you
    # use more you must create your own stylesheet and add the
    # additional settings for the extra data sets. You will know
    # if you go over 10 data sets as they will have no style and
    # be in black.
    #
    # Unlike the other types of charts, data sets must contain x,y pairs:
    #
    #   [ "12:30", 2 ]          # A data set with 1 point: ("12:30",2)
    #   [ "01:00",2, "14:20",6] # A data set with 2 points: ("01:00",2) and
    #                           #                           ("14:20",6)
    #
    # Note that multiple data sets within the same chart can differ in length,
    # and that the data in the datasets needn't be in order; they will be ordered
    # by the plot along the X-axis.
    #
    # The dates must be parseable by DateTime#parse or DateTime#strptime, but otherwise can be
    # any order of magnitude (seconds within the hour, or years)
    #
    # = See also
    #
    # * SVG::Graph::Graph
    # * SVG::Graph::BarHorizontal
    # * SVG::Graph::Bar
    # * SVG::Graph::Line
    # * SVG::Graph::Pie
    # * SVG::Graph::Plot
    #
    # == Author
    #
    # Sean E. Russell <serATgermaneHYPHENsoftwareDOTcom>
    #
    # Copyright 2004 Sean E. Russell
    # This software is available under the Ruby license[LICENSE.txt]
    #
    class TimeSeries < Plot
      # In addition to the defaults set by Graph::initialize and
      # Plot::set_defaults, sets:
      # [x_label_format] '%Y-%m-%d %H:%M:%S'
      # [popup_format]  '%Y-%m-%d %H:%M:%S'
      def set_defaults
        super
        init_with(
          #:max_time_span     => '',
          :x_label_format     => '%Y-%m-%d %H:%M:%S',
          :popup_format       => '%Y-%m-%d %H:%M:%S',
        )
      end

      # The format string used to format the X axis labels.
      # See Time::strformat, default: '%Y-%m-%d %H:%M:%S'
      attr_accessor :x_label_format
      # Use this to set the spacing between dates on the axis.  The value
      # must be of the form
      # "\d+ ?(days|weeks|months|years|hours|minutes|seconds)?"
      #
      # EG:
      #
      #   graph.timescale_divisions = "2 weeks"
      #
      # will cause the chart to try to divide the X axis up into segments of
      # two week periods.
      attr_accessor :timescale_divisions
      # The formatting used for the popups.  See x_label_format
      attr_accessor :popup_format

      # Add data to the plot.
      #
      #   d1 = [ "12:30", 2 ]          # A data set with 1 point: ("12:30",2)
      #   d2 = [ "01:00",2, "14:20",6] # A data set with 2 points: ("01:00",2) and
      #                                #                           ("14:20",6)
      #   graph.add_data(
      #     :data => d1,
      #     :title => 'One',
      #     :template => '%H:%M'  #template is optional
      #   )
      #   graph.add_data(
      #     :data => d2,
      #     :title => 'Two',
      #     :template => '%H:%M'
      #   )
      #
      # Note that the data must be in time,value pairs. The time may be any date in
      # a format that is parseable by ParseDate, a Time object, or a number of seconds
      # after the unix epoch.
      def add_data data
        data[:data].each_index do |i|
          data[:data][i] = parse_time(data[:data][i], data[:template]).to_i if i % 2 == 0  # only even indices are time, odd indices are values
        end
        super(data)
      end


      protected

      # value must be Integer, Time, or parseable by DateTime#parse
      def min_x_value=(value)
        t = parse_time(value, nil)
        @min_x_value = t.to_i
      end

      # value must be Integer, Time, or parseable by DateTime#parse
      def max_x_value=(value)
        t = parse_time(value, nil)
        @max_x_value = t.to_i
      end

      def format x, y, description
        info = [
          Time.at(x).strftime(popup_format),
          round_popups ? (y * 100).to_i / 100 : y,
          description
        ].compact.join(', ')
      end

      def get_x_labels
        get_x_values.collect { |v| Time.at(v).strftime( x_label_format ) }
      end

      private

      # Accepts date time as a string, number of seconds since the epoch, or Time
      # object and returns a Time object. Raises an error if not a valid date time
      # representation.
      def parse_time(time, template)
        case time
        when Time
          return time
        when String
          if template.kind_of? String
            return DateTime.strptime(time, template).to_time
          else
            return DateTime.parse(time).to_time
          end
        when Integer
          return Time.at(time)
        else
          raise "Can not parse time #{time.inspect}"
        end
      end

      def get_x_values
        rv = []
        min, max, @x_scale_division = x_label_range
        if timescale_divisions
          timescale_divisions =~ /(\d+) ?(day|week|month|year|hour|minute|second)?/
          division_units = $2 ? $2 : "day"
          amount = $1.to_i
          if amount
            step =  nil
            case division_units
            when "month"
              cur = min
              @x_scale_division = 365.25/12 * 24 * 60 * 60 * amount
              while cur < max
                rv << cur
                arr = Time.at( cur ).to_a
                arr[4] += amount
                if arr[4] > 12
                  arr[5] += (arr[4] / 12).to_i
                  arr[4] = (arr[4] % 12)
                end
                cur = Time.local(*arr).to_i
              end
            when "year"
              cur = min
              @x_scale_division = 365.25 * 24 * 60 * 60 * amount
              while cur < max
                rv << cur
                arr = Time.at( cur ).to_a
                arr[5] += amount
                cur = Time.local(*arr).to_i
              end
            when "week"
              step = 7 * 24 * 60 * 60 * amount
            when "day"
              step = 24 * 60 * 60 * amount
            when "hour"
              step = 60 * 60 * amount
            when "minute"
              step = 60 * amount
            when "second"
              step = amount
            end
            # only do this if division_units is not year or month. Those are done already above in the cases.
            min.step( max + (step/10), step ) {|v| rv << v} if step
            @x_scale_division = step if step
            return rv
          end
        end
        min.step( max + (@x_scale_division/10), @x_scale_division ) {|v| rv << v}
        return rv
      end # get_x_values

    end # class TimeSeries
  end # module Graph
end # module SVG
