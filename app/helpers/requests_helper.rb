module RequestsHelper
  def request_state_label(state)
    case state
    when 'succeeded'
      'label label-success'
    when 'failed'
      'label label-important'
    when 'waiting'
      'label label-info'
    when 'created'
      'label label-inverse'
    end
  end
end
