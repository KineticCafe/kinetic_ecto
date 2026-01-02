[
  inputs: ["{mix,.formatter,.credo}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Quokka],
  import_deps: [:ecto, :ecto_sql]
]
