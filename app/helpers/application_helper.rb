module ApplicationHelper
  def format_datetime(datetime)
    datetime.try(:localtime).try :strftime, '%H:%M %d.%m.%Y'
  end
end
