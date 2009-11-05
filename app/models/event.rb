class Event < ActiveRecord::Base

  attr_protected :approved, :submitted

  belongs_to :calendar
  is_site_scoped if respond_to? :is_site_scoped

  approved_sql = ' AND ((submitted = ?) OR (submitted = ? AND approved = ?))'

  named_scope :order, lambda { |order| { :order => order } }

  named_scope :in_calendars, lambda { |calendars| # list of calendar objects
    ids = calendars.map{ |c| c.id }
    { :conditions => [ ids.map{"calendar_id = ?"}.join(" OR "), *ids] }
  }
  
  named_scope :after, lambda { |datetime| # datetime. eg calendar.events.after(Time.now)
    { :conditions => ['start_date > ?' + approved_sql, datetime, false, true, true] }
  }
  
  named_scope :before, lambda { |datetime| # seconds. eg calendar.events.within(6.months)
    { :conditions => ['start_date < ?' + approved_sql, datetime, false, true, true] }
  }
  
  named_scope :within, lambda { |period| # seconds. eg calendar.events.within(6.months)
    start = Time.now
    finish = start + period
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }

  named_scope :in_the_last, lambda { |period| # seconds. eg calendar.events.in_the_last(1.week)
    finish = Time.now
    start = finish - period
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }

  named_scope :between, lambda { |start, finish| # datetimable objects. eg. Event.between(reader.last_login, Time.now)
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }

  named_scope :in_year, lambda { |year| # just a number. eg calendar.events.in_year(2010)
    start = DateTime.civil(year, 1, 1)
    finish = start + 1.year
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }

  named_scope :in_month, lambda { |year, month| # just numbers. eg calendar.events.in_month(2010, 12)
    start = DateTime.civil(year, month, 1)
    finish = start + 1.month
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }
  
  named_scope :in_week, lambda { |year, week| # numbers, with a commercial week: eg calendar.events.in_week(2010, 35)
    start = DateTime.commercial(year, week, 1)
    finish = start + 1.week
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }
  
  named_scope :on_day, lambda { |year, month, day| # numbers: eg calendar.events.on_day(2010, 12, 12)
    start = DateTime.civil(year, month, day)
    finish = start + 1.day
    { :conditions => ['start_date BETWEEN ? AND ?' + approved_sql, start, finish, false, true, true] }
  }

  named_scope :submitted, :conditions => { :submitted => true }
  named_scope :imported, :conditions => { :submitted => false }
  named_scope :approved, :conditions => ['submitted = ? AND approved = ?', true, true]
  named_scope :unapproved, :conditions => ['submitted = ? AND approved = ?', true, false]

  def approve!
    update_attribute :approved, true
  end

  def disapprove!
    update_attribute :approved, false
  end

  def approved?
    approved
  end

  def submitted?
    submitted
  end
  
  def allday?
    start_date.hour == 0 && end_date.hour == 0
  end
  
  def nice_start_time
    if start_date.min == 0
      start_date.to_datetime.strftime("%-1I%p").downcase
    else
      start_date.to_datetime.strftime("%-1I:%M%p").downcase
    end
  end

end
