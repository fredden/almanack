
module Almanack
  RSpec.describe Event do

    it "has a title" do
      event = Event.new(title: "Music with rocks in")
      expect(event.title).to eq("Music with rocks in")
    end

    it "has a start time" do
      event = Event.new(start_time: Time.new(2014, 01, 01))
      expect(event.start_time).to eq_time(Time.new(2014, 01, 01))
    end

    it "has a end time" do
      event = Event.new(end_time: Time.new(2014, 01, 02))
      expect(event.end_time).to eq_time(Time.new(2014, 01, 02))
    end

    it "has a location" do
      event = Event.new(location: "Street of Cunning Artificers")
      expect(event.location).to eq("Street of Cunning Artificers")
    end

    it "has a description" do
      event = Event.new(description: "Be there or be a rectangular thynge.")
      expect(event.description).to eq("Be there or be a rectangular thynge.")
    end

    describe "#formatted_duration" do
      it "handles events without an end date" do
        event = Event.new(start_time: Time.parse("2014-07-06 06:24:00 UTC"))
        expect(event.formatted_duration).to eq("July 6 2014 at 6:24am")
      end

      it "handles events with an end date on the same day" do
        event = Event.new(start_time: Time.parse("2014-07-06 06:24:00 UTC"),
                          end_time:   Time.parse("2014-07-06 13:20:00 UTC"))
        expect(event.formatted_duration).to eq("July 6 2014 at 6:24am to 1:20pm")
      end

      it "handles events with an end date on a different day" do
        event = Event.new(start_time: Time.parse("2014-07-06 06:00:00 UTC"),
                          end_time:   Time.parse("2014-08-07 10:00:00 UTC"))
        expect(event.formatted_duration).to eq("July 6 2014 at 6:00am to August 7 2014 at 10:00am")
      end

      it "handles single day events" do
        event = Event.new(start_time: Date.parse("2014-07-06"),
                          end_time:   Date.parse("2014-07-06"))
        expect(event.formatted_duration).to eq("July 6 2014")
      end
    end

    describe "#start_date" do
      it "returns start_time for legacy reasons" do
        event = Event.new(start_time: Time.new(2014, 01, 01))
        result = nil
        expect { result = event.start_date }.to output(/deprecated/i).to_stderr
        expect(result).to eq_time(Time.new(2014, 01, 01))
      end

      it "can be set via start_date for legacy reasons" do
        event = Event.new(start_date: Time.new(2014, 01, 01))
        result = nil
        expect { result = event.start_time }.to output(/deprecated/i).to_stderr
        expect(result).to eq_time(Time.new(2014, 01, 01))
      end

      it "raises an error when both start_date and start_time are given" do
        event = Event.new(start_date: Time.new(2014, 01, 01),
                          start_time: Time.new(2014, 01, 02))
        expect { event.start_date }.to raise_error
        expect { event.start_time }.to raise_error
      end
    end

    describe "#end_date" do
      it "returns end_time for legacy reasons" do
        event = Event.new(end_time: Time.new(2014, 01, 01))
        result = nil
        expect { result = event.end_date }.to output(/deprecated/i).to_stderr
        expect(result).to eq_time(Time.new(2014, 01, 01))
      end

      it "can be set via end_date for legacy reasons" do
        event = Event.new(end_date: Time.new(2014, 01, 01))
        result = nil
        expect { result = event.end_time }.to output(/deprecated/i).to_stderr
        expect(result).to eq_time(Time.new(2014, 01, 01))
      end

      it "raises an error when both end_date and end_time are given" do
        event = Event.new(end_date: Time.new(2014, 01, 01),
                          end_time: Time.new(2014, 01, 02))
        expect { event.end_date }.to raise_error
        expect { event.end_time }.to raise_error
      end

      it "does not output a deprecation warning when using end_time if neither end_date or end_time is set" do
        event = Event.new
        expect { event.end_time }.not_to output.to_stderr
      end
    end

    describe "#serialized" do
      it "returns attributes as a hash" do
        wed = Time.new(2014, 01, 01)
        thu = Time.new(2014, 01, 02)

        event = Event.new(title: "Hogswatch",
                          start_time: wed,
                          end_time: thu,
                          arbitrary: true)

        expect(event.serialized).to eq({
          title: "Hogswatch",
          start_time: wed.iso8601,
          end_time: thu.iso8601,
          arbitrary: true
        })
      end
    end

  end
end
