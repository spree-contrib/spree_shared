ActionView::Template.class_eval do
  alias_method :rails_render, :render

  # refresh view to get source again if
  # view needs to be recompiled
  #
  def render(view, locals, buffer=nil, &block)
    if @compiled && !view.respond_to?(method_name)
      @compiled = false
      @source = refresh(view).source
    end
    rails_render(view, locals, buffer, &block)
  end

  alias_method :rails_method_name, :method_name

  # inject subdomain into compiled view method name
  # forces combination per subdomain
  #
  def method_name
    "#{ENV['RAILS_CACHE_ID']}_#{rails_method_name}"
  end
end

