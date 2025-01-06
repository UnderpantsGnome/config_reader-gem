# Changelog

## 3.0.3 2025-01-06

Fix a bug in deep merge where values weren't getting set properly.

## 3.0.2 2024-12-13

Fix an issue when merging multiple envs.

## 3.0.1 2024-12-13 (yanked)

Don't merge! in deep_merge

## 3.0.0 2024-12-12 (yanked)

Update to latest Sekrets (1.14.0)
Explicitly require abbrev gem
Expose all environment configs at the Config.envs Hash

## 2.0.4 2024-05-17

- [update rexml](https://github.com/UnderpantsGnome/config_reader-gem/pull/5)

## 2.0.3 2024-05-10

- add dig method to be able to extract nested values programmatically

## 2.0.2 2023-03-11

- remove deep-merge dependency

## 2.0.1 2010-03-19

- update dependencies

## 1.0.5 2018-02-01

- pass ignore_missing_keys to nested hashes during conversion

## 1.0.4 2018-02-01

- add a config option for Key Error behavior

## 1.0.3 2017-06-20

- add the deep_merge gem so all keys don't need to be duplicated across env sections

## 0.0.9 2012-02-03

- Stop abusing Hash, it's not nice
- convert all keys to symbols internally
- move to a bundler style gem

## 0.0.8 2011-05-12

- Silence RAILS_ENV deprecation, thanks jeanmartin

## 0.0.7 2010-02-14

- moved to jeweler
- removed the annoying post install message
- updated specs

## 0.0.6 2009-04-02

- handle keys as ['foo'], [:foo] and .foo for real this time
- return nil on non-existent key instead of error

## 0.0.5 2009-01-29

- handle keys as ['foo'], [:foo] and .foo
- return nil on non-existent key instead of error

## 0.0.4 2008-12-08

- fix the environment merging issue, for real this time

## 0.0.3 2008-12-02

- fix the environment merging issue

## 0.0.2 2008-09-10

- have find_config return the file if it exists instead of looking in . and
  ./config

## 0.0.1 2008-08-06

- 1 major enhancement:
  - Initial release
