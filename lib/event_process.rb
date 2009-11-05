module EventProcess
  def self.included kls
    kls.send :alias_method_chain, :process, :event
    kls.class_eval { attr_accessor :event }
  end

  def process_with_event request, response
    if request.post? and request.parameters[:event]
      event = Event.new(request.parameters[:event])
      event.submitted = true
      event.save
      self.event = event
    end
    process_without_event request, response
  end
end
