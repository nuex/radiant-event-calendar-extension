module EventFormTags
  include Radiant::Taggable
  include ActionView::Helpers::DateHelper

  desc %{
    Renders an event signup form. 

    *Usage:*
    <pre><code><r:events:form>...</r:events:form></code></pre>
  }
  tag 'events:form' do |tag|
    calendar_id = tag.attr['calendar_id']
    %{<form action="#{tag.locals.page.url}" method="post">
        <div>
          <input type="hidden" value="#{calendar_id}" name="event[calendar_id]" />
          #{tag.expand}
        </div>
      </form>}
  end

  %W{title description location url email}.each do |method|
    desc %{
      Renders a #{method} input field

      *Usage:*
      <pre><code><r:events:form:#{method} /></code></pre>
    }
    tag "events:form:#{method}" do |tag|
      event = tag.locals.page.event
      value = (!event.nil? ? event.send(method) : '')
      %{<input type="text" size="23" name="event[#{method}]" value="#{value}" />}
    end
  end

  %W{start_date end_date}.each do |method|
    desc %{
      Renders a #{method} date select field.

      *Usage:*
      <pre><code><r:events:form:#{method} /></code></pre>
    }
    tag "events:form:#{method}" do |tag|
      event = tag.locals.page.event
      value = (!event.nil? ? event.send(method) : '')
      datetime_select('event', method, { :minute_step => 5 })
    end
  end

  desc %{
    Expands inner tags if the event isn't valid.

    *Usage:*
    <pre><code><r:events:if_error>...</r:events:if_error></code></pre>
  }
  tag 'events:if_error' do |tag|
    event = tag.locals.page.event
    attribute = tag.attr.delete('on')
    unless event.nil? or event.valid?
      if attribute
        if error = event.errors.on(attribute.to_sym)
          tag.locals.error = error
          return tag.expand
        else
          return
        end
      end
      tag.locals.error = event.errors
      tag.expand
    end
  end

  tag 'events:errors' do |tag|
    tag.expand
  end

  desc %{
    Iterates through each error message.

    *Usage:*
    <pre><code><r:events:errors:each>...</r:events:errors:each></code></pre>
  }
  tag 'events:errors:each' do |tag|
    rv = []
    tag.locals.error.full_messages.each do |m|
      tag.locals.error_message = m
      rv << tag.expand
    end
    rv
  end

  desc %{
    Renders an error message.

    *Usage:*
    <pre><code><r:events:error_message /></code></pre>
  }
  tag 'events:error_message' do |tag|
    tag.locals.error_message
  end

  desc %{
    Expands inner tags if the event was created successfully.

    *Usage:*
    <pre><code><r:events:if_success>...</r:events:if_success></code></pre>
  }
  tag 'events:if_success' do |tag|
    event = tag.locals.page.event
    tag.expand if event and !event.new_record?
  end

  desc %{
    Expands inner tags if the event has not been saved (a new signup).

    *Usage:*
    <pre><code><r:events:unless_success>...</r:events:unless_success></code></pre>
  }
  tag 'events:unless_success' do |tag|
    event = tag.locals.page.event
    tag.expand if event.nil? or (event and event.new_record?)
  end

end
