module Almanack
  module EventSource
    class MeetupGroup
      def initialize(options = {})
        @request_options = options
        @group_properties = {}
      end

      def events_between(date_range)
        events.select do |event|
          event.start_time >= date_range.min && event.start_time <= date_range.max
        end
      end

      def serialized_between(date_range)
        # TODO `events` must be called before @group_properties is accessed
        serialized_events = events_between(date_range).map(&:serialized)
        @group_properties.merge(events: serialized_events)
      end

      private

      def events
        results = MeetupAPIRequest.new(@request_options.clone).results
        record_group_details_from results
        results.map { |result| event_from(result) }
      end

      def record_group_details_from(results)
        first_result = results.first
        return if !first_result

        group = first_result['group']
        return if !group

        @group_properties = {
          name: group['name'],
          url: "http://www.meetup.com/" + group['urlname']
        }
      end

      def event_from(result)
        # 3 hours, as recommended by Meetup.com if duration isn't present
        default_duration_in_ms = 3 * 60 * 60 * 1000

        event_name = [result['group']['name'], result['name']].compact.join(': ')
        start_time = Time.at(result['time'] / 1000)
        duration_in_secs = (result['duration'] || default_duration_in_ms) / 1000
        end_time = start_time + duration_in_secs

        Event.new(
          title: event_name,
          start_time: start_time,
          end_time: end_time,
          description: result['description'],
          location: location_from_venue(result['venue']),
          url: result['event_url']
        )
      end

      def location_from_venue(venue)
        return nil if venue.nil?
        
        %w{ name address_1 address_2 address_3 city state country }.map do |attr|
          venue[attr]
        end.compact.join(', ')
      end
    end

    class MeetupAPIError < StandardError
    end

    class MeetupAPIException < Exception
    end

    class MeetupAPIRequest
      REQUIRED_OPTIONS = [:group_domain, :group_urlname, :group_id]

      attr_reader :options, :connection

      def initialize(options = {})
        @connection = options.delete(:connection)
        @options = options
      end

      def results
        response['results']
      end

      def uri
        if !options.has_key?(:key)
          raise MeetupAPIException, 'Cannot form valid URI, missing :key option'
        end

        if (options.keys & REQUIRED_OPTIONS).empty?
          raise MeetupAPIException, "Cannot form valid URI, missing one of: #{REQUIRED_OPTIONS}"
        end

        endpoint = "https://api.meetup.com/2/events"

        Addressable::URI.parse(endpoint).tap do |uri|
          uri.query_values = options
        end
      end

      def response
        response = connection.get(uri)
        data = JSON.parse(response.body)

        if data['problem']
          raise MeetupAPIError, data['problem']
        end

        data
      end
    end
  end
end
