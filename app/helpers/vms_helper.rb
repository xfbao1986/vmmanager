module VmsHelper
  def state_label(vm)
    case vm.active_state
    when 1
      'label label-important'
    when 2
      'label label-warning'
    when 3
      'label label-success'
    else
      'label'
    end
  end

  def deletable_label(vm)
    if vm.deletable
      'label label-important'
    else
      'label'
    end
  end
  
  def skip_label(vm)
    if vm.skipcheck
      'label label-important'
    else
      'label'
    end
  end
  
  def halted_days_label(vm)
    if vm.halted_days >= 7
      'label label-important'
    else
      'label'
    end
  end

  def power_state_label(power_state)
    case power_state
    when :running
      'label label-success'
    when :halted
      'label label-important'
    end
  end
end
