module SetupsHelper
  def job_state_label(state)
    case state
    when 'completed'
      'label label-success'
    when 'failed'
      'label label-important'
    when 'created'
      'label label-info'
    end
  end
end
