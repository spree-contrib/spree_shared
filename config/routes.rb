Spraycan::Engine.routes.prepend do
  match '/:id/compiled/:digest.:action', :controller => :compiler
end
