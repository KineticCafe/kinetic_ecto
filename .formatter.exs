[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  plugins: [Quokka],
  import_deps: [:ecto, :ecto_sql]
]
