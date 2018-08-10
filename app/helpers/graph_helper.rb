class GraphHelper

  def self.axis(type)
    axis = []
    (date_range(type)).step(date_step(type)).each { |v|
      axis.push(Time.at(v).strftime(type_str(type)))
    }

    return axis
  end

  def self.custom_axis(step, dates)
    axis = []
    (dates[0].to_i..dates[1].to_i).step(date_step(step)).each { |v|
      axis.push(Time.at(v).strftime(type_str(step)))
    }

    return axis
  end

  def self.date_range(type)
    if type == 'day'
      return DateTime.now.beginning_of_day.to_i..DateTime.now.end_of_day.to_i
    elsif type == 'week'
      return (DateTime.now - 1.week).to_i..DateTime.now.to_i
    elsif type == 'month'
      return (DateTime.now - 1.month).to_i..DateTime.now.to_i
    elsif type == 'year'
      return (DateTime.now - 1.year).to_i..DateTime.now.to_i
    end
  end

  def self.sql_date_range(type)
    if type == 'day'
      return DateTime.now.beginning_of_day..DateTime.now.end_of_day
    elsif type == 'week'
      return (DateTime.now - 1.week)..DateTime.now
    elsif type == 'month'
      return (DateTime.now - 1.month)..DateTime.now
    elsif type == 'year'
      return (DateTime.now - 1.year)..DateTime.now
    end
  end

  def self.date_step(type)
    if type == 'day'
      return 1.hour
    elsif type == 'week'
      return 1.day
    elsif type == 'month'
      return 1.day
    elsif type == 'year'
      return 1.month
    end
  end

  def self.type_str(type)
    if type == 'day'
      return "%H"
    elsif type == 'week'
      return "%e/%b"
    elsif type == 'month'
      return "%e/%b"
    elsif type == 'year'
      return "%b/%y"
    end
  end

end