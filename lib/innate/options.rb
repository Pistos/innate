module Innate
  # this has to be run after a couple of other files have been required

  options.dsl do
    o "Innate::start will not start an adapter if true",
      :started, false

    o "Will send ::setup to each element during Innate::start",
      :setup, [Innate, Innate::Cache, Innate::Node]

    o "Trap this signal to issue shutdown, nil/false to disable trap",
      :trap, 'SIGINT'

    o "Indicates which default middleware to use, (:dev|:live)",
      :mode, :dev

    o "The directories this application resides in",
      :roots, [File.dirname($0)]

    o "The directories containing static files to be served",
      :publics, ['public']

    o "Directories containing the view templates",
      :views, ['view']

    o "Directories containing the layout templates",
      :layouts, ['layout']

    o "Prefix used to create relative links",
      :prefix, '/'

    trigger(:mode){|value| Innate.recompile_middleware(value) }
  end
end
