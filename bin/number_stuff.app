{application, number_stuff,
  [{description, "A Number Normalization Application by Rilt"},
    {vsn, "1.0.0"},
    {modules, [number_stuff_app, number_stuff_handler, number_stuff_sup]},
    {registered, [number_stuff_sup, number_stuff_handler]},
    {applications, [kernel,stdlib]},
    {mod, {number_stuff_app,[]}},
    {start_phases, []}
  ]}.