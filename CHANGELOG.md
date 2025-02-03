# KineticEcto Changelog

## 1.1.1 / 2025-02-03

- Renamed `KineticEcto.Transact` to `KineticEcto.RepoTransact`.
  `use KineticEcto.Transact` will now output a warning indicating that it has
  been replaced with `use KineticEcto.RepoTransact`. The functionality otherwise
  remains the same.

## 1.1.0 / 2025-01-29

- Added `KineticEcto.Transact`, an easy way to add Saša Juriċ's
  `Repo.transact/2` to your arsenal.

## 1.0.0 / 2025-01-19

- Initial release, including changeset validation extensions
