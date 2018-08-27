class TimeFrameHelper

    def self.all
      return [:hour, :day, :week, :month]
    end

    def self.to_seconds(enum_item)
        case enum_item
        when "hour"
            return 1.hour
        when "day"
            return 1.day
        when "week"
            return 1.week
        else
            return 1.month
        end
    end
end