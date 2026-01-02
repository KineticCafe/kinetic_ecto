# Licence

- SPDX-Licence-Identifier: [Apache-2.0][apache-2]

KineticEcto is copyright © 2025 by Austin Ziegler.

## Developer Certificate of Origin

All contributors **must** certify they are willing and able to provide their
contributions under the terms of this project's licences with the certification
of the [Developer Certificate of Origin (Version 1.1)](licences/dco.txt).

Such certification is provided by ensuring that a `Signed-off-by`
[commit trailer][trailer] is present on every commit:

    Signed-off-by: FirstName LastName <email@example.org>

The `Signed-off-by` trailer can be automatically added by git with the `-s` or
`--signoff` option on `git commit`:

```sh
git commit --signoff
```

## Acknowledgements

- KineticEcto is based on code copyright © 2017-2024 by Kinetic Commerce,
  licensed under the [Apache License, version 2.0](licences/APACHE-2.0.txt).

  The following modules are based on [KineticCafe/elixir-utilities][utils] by
  Kinetic Commerce:

  - `Kinetic.Ecto`
  - `Kinetic.Ecto.ChangsetValidations`

- `Kinetic.Transact` is a near copy of `Repo.transact/2` in
  [sasa1977/mix\_phx\_alt][mpa] by Saša Jurić, copyright © 2022-2024, licensed
  under the MIT license.

  > Copyright 2022, Saša Jurić
  >
  > Permission is hereby granted, free of charge, to any person obtaining a copy
  > of this software and associated documentation files (the "Software"), to
  > deal in the Software without restriction, including without limitation the
  > rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  > sell copies of the Software, and to permit persons to whom the Software is
  > furnished to do so, subject to the following conditions:
  >
  > The above copyright notice and this permission notice shall be included in
  > all copies or substantial portions of the Software.
  >
  > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  > FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  > IN THE SOFTWARE.

- Most of the SQLite unit test setup is based on
  [elixir-sqlite/ecto\_sqlite3][ectosqlite3], copyright © 2021–2025 Matthew A.
  Johnston, licensed under the MIT license.

  > Copyright (c) 2021 Matthew A. Johnston
  >
  > Permission is hereby granted, free of charge, to any person obtaining a copy
  > of this software and associated documentation files (the "Software"), to
  > deal in the Software without restriction, including without limitation the
  > rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  > sell copies of the Software, and to permit persons to whom the Software is
  > furnished to do so, subject to the following conditions:
  >
  > The above copyright notice and this permission notice shall be included in
  > all copies or substantial portions of the Software.
  >
  > THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  > IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  > FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  > AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  > LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  > FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  > IN THE SOFTWARE.

[apache-2]: https://spdx.org/licenses/Apache-2.0.html
[ectosqlite3]: https://github.com/elixir-sqlite/ecto_sqlite3
[mpa]: https://github.com/sasa1977/mix_phx_alt/blob/d33a67fd6b2fa0ace5b6206487e774ef7a22ce5a/lib/core/repo.ex#L6-L44
[trailer]: https://git-scm.com/docs/git-interpret-trailers
[utils]: https://github.com/KineticCafe/elixir-utilities
