
module Almanack::EventSource
  RSpec.describe MeetupGroup do
    describe "#events_between" do
      it "returns a list of events" do
        feed = MeetupGroup.new(group_urlname: 'The-Foundation-Christchurch',
                               key: 'secrettoken',
                               connection: Faraday.new)
        events = nil

        Timecop.freeze(2014, 5, 24) do
          VCR.use_cassette('meetup') do
            from = Time.now
            to = from + 30 * 24 * 60 * 60
            events = feed.events_between(from..to)
          end
        end

        start_times = events.map(&:start_time)

        expect(events.length).to eq(5)
        expect(events).to all_have_properties(:title, :start_time, :end_time, :description, :location)
      end

      it "handles a missing location" do
        feed = MeetupGroup.new(group_urlname: 'adventurewellington',
                               key: 'secrettoken',
                               connection: Faraday.new)

        Timecop.freeze(2014, 7, 23) do
          VCR.use_cassette('meetup-without-location') do
            from = Time.now
            to = from + 30 * 24 * 60 * 60
            expect { feed.events_between(from..to) }.not_to raise_error
          end
        end
      end
    end

    describe "#serialized_between" do
      it "returns a hash containing attributes" do
        feed = MeetupGroup.new(group_urlname: 'The-Foundation-Christchurch',
                               key: 'secrettoken',
                               connection: Faraday.new)
        serialized = nil

        Timecop.freeze(2014, 5, 24) do
          VCR.use_cassette('meetup') do
            from = Time.now
            to = from + 30 * 24 * 60 * 60
            serialized = feed.serialized_between(from..to)
          end
        end

        expect(serialized[:events].length).to eq 5
        expect(serialized[:name]).to eq("The Foundation")
        expect(serialized[:url]).to eq("http://www.meetup.com/The-Foundation-Christchurch")
      end
    end

  end
end
